# 랜드스케이프 심화 — 레이어, 페인팅, 머티리얼, 최적화

> 소스 경로: Runtime/Landscape/Public/Landscape.h, LandscapeComponent.h
> 아티스트를 위한 설명

---

## 랜드스케이프 개요

랜드스케이프(Landscape)는 **대규모 야외 지형을 만드는 전용 시스템**입니다. 일반 스태틱 메시와 달리 높이맵 기반으로 동작하며, 자동 LOD·콜리전·머티리얼 레이어 시스템이 내장되어 있습니다.

---

## 랜드스케이프 생성 & 크기 선택

### 권장 크기 (컴포넌트 수 × 섹션 크기)

| 크기 | 버텍스 수 | 권장 사용 |
|------|---------|---------|
| 127×127 | 16K | 소규모 레벨 |
| 253×253 | 64K | 중규모 |
| 505×505 | 256K | 대규모 오픈 월드 |
| 1009×1009 | 1M | 초대형 (World Partition 필요) |

> **팁:** 크기를 `(n×컴포넌트 크기) - 1` 공식으로 선택해야 UV와 LOD가 정확히 맞습니다. 에디터에서 권장값으로 자동 제안됩니다.

---

## 높이맵 임포트/익스포트

### 임포트
1. Landscape 모드 → **Import from File**
2. 16비트 PNG 또는 RAW 파일 지원
3. 크기가 랜드스케이프 버텍스 수와 일치해야 함

### 익스포트
1. Landscape 모드 → 선택 → **Export to File**
2. 16비트 PNG로 내보내기 → Houdini/World Creator 등 DCC 툴에서 편집 후 재임포트

---

## 스컬프트 툴

| 툴 | 설명 |
|----|------|
| `Sculpt` | 기본 높이 올리기/내리기 |
| `Smooth` | 울퉁불퉁한 지형 부드럽게 |
| `Flatten` | 특정 높이로 평탄화 |
| `Ramp` | 두 점 사이 경사로 생성 |
| `Erosion` | 침식 효과 (물/열 침식) |
| `Hydro Erosion` | 물 흐름 침식 시뮬레이션 |
| `Noise` | 노이즈 기반 불규칙 표면 |
| `Retopologize` | UV 왜곡 없이 버텍스 재분배 |
| `Visibility` | 구멍 뚫기 (동굴 입구 등) |

---

## 랜드스케이프 머티리얼 레이어 시스템

랜드스케이프는 **여러 머티리얼 레이어를 페인팅**해 지형 표면을 표현합니다.

### 레이어 구성 개념

```
랜드스케이프 머티리얼
  ├─ Layer 0: Grass    (풀밭)
  ├─ Layer 1: Rock     (바위)
  ├─ Layer 2: Dirt     (흙길)
  ├─ Layer 3: Snow     (설원)
  └─ Layer 4: Sand     (모래)

각 레이어: BaseColor + Normal + Roughness + AO 텍스처 세트
혼합 방식: LandscapeLayerBlend 노드
```

### 머티리얼 설정 방법

1. 새 머티리얼 생성 (Domain = Surface)
2. `LandscapeLayerBlend` 노드 추가
3. 레이어 배열에 레이어 이름 추가 (예: `"Grass"`, `"Rock"`)
4. 각 레이어에 텍스처 세트 연결
5. 블렌드 타입 선택:
   - `LB_WeightBlend`: 가중치 기반 (기본값)
   - `LB_AlphaBlend`: 알파 기반 (레이어 간 날카로운 경계)
   - `LB_HeightBlend`: 높이맵 기반 자연스러운 혼합 (가장 자연스러움)

---

## 페인트 모드 — 레이어 페인팅

### 레이어 인포 에셋 생성

랜드스케이프 페인팅 전 레이어 인포 에셋이 필요합니다:

1. Landscape 모드 → **Paint 탭**
2. 레이어 목록에서 레이어 옆 `+` 클릭
3. **Weight-Blended Layer (Normal)** 선택
4. 저장 위치 지정 → `.uasset` 생성

### 페인트 툴

| 툴 | 설명 |
|----|------|
| `Paint` | 레이어 가중치 칠하기 |
| `Smooth` | 레이어 경계 부드럽게 |
| `Flatten` | 특정 가중치로 평탄화 |
| `Noise` | 노이즈 기반 자연스러운 혼합 |

### 브러시 설정

