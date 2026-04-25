# /wiki-scan

언리얼 씬을 스캔하여 이상 패턴을 탐지하고 wiki에 기록합니다.

## Steps

1. **반드시 `filter_class` 지정**해서 `list_actors` 호출 (무필터 전체 조회 금지)
   - 예: `list_actors(filter_class="StaticMeshActor")`
   - 전체 조회가 필요하면 클래스별로 나눠서 순차 호출
2. 의심 패턴 자동 탐지:
   - 같은 위치(±10cm)에 여러 액터 겹침
   - Z값이 음수인 액터 (바닥 아래)
   - 스케일이 0이거나 극단적으로 큰 액터 (>100x)
   - PlayerStart가 없거나 바닥 아래에 있음
3. 발견된 이슈 → `wiki/bugs/BUG-NNN.md` 자동 생성
4. `wiki/overview.md` 씬 상태 섹션 업데이트 (날짜 포함)
5. `wiki/log.md` 맨 아래에 추가:
   `## [YYYY-MM-DD] scan | [레벨명]`

## Rules

- 씬 스캔 데이터는 항상 날짜와 함께 기록 (씬은 변하기 때문)
- 탐지된 이슈가 없어도 log.md에 "이상 없음" 기록
- frontmatter에 `source: scene-scan`, `scene_verified: true` 명시
