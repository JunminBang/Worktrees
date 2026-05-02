# AI & 내비게이션 시스템

> 소스 경로: Runtime/AIModule/, Runtime/NavigationSystem/, Runtime/GameplayTasks/
> 아티스트를 위한 설명

---

## AI 시스템 개요

```
Runtime/AIModule/Classes/             ← AI 핵심 클래스 (AIController, BrainComponent 등)
Runtime/NavigationSystem/Public/NavMesh/ ← NavMesh, 경로 찾기
Runtime/GameplayTasks/Classes/        ← AI Task 시스템
```

### AI가 작동하는 흐름

```
① 감지 (Perception)
   AIPerceptionComponent가 주변 자극 수집
   (시각: 플레이어 발견, 청각: 발소리, 데미지: 피격)
        ↓
② 의사결정 (Decision)
   BehaviorTree 또는 StateTree 실행
   ("어떤 행동을 해야 하는가?")
        ↓
③ 행동 (Action)
   Task 노드가 실제 동작 수행
   (이동, 공격, 대기 등)
        ↓
④ 이동 (Navigation)
   PathFollowingComponent가 NavMesh 따라 이동
```

---

## AIController — AI의 두뇌

```
소스: Runtime/AIModule/Classes/AIController.h
```

- `APawn` 또는 `ACharacter`를 자동으로 조종
- PlayerController와 역할 동일하지만 사람 입력 대신 AI 로직 사용

### 주요 기능

| 함수 | 역할 |
|------|------|
| `Possess(APawn*)` | AI가 캐릭터 소유 |
| `MoveToActor(AActor*)` | 목표 액터로 이동 |
| `MoveToLocation(FVector)` | 목표 위치로 이동 |
| `SetFocus(AActor*)` | AI 시선 방향 설정 |

### 포커스 우선순위

```
Default  (0) ← 기본 바라보는 방향
Move     (1) ← 이동 경로 방향
Gameplay (2) ← 전투 대상 (가장 높은 우선순위)
```

---

## Behavior Tree (행동 트리)

```
소스: Runtime/AIModule/Classes/BehaviorTree/
```

### 트리 구조

```
Root
├── Selector (자식 중 첫 번째 성공한 것 실행 — OR 논리)
│   ├── [Decorator: 플레이어 발견됨?]
│   │   └── Sequence (자식을 순서대로 실행 — AND 논리)
│   │       ├── Task: 플레이어 위치 업데이트
│   │       └── Task: 플레이어에게 이동
│   └── Sequence (순찰)
│       ├── Task: 다음 순찰 포인트 선택
│       └── Task: 이동
└── ...
```

### 노드 종류

| 노드 타입 | 클래스 | 역할 |
|----------|--------|------|
| **Composite** | `UBTCompositeNode` | Selector / Sequence — 자식 실행 순서 결정 |
| **Decorator** | `UBTDecorator` | 조건 확인 — 실행 허용/차단 |
| **Service** | `UBTService` | 주기적 상태 업데이트 (플레이어 위치 추적) |
| **Task** | `UBTTaskNode` | 실제 행동 (이동, 공격, 대기) |

### Blackboard — AI 메모리

```
소스: Runtime/AIModule/Classes/BehaviorTree/BlackboardComponent.h
```

AI가 기억할 데이터를 저장하는 공간.

**자주 쓰는 키 예시**

| 키 이름 | 타입 | 용도 |
|---------|------|------|
| TargetActor | Object | 현재 추적 대상 |
| IsAlerted | Bool | 경계 상태 여부 |
| LastSeenLocation | Vector | 마지막 목격 위치 |
| PatrolIndex | Int | 현재 순찰 포인트 번호 |

---

## StateTree

BehaviorTree보다 **상태 기반**으로 더 명확한 의사결정.

| 항목 | BehaviorTree | StateTree |
|------|-------------|-----------|
| 패러다임 | Task 순차 실행 | 상태 기계 |
| 전환 로직 | Decorator | 명시적 State Transition |
| 사용 시점 | 복잡한 AI 플로우 | 명확한 상태 정의 |

**StateTree 예시**
```
State: Idle → Patrol → Chase → Attack
  Idle → Patrol: 대기 시간 초과
  Patrol → Chase: 플레이어 감지됨
  Chase → Attack: 공격 범위 내
  Attack → Idle: 플레이어 사라짐
```

---

## EQS (환경 쿼리 시스템)

```
소스: Runtime/AIModule/Classes/EnvironmentQuery/
```

"어디로 이동해야 가장 유리한가?" 같은 공간 질문에 답합니다.

### 작동 흐름

```
① Generator: 후보 위치 생성
   (플레이어 주변 도넛 형태로 50개 위치 생성)
        ↓
② Test: 각 위치 점수 계산
   (플레이어에서 1000~2000cm 거리? +점수)
   (시야 차단 없음? +점수)
   (아군과 겹치지 않음? +점수)
        ↓
③ 가장 높은 점수의 위치 반환
   → AI가 해당 위치로 이동
```

### 자주 쓰는 Generator 타입

| Generator | 용도 |
|-----------|------|
| Donut (도넛) | 플레이어 주변 원형 위치들 |
| Grid (격자) | 일정 영역 격자 위치들 |
| On Actor | 특정 액터 위치 기반 |

### 자주 쓰는 Test 타입

| Test | 용도 |
|------|------|
| Distance | 대상과의 거리 평가 |
| Trace | 시야 차단 여부 |
| Pathfinding | 경로 가능 여부 |

**성능 주의**: EQS는 비싸므로 매 틱 실행 금지. 조건 충족 시만 실행.

---

## AI Perception (감지 시스템)

