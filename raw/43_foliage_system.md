# Foliage 시스템 — 식생 배치 & 인스턴싱

> 소스 경로: Runtime/Foliage/Public/FoliageType.h, InstancedFoliageActor.h
> 아티스트를 위한 설명

---

## Foliage 시스템 개요

Foliage(폴리지) 시스템은 **나무, 풀, 꽃, 바위 등 반복 배치되는 자연물을 대량으로 효율적으로 배치**하는 도구입니다. 수동 배치 대신 페인팅 방식으로 수천 개를 빠르게 배치하며, 내부적으로 **Instanced Static Mesh(ISM)**를 사용해 드로우콜을 최소화합니다.

**비유:** 잔디 씨앗 뿌리기 — 하나씩 심는 것이 아니라 지면에 씨앗을 뿌리듯 페인팅으로 수천 개를 한 번에 배치합니다.

---

## Foliage 모드 진입

상단 모드 패널 → **Foliage** 아이콘 클릭 (또는 `Shift+3`)

---

## Foliage Type 에셋

`FoliageType` 에셋은 **어떤 메시를 어떤 규칙으로 배치할지 정의**하는 설정 파일입니다.

### 생성 방법
- Content Browser → 우클릭 → **Foliage → FoliageType_InstancedStaticMesh**
- 에셋 이름: `FT_` 접두사 권장 (예: `FT_GrassA`)

### 또는 드래그 앤 드롭
- Foliage 모드에서 Static Mesh 에셋을 패널에 드래그 → 자동으로 FoliageType 생성

---

## 배치 규칙 설정

### Painting 탭

| 프로퍼티 | 설명 |
|---------|------|
| `Density` | 단위 면적당 배치 밀도 (높을수록 촘촘) |
| `Radius` | 같은 타입 인스턴스 간 최소 거리 |
| `Align to Normal` | 지면 법선 방향에 맞춰 기울기 적용 |
| `Max Angle` | 지면 기울기 최대 허용 각도 (경사면 제한) |
| `Reapply Density` | 재도색 시 밀도 재적용 |

### Placement 탭

| 프로퍼티 | 설명 |
|---------|------|
| `Z Offset Min/Max` | 수직 오프셋 범위 (땅 속 박힘 방지) |
| `Random Yaw` | 수직축 랜덤 회전 (다양한 방향) |
| `Random Pitch Angle` | 전후 기울기 랜덤 범위 |
| `Ground Slope Angle` | 배치 가능한 경사 각도 범위 |
| `Height Min/Max` | 배치 가능한 고도 범위 |
| `Landscape Layer` | 특정 랜드스케이프 레이어 위에만 배치 |

### Scaling 탭

| 프로퍼티 | 설명 |
|---------|------|
| `Scale X/Y/Z Min/Max` | 각 축 랜덤 스케일 범위 |
| `Uniform Scale` | 균일 스케일 (비율 유지) |

---

## 페인팅 도구

| 도구 | 단축키 | 설명 |
|------|--------|------|
| `Paint` | 왼쪽 클릭 드래그 | 폴리지 추가 |
| `Erase` | Shift + 클릭 | 폴리지 제거 |
| `Reapply` | - | 선택 영역 규칙 재적용 |
| `Select` | - | 인스턴스 개별 선택 |
| `Lasso` | - | 올가미 선택 |
| `Fill` | - | 영역 전체 채우기 |

### 브러시 설정

| 설정 | 설명 |
|------|------|
| `Brush Size` | 페인팅 브러시 반경 |
| `Paint Density` | 한 번 칠할 때 밀도 |
| `Erase Density` | 지울 때 밀도 |

---

## Instanced Static Mesh (ISM) 최적화

폴리지는 같은 메시를 **Instanced Static Mesh(ISM)** 로 일괄 렌더링합니다.

| 일반 배치 | Foliage ISM |
|---------|-----------|
| 오브젝트 100개 = 드로우콜 100개 | 오브젝트 10,000개 = 드로우콜 1~몇 개 |

### HISM (Hierarchical ISM)

Foliage는 기본으로 **HISM**을 사용합니다:
- 카메라 거리별 자동 LOD 처리
- 컬링(화면 밖 인스턴스 제거) 자동화

---

## LOD 및 컬링 설정

| 프로퍼티 | 설명 |
|---------|------|
| `Cull Distance Min/Max` | 이 거리 밖에서 인스턴스 컬링 |
| `LOD Distance Scale` | 거리 기반 LOD 전환 배율 |
| `Cast Shadow` | 그림자 생성 여부 |
| `Receive Decals` | 데칼 받을지 여부 |

> **성능 팁:** 풀처럼 가까이 있을 때만 필요한 것은 `Cull Distance Max`를 3000~5000cm로 낮게 설정하세요.

---

## Landscape Layer 연동

특정 랜드스케이프 페인팅 레이어 위에만 폴리지를 자동 배치:

1. FoliageType → Placement → `Landscape Layers`
2. 레이어 이름 입력 (예: `"Grass"`)
3. 해당 레이어가 페인팅된 곳에만 폴리지 배치

---

## PCG와 Foliage 비교

| 방식 | 장점 | 단점 |
|------|------|------|
| **Foliage Tool** | 직관적 페인팅, 빠른 배치 | 수동 작업 |
| **PCG** | 규칙 기반 자동 배치 | 설정 복잡 |
| **Landscape Grass** | 랜드스케이프와 완전 자동 연동 | 제어 옵션 제한 |

---

## 아티스트 체크리스트

### 배치 규칙
- [ ] `Max Angle`로 절벽/경사면에 배치 방지 처리를 했는가?
- [ ] `Z Offset`으로 오브젝트가 지면에 박히지 않는가?
- [ ] `Random Yaw`가 켜져 있어 모든 인스턴스가 같은 방향을 보지 않는가?

### 성능
- [ ] `Cull Distance Max`가 적절히 설정되어 원거리 컬링이 되는가?
- [ ] 폴리지 메시에 LOD가 설정되어 있는가?
- [ ] `Cast Shadow`가 큰 나무 외 작은 풀에서는 OFF 처리되어 있는가?
- [ ] 화면에 동시 렌더링되는 인스턴스 수를 확인했는가?

### Landscape 연동
- [ ] Landscape Layer 이름이 랜드스케이프 머티리얼 레이어 이름과 일치하는가?
- [ ] 눈/모래 레이어 위에 풀이 자라지 않도록 설정했는가?
