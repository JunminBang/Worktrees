<#
.SYNOPSIS
    JSON 프로파일링 리포트 파서 — 예산 초과 항목 + 상위 후보 추출
.PARAMETER FilePath
    파싱할 .json 파일 경로
.OUTPUTS
    Markdown 문자열 ($null = 스킵)

수정 이력:
  2026-04-26  어드바이저 검수 반영
    - -Raw + -TotalCount 동시 사용 버그 수정: 100MB+ JSON은 파싱 생략 후 $null 반환
      (JSON 부분 파싱은 무의미하며 항상 파싱 실패로 이어짐)
    - ?? 연산자 → PS 5.1 호환 if/else 로 교체
    - 알 수 없는 스키마 폴백 raw dump 제거 (민감정보 노출 위험)
#>
param(
    [Parameter(Mandatory)][string]$FilePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$fileInfo = Get-Item $FilePath
if ($fileInfo.Length -lt 1KB) { return $null }

# 100MB 초과 JSON은 부분 파싱이 무의미 — 스킵 (raw에 oversized 메타만 기록)
if ($fileInfo.Length -gt 100MB) {
    $date     = Get-Date -Format 'yyyy-MM-dd HH:mm'
    $fileName = Split-Path $FilePath -Leaf
    $sizeMB   = [math]::Round($fileInfo.Length / 1MB, 1)
    return @"
# 프로파일링 리포트 — $fileName

> 분석 일시: $date
> ⚠️ 파일 크기 ${sizeMB}MB 초과 — 파싱 생략. 직접 확인 필요.
> 파일 경로: $FilePath
"@
}

$raw = Get-Content $FilePath -Raw

try {
    $data = $raw | ConvertFrom-Json
} catch {
    return $null
}

$date     = Get-Date -Format 'yyyy-MM-dd HH:mm'
$fileName = Split-Path $FilePath -Leaf

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("# 프로파일링 리포트 — $fileName")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("> 분석 일시: $date")
[void]$sb.AppendLine("")

# 환경 메타데이터 (StartupProfile 등)
if ($null -ne $data.environment) {
    [void]$sb.AppendLine("## 측정 환경")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine('```json')
    [void]$sb.AppendLine(($data.environment | ConvertTo-Json -Depth 3))
    [void]$sb.AppendLine('```')
    [void]$sb.AppendLine("")
}

# 예산 초과 항목
if ($null -ne $data.budgetExceeded -and $data.budgetExceeded.Count -gt 0) {
    [void]$sb.AppendLine("## 예산 초과 항목")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("| 항목 | 값 | 예산 |")
    [void]$sb.AppendLine("|---|---|---|")
    foreach ($item in $data.budgetExceeded) {
        [void]$sb.AppendLine("| $($item.name) | $($item.value) | $($item.budget) |")
    }
    [void]$sb.AppendLine("")
}

# 최적화 후보 상위 5개
if ($null -ne $data.candidates -and $data.candidates.Count -gt 0) {
    [void]$sb.AppendLine("## 최적화 후보 (상위 5개)")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("| 순위 | 항목 | 설명 |")
    [void]$sb.AppendLine("|---|---|---|")
    $rank = 1
    foreach ($c in $data.candidates | Select-Object -First 5) {
        $desc = if ($null -ne $c.description) { $c.description } else { '-' }
        [void]$sb.AppendLine("| $rank | $($c.name) | $desc |")
        $rank++
    }
    [void]$sb.AppendLine("")
}

# 알려진 스키마가 없으면 스킵 (민감정보 raw dump 금지)
if ($null -eq $data.budgetExceeded -and $null -eq $data.candidates -and $null -eq $data.environment) {
    return $null
}

return $sb.ToString()
