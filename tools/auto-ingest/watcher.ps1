<#
.SYNOPSIS
    실시간 파일 감시 — FileSystemWatcher 기반. 별도 터미널에서 수동 실행.

⚠️ v1 KNOWN ISSUE (어드바이저 검수 2026-04-26):
    Register-ObjectEvent 의 -Action 스크립트 블록은 별도 runspace에서 실행되므로
    현재 스크립트에 정의된 함수(Invoke-Parser 등)가 보이지 않아 런타임 오류 발생.
    또한 scan.ps1과 동시에 큐 파일을 쓸 경우 race condition이 발생할 수 있음.

v2 권장 구조 (미구현):
    watcher는 이벤트 발생 시 트리거 파일 경로만 raw/auto/trigger.txt에 append,
    scan.ps1이 -Watch 플래그로 polling loop를 돌며 실제 처리를 담당.
    → runspace 분리 문제 해소 + 동시성 표면적 최소화

현재 v1은 ueProjectPath 설정 후 scan.ps1으로 충분히 운용 가능.
인디 프로젝트 규모에서 세션 시작 시 scan.ps1을 수동 실행하는 것으로 대체 가능.
.DESCRIPTION
    config.json의 watchTargets마다 FileSystemWatcher를 등록.
    파일 이벤트 발생 시 raw/auto/trigger.txt에 경로를 기록하고 scan.ps1을 호출.
    Ctrl+C로 종료.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir  = Split-Path $MyInvocation.MyCommand.Path
$configPath = Join-Path $scriptDir 'config.json'
$scanScript = Join-Path $scriptDir 'scan.ps1'

if (-not (Test-Path $configPath)) {
    Write-Error "config.json not found at $configPath"
    exit 1
}

$config        = Get-Content $configPath -Raw | ConvertFrom-Json
$workspacePath = $config.workspacePath
$ueProjectPath = $config.ueProjectPath

if ([string]::IsNullOrWhiteSpace($ueProjectPath)) {
    Write-Error "ueProjectPath is not set in config.json. Edit tools/auto-ingest/config.json first."
    exit 1
}
if (-not (Test-Path $ueProjectPath)) {
    Write-Error "ueProjectPath '$ueProjectPath' does not exist."
    exit 1
}

$triggerFile = Join-Path $workspacePath 'raw/auto/trigger.txt'
$debounceTable = @{}

$watchers = @()

foreach ($target in $config.watchTargets) {
    $watchDir  = Join-Path $ueProjectPath (Split-Path $target.pattern)
    $fileFilter = Split-Path $target.pattern -Leaf

    if (-not (Test-Path $watchDir)) {
        Write-Warning "Watch directory not found, skipping: $watchDir"
        continue
    }

    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path    = $watchDir
    $watcher.Filter  = $fileFilter
    $watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::FileName
    $watcher.EnableRaisingEvents = $true

    # v1 workaround: action에서 외부 함수 대신 Start-Process로 scan.ps1 호출
    # Created/Changed 중 Changed만 등록 (이중 트리거 방지)
    $msgData = [PSCustomObject]@{
        debounce    = $target.debounceSeconds
        table       = $debounceTable
        triggerFile = $triggerFile
        scanScript  = $scanScript
    }

    $action = {
        $path    = $Event.SourceEventArgs.FullPath
        $now     = Get-Date
        $tbl     = $Event.MessageData.table
        $debSecs = $Event.MessageData.debounce

        # debounce
        $last = $tbl[$path]
        if ($last -and ($now - $last).TotalSeconds -lt $debSecs) { return }
        $tbl[$path] = $now

        # 트리거 파일에 경로 기록 (append, 잠금 없이 간단하게)
        try {
            $Event.MessageData.triggerFile |
                ForEach-Object { Add-Content -Path $_ -Value $path -Encoding UTF8 }
        } catch { }

        # scan.ps1 호출 (별도 프로세스로 실행 — runspace 분리 우회)
        $scan = $Event.MessageData.scanScript
        Start-Process 'pwsh' -ArgumentList "-NoProfile -NonInteractive -File `"$scan`"" `
            -WindowStyle Hidden -ErrorAction SilentlyContinue
    }

    Register-ObjectEvent $watcher 'Changed' -Action $action -MessageData $msgData | Out-Null

    $watchers += $watcher
    Write-Host "Watching: $watchDir\$fileFilter  (debounce: $($target.debounceSeconds)s)"
}

if ($watchers.Count -eq 0) {
    Write-Warning "No watch targets registered. Check ueProjectPath and watchTargets in config.json."
    exit 1
}

Write-Host ""
Write-Host "Auto-Ingest Watcher v1 running. Press Ctrl+C to stop."
Write-Host "(이벤트 발생 시 scan.ps1을 별도 프로세스로 호출합니다)"
Write-Host ""

try {
    while ($true) { Start-Sleep -Seconds 1 }
} finally {
    foreach ($w in $watchers) { $w.Dispose() }
    Get-EventSubscriber | Unregister-Event -Force
    Write-Host "Auto-Ingest Watcher stopped."
}
