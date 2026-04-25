# 머티리얼 고급 — 인스턴스, 함수, 레이어, 파라미터 컬렉션

> 소스 경로: Runtime/Engine/Classes/Materials/
> 아티스트를 위한 설명

---

## Material vs Material Instance 관계

### 기본 개념

| 구분 | 역할 | 비유 |
|------|------|------|
| **Material** (부모) | 셰이더 로직 정의, 노드 그래프 구성 | 빵틀(금형) |
| **Material Instance** (자식) | 파라미터 값만 변경, 로직 재사용 | 빵틀로 찍어낸 빵 |

**핵심 이점:**
- 수천 개의 Material Instance가 하나의 Material을 공유 → 드로우콜 최적화
- Instance는 별도 셰이더 컴파일 없이 즉시 파라미터 변경 가능

---

## Material Instance Constant (MIC) vs Dynamic (MID)

| 구분 | MIC (Constant) | MID (Dynamic) |
|------|---------------|---------------|
| 생성 방법 | 에디터에서 우클릭 → Create Material Instance | Blueprint에서 `Create Dynamic Material Instance` |
| 런타임 변경 | 불가 | 가능 |
| 성능 비용 | 낮음 | 약간 높음 |
| 사용 시기 | 정적 에셋 (벽, 바닥, 소품) | 동적 변화 필요 시 (HP바, 색상 변경, 용해 효과) |

### Blueprint에서 MID 사용 예시

```
Event BeginPlay
  → Create Dynamic Material Instance (Source Material: M_Character)
  → Set Material (Mesh: SkeletalMesh, Material: 위 결과)
  → 변수에 저장 (Dynamic Material)

[데미지 받을 때]
  → Set Scalar Parameter Value
      Target: Dynamic Material
      Parameter Name: "DamageAmount"
      Value: 0.5
```

---

## 머티리얼 파라미터 종류

| 파라미터 타입 | 데이터 | 용도 |
|------------|--------|------|
| **Scalar Parameter** | 단일 float 값 | 강도, 배율, 진행도 (0~1) |
| **Vector Parameter** | RGBA 4개 값 | 색상, 방향, 복합 데이터 |
| **Texture Parameter** | 텍스처 에셋 | 베이스컬러, 노멀, 러프니스 맵 교체 |
| **StaticSwitch Parameter** | True/False | 특정 기능 ON/OFF (셰이더 분기) |
| **StaticComponentMask** | RGBA 채널 선택 | 특정 채널만 마스킹 |

### 파라미터 이름 작성 규칙

- **일관성 있는 이름 사용:** 팀 전체가 동일한 이름을 사용해야 합니다
- 예: `BaseColor_Tint`, `Roughness_Scale`, `Normal_Intensity`, `Opacity_Amount`
- CamelCase 또는 Snake_Case 중 하나로 통일

---

## Material Function — 재사용 가능한 노드 묶음

### Material Function이란?

Material Function은 **자주 쓰는 노드 조합을 하나의 블랙박스로 캡슐화**한 것입니다.

**비유:** 머티리얼용 "커스텀 노드" 또는 "매크로"입니다.

### 생성 방법

1. Content Browser → 우클릭 → **Materials → Material Function**
2. 함수 내부에 노드 그래프 작성
3. `FunctionInput` 노드: 외부에서 받을 입력값 정의
4. `FunctionOutput` 노드: 외부로 내보낼 출력값 정의
5. 에셋 이름은 `MF_` 접두사 권장 (예: `MF_TriplanarMapping`)

### 호출 방법

머티리얼 에디터에서 `Material Function Call` 노드를 추가하고 함수 에셋을 지정합니다.

### 자주 쓰는 내장 Material Function 예시

| 함수 이름 | 기능 |
|---------|------|
| `Lerp` | 두 값 사이 선형 보간 |
| `Blend_Overlay` | 포토샵 Overlay 블렌드 |
| `CheapContrast` | 저비용 대비 조정 |
| `WorldAlignedTexture` | 월드 기준 텍스처 매핑 (트리플래너) |
| `MakeFloat3` / `BreakFloat3` | 벡터 조립·분해 |

---

## Material Layer & Blend — 레이어 시스템

### 개념

Material Layer는 **포토샵의 레이어처럼 여러 머티리얼을 쌓아 올리는 시스템**입니다. Layer 간 전환·블렌딩을 하나의 머티리얼 그래프에서 처리할 수 있습니다.

