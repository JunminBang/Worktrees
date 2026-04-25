# /wiki-lint

wiki 건강 상태를 점검합니다.

## Steps

1. `wiki/index.md` 읽기 → 등록된 모든 페이지 목록 수집
2. `wiki/` 디렉토리 실제 파일 목록과 비교:
   - **고립 페이지**: 파일은 있으나 index.md에 없는 페이지
   - **유령 링크**: index.md에 있으나 파일이 없는 항목
3. `wiki/bugs/` 점검:
   - `status: resolved`인데 오래된 버그 (해결 완료 처리 제안)
   - `status: open`인데 90일 이상 업데이트 없는 버그 (재검토 제안)
4. frontmatter 누락 페이지 탐지 (source, last_updated 없는 것)
5. `general-knowledge` 단독인 페이지에 ⚠️ 경고가 없으면 추가 제안
6. 리포트 출력 후 수정이 필요한 항목 제안

## Output Format

```
## Wiki Lint Report [YYYY-MM-DD]

### 고립 페이지 (N개)
- wiki/assets/Foo.md — index.md에 없음

### 유령 링크 (N개)
- [Bar](wiki/assets/Bar.md) — 파일 없음

### 오래된 버그 (N개)
- BUG-001 — 마지막 업데이트 YYYY-MM-DD

### frontmatter 누락 (N개)
- wiki/systems/Baz.md — source 없음
```
