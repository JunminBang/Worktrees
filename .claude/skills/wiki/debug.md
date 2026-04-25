# /wiki-debug

"X가 왜 안돼요?" 디버그 질문에 답합니다.

## Steps

1. **`get_changes()`** 먼저 호출 → 최근 씬 변경 파악
2. `wiki/index.md` **만** 읽어서 관련 페이지 파악 (전체 wiki 읽기 금지)
3. 관련 wiki 페이지 선택적으로 읽기 (최대 3개)
4. **wiki에 답이 있으면** → 씬 스캔 생략하고 바로 답변
5. **wiki에 없을 때만** → `mcp__unreal__` 도구로 실시간 씬 확인
   - 특정 액터 이름을 알면: `get_actor_info(label)` 직접 호출
   - 소스 참조 시: 파일 전체 Read 금지, Grep으로 특정 심볼만 추출
6. 원인 종합 설명 (wiki 기록 + 실시간 데이터)
7. 새로운 발견이면 `wiki/bugs/BUG-NNN.md` 생성
8. `wiki/log.md` 맨 아래에 추가:
   `## [YYYY-MM-DD] debug | [질문 요약]`

## Rules

- 한 번에 읽는 wiki 페이지: 최대 3개
- `list_actors()` 무필터 호출 금지 — 반드시 `filter_class` 지정
- 새 버그: BUG-001, BUG-002... 순서로 번호 부여
