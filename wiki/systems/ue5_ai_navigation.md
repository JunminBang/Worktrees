---
name: UE5 AI & 내비게이션 시스템
type: System
tags: unreal-engine, AI, behavior-tree, blackboard, navmesh, EQS, perception, state-tree
source: raw-ingest
scene_verified: false
last_updated: 2026-04-19
---

# UE5 AI & 내비게이션 시스템

> 소스 경로: Runtime/AIModule/, Runtime/NavigationSystem/, Runtime/GameplayTasks/
> 🔗 Engine Reference (UE5.7 API 변경): [modules/navigation.md](../../docs/engine-reference/unreal/modules/navigation.md)

---

## AI 작동 흐름

```
① 감지 (Perception) — AIPerceptionComponent가 자극 수집
② 의사결정 (Decision) — BehaviorTree 또는 StateTree 실행
③ 행동 (Action) — Task 노드가 실제 동작 수행
④ 이동 (Navigation) — PathFollowingComponent가 NavMesh 따라 이동
```

---

## Behavior Tree 구조

| 노드 타입 | 역할 |
|----------|------|
| Composite (Selector/Sequence) | 자식 실행 순서 결정 |
| Decorator | 조건 확인 — 실행 허용/차단 |
| Service | 주기적 상태 업데이트 (플레이어 위치 추적) |
| Task | 실제 행동 (이동, 공격, 대기) |

**Blackboard 자주 쓰는 키**

| 키 이름 | 타입 | 용도 |
|---------|------|------|
| TargetActor | Object | 현재 추적 대상 |
| IsAlerted | Bool | 경계 상태 여부 |
| LastSeenLocation | Vector | 마지막 목격 위치 |
| PatrolIndex | Int | 현재 순찰 포인트 번호 |

---

## StateTree vs BehaviorTree

| 항목 | BehaviorTree | StateTree |
|------|-------------|-----------|
| 패러다임 | Task 순차 실행 | 상태 기계 |
| 전환 로직 | Decorator | 명시적 State Transition |
| 사용 시점 | 복잡한 AI 플로우 | 명확한 상태 정의 |

---

## AI Perception

| Sense | 트리거 조건 |
|-------|-----------|
| Sight (UAISense_Sight) | 시야 범위 + 각도 내 액터 |
| Hearing (UAISense_Hearing) | 소리 이벤트 발생 |
| Damage (UAISense_Damage) | 피해를 입었을 때 |

**Sight 주요 설정**: Sight Radius / Lose Sight Radius / Peripheral Vision Angle / Age Limit

---

## NavMesh

```
레벨 지형 분석 → AI가 걸을 수 있는 표면 계산
→ A* 알고리즘으로 최단 경로 계산
→ AIController → PathFollowingComponent → 캐릭터 이동
```

**에디터 P키**: NavMesh 시각화 (초록=이동 가능)

| 설정 | 설명 |
|------|------|
| Agent Radius | AI 반경 (좁은 통로 통과 여부) |
| Agent Height | AI 높이 |
| Cell Size | NavMesh 정밀도 (낮을수록 정확, 비쌈) |

---

## EQS (환경 쿼리 시스템)

"어디로 이동해야 가장 유리한가?" 질문에 답함.
Generator(후보 위치 생성) → Test(점수 계산) → 최고 점수 위치 반환.
**성능 주의**: 매 틱 실행 금지. 조건 충족 시만 실행.

---

## 흔한 문제 해결

| 문제 | 원인 | 해결 |
|------|------|------|
| AI가 움직이지 않음 | NavMesh 없음 | NavMeshBoundsVolume 배치 후 빌드 |
| AI가 플레이어 못 찾음 | Perception 미설정 | AIPerceptionComponent + SightConfig 추가 |
| AI가 장애물 관통 | 콜리전 설정 오류 | 장애물에 Static Mesh 콜리전 확인 |
| AI가 경사면에서 미끄러짐 | Step Height 부족 | Agent Step Height 값 증가 |

---

## 관련 페이지
- [UE5 전체 개요](ue5_overview.md)
- [게임플레이 프레임워크](ue5_gameplay_framework.md)
- [StaticMesh 시스템](static_mesh.md)
