# 스켈레탈 메시 LOD & 클로스 시뮬레이션

> 소스 경로: Runtime/Engine/Classes/Engine/SkeletalMesh.h, Runtime/ClothingSystemRuntimeCommon/
> 아티스트를 위한 설명

---

## LOD (Level of Detail) 개요

LOD는 **카메라에서 멀어질수록 낮은 품질 메시로 자동 교체**하는 성능 최적화 기법입니다.

**비유:** 멀리서 보면 구분 안 되는 세밀한 조각 — 가까이 있을 때만 고해상도를 쓰고, 멀리 있으면 단순한 형태를 씁니다.

| LOD 레벨 | 사용 시점 | 특징 |
|---------|---------|------|
| LOD 0 | 가장 가까울 때 | 최고 품질, 최고 폴리곤 수 |
| LOD 1 | 중거리 | 폴리곤 30~50% 감소 |
| LOD 2 | 원거리 | 폴리곤 70~80% 감소 |
| LOD 3+ | 매우 먼 거리 | 극단적 단순화 또는 컬링 |

---

## LOD 생성 방법

### 자동 생성 (Auto Generate)

1. 스켈레탈 메시 에디터 열기
2. 상단 메뉴 → **LOD Settings**
3. `Number of LODs` 설정 (예: 4)
4. **Regenerate** 클릭
5. 각 LOD별 `Percent Triangles` 또는 `Max Deviation` 조정

### 수동 LOD 임포트 (Custom)

1. DCC 툴(Maya, Blender)에서 각 LOD 메시 제작
2. 언리얼 에디터에서 **LOD Pick** → 해당 LOD 슬롯에 FBX 임포트
3. 각 LOD는 **동일한 스켈레톤**을 사용해야 합니다

---

## LOD 설정 파라미터

| 파라미터 | 설명 |
|---------|------|
| `Screen Size` | 화면 크기 임계값. 이 크기 이하로 작아지면 다음 LOD로 전환 (0~1) |
| `Percent Triangles` | 원본 대비 남길 삼각형 비율 |
| `Max Deviation` | 허용되는 최대 표면 오차 (cm). 작을수록 원본에 가까움 |
| `Silhouette Importance` | 실루엣 유지 우선도 (Lowest~Highest) |
| `Texture Importance` | UV 영역 유지 우선도 |
| `Shading Importance` | 노멀 방향 유지 우선도 |

---

## LOD별 머티리얼 슬롯 독립 설정

LOD가 바뀔 때 다른 머티리얼을 사용할 수 있습니다:

1. 스켈레탈 메시 에디터 → LOD 탭 선택
2. `LOD Info` 섹션 → 해당 LOD의 섹션별 머티리얼 오버라이드 설정
3. 원거리 LOD에는 단순화된 머티리얼(Unlit, 텍스처만) 적용 가능

---

## LOD 강제 설정

Blueprint 또는 디테일 패널에서 LOD를 수동으로 고정할 수 있습니다:

| 설정 | 설명 |
|------|------|
| `Forced LOD Model` | 항상 특정 LOD 사용 (0=자동, 1~N=고정) |
| `Min LOD Level` | 최소 LOD 레벨 제한 (이 값 이상의 LOD만 사용) |

Blueprint 노드: `Set Forced LOD` — 런타임에 LOD 강제 전환

---

## Morph Target (모프 타겟 / 블렌드셰이프)

### 개념

Morph Target은 **같은 토폴로지의 메시를 다른 형태로 변형**하는 기능입니다. DCC 툴의 블렌드셰이프와 동일합니다.

**사용 예시:**
- 얼굴 표정 (웃음, 찡그림, 눈 깜빡임)
- 근육 팽창/이완
- 상처/데미지 형태 변화

### 임포트 방법

1. DCC 툴에서 블렌드셰이프가 포함된 FBX 내보내기
2. 언리얼 임포트 시 `Import Morph Targets` 체크
3. 스켈레탈 메시 에디터 → **Morph Targets 탭**에서 확인

### Blueprint에서 Morph Target 제어

```
[웃음 표정 적용]
→ Set Morph Target
    Target: SkeletalMeshComponent
    Morph Target Name: "Smile"
    Value: 0.8  (0.0=기본, 1.0=최대 변형)
```

---

## ChaosCloth — 헝겊 시뮬레이션

### 개념

ChaosCloth는 천, 옷, 깃발, 망토 등을 **물리적으로 시뮬레이션**합니다. 캐릭터 이동에 따라 자연스럽게 흔들리고 늘어집니다.

### 클로스 에셋 생성 방법

1. 스켈레탈 메시 에디터 → **Clothing 탭**
2. `Create Clothing Data from Section` — 특정 메시 섹션을 클로스로 지정
3. 페인트 툴로 **Fixed (고정)/Free (자유)** 가중치 페인팅
4. 물리 파라미터 조정

### 클로스 페인트 가중치

| 색상 | 의미 | 예시 |
|------|------|------|
| 검정 (0) | Fixed — 고정점, 움직이지 않음 | 어깨 부착점, 벨트 |
| 흰색 (1) | 완전히 자유롭게 흔들림 | 치마 끝단, 망토 아랫부분 |
| 회색 (0.5) | 반고정 — 약하게 흔들림 | 중간 허리 부분 |

**페인트 파라미터:**
- `Max Distance`: 기준 포즈에서 최대 이탈 거리. 0=고정, 클수록 더 많이 움직임
- `Backstop Distance/Radius`: 뒤쪽으로 파고드는 것 방지 (피부 관통 방지)

### 클로스 물리 파라미터

| 파라미터 | 설명 |
|---------|------|
| `Damping` | 진동 감쇠. 높을수록 빨리 정지 |
| `Gravity Scale` | 중력 영향 배율 (1.0=기본) |
| `Stiffness` | 천 경도. 높을수록 뻣뻣함 |
| `Wind Method` | 바람 반응 방식 (Accurate/Legacy) |
| `Self Collision` | 천끼리 자기 충돌 (성능 비용 있음) |

### LOD별 클로스 비활성화

원거리 LOD에서는 클로스를 비활성화해 성능을 절약할 수 있습니다:

1. 스켈레탈 메시 에디터 → 해당 LOD 선택
2. `Clothing` 섹션 → `Disabled` 체크

---

## 아티스트 체크리스트

### LOD 설정 시
- [ ] LOD 0의 폴리곤 수가 타겟 플랫폼 예산 안에 있는가?
- [ ] Screen Size 임계값이 씬 규모에 맞게 설정되어 있는가?
- [ ] 모든 LOD가 동일한 스켈레톤을 사용하는가?
- [ ] LOD 전환 시 팝핑(급격한 형태 변화)이 없는가?
- [ ] 원거리 LOD에 단순화된 머티리얼을 적용했는가?

### Morph Target 사용 시
- [ ] FBX 임포트 시 `Import Morph Targets`가 체크되었는가?
- [ ] 모프 타겟 이름이 Blueprint 참조 이름과 일치하는가?
- [ ] 모프 값 범위(0~1)가 DCC 툴에서 올바르게 설정되었는가?

### ChaosCloth 설정 시
- [ ] 고정점(Fixed) 가중치가 캐릭터 부착점에 올바르게 페인팅되었는가?
- [ ] Backstop이 피부 관통을 방지하도록 설정되었는가?
- [ ] 원거리 LOD에서 클로스가 비활성화되어 있는가?
- [ ] Self Collision이 필요한 경우에만 활성화되어 있는가?
- [ ] Wind 반응이 레벨의 바람 방향과 연동되어 있는가?
