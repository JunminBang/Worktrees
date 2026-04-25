# /wiki-ingest

raw/ 에 추가된 파일을 읽어 wiki 페이지를 생성/업데이트합니다.

## Steps

1. `raw/` 디렉토리에서 새 파일 목록 확인
2. 각 파일에서 핵심 정보 추출:
   - 에셋명, 액터 클래스, 시스템 이름
   - 알려진 버그 또는 주의사항
   - 관련 컴포넌트/블루프린트
3. `wiki/assets/` 또는 `wiki/systems/` 에 페이지 생성 또는 업데이트
   - 신규: frontmatter 포함한 전체 페이지 작성
   - 기존: 변경된 섹션만 업데이트
4. `wiki/index.md` 업데이트 (새 페이지 링크 추가)
5. `wiki/log.md` 맨 아래에 추가:
   `## [YYYY-MM-DD] ingest | [파일명]`

## Rules

- `raw/` 파일은 절대 수정하지 않는다
- frontmatter에 `source: raw-ingest` 명시
- `scene_verified: false` 로 초기화 (씬 스캔 전)
