# 콜리전 & 라인 트레이스

> 소스 경로: Runtime/Engine/Classes/Engine/CollisionProfile.h, Engine/Classes/Kismet/KismetSystemLibrary.h
> 아티스트를 위한 설명

---

## 콜리전이란?

콜리전(Collision)은 **오브젝트가 서로 겹치지 않도록 막거나, 겹쳤을 때 이벤트를 발생시키는 시스템**입니다.

**두 가지 역할:**
- **Block**: 물리적으로 통과 불가 (벽, 바닥)
- **Overlap**: 통과는 가능하지만 이벤트 발생 (트리거 존, 아이템 습득 범위)

---

## 콜리전 프리셋 (Collision Preset)

오브젝트 디테일 패널 → `Collision` → `Collision Presets`에서 선택합니다.

| 프리셋 | 설명 | 대표 사용 |
|--------|------|---------|
| `BlockAll` | 모든 채널 차단 | 벽, 바닥, 장애물 |
| `BlockAllDynamic` | 동적 오브젝트만 차단 | 움직이는 장애물 |
| `OverlapAll` | 모든 채널과 겹침 | 트리거 존 |
| `OverlapAllDynamic` | 동적 오브젝트와 겹침 | 아이템 습득 범위 |
| `NoCollision` | 콜리전 없음 | 장식용 오브젝트 |
| `Pawn` | 폰 전용 설정 | 캐릭터 캡슐 |
| `PhysicsActor` | 물리 액터 | 상자, 통 등 |
| `Trigger` | 트리거 전용 | TriggerVolume |
| `Ragdoll` | 래그돌 전용 | 사망한 캐릭터 |
| `Projectile` | 발사체 전용 | 총알, 화살 |

---

## 오브젝트 타입 & 채널

각 오브젝트는 **하나의 Object Type**을 가지며, 다른 타입에 대해 Block/Overlap/Ignore를 개별 설정합니다.

### 기본 오브젝트 타입

| 타입 | 대표 사용 |
|------|---------|
| `WorldStatic` | 움직이지 않는 지형, 건물 |
| `WorldDynamic` | 런타임에 움직이는 오브젝트 |
| `Pawn` | 캐릭터, 플레이어 |
| `PhysicsBody` | 물리 시뮬레이션 오브젝트 |
| `Vehicle` | 차량 |
| `Destructible` | 파괴 가능 오브젝트 |
| `Visibility` | 시야 확인용 (레이캐스트) |
| `Camera` | 카메라 충돌 전용 |

### 커스텀 채널 추가

`Project Settings → Collision → Object Channels` 또는 `Trace Channels`에서 새 채널 추가 가능 (예: `Interactable`, `Bullet`)

---

## Line Trace — 레이캐스트

Line Trace는 **한 지점에서 다른 지점으로 보이지 않는 선을 쏴서 첫 번째 충돌 오브젝트를 감지**하는 기능입니다.

**비유:** 레이저 포인터 — 레이저를 쏘면 첫 번째로 맞는 표면의 정보를 알 수 있습니다.

### Line Trace By Channel (가장 일반적)

```
→ Line Trace By Channel
    Start: Camera Location
    End: Camera Location + (Camera Forward × 3000)
    Trace Channel: ECC_Visibility
    Draw Debug Type: For Duration (개발 시 시각화)

→ Break Hit Result
    bBlockingHit: 뭔가 맞았는지 (True/False)
    Hit Actor: 맞은 액터
    Impact Point: 충돌 위치
    Impact Normal: 충돌 표면 법선 방향
    Hit Bone Name: 맞은 뼈대 이름 (스켈레탈 메시)
    Distance: 시작점에서 충돌점까지 거리
```

### 주요 Trace 노드 종류

| 노드 | 설명 |
|------|------|
| `Line Trace By Channel` | 채널 기반. 단일 충돌 반환 |
| `Multi Line Trace By Channel` | 채널 기반. 경로상 모든 충돌 반환 |
| `Line Trace By Object Type` | 특정 오브젝트 타입만 감지 |
| `Sphere Trace By Channel` | 구체 형태로 스윕 (두께 있는 레이) |
| `Box Trace By Channel` | 박스 형태 스윕 |
| `Capsule Trace By Channel` | 캡슐 형태 스윕 |

---

## Trace Channel 선택 기준

| 목적 | 추천 채널 |
|------|---------|
| 총기 레이캐스트 (벽 관통 X) | `ECC_Visibility` |
| 카메라 충돌 | `ECC_Camera` |
| 특정 오브젝트만 감지 | 커스텀 채널 생성 |
| 플레이어 감지 (AI 시야) | `ECC_Pawn` |

---

## Shape Trace — 부피 있는 트레이스

총알처럼 얇은 것이 아닌, **부피 있는 물체의 이동 경로 감지**에 사용합니다.

```
예시: 근접 공격 범위 판정
→ Sphere Trace By Channel
    Start: 손목 소켓 위치
    End: 손목 소켓 위치 + (공격 방향 × 100)
    Radius: 30
    → 구체 반경 30cm 안에 있는 적 감지
```

---

## Overlap 이벤트

오브젝트에 `Generate Overlap Events`가 켜져 있으면 겹침 감지가 가능합니다.

### Blueprint 이벤트

```
Event On Component Begin Overlap (CollisionBox)
  Other Actor: 겹친 액터
  Other Component: 겹친 컴포넌트

→ Cast to BP_Player → TakeDamage
```

### 조건 설정

1. 내 컴포넌트 → Collision → `Generate Overlap Events` ON
2. 상대 오브젝트도 Overlap 반응이 설정되어 있어야 이벤트 발생

---

## Complex vs Simple 콜리전

| 타입 | 설명 | 성능 |
|------|------|------|
| `Simple` | 엔진이 자동 생성한 볼록 도형 | 빠름 |
| `Complex` | 실제 폴리곤 메시 | 정확하지만 느림 |

`Use Complex as Simple`: 정적 장식물에만 권장 (움직이지 않는 경우)

---

## 디버그 시각화

개발 중 트레이스를 눈에 보이게 하려면:

```
→ Line Trace By Channel
    Draw Debug Type: For Duration
    Draw Time: 2.0  ← 2초간 빨간선으로 표시
```

또는 콘솔 명령: `show COLLISION` — 모든 콜리전 도형 표시

---

## 아티스트 체크리스트

### 콜리전 설정
- [ ] 오브젝트의 Collision Preset이 역할에 맞는가? (장식물=NoCollision, 장애물=BlockAll)
- [ ] 장식용 소품에 불필요한 콜리전이 켜져 있지 않은가?
- [ ] 트리거 존에 `Generate Overlap Events`가 ON인가?

### Line Trace 사용 시
- [ ] Trace Channel이 의도한 오브젝트 타입을 감지하는가?
- [ ] `bBlockingHit` 결과를 확인한 후 Hit Result를 사용하는가?
- [ ] 개발 중 `Draw Debug Type`으로 트레이스 시각화를 확인했는가?

### 근접 공격 판정
- [ ] 단순 Line Trace가 아닌 Sphere/Box Trace로 범위를 표현했는가?
- [ ] 판정 타이밍이 애니메이션의 실제 타격 프레임과 일치하는가?