| 에셋 타입 | 역할 |
|---------|------|
| `Material Layer` | 하나의 레이어 정의 (예: 금속 레이어, 흙 레이어) |
| `Material Layer Blend` | 두 레이어를 어떻게 섞을지 정의 (마스크 기반) |

### 레이어 스택 예시 (캐릭터 갑옷)

```
Layer 0: M_Layer_Iron     ← 기본 철 재질
Layer 1: M_Layer_Rust     ← 녹 레이어 (마스크: 가장자리 부분)
Layer 2: M_Layer_Dirt     ← 먼지 레이어 (마스크: 오목한 부분)
```

### 사용 방법

1. 머티리얼 에디터에서 `Use Material Layers` 활성화
2. Layer Stack 패널에서 레이어 추가
3. 각 레이어에 `Material Layer` 에셋 할당
4. `Material Layer Blend` 에셋으로 블렌드 방식 지정

---

## Material Parameter Collection (MPC)

### MPC란?

**Material Parameter Collection**은 **여러 머티리얼이 공유하는 전역 파라미터 저장소**입니다.

**비유:** 프로젝트 전체 조명 색을 조절하는 "마스터 리모컨" — 하나의 값을 바꾸면 이 MPC를 참조하는 모든 머티리얼이 동시에 반응합니다.

### 사용 예시

```
MPC_WorldParameters (Material Parameter Collection 에셋)
├─ WindDirection: Vector (0, 1, 0)
├─ WindStrength: Scalar 3.5
├─ TimeOfDay: Scalar 0.75
└─ GlobalTint: Vector (1.0, 0.9, 0.8, 1.0)

→ 모든 식물 머티리얼이 WindDirection·WindStrength 참조
→ 하늘·안개 머티리얼이 TimeOfDay 참조
→ Blueprint에서 Set Scalar/Vector Parameter Value (MPC) 노드로 런타임 변경
```

### Blueprint에서 MPC 변경

```
[바람 강도 조절]
→ Set Scalar Parameter Value (Collection: MPC_WorldParameters)
    Parameter Name: "WindStrength"
    Parameter Value: 5.0
```

> **성능 주의:** MPC는 최대 1024개의 Scalar, 1024개의 Vector 파라미터를 가질 수 있습니다. 과도하게 많은 파라미터는 피하세요.

---

## 머티리얼 최적화 팁

| 팁 | 설명 |
|----|------|
| Instruction Count 줄이기 | Stats 창에서 Instruction 수 확인 (목표: 100~200 이하) |
| Texture Sampling 최소화 | 같은 텍스처를 여러 곳에서 샘플링하지 않도록 노드 공유 |
| `Static Switch` 활용 | 분기 로직 대신 StaticSwitch로 셰이더 코드 제거 |
| Material Instance 사용 | 불필요한 셰이더 컴파일 방지 |
| LOD Material | 원거리 메시에 단순화된 머티리얼 사용 |
| `Mobile` 체크 | 모바일 타겟 시 복잡한 노드(Refraction, CustomDepth 등) 제거 |

---

## 아티스트 체크리스트

### Material Instance 작성 시
- [ ] 부모 Material에 필요한 파라미터가 노출되어 있는가?
- [ ] 파라미터 이름이 팀 네이밍 컨벤션을 따르는가?
- [ ] MIC로 충분한가, 아니면 MID(Dynamic)가 필요한가?
- [ ] Material Instance 에셋 이름에 `MI_` 접두사를 붙였는가?

### Material Function 작성 시
- [ ] FunctionInput/Output 핀 이름이 명확한가?
- [ ] 에셋 이름에 `MF_` 접두사를 붙였는가?
- [ ] Preview 노드를 추가해 함수 내부 결과를 확인했는가?

### Material Parameter Collection 사용 시
- [ ] MPC 에셋 이름에 `MPC_` 접두사를 붙였는가?
- [ ] Blueprint에서 Set Parameter Value 호출 후 변화가 실시간 반영되는지 확인했는가?
- [ ] 너무 많은 파라미터를 하나의 MPC에 몰아넣지 않았는가?

### 성능 검토
- [ ] Shader Complexity 뷰 모드에서 빨간 영역(고비용 셰이더)이 있는가?
- [ ] Stats 패널에서 Instruction Count를 확인했는가?
- [ ] 불필요한 텍스처 샘플러가 중복 사용되지 않는가?