| 설정 | 설명 |
|------|------|
| `Brush Size` | 브러시 반경 |
| `Brush Falloff` | 브러시 경계 페이드 |
| `Tool Strength` | 페인팅 강도 |
| `Use Layer Info` | 레이어 인포 에셋 선택 |

---

## LandscapeLayerCoords — UV 타일링 제어

각 레이어의 텍스처 반복 배율을 제어합니다:

| 프로퍼티 | 설명 |
|---------|------|
| `Mapping Type` | XY Offset / Auto / Custom |
| `Custom UVType` | 텍스처 좌표 방식 |
| `Repeat Size` | 텍스처가 반복되는 월드 크기 (cm) |

---

## 랜드스케이프 LOD

랜드스케이프는 **자동으로 거리별 LOD**를 적용합니다.

| 프로퍼티 | 설명 |
|---------|------|
| `LOD Bias` | LOD 전환 거리 조정 (양수=더 빠른 LOD 전환) |
| `LOD Distance Factor` | 전체 LOD 거리 배율 |
| `Max LOD Level` | 최대 LOD 레벨 제한 |

---

## 런타임 버추얼 텍스처 (RVT) 연동

랜드스케이프 위에 도로, 웅덩이, 발자국 등을 **데칼처럼 블렌딩**하려면 RVT를 사용합니다:

1. `RuntimeVirtualTexture` 에셋 생성
2. 랜드스케이프 → Details → `Runtime Virtual Textures` 배열에 추가
3. 도로/웅덩이 머티리얼에서 `RuntimeVirtualTextureSample` 노드로 출력
4. 랜드스케이프 머티리얼에서 RVT 입력으로 최종 혼합

---

## 폴리지와 자동 연동

랜드스케이프 레이어에 따라 폴리지를 자동 배치할 수 있습니다:

1. **Foliage 모드** 활성화
2. 폴리지 타입 추가 → Details → `Landscape Layers` 설정
3. 풀 레이어 위에만 풀 폴리지, 바위 레이어 위에만 이끼 배치 가능

---

## 랜드스케이프 최적화

| 최적화 | 설명 |
|--------|------|
| `Nanite` 활성화 | 랜드스케이프 Nanite ON → 고해상도 지형 저비용 렌더링 |
| LOD Distance Factor | 원거리 LOD 전환 거리 단축 |
| 섹션 크기 최소화 | 컴포넌트 수 × 섹션 크기 조정으로 드로우콜 최적화 |
| Grass 시스템 | 폴리지 대신 LandscapeGrass 사용 (인스턴스 자동 관리) |
| HLOD | World Partition HLOD로 원거리 지형 단순화 |

---

## 아티스트 체크리스트

### 지형 제작 시
- [ ] 랜드스케이프 크기가 `(n×컴포넌트) - 1` 공식에 맞는가?
- [ ] 높이맵이 16비트 PNG 포맷인가?
- [ ] 스컬프트 후 Smooth 처리로 날카로운 경계를 제거했는가?

### 머티리얼 레이어 설정 시
- [ ] LandscapeLayerBlend 노드에 모든 레이어가 등록되어 있는가?
- [ ] 레이어 이름이 페인트 모드의 레이어 인포 이름과 정확히 일치하는가?
- [ ] `LB_HeightBlend`로 레이어 경계가 자연스러운가?
- [ ] 레이어 텍스처의 Repeat Size가 지형 스케일에 맞는가?

### 성능
- [ ] Nanite가 활성화되어 있는가?
- [ ] 폴리지 밀도가 프레임 예산 안에 있는가?
- [ ] 레이어 수가 5개 이하인가? (많을수록 셰이더 복잡도 증가)

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [43_foliage_system.md](43_foliage_system.md) | Foliage — 랜드스케이프 레이어 연동 자동 식생 배치 |
| [11_pcg_procedural.md](11_pcg_procedural.md) | PCG — 높이맵·경사 데이터 기반 절차적 오브젝트 배치 |
| [40_world_partition.md](40_world_partition.md) | World Partition — 대형 랜드스케이프 셀 스트리밍 및 HLOD |
| [24_material_advanced.md](24_material_advanced.md) | 머티리얼 레이어 — LandscapeLayerBlend와 Material Layer 통합 |
| [25_lighting_system.md](25_lighting_system.md) | 야외 Directional Light + Sky Light — 지형 조명 셋업 |
| [14_textures_advanced.md](14_textures_advanced.md) | Runtime Virtual Texture — 도로·데칼을 랜드스케이프에 블렌딩 |
