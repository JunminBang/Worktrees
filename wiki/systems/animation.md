---
name: 캐릭터 애니메이션 시스템
type: system
tags: animation, skeletal-mesh, anim-blueprint, character
last_updated: 2026-04-09
source: engine-source
source_path: Engine/Source/Runtime/Engine/Classes/Animation/AnimInstance.h
source_path2: Engine/Source/Runtime/Engine/Classes/Components/SkeletalMeshComponent.h
engine_version: UE_5.7
scene_verified: false
---

# 캐릭터 애니메이션 시스템

> ⚠️ **주의**: 이 페이지는 2026-04-09 debug query 시 씬에 SkeletalMesh 액터가 없어 general-knowledge 기반으로 작성됨. scene_verified: false. UE5 소스 기반 심화 내용은 [ue5_animation_physics.md](ue5_animation_physics.md) 참조.

## 개요

인게임 캐릭터 애니메이션은 ACharacter → USkeletalMeshComponent → UAnimInstance 구조로 동작.

```
ACharacter
  └── USkeletalMeshComponent
        ├── USkeletalMesh        ← 본(Bone) 계층구조 + 메시
        ├── UAnimInstance        ← 애니메이션 로직 (AnimBP)
        │     ├── State Machine  ← Idle/Walk/Jump 상태 전환
        │     ├── BlendSpace     ← 방향/속도에 따른 블렌딩
        │     └── Montage        ← 공격/피격 등 단발성 재생
        └── USkeleton            ← 본 정의 (공유 에셋)
```

---

## 핵심 컴포넌트

### 1. AnimBlueprint (UAnimInstance)
매 프레임 실행되는 로직. 캐릭터 속도, 방향, 상태를 읽어서 어떤 애니메이션을 재생할지 결정.

**업데이트 파이프라인** (AnimInstance.h 실제 소스 기준):
```
NativeInitializeAnimation()          // 초기화 1회
  ↓ 매 프레임
NativeUpdateAnimation(DeltaSeconds)  // 게임 스레드 — 데이터 수집만 권장
NativeThreadSafeUpdateAnimation()    // 워커 스레드 — 실제 로직 처리 권장
  ↓
NativePostEvaluateAnimation()        // 평가 완료 후
```

> 📌 소스 주석 원문:  
> *"It is usually a good idea to simply gather data in NativeUpdateAnimation  
> and for the bulk of the work to be done in NativeThreadSafeUpdateAnimation"*
> — `AnimInstance.h:1374`

- **SkeletalMeshComponent.AnimClass**: 사용할 AnimBP 클래스 지정
- **SkeletalMeshComponent.AnimScriptInstance**: 실행 중인 UAnimInstance 인스턴스 (transient)
- **Event Graph**: 변수 업데이트 (Speed, IsAiming, IsFalling 등)
- **Anim Graph**: State Machine으로 실제 포즈 출력

### 2. State Machine
상태(State)와 전환 조건(Transition)으로 구성.
```
[Idle] --Speed > 0--> [Walk] --Speed > 300--> [Run]
  ↑___________________Speed = 0________________↓
```

### 3. BlendSpace
두 축(예: 속도/방향)에 따라 여러 애니메이션을 자연스럽게 블렌딩.
- 1D BlendSpace: 속도만 (걷기 → 달리기)
- 2D BlendSpace: 속도 + 방향 (전후좌우 이동)

### 4. Montage
State Machine 위에 덮어씌우는 단발성 애니메이션.
공격, 구르기, 피격처럼 "중간에 끼어드는" 동작에 사용.
- **Slot**: Montage가 어느 레이어에 재생될지 지정. State Machine과 연결 필수.
- 재생 후 자동으로 State Machine으로 복귀.

### 5. IK (Inverse Kinematics)
발이 바닥에 맞닿도록 본 위치를 역산. Two Bone IK 또는 Full Body IK 사용.
- 루트 모션과 충돌 가능 — 동시 사용 시 주의.

---

## 자주 발생하는 버그 패턴

| 증상 | 원인 | 해결 |
|------|------|------|
| T포즈로 굳음 | AnimBP 없음 또는 컴파일 오류 | AnimBP 재컴파일, 슬롯 연결 확인 |
| 애니가 뚝뚝 끊김 | BlendSpace 미설정, 직접 교체 | BlendSpace로 전환 |
| 공격 모션 안 나옴 | Montage Slot이 Anim Graph에 없음 | DefaultSlot 노드 추가 |
| 발이 바닥에 안 닿음 | IK 미설정 또는 루트 모션 충돌 | IK 활성화 또는 루트 모션 설정 확인 |
| 이동 방향과 애니 불일치 | Velocity vs Acceleration 혼용 | 기준 통일 |
| 애니 재생되다 갑자기 멈춤 | Montage 종료 후 State 복귀 안 됨 | OnMontageEnded 이벤트 처리 |

---

## 씬 상태

> ✅ **시스템 설명은 UE 5.7 엔진 소스 기반으로 검증되었습니다.**  
> ⚠️ **현재 프로젝트 씬에는 캐릭터 액터가 없어 실측 데이터는 없습니다.**

- 스캔일 2026-04-09 기준, 현재 레벨에 SkeletalMeshActor / Character 클래스 액터 없음
- 실제 캐릭터 연결 후 `scene_verified: true`로 업데이트 필요

## VisibilityBasedAnimTickOption (성능 최적화)
소스 확인된 최적화 옵션 (`SkeletalMeshComponent.h:1675`):
- 화면 밖 캐릭터의 애니 틱을 줄여 성능 절약
- `OnlyTickMontagesWhenNotRendered` 설정 시 화면 밖에서 Montage만 틱됨
- 100명 프로젝트에서 중요한 최적화 포인트

---

## 관련 페이지
- [StaticMesh 시스템](static_mesh.md)
- [레벨 개요](../overview.md)
