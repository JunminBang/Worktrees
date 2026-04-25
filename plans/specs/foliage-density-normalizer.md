# 기획서 — Foliage Density & Masked Cost Auditor

> 작성일: 2026-04-25  
> 수정일: 2026-04-26 (Masked 재질 비용 분석 통합)  
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

## 분석 탭 구성

도구는 두 개의 분석 탭으로 구성된다.

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
| Masked 메시 목록 수집 | 레벨 내 Masked 재질 사용 폴리지 전체 열거 |
| Cast Shadow 감사 | Masked + Cast Shadow ON 인스턴스 수 집계 → 불필요한 그림자 후보 탐지 |
| Opacity Mask Instruction 수집 | 머티리얼별 Shader Stats에서 Instruction 수 추출 |
| 원거리 Masked 탐지 | 지정 거리(기본: 5000 UU) 이상 배치된 Masked 메시 목록 |
| Two-Sided Foliage 미설정 탐지 | Masked 폴리지 중 Two-Sided Foliage 셰이딩 모델 미사용 메시 |
| Masked 밀도 오버레이 | 탭 A 힌트맵 위에 Masked 인스턴스 밀도를 레이어로 오버레이 |

---

## 자동 제안 목록

| 감지 패턴 | 제안 |
|---|---|
| 밀도 과밀 구간 | 삭제 후보 수량 제시 |
| 밀도 과소 구간 | 추가 권장 수량 제시 |
| Masked + Cast Shadow ON + 소형 메시 | 그림자 비활성화 후보 (잔디, 작은 잎류) |
| 원거리 Masked 메시 | Dithered LOD → Opaque Imposter 전환 후보 |
| Opacity Mask Instruction 50개 이상 | 마스크 단순화 검토 대상 |
| Masked + Two-Sided 미설정 | Two-Sided Foliage 셰이딩 모델 전환 후보 |
| Masked 과밀 구간 (밀도 × Instruction 곱 기준) | Masked 비용 핫스팟으로 우선 최적화 대상 지목 |

---

## 구현 방향

- `AInstancedFoliageActor` 순회로 인스턴스 위치 / 재질 / Cast Shadow 수집
- 월드 바운드 기준 그리드 분할 (기본 셀 크기: 1000 UU)
- 머티리얼 블렌드 모드 `BLEND_Masked` 여부로 Masked 메시 필터링
- Opacity Mask Instruction 수: `UMaterial::GetMaterialResource()->GetNumInstructions()` 또는 `stat ShaderCompiling` 경유
- Two-Sided Foliage 셰이딩 모델: `UMaterial::ShadingModel == MSM_TwoSidedFoliage` 확인
- 힌트맵: 밀도 레이어(파란색) + Masked 밀도 레이어(빨간색) 오버레이
- 수십만 인스턴스 순회는 비동기 처리
- Editor Utility Widget으로 파라미터 조정

---

## 입출력

**입력**
- 대상 레벨
- 셀 크기 (기본값: 1000 UU)
- 밀도 편차 임계값 (기본값: ±30%)
- 원거리 Masked 탐지 거리 (기본값: 5000 UU)
- Opacity Mask Instruction 경고 임계값 (기본값: 50개)
- 폴리지 타입 필터 (선택)

**출력**
- Viewport 오버레이 힌트맵 (밀도 + Masked 레이어)
- 에디터 내 결과 패널 (탭 A / 탭 B / 제안 목록)
- `Saved/FoliageReport_레벨명_YYYYMMDD.csv`

---

## 제약 / 리스크

- 인스턴스 수가 수십만 개일 경우 순회 성능 이슈 → 비동기 처리 필수
- World Partition 환경에서는 로드된 셀 범위에서만 측정 가능
- Opacity Mask Instruction 수는 셰이더 컴파일 후에만 정확히 수집 가능

---

## 완료 기준

- [ ] 탭 A: 그리드 밀도 측정 + 과밀/과소 탐지 + 힌트맵
- [ ] 탭 B: Masked 메시 목록 + Cast Shadow 감사 + Instruction 수집
- [ ] 탭 B: 원거리 Masked / Two-Sided 미설정 탐지
- [ ] Masked 밀도 오버레이 (힌트맵 레이어)
- [ ] 자동 제안 목록 출력
- [ ] CSV 리포트 저장
- [ ] wiki에 패턴 ingest
