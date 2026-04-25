---
name: UE5 애니메이션 & 물리 시스템
type: System
tags: unreal-engine, animation, animBP, state-machine, IK, physics, chaos, ragdoll, cloth
source: raw-ingest
scene_verified: false
last_updated: 2026-04-19
---

# UE5 애니메이션 & 물리 시스템

> 소스 경로: Runtime/AnimGraphRuntime/, Runtime/AnimationCore/, Runtime/PhysicsCore/, Runtime/ClothingSystem*/
> 🔗 Engine Reference (UE5.7 API 변경): [modules/animation.md](../../docs/engine-reference/unreal/modules/animation.md) · [modules/physics.md](../../docs/engine-reference/unreal/modules/physics.md)

---

## 애니메이션 시스템 구조

```
스켈레톤 (Skeleton) — 뼈대 계층 구조 정의
  → 애니메이션 시퀀스 — 실제 동작 데이터 (키프레임)
  → 애니메이션 블루프린트 (AnimBP) — 어떤 동작을 언제 재생할지 로직
  → 스켈레탈 메시 컴포넌트 — 월드에서 실제 렌더링
```

**소스 경로**
```
Runtime/AnimGraphRuntime/Public/AnimNodes/ ← AnimNode 클래스 (88개 헤더)
Runtime/AnimationCore/Public/             ← IK 알고리즘 라이브러리 (17개)
Runtime/Engine/Classes/Animation/         ← 게임플레이 클래스 (112개)
```

---

## 주요 AnimNode 클래스

| 클래스 | 에디터 노드 | 역할 |
|--------|-----------|------|
| AnimNode_StateMachine | State Machine | 상태 전환 관리 |
| AnimNode_BlendSpacePlayer | Blend Space | 파라미터 기반 자동 블렌딩 |
| AnimNode_LayeredBoneBlend | Layered Blend | 특정 본만 덮어쓰기 |
| AnimNode_Slot | Slot | Montage 재생 슬롯 |
| AnimNode_TwoWayBlend | Blend | Alpha로 두 포즈 혼합 |

---

## IK (Inverse Kinematics)

| IK 종류 | 소스 파일 | 특징 | 용도 |
|---------|----------|------|------|
| Two-Bone IK | TwoBoneIK.h | 가장 빠름, 2관절만 | 발/손 위치 맞추기 |
| FABRIK | FABRIK.h | 다중 관절, 각도 제약 | 척추, 꼬리 |
| CCD IK | CCDIK.h | 빠른 수렴, 자연스러움 | 일반 IK |
| Spline IK | SplineIK.h | 곡선 경로 | 뱀, 체인 |

---

## 물리 시스템 (Chaos)

| 클래스 | 역할 |
|--------|------|
| UBodySetup | 콜리전 형태 (박스/캡슐/컨벡스) |
| UPhysicsAsset | 래그돌용 여러 본의 물리 에셋 |
| FBodyInstance | 개별 본의 물리 런타임 데이터 |
| UPhysicsConstraintComponent | 물리 관절(Joint) 연결 |

**콜리전 채널**: WorldStatic / WorldDynamic / Pawn / Ragdoll
**상호작용**: Block (충돌) / Overlap (감지만) / Ignore

---

## 래그돌

```
캐릭터 사망 이벤트
  → SetSimulatePhysics(true)
  → 물리가 자동으로 남은 모션 계산
```

부분 래그돌: `SetBodyInstanceSimulatePhysics("Spine", true, true)` → 상체만 래그돌

---

## 천 시뮬레이션 파라미터

| 파라미터 | 설명 | 범위 |
|---------|------|------|
| Damping | 진동 감쇠 | 0.0~1.0 |
| Gravity Scale | 중력 영향도 | 0.0~2.0 |
| Air Resistance | 공기 저항 | 0.0~1.0 |
| Stiffness | 천의 뻣뻣함 | 0.0~1.0 |

---

## 흔한 문제 해결

| 문제 | 원인 | 해결 |
|------|------|------|
| 발이 지면 아래로 꺼짐 | Foot IK 미설정 | Two-Bone IK 레이어 추가 |
| 천이 몸 관통 | 콜리전 부족 | PhysicsAsset 캡슐 추가 |
| 블렌드가 뚝뚝함 | 전환 시간 너무 짧음 | Transition 0.2~0.3초로 늘림 |
| 래그돌이 튕겨나감 | 관절 제약 너무 강함 | Damping 증가, 제약 범위 완화 |

---

## 관련 페이지
- [애니메이션 시스템](animation.md)
- [Neural Avatar 논문](../papers/neural_avatar.md)
- [UE5 전체 개요](ue5_overview.md)
- [게임플레이 프레임워크](ue5_gameplay_framework.md)
- [UI & 시네마틱 시스템](ue5_ui_cinematics.md)
