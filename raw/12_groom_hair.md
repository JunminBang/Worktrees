# Groom (Hair & Strands) 시스템

> 소스 경로: Engine/Plugins/Runtime/HairStrands/Source/HairStrandsCore/Public/
> 아티스트를 위한 설명

---

## Groom 시스템이란?

Groom은 UE5의 **머리카락·수염·눈썹·속눈썹·동물 털**을 사실적으로 렌더링하기 위한 전용 시스템입니다.

**핵심 특징:**
- **Alembic (.abc) 파일** 임포트 (DCC 툴에서 제작한 헤어를 그대로 가져옴)
- 실제 머리카락 한 올 한 올을 곡선(Strand/Curve)으로 표현
- Niagara 기반 물리 시뮬레이션 내장
- 스켈레탈 메시에 붙여서 캐릭터와 함께 움직이게 설정 가능

**핵심 에셋 3종:**

| 에셋 | 역할 |
|------|------|
| `UGroomAsset` | 실제 헤어 데이터 (곡선, LOD, 재질, 물리 설정 전부 포함) |
| `UGroomBindingAsset` | Groom을 스켈레탈 메시에 붙이기 위한 투영 데이터 |
| `UGroomComponent` | 레벨/캐릭터에 Groom을 배치하는 컴포넌트 |

---

## Alembic 임포트 워크플로우

### 1단계: DCC에서 헤어 제작
- Maya/Houdini/Blender 등에서 헤어 가이드와 스트랜드 제작
- Alembic (.abc)로 익스포트 시 헤어 그룹(Group) 분리 권장
- 단위는 UE 기준 센티미터(cm)로 맞추거나 임포트 시 Scale로 보정

### 2단계: UE에 임포트
- 콘텐츠 브라우저에 .abc 파일 드래그 또는 Import 버튼 클릭
- 임포트 옵션에서:
  - **Conversion Settings**: 회전(Rotation), 스케일(Scale) 보정
  - **Interpolation Settings**: 가이드 타입, 인터폴레이션 품질 선택

### 3단계: 그룹 매핑 확인
- 재임포트 시 그룹 이름이 달라지면 `UGroomHairGroupsMapping`으로 구 그룹 → 새 그룹 매핑

---

## GroomAsset 구조

### 그룹 (Group)
Groom 하나는 여러 **Hair Group**으로 구성됩니다.
(예: 두피 헤어 / 눈썹 / 속눈썹을 각각 별도 그룹으로 관리)

**그룹별 설정 카테고리:**

| 카테고리 | 역할 |
|---------|------|
| 렌더링 | 폭, 그림자, 안티앨리어싱 설정 |
| 물리 | 시뮬레이션 솔버, 충돌, 제약 조건 |
| 인터폴레이션 | 가이드-스트랜드 연결 품질 |
| LOD | LOD별 감소율 / 지오메트리 타입 변경 |
| Cards | 카드 메시 및 텍스처 연결 |
| 재질 | 머티리얼 슬롯 |

### LOD 시스템

각 그룹은 여러 LOD를 가집니다:

| 설정 | 설명 |
|------|------|
| `CurveDecimation` (0~1) | 가닥 수 감소율 (1=원본, 0=전부 제거) |
| `VertexDecimation` (0~1) | 가닥당 버텍스 수 감소율 |
| `ScreenSize` (0~1) | 이 LOD가 활성화되는 화면 비율 |
| `ThicknessScale` | 가닥이 줄어든 것 보정을 위한 굵기 스케일 |
| `GeometryType` | Strands / Cards / Meshes 중 선택 |
| `Simulation` | Auto / Enable / Disable |

**LOD 모드:**
- `Default`: 프로젝트 설정을 따름
- `Manual`: 직접 설정한 LOD 기준값 사용
- `Auto`: 화면 커버리지에 따라 자동 감소

---

## 렌더링 모드 3가지

### Strands (스트랜드) — 최고 품질
- 머리카락 한 올 한 올을 실제 곡선으로 렌더링
- 가장 사실적이지만 GPU 비용이 가장 높음
- 전용 Hair Shader 필요 (`Hair` 도메인 머티리얼)
- 레이트레이싱 지원

### Cards (카드) — 중간 품질, 원거리/모바일 권장
- 납작한 폴리곤 카드 위에 헤어 텍스처를 올리는 방식
- 외부 DCC 툴에서 카드 메시를 만들어 Static Mesh로 임포트
- 텍스처 종류: Depth, Tangent, Attribute, Coverage, Material

### Meshes (메시) — 저비용, 원거리 전용
- 일반 스태틱 메시로 머리를 표현
- 가장 낮은 렌더링 비용
- 원거리 LOD 또는 모바일 저사양용

### LOD별 타입 전환 예시 (권장)

| LOD | GeometryType | 화면 크기 | 용도 |
|-----|-------------|---------|------|
| LOD 0 | Strands | 0.3 이상 | 근거리, 최고 품질 |
| LOD 1 | Strands | 0.1~0.3 | 중거리, 가닥 감소 |
| LOD 2 | Cards | 0.05~0.1 | 원거리, 카드 전환 |
| LOD 3 | Meshes | 0.05 이하 | 극원거리 |

