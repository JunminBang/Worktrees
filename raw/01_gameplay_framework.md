# 언리얼 5.7 게임플레이 뼈대 & 입력 시스템

> 소스 경로: Runtime/Engine/Classes/GameFramework/, Runtime/InputCore/
> 아티스트를 위한 설명 — 코드를 몰라도 됩니다.

---

## 핵심 개념: 게임 세계의 계층 구조

언리얼의 게임플레이 시스템은 **극장 공연**처럼 작동합니다.

| 계층 | 역할 | 비유 |
|------|------|------|
| **World** | 게임이 펼쳐지는 전체 공간 | 극장 건물 전체 |
| **GameMode** | 게임의 규칙을 결정 | 연출 감독 |
| **GameState** | 게임의 현재 상태 정보 | 스코어보드 |
| **PlayerController** | 플레이어 입력 → 캐릭터 조종 | 조종자 |
| **Pawn / Character** | 플레이어/AI가 조종하는 물리적 존재 | 배우 |
| **PlayerState** | 플레이어 정보 (이름, 점수, 팀) | 프로그램 책자 |
| **GameInstance** | 맵 전환 후에도 유지되는 데이터 | 극장 운영 시스템 |

---

## 클래스 계층 구조

```
AActor                         ← 레벨에 배치 가능한 모든 것의 기초
  └─ APawn                     ← 조종 가능한 액터
       └─ ACharacter           ← 스켈레탈 메시 + 이동이 내장된 캐릭터
            └─ [플레이어, 적 AI]

AInfo
  └─ AGameModeBase             ← 게임 규칙 (서버에만 존재)
       └─ AGameMode            ← 멀티플레이 매치 기반
  └─ AGameStateBase            ← 모든 클라이언트에 동기화
       └─ AGameState

AController
  ├─ APlayerController         ← 플레이어 입력 처리
  └─ AAIController             ← AI 로직 처리
```

---

## 각 클래스 상세 설명

### Actor — 모든 게임 객체의 기초
- 에디터에서 배치한 **모든 오브젝트**가 Actor
- 위치(Location), 회전(Rotation), 크기(Scale)를 가짐
- 캐릭터, 적, 함정, 아이템, 파티클 — 전부 Actor

### Character — 조종 가능한 물리적 존재
- `UCapsuleComponent` — 충돌 캡슐 (루트)
- `USkeletalMeshComponent` — 3D 모델 (캡슐 안에 위치)
- `UCharacterMovementComponent` — 걷기·점프·수영·낙하 처리
- 이동 모드: `Walking → Falling → Walking` (점프 시 자동 전환)

**CharacterMovement 주요 수치 (아티스트가 직접 조정)**

| 속성 | 설명 | 예시 값 |
|------|------|---------|
| `MaxWalkSpeed` | 걷기 속도 (cm/s) | 느림=300, 보통=600, 빠름=1200 |
| `JumpZVelocity` | 점프 높이 | 낮음=300, 보통=600, 높음=1000 |
| `GravityScale` | 중력 배수 | 1.0=기본, 0.5=달처럼 둥실 |
| `MaxStepHeight` | 올라갈 수 있는 계단 높이 | 기본=45 |
| `WalkableFloorAngle` | 올라갈 수 있는 경사도 | 기본=44도 |

### GameMode — 게임의 심판
- **서버에만 존재** (클라이언트에는 없음)
- 플레이어가 들어올 때 캐릭터를 어디에 스폰할지 결정
- 경기 상태 관리: `WaitingToStart → InProgress → WaitingPostMatch`
- 맵이 바뀌면 새로 생성됨

### GameState — 모든 플레이어가 공유하는 상태판
- 서버 + **모든 클라이언트에 동기화**
- 경기 시간(`ElapsedTime`), 경기 상태(`MatchState`), 플레이어 목록(`PlayerArray`)
- HUD에서 점수·시간 표시 시 여기서 데이터를 읽음

### PlayerController — 플레이어의 손
- 각 플레이어마다 1개, 자신의 컴퓨터에만 존재
- 키보드·마우스 입력 → 소유한 캐릭터에 명령 전달
- 카메라 관리 (`PlayerCameraManager`)

### PlayerState — 플레이어 명찰
- 점수(`Score`), 플레이어 이름, 핑, 관전자 여부
- 모든 클라이언트가 볼 수 있음 (네트워크 복제)
- 점수판(Scoreboard) UI는 여기서 데이터를 읽음

### GameInstance — 게임 내내 살아있는 금고
- 맵 A → 맵 B 이동해도 **사라지지 않음**
- 플레이어 설정, 로그인 정보, 통계 저장용

---

## 컴포넌트 시스템

**액터(Actor) = 인형 / 컴포넌트(Component) = 옷·도구**

| 컴포넌트 | 역할 |
|---------|------|
| `SkeletalMeshComponent` | 뼈대 있는 3D 모델 (캐릭터 몸통) |
| `StaticMeshComponent` | 정적 3D 모델 (박스, 건물) |
| `CapsuleComponent` | 캡슐 충돌체 (캐릭터 감지) |
| `BoxComponent` | 박스 충돌 트리거 |
| `CharacterMovementComponent` | 이동·점프·중력 처리 |
| `SpringArmComponent` | 카메라 붐대 (카메라를 일정 거리 유지) |
| `CameraComponent` | 실제 카메라 |
| `InputComponent` | 키 입력 바인딩 |

---

## 입력 시스템

```
플레이어 키 누름
  ↓
PlayerController 감지
  ↓
InputMappingContext 확인
  ↓
InputAction 발동 (예: IA_Jump)
  ↓
바인딩된 함수 실행 (예: Jump())
  ↓
캐릭터 점프
```

### 핵심 용어

| 용어 | 역할 |
|------|------|
| `InputMappingContext` | 입력 설정 묶음 (게임 중/메뉴 중 각각 다른 설정) |
| `InputAction` | 게임 기능 단위 (IA_Jump, IA_Move, IA_Attack) |
| `InputModifier` | 입력값 변환 (감도, 데드존, 반전) |
| `InputTrigger` | 발동 조건 (눌렀을 때, 떼었을 때, 누르는 동안) |

---

## 점프 한 번에 무슨 일이 일어나나?

```
① 스페이스 누름
② PlayerController → InputComponent → Jump() 호출
③ CharacterMovementComponent: 이동 모드 Walking → Falling
④ Z축 속도 += JumpZVelocity
⑤ 매 프레임 중력이 Z속도를 감소시킴
⑥ 지면 충돌 → 이동 모드 Falling → Walking
⑦ AnimBlueprint가 이동 모드 변화 감지 → 착지 애니메이션 재생
```

---

## 멀티플레이 네트워크: 누가 어디에 있나?

| 객체 | 서버 | 내 클라이언트 | 다른 클라이언트 |
|------|------|-------------|----------------|
| GameMode | ✅ | ❌ | ❌ |
| GameState | ✅ | ✅ | ✅ |
| 내 PlayerController | ✅ | ✅ | ❌ |
| 내 Character | ✅ | ✅ | ✅ (복제) |
| 내 PlayerState | ✅ | ✅ | ✅ |

---

## 아티스트 체크리스트

```
새 캐릭터 만들 때:
✓ ACharacter 기반 Blueprint 생성
✓ SkeletalMesh 할당
✓ AnimBlueprint 연결
✓ CapsuleComponent 크기 조정 (캐릭터 키에 맞게)
✓ MaxWalkSpeed, JumpZVelocity 수치 조정
✓ InputMappingContext 할당
✓ 레벨에 PlayerStart 배치
```
