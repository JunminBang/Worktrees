# Physics Asset & 래그돌 시스템

> 소스 경로: Runtime/Engine/Classes/PhysicsEngine/PhysicsAsset.h
> 아티스트를 위한 설명

---

## Physics Asset이란?

Physics Asset은 **스켈레탈 메시의 물리 시뮬레이션 설정 파일**입니다. 뼈대마다 충돌 바디(캡슐/구체/박스)를 배치하고, 관절 제한(Constraint)을 설정해 사실적인 래그돌과 물리 기반 히트 반응을 만듭니다.

**비유:** 마네킹의 관절과 충돌 범위 — 각 뼈대에 물리 껍질을 씌우고, 팔꿈치가 반대로 꺾이지 않도록 관절 제한을 설정합니다.

---

## Physics Asset Editor 열기

1. 스켈레탈 메시 에디터 → 상단 **Physics** 탭 클릭
2. 또는 Content Browser에서 `.uasset` (PhysicsAsset) 더블클릭

---

## Bodies — 물리 바디

각 뼈대에 **물리 충돌 도형**을 배치합니다.

### 바디 타입

| 타입 | 설명 | 권장 사용 |
|------|------|---------|
| `Capsule` | 캡슐 형태. 대부분의 뼈대에 적합 | 팔, 다리, 척추 |
| `Sphere` | 구형. 관절 끝에 적합 | 머리, 손, 발 |
| `Box` | 박스형. 각진 부위 | 어깨, 골반 (드물게) |
| `Convex Hull` | 커스텀 볼록 도형 | 특수한 형태 |

### 바디 설정 (Per Bone)

| 프로퍼티 | 설명 |
|---------|------|
| `Physics Type` | Default / Kinematic / Simulated |
| `Mass` | 이 바디의 질량 (kg) |
| `Linear Damping` | 선형 이동 감쇠 |
| `Angular Damping` | 회전 감쇠 |
| `Enable Gravity` | 중력 적용 여부 |
| `Collision Response` | 충돌 반응 설정 |

### Physics Type 의미

| 타입 | 설명 |
|------|------|
| `Default` | 부모 설정 따름 |
| `Kinematic` | 물리 비활성 — 애니메이션으로만 움직임 |
| `Simulated` | 물리 활성 — 중력/충돌 자동 처리 |

---

## Constraints — 관절 제한

관절(Constraint)은 **두 바디 사이의 움직임 범위를 제한**합니다. 팔꿈치가 앞으로만 꺾이고, 목이 과도하게 회전하지 않도록 합니다.

### Constraint 설정

| 프로퍼티 | 설명 |
|---------|------|
| `Linear Motion` | 선형 이동 제한 (Free/Limited/Locked) |
| `Angular Swing 1/2` | 두 가지 방향 스윙 제한 |
| `Angular Twist` | 비틀림 제한 |
| `Swing 1/2 Limit` | 스윙 최대 각도 (도) |
| `Twist Limit` | 비틀림 최대 각도 |

### 관절 타입 예시

| 관절 | 권장 설정 |
|------|---------|
| 팔꿈치/무릎 | Swing 1: 제한 (120°), Swing 2: 잠금, Twist: 소폭 허용 |
| 어깨 | 모든 방향 넓게 허용 (볼 조인트) |
| 척추 | 각 방향 작게 제한 (20~30°) |
| 목 | 스윙 45°, 트위스트 45° |
| 손목/발목 | Swing 넓게, Twist 제한 |

---

## 래그돌 설정 & Blueprint

### 래그돌 활성화

```
[캐릭터 사망 시]
→ Get Mesh (SkeletalMeshComponent)
→ Set Simulate Physics: true
→ Set Physics Blend Weight: 1.0
```

### 부분 래그돌 (Hit Reaction)

하체는 애니메이션 유지, 상체만 물리 반응:

```
→ Set All Bodies Below Simulate Physics
    In Bone Name: "spine_01"
    bNewSimulate: true
    bIncludeSelf: true
```

### 래그돌 → 애니메이션 복귀

```
→ Set Simulate Physics: false
→ Set Physics Blend Weight: 0.0 (애니메이션 완전 복귀)

또는 부드러운 복귀:
→ Timeline: 1.0 → 0.0 (1초 동안)
  → Set Physics Blend Weight (0~1 사이 값으로 블렌딩)
```

---

## 물리 기반 히트 반응

총탄/폭발 충격을 특정 뼈대에 전달:

```
[총격 히트 시]
→ Apply Impulse to Bone
    Bone Name: HitResult.BoneName
    Impulse: HitResult.ImpactNormal * -50000
    bVelChange: false
```

---

## Collision Profile 설정

Physics Asset → 각 Body의 Collision 설정:

| 프리셋 | 설명 |
|--------|------|
| `Ragdoll` | 래그돌 전용 채널 |
| `PhysicsActor` | 일반 물리 오브젝트 |
| `CharacterMesh` | 캐릭터 메시 기본 |
| `NoCollision` | 충돌 없음 |

---

## Physical Animation Component

물리와 애니메이션을 **자연스럽게 혼합**해 바람/충격에 흔들리는 캐릭터를 만듭니다:

```
→ Physical Animation Component 추가
→ Apply Physical Animation Settings Below
    Bone: "pelvis"
    IsLocalSimulation: true
    OrientationStrength: 1000
    AngularVelocityStrength: 100

→ Set All Bodies Below Simulate Physics: true
→ Physics Blend Weight: 0.15 (15% 물리, 85% 애니메이션)
```

---

## 아티스트 체크리스트

### Physics Asset 설정
- [ ] 모든 주요 뼈대에 충돌 바디가 배치되어 있는가?
- [ ] 바디 크기가 실제 메시 외형과 맞는가? (너무 크거나 작지 않은가)
- [ ] 관절 제한이 해당 관절의 실제 가동 범위와 유사한가?
- [ ] 래그돌 시 서로 다른 바디가 겹치지 않는가?

### 래그돌 동작
- [ ] 사망 시 래그돌이 자연스럽게 쓰러지는가?
- [ ] 바닥이나 장애물에서 지나치게 튀지 않는가?
- [ ] `Linear/Angular Damping` 값이 너무 낮아 과도하게 흔들리지 않는가?

### 부분 물리
- [ ] 히트 리액션 시 자연스러운 뼈대에 Impulse가 적용되는가?
- [ ] Physics Blend Weight로 물리↔애니메이션 전환이 부드러운가?
