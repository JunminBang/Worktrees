# Physical Material — 표면 타입 & 충격 반응

> 소스 경로: Runtime/Engine/Classes/PhysicalMaterials/PhysicalMaterial.h
> 아티스트를 위한 설명

---

## Physical Material이란?

Physical Material은 **표면의 물리적 특성(마찰, 반발, 표면 타입)을 정의하는 에셋**입니다. 머티리얼 에셋과 다르며, 시각적인 것이 아니라 "이 표면은 얼마나 미끄러운가", "이 표면은 어떤 종류인가"를 정의합니다.

**비유:** 신발 밑창이 느끼는 바닥 재질 — 대리석인지 모래인지 잔디인지에 따라 걸음 소리, 미끄러짐, 파티클이 달라집니다.

---

## Physical Material 생성

1. Content Browser → 우클릭 → **Physics → Physical Material**
2. 이름 규칙: `PM_` 접두사 (예: `PM_Grass`, `PM_Concrete`, `PM_Metal`)
3. 더블클릭 → 설정 편집

---

## 주요 프로퍼티

| 프로퍼티 | 설명 | 기본값 |
|---------|------|-------|
| `Friction` | 마찰계수. 높을수록 잘 미끄러지지 않음 | 0.7 |
| `Restitution` | 반발계수(탄성). 높을수록 더 많이 튕김 | 0.3 |
| `Density` | 밀도 (kg/cm³). 물리 질량 계산에 사용 | 1.0 |
| `Raise Mass to Power` | 질량 스케일 조정 | 0.75 |
| `Surface Type` | 표면 타입 (사운드/이펙트 연동용 enum) | Default |

### 마찰 예시

| 표면 | Friction 값 |
|------|------------|
| 얼음 | 0.05 |
| 대리석/젖은 바닥 | 0.3 |
| 콘크리트 | 0.7 |
| 고무/잔디 | 0.9 |

### 반발 예시

| 표면 | Restitution 값 |
|------|--------------|
| 콘크리트 | 0.1 |
| 나무 | 0.2 |
| 고무 | 0.7 |
| 금속 스프링 | 0.9 |

---

## Surface Type — 표면 타입 등록

Surface Type은 **어떤 표면인지를 나타내는 식별자**로, 발걸음 소리·파티클·데칼을 표면에 따라 다르게 재생할 때 사용합니다.

### Surface Type 등록 방법

1. `Project Settings → Physics → Physical Surface` 탭
2. `SurfaceType1` ~ `SurfaceType62`에 이름 입력
   - 예: `SurfaceType1 = Grass`
   - `SurfaceType2 = Concrete`
   - `SurfaceType3 = Metal`
   - `SurfaceType4 = Wood`
   - `SurfaceType5 = Sand`
   - `SurfaceType6 = Water`

---

## 머티리얼에 Physical Material 할당

1. 머티리얼 에디터 열기
2. Details → `Phys Material` 슬롯에 Physical Material 에셋 할당
3. Material Instance도 동일하게 설정 가능

---

## Blueprint에서 Surface Type 읽기

Line Trace Hit Result에서 표면 타입을 읽어 소리/이펙트를 분기합니다:

```
→ Line Trace By Channel (발밑을 향해 트레이스)
→ Break Hit Result → Physical Material
→ Get Surface Type
    반환: EPhysicalSurface (SurfaceType1, SurfaceType2...)

→ Switch on EPhysicalSurface
    SurfaceType1 (Grass):
        → Play Sound: Footstep_Grass
        → Spawn Emitter: NS_GrassDust
    SurfaceType2 (Concrete):
        → Play Sound: Footstep_Concrete
        → Spawn Emitter: NS_ConcreteDust
    SurfaceType3 (Metal):
        → Play Sound: Footstep_Metal
        → Spawn Emitter: NS_MetalSpark
    Default:
        → Play Sound: Footstep_Default
```

---

## 발걸음 소리 시스템 구축

### 전체 흐름

```
1. 각 표면 머티리얼에 PM_Grass / PM_Concrete 등 할당
2. AnimNotify로 발이 땅에 닿는 프레임 감지
3. 발 소켓 위치에서 Line Trace Down
4. Hit Result → Physical Material → Surface Type 읽기
5. 표면 타입에 따라 사운드/파티클 선택 재생
```

### AnimNotify 설정

1. 애니메이션 에디터 → Notify 트랙
2. `Add Notify → AnimNotify` 커스텀 노드 추가 (또는 기본 제공 Notify 활용)
3. 발이 땅에 닿는 정확한 프레임에 배치

---

## 총탄 충격 반응

표면 타입별 총탄 충격 이펙트/소리:

```
→ Line Trace (총기 레이캐스트)
→ Hit Result → Physical Material → Get Surface Type

→ Switch on Surface Type
    Metal:   → NS_BulletSpark + Sound_BulletMetal + Decal_MetalHole
    Wood:    → NS_WoodChip   + Sound_BulletWood  + Decal_WoodHole
    Flesh:   → NS_BloodSplat + Sound_BulletFlesh + Decal_BloodMark
    Concrete:→ NS_ConcretePuff + Sound_BulletConcrete + Decal_ConcreteHole
```

---

## Destructible & Chaos 연동

Chaos 파괴 시스템과 Physical Material 연동:

- 파괴 임계값(Break Threshold)을 Physical Material의 `Density`/`Friction`과 연동 가능
- 파괴 이펙트를 Surface Type 기반으로 분기

---

## 아티스트 체크리스트

### Physical Material 설정
- [ ] 프로젝트의 모든 주요 표면 타입이 Project Settings에 등록되어 있는가?
- [ ] 각 표면 머티리얼에 올바른 Physical Material이 할당되어 있는가?
- [ ] `PM_` 접두사 네이밍 컨벤션을 따르는가?

### 발걸음 시스템
- [ ] Footstep AnimNotify가 발이 땅에 닿는 정확한 프레임에 배치되어 있는가?
- [ ] 모든 주요 표면에 대한 사운드 에셋이 준비되어 있는가?
- [ ] Default 케이스(미등록 표면)에 대한 처리가 있는가?

### 총탄 충격
- [ ] 총탄 Hit Result에서 Physical Material을 읽는 로직이 있는가?
- [ ] 각 표면 타입별 데칼 + 파티클 + 사운드 세트가 준비되어 있는가?
