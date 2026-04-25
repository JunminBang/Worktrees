# 애니메이션 & 물리 시스템

> 소스 경로: Runtime/AnimGraphRuntime/, Runtime/AnimationCore/, Runtime/PhysicsCore/, Runtime/ClothingSystem*/
> 아티스트를 위한 설명

---

## 애니메이션 시스템 개요

언리얼 엔진의 애니메이션은 3가지 핵심 요소로 구성됩니다.

```
스켈레톤 (Skeleton)         ← 뼈대 계층 구조 정의
    ↓
애니메이션 시퀀스            ← 실제 동작 데이터 (키프레임)
    ↓
애니메이션 블루프린트 (AnimBP) ← 어떤 동작을 언제 재생할지 로직
    ↓
스켈레탈 메시 컴포넌트       ← 월드에서 실제로 렌더링
```

**소스 경로**
```
Runtime/AnimGraphRuntime/Public/AnimNodes/  ← AnimNode 클래스 (88개 헤더)
Runtime/AnimationCore/Public/              ← IK 알고리즘 라이브러리 (17개)
Runtime/Engine/Classes/Animation/          ← 게임플레이 클래스 (112개)
```

---

## 스켈레탈 메시와 뼈대 구조

| 개념 | 역할 |
|------|------|
| `USkeleton` | 뼈대 계층 구조 에셋 (Root → Pelvis → Spine → ...) |
| `USkeletalMesh` | 3D 모델 + 스킨 가중치 데이터 |
| `FCompactPose` | 런타임에 사용하는 컴팩트 포즈 (메모리 효율적) |
| `FBoneContainer` | 뼈 인덱스 변환 캐시 (성능 최적화) |

**스킨 가중치**: 버텍스 하나가 여러 본에 얼마나 영향받을지 비율
- 일반 캐릭터: 4본 가중치
- 고급 캐릭터 (근육, 의류): 16본 이상

---

## 애니메이션 블루프린트 & 스테이트 머신

### 주요 AnimNode 클래스

| 클래스 | 에디터 노드 | 역할 |
|--------|-----------|------|
| `AnimNode_StateMachine` | State Machine | 상태 전환 관리 |
| `AnimNode_BlendSpacePlayer` | Blend Space | 파라미터 기반 자동 블렌딩 |
| `AnimNode_LayeredBoneBlend` | Layered Blend | 특정 본만 덮어쓰기 |
| `AnimNode_Slot` | Slot | Montage 재생 슬롯 |
| `AnimNode_BlendListByBool` | Blend Poses by bool | 2개 포즈 선택 |
| `AnimNode_TwoWayBlend` | Blend | Alpha로 두 포즈 혼합 |

### 스테이트 머신 구조 예시

```
Idle State
  └─ Blend Space: 속도 0~600 → Idle / Walk / Run

Combat State
  ├─ Attack_Light
  ├─ Attack_Heavy
  └─ Dodge (Montage)

전환(Transition):
  Idle → Combat: bInCombat == true (0.2초 블렌드)
  Combat → Idle: bInCombat == false (0.3초 블렌드)
```

### 블렌드 스페이스

- **1D**: 한 축 (예: 속도 0~600 → Idle/Walk/Run)
- **2D**: 두 축 (예: 속도 + 방향 → 8방향 이동)
- 중간값은 엔진이 자동 보간

### 레이어 블렌딩

상체만 공격 애니메이션, 하체는 이동 애니메이션 유지:
```
AnimNode_LayeredBoneBlend
  Base Pose: 달리기 애니메이션
  Blend Pose [0]: 공격 애니메이션 (Spine 본부터 아래 자식 전체 적용)
```

---

## IK (Inverse Kinematics)

목표 위치를 주면 관절 각도를 자동 계산합니다.

### IK 종류 비교

| IK 종류 | 소스 파일 | 특징 | 용도 |
|---------|----------|------|------|
| Two-Bone IK | `TwoBoneIK.h` | 가장 빠름, 2관절만 | 발/손 위치 맞추기 |
| FABRIK | `FABRIK.h` | 다중 관절, 각도 제약 | 척추, 꼬리 |
| CCD IK | `CCDIK.h` | 빠른 수렴, 자연스러움 | 일반 IK |
| Spline IK | `SplineIK.h` | 곡선 경로 | 뱀, 체인 |

**Two-Bone IK 사용 예시**
```
어깨(Root) → 팔꿈치(Joint) → 손(End)
목표: 손이 문손잡이 위치에 닿도록 각도 자동 계산
```

---

## 물리 시스템 (Chaos)

```
Runtime/PhysicsCore/           ← 물리 핵심 인터페이스
Runtime/Chaos/                 ← Chaos 솔버 구현
Runtime/Engine/Classes/PhysicsEngine/ ← 게임플레이 래퍼 클래스
```

### 핵심 클래스

| 클래스 | 역할 |
|--------|------|
| `UBodySetup` | 콜리전 형태 (박스/캡슐/컨벡스) |
| `UPhysicsAsset` | 래그돌용 여러 본의 물리 에셋 |
| `FBodyInstance` | 개별 본의 물리 런타임 데이터 |
| `UPhysicsConstraintComponent` | 물리 관절(Joint) 연결 |
| `UPhysicalAnimationComponent` | 물리 기반 애니메이션 보정 |

