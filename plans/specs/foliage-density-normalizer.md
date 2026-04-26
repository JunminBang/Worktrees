# 기획서 — Foliage Density & Masked Cost Auditor

> 작성일: 2026-04-25  
> 수정일: 2026-04-26 (아키텍트 검수 반영)  
> 카테고리: 월드 빌딩 / 퍼포먼스 프로파일링  
> 우선순위: 중

---

## 개요

레벨을 구역(그리드 셀)으로 나눠 폴리지 밀도를 측정하고, Masked 재질 비용(EarlyZ 제외, 그림자 비용, 셰이더 복잡도)을 함께 분석해 밀도 균등화 제안과 Masked 최적화 후보를 동시에 출력하는 에디터 유틸리티.

---

## 문제 정의

- 작업자마다 폴리지를 칠하는 습관이 달라 레벨 일부 구역이 과밀하거나 과소해진다.
- 자연물에 주로 쓰이는 Masked 재질은 EarlyZ에서 제외되어 가려진 픽셀도 픽셀 셰이더를 실행 → 밀도가 높을수록 Overdraw 비용이 급격히 증가한다.
- Masked 폴리지의 그림자는 픽셀별 클립 테스트가 필요해 Opaque보다 Shadow Depth Pass 비용이 크다.
- 육안으로 밀도 분포와 Masked 비용 구간을 동시에 파악하기 어렵다.

---

## 목표

- 레벨 전체 폴리지 밀도 분포 수치화 + 편차 구간 탐지
- Masked 재질 비용 핫스팟 구간 탐지
- 밀도 균등화 제안과 Masked 최적화 후보를 하나의 리포트로 출력

---

## 수집 범위 (인스턴스 소스)

> ⚠️ `AInstancedFoliageActor` 단독 순회로는 누락이 발생한다. 아래 3가지를 모두 수집해야 한다.

| 소스 | 수집 방법 | 비고 |
|---|---|---|
| `AInstancedFoliageActor::FoliageInfos` | TActorIterator | Foliage Mode로 배치된 인스턴스 |
| `UHierarchicalInstancedStaticMeshComponent` | TObjectIterator | 아티스트가 BP로 직접 배치한 풀숲 등 |
| `AProceduralFoliageVolume` | TActorIterator | Procedural Foliage Spawner 생성 인스턴스 |
| `ULandscapeGrassType` | **1차 릴리스 제외** | GPU-side 인스턴스 — 위치 기반 측정 불가 |
| PCG Component 인스턴스 | **1차 릴리스 제외** | PCG는 별도 스코프 |

---

## 분석 탭 구성

### 탭 A — 밀도 분석

| 기능 | 설명 |
|---|---|
| 그리드 분할 측정 | 레벨을 N×N 셀로 나눠 셀당 폴리지 인스턴스 수 집계 |
| 편차 탐지 | 평균 대비 ±X% 초과 구간 강조 |
| 밀도 힌트맵 | 밀도 히트맵을 Viewport 오버레이 또는 이미지로 저장 |
| 균등화 제안 | 과밀 구간 → 삭제 후보 수량, 과소 구간 → 추가 권장 수량 |
| 폴리지 타입 필터 | 특정 Static Mesh 종류만 선택해 분석 |

### 탭 B — Masked 비용 분석

| 기능 | 설명 |
|---|---|
| Masked 메시 목록 수집 | `UMaterialInterface::GetBlendMode() == BLEND_Masked` 기준. MID/OverrideMaterials 우선순위 적용 |
| Cast Shadow 감사 | FoliageType → HISMC → StaticMesh → 머티리얼 **4계층 AND** 체크 후 판정 |
| 원거리 Masked 탐지 | 지정 거리(기본: 5000 UU) 이상 + Cull Distance 밖 인스턴스 제외 |
| Two-Sided Foliage 미설정 탐지 | `GetShadingModels().HasShadingModel(MSM_TwoSidedFoliage)` — MI 오버라이드 포함 |
| Masked 밀도 오버레이 | 탭 A 힌트맵 위에 Masked 인스턴스 밀도를 레이어로 오버레이 |
| Pixel Shader Instruction 수집 | **2차 릴리스** — `FMaterialStatsUtils` + 컴파일 완료 폴링 필요 |

