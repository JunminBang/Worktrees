<#
.SYNOPSIS
    CSV 감사 리포트 파서 — 헤더 + 상위 20행 + 요약
.PARAMETER FilePath
    파싱할 .csv 파일 경로
.OUTPUTS
    Markdown 문자열 ($null = 스킵)

수정 이력:
  2026-04-26  어드바이저 검수 반영
    - 셀 안 파이프(|)뿐 아니라 줄바꿈·탭도 escape (마크다운 테이블 보호)
    - 100MB 초과: Import-Csv 대신 Get-Content로 처음 500줄만 읽도록 수정
#>
param(
    [Parameter(Mandatory)][string]$FilePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$fileInfo = Get-Item $FilePath
if ($fileInfo.Length -lt 1KB) { return $null }

$truncated = $fileInfo.Length -gt 100MB

$rows = if ($truncated) {
    # 100MB 초과 시 앞 500줄(헤더 포함) 임시 파일로 파싱
    $tmpFile = [System.IO.Path]::GetTempFileName()
    try {
        Get-Content $FilePath -TotalCount 501 | Set-Content $tmpFile -Encoding UTF8
        Import-Csv $tmpFile
    } finally {
        Remove-Item $tmpFile -ErrorAction SilentlyContinue
    }
} else {
    Import-Csv $FilePath
}

$totalRows = @($rows).Count
if ($totalRows -eq 0) { return $null }

$date     = Get-Date -Format 'yyyy-MM-dd HH:mm'
$fileName = Split-Path $FilePath -Leaf
$headers  = $rows[0].PSObject.Properties.Name

# 셀 값을 마크다운 테이블 안전 문자열로 변환
function Escape-Cell([string]$v) {
    $v -replace '\r?\n', ' ' `
       -replace '\t', ' ' `
       -replace '\|', '\|' `
       -replace '`', "'" `
       | ForEach-Object { $_.Trim() }
}

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("# CSV 감사 리포트 — $fileName")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("> 분석 일시: $date")
[void]$sb.AppendLine("> 총 항목 수: $totalRows$(if ($truncated) { ' (100MB 초과 — 500행까지만 처리)' })")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## 데이터 (상위 20행)")
[void]$sb.AppendLine("")

# 헤더
[void]$sb.AppendLine("| $(($headers | ForEach-Object { Escape-Cell $_ }) -join ' | ') |")
# 구분선
[void]$sb.AppendLine("| $(($headers | ForEach-Object { '---' }) -join ' | ') |")

# 데이터 행
foreach ($row in $rows | Select-Object -First 20) {
    $cells = $headers | ForEach-Object { Escape-Cell ($row.$_) }
    [void]$sb.AppendLine("| $($cells -join ' | ') |")
}

if ($totalRows -gt 20) {
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("_... ($($totalRows - 20)개 행 생략)_")
}

return $sb.ToString()
