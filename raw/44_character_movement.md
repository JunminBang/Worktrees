# Character Movement Component 심화

> 소스 경로: Runtime/Engine/Classes/GameFramework/CharacterMovementComponent.h
> 아티스트를 위한 설명

---

## CharacterMovementComponent란?

`CharacterMovementComponent`는 **캐릭터의 모든 이동 물리를 담당**하는 핵심 컴포넌트입니다. 걷기·달리기·점프·수영·비행 등 모든 이동 모드가 이 컴포넌트에서 처리됩니다.

**비유:** 캐릭터 몸에 붙은 "물리 엔진 모듈" — 어떻게 움직일지의 모든 규칙이 여기에 있습니다.

---

## 이동 모드 (Movement Mode)

| 모드 | 설명 |
|------|------|
| `Walking` | 지면 위 이동 (기본) |
| `Falling` | 공중 낙하 중 |
| `Swimming` | 물속 수영 |
| `Flying` | 비행 (중력 무시) |
| `Custom` | 완전 커스텀 이동 모드 |

### Blueprint에서 모드 변경

```
→ Set Movement Mode
    NewMovementMode: Flying
    
→ Launch Character
    LaunchVelocity: (0, 0, 1200)  ← 위로 점프 힘
    bOverrideXY: false
    bOverrideZ: true
```

---

## 지상 이동 설정 (Walking)

| 프로퍼티 | 설명 | 기본값 |
|---------|------|-------|
| `Max Walk Speed` | 최대 보행 속도 (cm/s) | 600 |
| `Max Walk Speed Crouched` | 웅크린 상태 최대 속도 | 300 |
| `Max Acceleration` | 가속도 | 2048 |
| `Braking Deceleration Walking` | 감속도 (멈출 때) | 2048 |
| `Ground Friction` | 지면 마찰계수. 클수록 빠르게 멈춤 | 8.0 |
| `Max Step Height` | 올라갈 수 있는 최대 계단 높이 (cm) | 45 |
| `Walkable Floor Angle` | 걸어갈 수 있는 최대 경사 각도 (도) | 44 |

---

## 점프 설정

| 프로퍼티 | 설명 | 기본값 |
|---------|------|-------|
| `Jump Z Velocity` | 점프 초기 수직 속도 (cm/s) | 420 |
| `Air Control` | 공중에서 방향 제어력 (0=없음, 1=지상과 동일) | 0.35 |
| `Air Control Boost Multiplier` | 정지 상태에서 공중 제어 배율 | 2.0 |
| `Gravity Scale` | 중력 배율 (0=무중력, 2=2배 중력) | 1.0 |
| `Max Number of Jumps` | 최대 연속 점프 횟수 (2=더블점프) | 1 |
| `Braking Deceleration Falling` | 공중 감속도 | 0 |

### 더블 점프 구현

```
캐릭터 BP → JumpMaxCount = 2
→ 이미 내장 기능으로 동작
```

---

## 웅크리기 (Crouch)

| 프로퍼티 | 설명 |
|---------|------|
| `Can Crouch` | 웅크리기 허용 여부 |
| `Crouched Half Height` | 웅크린 상태 캡슐 절반 높이 |
| `Max Walk Speed Crouched` | 웅크린 속도 |

Blueprint: `Crouch` / `UnCrouch` 노드 사용

---

## 수영 설정 (Swimming)

| 프로퍼티 | 설명 |
|---------|------|
| `Max Swim Speed` | 최대 수영 속도 |
| `Buoyancy` | 부력 (1.0=중립, >1=뜸, <1=가라앉음) |
| `Braking Deceleration Swimming` | 수중 감속도 |

PhysicsVolume의 `bWaterVolume = true` 설정 시 자동으로 Swimming 모드 전환

---

## 비행 설정 (Flying)

| 프로퍼티 | 설명 |
|---------|------|
| `Max Fly Speed` | 최대 비행 속도 |
| `Braking Deceleration Flying` | 비행 중 감속도 |

`Set Movement Mode → Flying`으로 전환, 중력 자동 비활성화

---

## NavMesh 이동 연동

AI 캐릭터가 NavMesh를 사용하는 경우 CharacterMovementComponent가 경로를 따라 이동합니다:

| 프로퍼티 | 설명 |
|---------|------|
| `Use Acceleration for Paths` | 경로 추종 시 가속 사용 |
| `Path Following Component` | 경로 추종 컴포넌트 |

---

## 네트워크 설정

멀티플레이어에서 이동 동기화 관련:

| 프로퍼티 | 설명 |
|---------|------|
| `Network Max Smoothing Distance` | 서버-클라이언트 위치 보정 최대 거리 |
| `Network Smoothing Mode` | Disabled/Linear/Exponential |
| `Net Correction Impulse Factor` | 위치 오차 보정 강도 |

---

## 루트 모션 설정

| 프로퍼티 | 설명 |
|---------|------|
| `Allow Physics Rotation During Anim Root Motion` | 루트 모션 중 물리 회전 허용 |
| `Rotate Rate` | 캐릭터 회전 속도 (UseControllerDesiredRotation 시) |
| `Use Controller Desired Rotation` | 컨트롤러 회전 방향으로 서서히 회전 |
| `Orient Rotation to Movement` | 이동 방향으로 캐릭터 자동 회전 |

---

## Blueprint에서 속도 변경 (런타임)

```
[달리기 시작]
→ Get Character Movement
→ Set Max Walk Speed: 1200

[걷기 복귀]
→ Set Max Walk Speed: 600

[슬로우 효과]
→ Set Movement Mode → Walking
→ Set Max Walk Speed: 150
→ Set Gravity Scale: 0.5
```

---

## 아티스트 체크리스트

### 기본 이동 설정
- [ ] `Max Walk Speed`가 게임 컨셉(사실적/아케이드)에 맞는가?
- [ ] `Max Step Height`가 씬의 계단/턱 높이와 맞는가?
- [ ] `Walkable Floor Angle`이 씬의 경사면 각도를 커버하는가?

### 점프 설정
- [ ] `Jump Z Velocity`로 점프 높이가 적절한가?
- [ ] `Air Control`이 너무 높아 공중 조작이 부자연스럽지 않은가?
- [ ] 더블 점프가 필요하면 `JumpMaxCount = 2`로 설정했는가?

### 수영/비행
- [ ] 수영 가능 구역에 PhysicsVolume(`bWaterVolume=true`)이 배치되어 있는가?
- [ ] `Buoyancy` 값이 물 위에 떠 있는 느낌을 주는가?

### 네트워크 (멀티플레이)
- [ ] `Network Smoothing Mode`가 게임 타입(FPS/TPS)에 맞게 설정되어 있는가?
