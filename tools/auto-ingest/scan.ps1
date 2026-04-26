<#
.SYNOPSIS
    원샷 스캔 — session-start.sh에서 호출. 새 파일을 감지해 raw/auto/queue/pending/ 에 저장.
.DESCRIPTION
    config.json의 watchTargets를 순회하며 lastScanTimestamp.json 이후 생성된 파일을 수집.
    파서를 실행해 raw/auto/ 에 Markdown 저장 후 디렉토리 큐(pending/<guid>.json)에 항목 추가.
    dedupKey로 중복 처리를 방지한다.

큐 구조 (디렉토리 큐 방식):
  raw/auto/queue/
    pending/  - Claude가 처리 대기 중인 항목 (각 항목: <guid>.json)
    done/     - wiki_ingest 완료 항목
    failed/   - 실패 항목 (attempts, lastError 기록)

수정 이력:
  2026-04-26  어드바이저 검수 반영
    - 단일 pending-ingest.json → 디렉토리 큐로 전환 (동시성 안전, 원자적 상태 전이)
    - id(GUID), status, attempts, dedupKey, lastError 필드 추가
    - dedupKey(SHA1) 기반 중복 검사 — 이미 pending/done/failed에 있으면 스킵
    - 같은 날 baseName 충돌: dateSuffix에 시분초 추가
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir  = Split-Path $MyInvocation.MyCommand.Path
$configPath = Join-Path $scriptDir 'config.json'
$parserDir  = Join-Path $scriptDir 'parsers'

if (-not (Test-Path $configPath)) {
    Write-Host "auto-ingest: config.json not found, skipping scan."
    exit 0
}

$config        = Get-Content $configPath -Raw | ConvertFrom-Json
$workspacePath = $config.workspacePath
$ueProjectPath = $config.ueProjectPath

if ([string]::IsNullOrWhiteSpace($ueProjectPath)) {
    Write-Host "auto-ingest: ueProjectPath not set in config.json, skipping scan."
    exit 0
}
if (-not (Test-Path $ueProjectPath)) {
    Write-Host "auto-ingest: ueProjectPath '$ueProjectPath' not found, skipping scan."
    exit 0
}

# 큐 디렉토리 초기화
$queueRoot  = Join-Path $workspacePath 'raw/auto/queue'
$pendingDir = Join-Path $queueRoot 'pending'
$doneDir    = Join-Path $queueRoot 'done'
$failedDir  = Join-Path $queueRoot 'failed'
foreach ($d in @($pendingDir, $doneDir, $failedDir)) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}

# dedupKey 계산 (SHA1 of "path:size:mtime_ticks")
function Get-DedupKey([System.IO.FileInfo]$file) {
    $raw   = "$($file.FullName):$($file.Length):$($file.LastWriteTimeUtc.Ticks)"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($raw)
    $sha1  = [System.Security.Cryptography.SHA1]::Create()
    ($sha1.ComputeHash($bytes) | ForEach-Object { $_.ToString('x2') }) -join ''
}

# 기존 큐의 dedupKey 목록 로드 (중복 검사용)
function Get-ExistingDedupKeys([string]$dir) {
    $keys = @{}
    Get-ChildItem -Path $dir -Filter '*.json' -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $entry = Get-Content $_.FullName -Raw | ConvertFrom-Json
            if ($entry.dedupKey) { $keys[$entry.dedupKey] = $true }
        } catch { <# 손상 파일 무시 #> }
    }
    $keys
}

$existingKeys = @{}
foreach ($dir in @($pendingDir, $doneDir, $failedDir)) {
    (Get-ExistingDedupKeys $dir).GetEnumerator() | ForEach-Object { $existingKeys[$_.Key] = $true }
}

# lastScanTimestamp 로드
$timestampPath = Join-Path $scriptDir 'lastScanTimestamp.json'
$lastScan = if (Test-Path $timestampPath) {
    try { (Get-Content $timestampPath -Raw | ConvertFrom-Json).lastScan | Get-Date }
    catch { [datetime]::MinValue }
} else {
    # 타임스탬프 없음 = 최초 실행. 과거 파일 일괄 처리 방지를 위해 1일 전으로 초기화
    (Get-Date).AddDays(-1)
}

$newCount = 0

foreach ($target in $config.watchTargets) {
    $patternFull = Join-Path $ueProjectPath $target.pattern
    $searchDir   = Split-Path $patternFull
    $searchFile  = Split-Path $patternFull -Leaf

    if (-not (Test-Path $searchDir)) { continue }

    $files = Get-ChildItem -Path $searchDir -Filter $searchFile -ErrorAction SilentlyContinue |
             Where-Object { $_.LastWriteTime -gt $lastScan }

    foreach ($file in $files) {
        if ($file.Length -lt ($target.minSizeKB * 1KB)) { continue }

        # 중복 검사
        $dedupKey = Get-DedupKey $file
        if ($existingKeys.ContainsKey($dedupKey)) {
            Write-Host "auto-ingest: skip (already queued) $($file.Name)"
            continue
        }

        # 파서 실행
        $parserScript = Join-Path $parserDir "$($target.parser).ps1"
        if (-not (Test-Path $parserScript)) {
            Write-Warning "auto-ingest: parser '$($target.parser)' not found"
            continue
        }

        $markdown = & $parserScript -FilePath $file.FullName
        if ($null -eq $markdown) { continue }

        # Markdown 저장 (같은 날 충돌 방지 위해 HHmmss 포함)
        $rawDir = Join-Path $workspacePath $target.rawPath
        if (-not (Test-Path $rawDir)) { New-Item -ItemType Directory -Path $rawDir -Force | Out-Null }

        $stamp       = Get-Date -Format 'yyyyMMdd_HHmmss'
        $baseName    = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $outFileName = "${baseName}_${stamp}.md"
        $outPath     = Join-Path $rawDir $outFileName

        # 원자적 쓰기: 임시 파일 → rename
        $tmpPath = "$outPath.tmp"
        $markdown | Set-Content -Path $tmpPath -Encoding UTF8
        Move-Item -Path $tmpPath -Destination $outPath -Force

        # 큐 항목 생성 → pending/ 에 저장 (원자적: tmp → rename)
        $entryId = [System.Guid]::NewGuid().ToString()
        $entry   = [ordered]@{
            id           = $entryId
            rawPath      = ($target.rawPath + $outFileName) -replace '\\', '/'
            wikiCategory = $target.wikiCategory
            wikiTags     = $target.wikiTags
            sourceFile   = $file.FullName -replace '\\', '/'
            createdAt    = (Get-Date -Format 'o')
            status       = 'pending'
            attempts     = 0
            dedupKey     = $dedupKey
            lastError    = $null
        }
        $entryPath = Join-Path $pendingDir "$entryId.json"
        $tmpEntry  = "$entryPath.tmp"
        $entry | ConvertTo-Json -Depth 5 | Set-Content -Path $tmpEntry -Encoding UTF8
        Move-Item -Path $tmpEntry -Destination $entryPath -Force

        $existingKeys[$dedupKey] = $true
        $newCount++

        Write-Host "auto-ingest: queued $($file.Name) → $($entry.rawPath)"
    }
}

# lastScanTimestamp 업데이트
@{ lastScan = (Get-Date -Format 'o') } | ConvertTo-Json | Set-Content -Path $timestampPath -Encoding UTF8

$pendingCount = @(Get-ChildItem -Path $pendingDir -Filter '*.json' -ErrorAction SilentlyContinue).Count
Write-Host "auto-ingest: scan complete. $newCount new item(s) added. $pendingCount pending."
exit 0