```
소스: Runtime/AIModule/Classes/Perception/
  AIPerceptionComponent.h
  AISense_Sight.h
  AISense_Hearing.h
  AISense_Damage.h
```

### Sense 종류

| Sense | 클래스 | 트리거 조건 |
|-------|--------|-----------|
| Sight (시각) | `UAISense_Sight` | 시야 범위 + 각도 내 액터 |
| Hearing (청각) | `UAISense_Hearing` | 소리 이벤트 발생 |
| Damage (피해) | `UAISense_Damage` | 피해를 입었을 때 |
| Touch (접촉) | `UAISense_Touch` | 충돌 발생 |

### Sight 주요 설정 (에디터)

| 속성 | 설명 |
|------|------|
| Sight Radius | 시야 범위 (cm) |
| Lose Sight Radius | 시야를 잃는 거리 (보통 Sight Radius보다 큼) |
| Peripheral Vision Angle | 옆 시야 각도 (90 = 180도 범위) |
| Age Limit | 감지 정보 유효 시간 (초) |

---

## NavMesh (내비게이션 메시)

```
소스: Runtime/NavigationSystem/Public/NavMesh/
  RecastNavMesh.h         ← 기본 NavMesh 액터
  NavMeshBoundsVolume.h   ← 생성 범위 볼륨
```

### NavMesh가 하는 일

```
레벨 지형 분석
    ↓
AI가 걸을 수 있는 표면 계산 (NavMesh 생성)
    ↓
목표 위치까지 최단 경로 계산 (A* 알고리즘)
    ↓
AIController → PathFollowingComponent → 캐릭터 이동
```

### NavMesh 시각화

에디터에서 **P** 키 또는 `Show → Navigation` 토글

| 색상 | 의미 |
|------|------|
| 초록 | AI가 이동 가능한 영역 |
| (없음) | 이동 불가 |
| 노란 점 | NavLink 연결점 |

### NavMesh 관련 액터

| 액터 | 역할 |
|------|------|
| `ANavMeshBoundsVolume` | NavMesh 생성 범위 지정 (필수) |
| NavModifierVolume | 특정 영역 이동 비용 조정 (물, 위험 지역) |
| NavLinkProxy | 점프 또는 특수 이동 연결 |

### RecastNavMesh 주요 설정

| 속성 | 설명 |
|------|------|
| Agent Radius | AI 캐릭터 반경 (좁은 통로 통과 여부) |
| Agent Height | AI 캐릭터 높이 |
| Agent Step Height | 올라갈 수 있는 계단 높이 |
| Cell Size | NavMesh 정밀도 (낮을수록 정확, 비쌈) |

---

## AI 패턴 예시

### 패턴 1: 순찰 → 추적 → 공격

```
BehaviorTree:
Selector
  ├─ [Decorator: TargetActor != null]
  │   Sequence
  │     ├─ Service: 플레이어 위치 Blackboard 업데이트
  │     └─ Task: MoveToActor (TargetActor)
  └─ Sequence (순찰)
        ├─ Task: SelectNextPatrolPoint
        └─ Task: MoveToLocation (PatrolPoint)

Perception:
  OnPerceptionUpdated → Blackboard TargetActor 업데이트
```

### 패턴 2: 최적 공격 위치 선택 (EQS)

```
EQS 쿼리:
  Generator: Donut (플레이어 기준, 반경 1000~2000cm)
  Test: Distance → 플레이어에서 적정 거리
  Test: Trace → 시야 차단 없음

BehaviorTree:
  Task: EQSQuery → 결과 위치로 이동
  Task: 공격 애니메이션 재생 (병렬)
```

---

## 아티스트 레벨 배치 체크리스트

```
AI 캐릭터 배치:
✓ NavMeshBoundsVolume이 플레이 영역 전체를 덮는가?
✓ P 키로 NavMesh 초록색 영역 확인
✓ AICharacter가 NavMesh 위에 스폰되는가?
✓ AIController에 BehaviorTree 에셋 연결됨?
✓ AIPerceptionComponent에 Sight Config 추가됨?

NavMesh:
✓ Agent Radius가 캐릭터 크기에 맞는가?
✓ 장애물 (벽, 기둥)이 NavMesh에서 제외됨?
✓ 점프/특수 이동 구간에 NavLink 배치됨?
```

---

## 흔한 문제 해결

| 문제 | 원인 | 해결 |
|------|------|------|
| AI가 움직이지 않음 | NavMesh 없음 | NavMeshBoundsVolume 배치 후 빌드 |
| AI가 장애물 관통 | 콜리전 설정 오류 | 장애물에 Static Mesh 콜리전 확인 |
| AI가 플레이어 못 찾음 | Perception 미설정 | AIPerceptionComponent + SightConfig 추가 |
| AI가 엉뚱한 곳으로 감 | NavMesh 생성 범위 부족 | BoundsVolume 크기 확대 |
| AI가 경사면에서 미끄러짐 | Step Height 부족 | Agent Step Height 값 증가 |

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [01_gameplay_framework.md](01_gameplay_framework.md) | AIController — PlayerController와 같은 Controller 계층 구조 |
| [03_animation_physics.md](03_animation_physics.md) | AI 캐릭터 애니메이션 State Machine — 이동/공격 상태 전환 |
| [09_gameplay_ability_system.md](09_gameplay_ability_system.md) | GAS — AI가 GameplayAbility로 스킬 사용 및 상태이상 처리 |
| [48_collision_trace.md](48_collision_trace.md) | Trace — EQS Trace Test, AI 시야 Ray 감지 |
| [16_data_management.md](16_data_management.md) | GameplayTag — Blackboard 값 대신 Tag로 AI 상태 표현 |
| [27_mass_entity.md](27_mass_entity.md) | Mass Entity — 수백~수천 AI 군중 최적화 대안 |