---

## 머티리얼 조회 우선순위

```
FoliageType.OverrideMaterials
  → StaticMesh.StaticMaterials
    → Default Material
```

---

## 자동 제안 목록

| 감지 패턴 | 제안 |
|---|---|
| 밀도 과밀 구간 | 삭제 후보 수량 제시 |
| 밀도 과소 구간 | 추가 권장 수량 제시 |
| Masked + Cast Shadow ON (4계층 AND) + 소형 메시 + 카메라 거리 밖 | 그림자 비활성화 후보 |
| 원거리 Masked 메시 (Cull Distance 이내) | Dithered LOD → Opaque Imposter 전환 후보 |
| Masked + Two-Sided 미설정 | Two-Sided Foliage 셰이딩 모델 전환 후보 |
| Masked 과밀 구간 (밀도 × 화면 점유 면적 기준) | Masked 비용 핫스팟으로 우선 최적화 대상 지목 |

---

## 구현 단계 (Phase)

> ⚠️ 기획서 완료 기준 순서와 **역순**으로 구현하는 것이 안전하다.

### Phase 1 — 데이터 수집 레이어
1. IFA + HISMC + ProceduralFoliage 통합 enumerator
2. HLOD Actor(`AWorldPartitionHLOD`) 필터 제외

### Phase 2 — 머티리얼 메타 수집
3. Blend Mode, ShadingModel(`GetShadingModels()`), Cast Shadow 4계층 체크
4. 머티리얼 조회 우선순위 적용 (OverrideMaterials → StaticMaterials)

### Phase 3 — 탭 B (Masked 정성 분석, Instruction 제외)
5. Cast Shadow 감사, Two-Sided 미설정 탐지, 원거리 Masked 탐지

### Phase 4 — 탭 A (밀도 그리드)
6. 그리드 분할, 평균/편차, 힌트맵

### Phase 5 — UI / CSV / 오버레이
7. Editor Utility Widget, Masked 밀도 오버레이, CSV 저장

### Phase 6 — Instruction 수집 (2차 릴리스)
8. `FMaterialStatsUtils::GetRepresentativeInstructionCounts()` + `FMaterial::IsCompilationFinished()` 폴링
9. 임계값: Pixel Shader 전체 Instruction 100개 이상 (50은 평범한 PBR도 80+ → 오탐 과다)

---

## 입출력

**입력**
- 대상 레벨
- 셀 크기 (기본값: 1000 UU)
- 밀도 편차 임계값 (기본값: ±30%)
- 원거리 Masked 탐지 거리 (기본값: 5000 UU)
- 폴리지 타입 필터 (선택)

**출력**
- Viewport 오버레이 힌트맵 (밀도 + Masked 레이어)
- 에디터 내 결과 패널 (탭 A / 탭 B / 제안 목록)
- `Saved/FoliageReport_레벨명_YYYYMMDD.csv`

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| Landscape Grass Type | GPU-side 인스턴스 — 위치 기반 측정 불가. 1차 릴리스 스코프 외 |
| World Partition | 현재 로드된 셀 범위에서만 측정 가능. "현재 로드 영역" 명시 필수 |
| 인스턴스 수십만 개 | 비동기 처리 필수 |
| Instruction 수집 | 셰이더 컴파일 완료 후에만 정확. 2차 릴리스로 분리 |
| PCG 인스턴스 | 1차 릴리스 스코프 외 |

---

## 완료 기준

- [ ] Phase 1: IFA + HISMC + ProceduralFoliage 통합 수집
- [ ] Phase 2: 머티리얼 메타 수집 (4계층 Cast Shadow 포함)
- [ ] Phase 3: 탭 B Masked 정성 분석
- [ ] Phase 4: 탭 A 그리드 밀도 측정
- [ ] Phase 5: Masked 오버레이 + CSV 저장 + Editor Utility Widget
- [ ] wiki에 패턴 ingest
- [ ] Phase 6 (2차): Instruction 수집 + 임계값 적용
