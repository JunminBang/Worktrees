<#
.SYNOPSIS
    UE 빌드 로그 파서 — Error/Warning 수집 후 Markdown 반환
.PARAMETER FilePath
    파싱할 .log 파일 경로
.OUTPUTS
    Markdown 문자열 (에러 없으면 $null)

수정 이력:
  2026-04-26  어드바이저 검수 반영
    - regex: ^Error: → UE 실제 포맷 커버 (LogXxx: Error:, Fatal:, Assertion 등)
    - 100MB 초과 시 앞 500줄 → 마지막 500줄 (UE fatal은 보통 로그 끝부분)
    - ?? 연산자 → PS 5.1 호환 if/else 로 교체
#>
param(
    [Parameter(Mandatory)][string]$FilePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$fileInfo = Get-Item $FilePath
if ($fileInfo.Length -lt 1KB) { return $null }

$truncated = $fileInfo.Length -gt 100MB

# 100MB 초과 시 마지막 500줄 (UE 빌드 에러·fatal은 끝에 몰린다)
$lines = if ($truncated) {
    Get-Content $FilePath -Tail 500
} else {
    Get-Content $FilePath
}

$errors   = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()
$compileTime = ''

# UE 로그 실제 에러 패턴:
#   "Error: ..."              기본 에러
#   "LogXxx: Error: ..."      카테고리 에러
#   "Fatal error!"            치명 에러
#   "Assertion failed:"       단정 실패
#   "error LNK..."            링커 에러 (대소문자 혼용)
$errorPattern   = '(^|\s)(Error:|Fatal error!|Assertion failed:|error LNK|error C\d+)'
$warningPattern = '(^|\s)(Warning:|LogXxx: Warning:)'

foreach ($line in $lines) {
    if ($line -match $errorPattern) {
        $errors.Add($line.Trim())
    } elseif ($line -match $warningPattern) {
        $warnings.Add($line.Trim())
    } elseif ($line -match 'Total time:') {
        $compileTime = $line.Trim()
    }
}

# 에러·경고 모두 없으면 저장 생략
if ($errors.Count -eq 0 -and $warnings.Count -eq 0) { return $null }

# 반복 패턴 탐지 (숫자를 # 로 정규화 후 3회 이상)
$errorCounts = @{}
foreach ($e in $errors) {
    $key = $e -replace '\d+', '#'
    $errorCounts[$key] = ($errorCounts[$key], 0 | Measure-Object -Maximum).Maximum + 1
}
$repeatedErrors = $errorCounts.GetEnumerator() | Where-Object { $_.Value -ge 3 }

$date     = Get-Date -Format 'yyyy-MM-dd HH:mm'
$fileName = Split-Path $FilePath -Leaf

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("# 빌드 로그 분석 — $fileName")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("> 분석 일시: $date")
if ($truncated) { [void]$sb.AppendLine("> ⚠️ 파일이 100MB 초과 — 마지막 500줄만 파싱됨") }
[void]$sb.AppendLine("")

[void]$sb.AppendLine("## 요약")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| 항목 | 수 |")
[void]$sb.AppendLine("|---|---|")
[void]$sb.AppendLine("| 에러 | $($errors.Count) |")
[void]$sb.AppendLine("| 경고 | $($warnings.Count) |")
if ($compileTime) { [void]$sb.AppendLine("| 컴파일 시간 | $compileTime |") }
[void]$sb.AppendLine("")

if ($repeatedErrors) {
    [void]$sb.AppendLine("## 반복 에러 (3회 이상)")
    [void]$sb.AppendLine("")
    foreach ($re in $repeatedErrors) {
        [void]$sb.AppendLine("- **[$($re.Value)회]** $($re.Key)")
    }
    [void]$sb.AppendLine("")
}

if ($errors.Count -gt 0) {
    [void]$sb.AppendLine("## 에러 목록")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine('```')
    foreach ($e in $errors | Select-Object -First 50) { [void]$sb.AppendLine($e) }
    if ($errors.Count -gt 50) { [void]$sb.AppendLine("... ($($errors.Count - 50)개 생략)") }
    [void]$sb.AppendLine('```')
    [void]$sb.AppendLine("")
}

if ($warnings.Count -gt 0) {
    [void]$sb.AppendLine("## 경고 목록 (상위 20개)")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine('```')
    foreach ($w in $warnings | Select-Object -First 20) { [void]$sb.AppendLine($w) }
    if ($warnings.Count -gt 20) { [void]$sb.AppendLine("... ($($warnings.Count - 20)개 생략)") }
    [void]$sb.AppendLine('```')
}

return $sb.ToString()
