# PCG (Procedural Content Generation) — 절차적 콘텐츠 생성

> 소스 경로: Engine/Plugins/PCG/Source/PCG/Public/
> 아티스트를 위한 설명

---

## PCG란?

PCG는 **절차적 콘텐츠 생성(Procedural Content Generation)** 시스템입니다.

"어떤 규칙을 만들어두면 엔진이 자동으로 오브젝트를 배치해주는 것"입니다.

- 지형(Landscape) 위에 나무, 바위, 풀을 자동으로 배치
- Spline(곡선 경로) 옆에 울타리나 가로등을 일렬로 세우기
- 볼륨 영역 안에 랜덤하게 소품을 흩뿌리기

노드 그래프로 규칙을 만들면 버튼 한 번 (또는 자동으로) 배치가 완료됩니다.

**핵심 구성 요소:**

| 요소 | 역할 |
|------|------|
| `UPCGComponent` | 액터에 붙이는 컴포넌트. "이 액터에서 PCG를 실행하라"는 명령자 |
| `UPCGGraph` | 노드들이 연결된 그래프 에셋. "어떤 규칙으로 배치할지" 레시피 |
| `UPCGNode` | 그래프 안의 개별 작업 단위 |

---

## PCGGraph 노드 시스템 구조

```
[Input Node]
     ↓  (데이터: 지형, 스플라인, 볼륨 등)
[Sampler Node]      ← 포인트 뿌리기
     ↓
[Filter Node]       ← 원하는 것만 남기기
     ↓
[Transform Node]    ← 위치/회전/크기 조정
     ↓
[Spawner Node]      ← 실제 메시 또는 액터 생성
     ↓
[Output Node]
```

### 데이터 타입 (핀을 통해 전달)

| 타입 | 설명 |
|------|------|
| `Point` | 위치/회전/크기를 가진 점들의 배열 (가장 많이 쓰임) |
| `Spline` | 스플라인 곡선 경로 |
| `Landscape` | 지형 데이터 |
| `Volume` | 3D 볼륨 영역 |
| `Texture / RenderTarget` | 텍스처 기반 샘플링 소스 |
| `Param` | 수치·문자열 등의 속성 묶음 |

---

## 자주 쓰는 노드 타입

### Sampler 계열 — "포인트를 어디에 뿌릴까"

| 노드 | 역할 |
|------|------|
| **Surface Sampler** | 지형/서피스 위에 밀도 기반으로 포인트 생성. `PointsPerSquaredMeter`로 밀도 조정 |
| **Spline Sampler** | 스플라인 위 또는 스플라인 내부 면적에 포인트 생성 |
| **Volume Sampler** | 볼륨 Actor 내부를 Voxel 단위로 채우며 포인트 생성 |
| **Create Points Grid** | 격자 형태로 규칙적인 포인트 생성 |

**Spline Sampler 방식:**
- `OnSpline` — 선 위에 점
- `OnHorizontal` — 스플라인 수평 확장 면
- `OnVolume` — 스플라인으로 감싸인 볼륨
- `OnInterior` — 닫힌 스플라인 내부 채우기

### Filter 계열 — "어떤 포인트만 남길까"

| 노드 | 역할 |
|------|------|
| **Attribute Filter** | 속성 값 비교로 필터링. 예: `Density > 0.5`, `LayerWeight >= 0.3` |
| **Self Pruning** | 서로 겹치는 포인트 제거. LargeToSmall / SmallToLarge / RemoveDuplicates |
| **Difference** | 특정 영역과 겹치는 포인트 제거 |

### Transform 계열 — "포인트 위치/회전/크기 조정"

| 노드 | 역할 |
|------|------|
| **Transform Points** | 오프셋, 회전, 스케일을 Min~Max 범위로 랜덤 적용 |
| **Attribute Noise** | 속성 값에 노이즈 추가 |
| **Bounds Modifier** | 포인트의 바운딩 박스 크기 조정 |

### Spawner 계열 — "실제로 무엇을 만들까"

| 노드 | 역할 |
|------|------|
| **Static Mesh Spawner** | 포인트 위치에 Static Mesh 배치. 내부적으로 ISM/HISM 사용 |
| **Spawn Actor** | 포인트마다 Actor 생성 |
| **Spawn Spline Mesh** | 스플라인을 따라 변형되는 메시 배치 |

### Control Flow — "조건에 따라 분기"

| 노드 | 역할 |
|------|------|
| **Branch** | 불리언 값에 따라 두 경로로 분기 |
| **Quality Branch** | 품질 레벨(Low/Med/High)에 따라 분기 |
| **Switch** | 다중 조건 분기 |