### 콜리전 채널

| 채널 | 예시 |
|------|------|
| WorldStatic | 바닥, 벽, 고정된 환경 |
| WorldDynamic | 이동 가능한 오브젝트 |
| Pawn | 플레이어 캐릭터 |
| Ragdoll | 래그돌 상태의 캐릭터 |

채널 간 상호작용:
- **Block**: 충돌 발생, 물리 반영
- **Overlap**: 감지만 (물리 반영 없음)
- **Ignore**: 무시

### 물리 시뮬레이션 모드

| 모드 | 설명 | 사용처 |
|------|------|--------|
| Static | 움직이지 않음 | 건물, 지형 |
| Dynamic | 중력/충돌 자동 계산 | 래그돌, 낙하 물체 |
| Kinematic | 애니메이션 제어, 충돌 감지 | 플레이어 캐릭터 |

---

## 래그돌

캐릭터 사망 시 물리 시뮬레이션으로 전환.

### 설정 단계

1. **Physics Asset 생성**: 각 본에 캡슐/박스 콜리전 할당
2. **관절 제약 설정**: 각 관절 운동 범위 (예: 팔꿈치 -5도~160도)
3. **런타임 전환**:
   ```
   캐릭터 사망 이벤트
     → SetSimulatePhysics(true)
     → 물리가 자동으로 남은 모션 계산
   ```

### 관절 제약 종류

| 제약 | 설명 |
|------|------|
| Limited | 운동 범위 제한 |
| Locked | 완전 고정 |
| Free | 제약 없음 |

### 부분 래그돌 패턴

```
상반신만 래그돌:
  SetBodyInstanceSimulatePhysics("Spine", true, true) ← 자식 본 포함
  하반신은 애님 계속 유지
  → 피격 시 상체가 물리 반응하면서 하체는 움직임
```

---

## 천 시뮬레이션 (ClothingSystem)

```
Runtime/ClothingSystemRuntimeCommon/  ← 공용 클래스
Runtime/ClothingSystemRuntimeNv/      ← NVIDIA Cloth 구현
```

### 핵심 개념

천 메시는 **일반 스켈레탈 메시 버텍스** + **물리로 독립 움직이는 천 버텍스** 두 가지로 구성됩니다.

### 주요 파라미터 (에디터에서 조정)

| 파라미터 | 설명 | 범위 |
|---------|------|------|
| Damping | 진동 감쇠 (높을수록 덜 흔들림) | 0.0~1.0 |
| Gravity Scale | 중력 영향도 | 0.0~2.0 |
| Air Resistance | 공기 저항 | 0.0~1.0 |
| Stiffness | 천의 뻣뻣함 | 0.0~1.0 |

### LOD별 성능 가이드

| LOD | 버텍스 수 | 비용 | 용도 |
|-----|---------|------|------|
| 원거리 LOD | 5,000 미만 | ~0.5ms | 먼 거리 |
| 중거리 LOD | 5,000~15,000 | ~1-2ms | 보통 |
| 근거리 LOD | 15,000~40,000 | ~3-5ms | 클로즈업 |

---

## 애니메이션 노티파이 (Notifies)

특정 프레임 타이밍에 이벤트를 발생시킵니다.

```
발소리 노티파이: 걷기 애니메이션의 발이 땅에 닿는 프레임
  → SoundWave 재생
  
공격 판정 노티파이: 검을 휘두르는 정점 프레임
  → 콜리전 활성화 (데미지 판정 시작)

이펙트 노티파이: 마법 시전 프레임
  → 나이아가라 VFX 스폰
```

**클래스**: `UAnimNotify` (Runtime/Engine/Classes/Animation/AnimNotifies/)

---

## 아티스트 체크리스트

```
새 캐릭터 애니메이션 설정:
✓ Skeleton 에셋 확인 (뼈 이름 일치)
✓ AnimBlueprint 생성 및 SkeletalMesh에 연결
✓ State Machine에 필수 상태 추가 (Idle, Walk, Run, Jump, Fall, Land)
✓ Blend Space로 이동 애니메이션 연결
✓ Foot IK 레이어 추가 (발이 지면에 자연스럽게)
✓ Montage 슬롯 설정 (공격, 상호작용용)
✓ 물리 시뮬레이션이 필요하면 PhysicsAsset 할당

천 시뮬레이션:
✓ 천 메시 섹션에 ClothingAsset 할당
✓ Tether 설정으로 캐릭터에서 너무 멀어지지 않도록
✓ PhysicsAsset 캡슐 콜리전 추가 (천이 몸을 관통하지 않도록)
✓ LOD별 버텍스 수 조정
```

---

## 흔한 문제 해결

| 문제 | 원인 | 해결 |
|------|------|------|
| 발이 지면 아래로 꺼짐 | Foot IK 미설정 | Two-Bone IK 레이어 추가 |
| 천이 몸 관통 | 콜리전 부족 | PhysicsAsset 캡슐 추가 |
| 블렌드가 뚝뚝함 | 전환 시간 너무 짧음 | Transition 0.2~0.3초로 늘림 |
| 래그돌이 튕겨나감 | 관절 제약 너무 강함 | Damping 증가, 제약 범위 완화 |
| 애니메이션 발자국 소리 없음 | Notify 미설정 | AnimNotify 프레임 추가 |