---

## Groom Binding (스켈레탈 메시에 붙이기)

바인딩 에셋은 Groom 뿌리를 스켈레탈 메시 표면에 투영한 데이터를 저장합니다.
미리 빌드해두면 게임 실행 시 비싼 GPU 투영 연산을 생략할 수 있습니다.

### 바인딩 에셋 생성

1. 콘텐츠 브라우저 우클릭 → **Groom Binding** 생성
2. 설정:
   - `Groom` — 연결할 GroomAsset
   - `TargetSkeletalMesh` — 실제 캐릭터 메시
   - `NumInterpolationPoints` — RBF 보간 포인트 수 (기본 100)
3. **Build** 버튼 클릭 → 비동기 빌드 (수 분 소요 가능)

### 바인딩 타입

| 타입 | 동작 | 사용 시기 |
|------|------|---------|
| `Rigid` | 지정 본/소켓을 따라 전체 이동 | 모자, 장신구 |
| `Skinning` | 메시 표면 스키닝을 따라 뿌리 변형 | 일반 헤어, 피부 위 털 |

> **주의:** 스켈레탈 메시가 업데이트되면 반드시 바인딩을 재빌드해야 합니다.

---

## 물리 시뮬레이션

### 솔버 종류

| 솔버 | 특징 |
|------|------|
| `CosseratRods` | 코세라 로드 방정식 기반, 정확한 굽힘/비틀림 |
| `AngularSprings` | 스프링 기반, 빠름 |
| `CustomSolver` | 직접 만든 Niagara 시스템 연결 가능 |

### 주요 물리 파라미터

| 파라미터 | 설명 |
|---------|------|
| `GravityVector` | 중력 가속도 벡터 |
| `AirDrag` (0~1) | 공기 저항 계수 |
| `AirVelocity` | 바람 방향/세기 |
| `BendStiffness` | 굽힘 강성 (높을수록 뻣뻣) |
| `StretchStiffness` | 늘어남 강성 |
| `CollisionRadius` | 충돌 감지 반경 |
| `SubSteps` | 프레임당 서브스텝 수 (높을수록 정확, 느림) |
| `LinearVelocityScale` | 캐릭터 속도가 Groom에 전달되는 비율 |
| `TeleportDistance` | 이 거리 이상 순간이동 시 시뮬레이션 리셋 |

---

## GroomComponent 주요 설정

| 프로퍼티 | 설명 |
|---------|------|
| `GroomAsset` | 사용할 Groom 에셋 지정 |
| `BindingAsset` | 스켈 메시 바인딩 에셋 |
| `PhysicsAsset` | 충돌에 쓸 피직스 에셋 |
| `HairWidth` | 머리카락 굵기 (cm) |
| `HairLengthScale` (0~1) | 머리카락 길이 스케일 |
| `LODBias` (-7~7) | LOD 전환 바이어스 |
| `bUseStableRasterization` | 앨리어싱 방지 (두꺼워 보일 수 있음) |
| `bScatterSceneLighting` | 주변 피부 색 반영 (벨루스 헤어용) |

---

## 성능 최적화

| 팁 | 설명 |
|----|------|
| **BindingAsset 미리 빌드** | 없으면 시작 시 GPU 투영 연산 → 프레임 드랍 |
| **LOD 적극 활용** | CurveDecimation으로 가닥 수 단계적 감소 |
| **원거리 시뮬레이션 끄기** | 원거리 LOD에서 `Simulation = Disable` |
| **SubSteps 낮추기** | 1~2 권장 (정확도 낮지만 비용 절감) |
| **bVoxelize** | 그림자/AO용. 불필요 그룹은 끄기 |
| **MinLOD** | 플랫폼별 최소 LOD 강제 설정 |

---

## 아티스트 체크리스트

### 임포트 전 DCC 단계
- [ ] 헤어 그룹을 기능별로 분리했는가? (두피/눈썹/속눈썹/수염 별도)
- [ ] 가이드 곡선이 포함되어 있는가?
- [ ] 단위가 cm 기준인가?

### 임포트 단계
- [ ] ConversionSettings의 Rotation/Scale이 올바른가?
- [ ] 각 그룹의 InterpolationQuality가 적절한가?

### GroomAsset 설정
- [ ] 각 그룹에 올바른 머티리얼이 할당되어 있는가?
- [ ] LOD가 최소 3단계 이상 설정되어 있는가?
- [ ] 원거리 LOD에서 Cards 또는 Meshes로 전환되는가?

### 바인딩 설정
- [ ] GroomBindingAsset이 빌드 완료되었는가?
- [ ] TargetSkeletalMesh가 올바른 캐릭터 메시를 가리키는가?
- [ ] GroomComponent의 BindingAsset 슬롯에 할당되어 있는가?
- [ ] 스켈레탈 메시 업데이트 후 바인딩을 재빌드했는가?

### 물리 시뮬레이션
- [ ] 원거리 LOD에서 Simulation이 꺼져 있는가?
- [ ] LocalBone이 올바른 본 이름으로 설정되어 있는가?
- [ ] PhysicsAsset이 컴포넌트에 연결되어 있는가?
