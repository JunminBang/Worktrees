# Unreal Engine Debug Rules

Applies to: wiki/ 작업, Unreal 디버그 쿼리

## Wiki 우선 원칙

- 디버그 쿼리 시 wiki 먼저 — 답이 있으면 씬 스캔 생략하고 바로 답변
- `wiki/index.md`만 읽고 필요한 페이지 파악 (전체 wiki 읽기 금지)
- 한 번에 열람하는 wiki 페이지: 최대 3개

## 소스 탐색 규칙

- 엔진 소스 Grep 전, **`docs/engine-reference/unreal/`에서 먼저 확인** (버전 고정 API 레퍼런스)
- 엔진 소스 파일 전체 Read **금지** — Grep으로 특정 심볼/패턴만 추출
- 특정 액터/클래스 이름을 알면 전체 탐색 대신 직접 조회

## 데이터 무결성

- `raw/` 파일 수정 **금지** (AI 쓰기 금지 — 읽기 전용)
- `wiki/log.md` 기존 항목 수정 **금지** (append-only)
- 씬 스캔 데이터는 항상 날짜 포함 기록
- 새 버그: `wiki/bugs/BUG-NNN.md` — BUG-001부터 순서대로

## 엔진 소스 경로

- 루트: `C:/Program Files/Epic Games/UE_5.7/Engine/Source/Runtime/`
- Animation: `Engine/Classes/Animation/`
- Components: `Engine/Classes/Components/`
- GameFramework: `Engine/Classes/GameFramework/`