---

## 아티스트 워크플로우 — 지형 위 나무 배치

```
1. 빈 Actor에 PCGComponent 추가
2. PCGGraph 에셋 생성 후 컴포넌트에 연결
3. 그래프 열기 → 아래 순서로 노드 연결:
```

**그래프 내부:**
```
[Input Node]                          ← Landscape 데이터 자동 포함
     ↓
[Surface Sampler]
  - Points Per Squared Meter: 0.1     ← 10m²당 1개
  - Point Extents: 200cm              ← 나무 크기 기준
     ↓
[Attribute Filter]                    ← 선택사항
  - Landscape Layer "Forest" > 0.5   ← 숲 레이어 영역만 통과
     ↓
[Transform Points]
  - Rotation Z: -180 ~ +180           ← 랜덤 회전
  - Scale: 0.8 ~ 1.2                  ← 크기 랜덤
     ↓
[Self Pruning]                        ← 겹치는 나무 제거
  - LargeToSmall 모드
     ↓
[Static Mesh Spawner]                 ← 나무 메시 등록
     ↓
[Output Node]
```

---

## Spline 기반 배치 방법

### A. 스플라인 옆에 울타리/가로등

```
[Spline Sampler]
  - Dimension: OnSpline
  - Mode: Distance
  - Distance: 400cm (4m마다 1개)
  ↓
[Transform Points]
  ↓
[Static Mesh Spawner] — 가로등 메시
```

### B. 스플라인 내부 면적 채우기

```
[Spline Sampler]
  - Dimension: OnInterior
  - Points Per Squared Meter: 0.05
  ↓
[Self Pruning]
  ↓
[Static Mesh Spawner]
```

### C. Grammar 기반 세분화

`PCGSelectGrammar` 노드로 위치마다 다른 메시 선택 가능
- 예: 모서리엔 기둥, 직선엔 벽, 출입구엔 게이트

---

## PCGComponent 주요 설정

| 항목 | 설명 |
|------|------|
| `Seed` | 랜덤 시드값. 숫자 바꾸면 배치 패턴 변경 |
| `Is Partitioned` | 월드 파티션 레벨에서 그리드 단위로 나눠 생성 |
| `Generation Trigger` | `GenerateOnLoad` / `GenerateOnDemand` / `GenerateAtRuntime` |
| `GenerationRadii` | 런타임 생성 반경 |

---

## 성능 고려사항

| 사항 | 설명 |
|------|------|
| **Static Mesh Spawner 우선** | ISM/HISM 자동 사용 → 드로 콜 최소화. Spawn Actor 대신 사용 권장 |
| **Is Partitioned** | 대규모 오픈월드라면 필수 활성화 |
| **GenerateAtRuntime** | 플레이어 주변 반경 안에서만 생성/정리 반복 |
| **GPU 실행** | Transform Points 등 일부 노드는 `Execute On GPU` 지원 |
| **Self Pruning 순서** | Pruning 전에 Filter로 포인트 수를 미리 줄일 것 |

---

## 아티스트 체크리스트

### 그래프 설계 전
- [ ] 배치 표면이 Landscape인지, Spline인지, Volume인지 확인
- [ ] 밀도(m²당 개수)와 최소 간격(Extents) 대략 계산
- [ ] Landscape Layer로 구역을 구분할지 결정
- [ ] Static Mesh 배치인지, Actor 배치인지 결정 (가능하면 Mesh 우선)

### 그래프 작성 시
- [ ] Sampler → Filter → Transform → Spawner 순서 유지
- [ ] `Point Extents`를 배치할 오브젝트 크기에 맞게 설정
- [ ] Transform Points에서 Z 회전 범위 설정 (단조로움 방지)
- [ ] Self Pruning으로 겹침 제거 (LargeToSmall 추천)
- [ ] 그래프 파라미터(UserParameters)에 노출할 수치 등록

### 배치 결과 확인
- [ ] 그래프 에디터에서 각 노드 클릭 → 디버그 뷰로 포인트 수 확인
- [ ] Self Pruning 후 포인트가 너무 적으면 Extents 값 줄이기
- [ ] 메시가 지형 아래로 꺼지면 높이 오프셋 조정

### 최적화
- [ ] Spawn Actor 대신 Static Mesh Spawner 사용 여부 재확인
- [ ] 오픈월드라면 `Is Partitioned` + `GenerateAtRuntime` 조합 적용
- [ ] 같은 메시 변형은 한 Static Mesh Spawner에 복수 등록 (랜덤 선택)
