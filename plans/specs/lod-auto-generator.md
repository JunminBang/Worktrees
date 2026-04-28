# 기획서 — LOD Auto Generator

> 작성일: 2026-04-26  
> 수정일: 2026-04-26 (어드바이저 검수 반영)  
> 카테고리: 에셋 파이프라인  
> 우선순위: 중간

---

## 개요

LOD가 미설정된 StaticMesh 에셋에 LOD를 일괄 자동 생성하는 에디터 유틸리티.  
신규 임포트 에셋뿐 아니라 기존 LOD 미설정 메시 전체를 한 번에 처리할 수 있다.  
**드라이런 + 승인 게이트 포함 — 실제 변경은 사용자 확인 후 진행.**

---

## 문제 정의

- 메시마다 수동으로 LOD를 설정하면 기준이 달라지고 시간도 많이 걸린다.
- LOD 없는 메시가 씬에 다수 배치되면 드로우콜과 폴리곤 예산을 초과한다.
- 아티스트가 LOD Reduction 기준을 모르거나 무시하고 임포트하는 경우가 잦다.

---

## 목표

- `/Game/` 또는 지정 경로의 LOD 미설정 StaticMesh에 LOD 일괄 자동 생성
- Nanite/HLOD 메시 자동 제외 (손상 방지)
- 드라이런으로 후보 목록 먼저 확인 후 배치 실행
- 결과 리포트 출력

---

## 대상 선정 기준

### 포함 (처리 대상)
- `UStaticMesh::GetNumSourceModels() == 1` (자동·커스텀 LOD 없음)
- SourceModel LOD0의 MeshDescription이 유효함 (Cooked-only 메시 제외)
- 버텍스 수 ≥ 50 (설정 가능) — MeshDescription 기반 카운트

### 제외 (스킵)
- `NaniteSettings.bEnabled == true` — Nanite 메시는 클러스터 LOD 자체 사용, 기본 제외  
  (옵션: `--include-nanite-fallback` 활성 시 Fallback Mesh 전용 처리)
- `/Game/HLOD/` 경로 — World Partition HLOD 프록시 메시
- `/Engine/`, `/Game/Developers/`, 플러그인 경로
- LOD 이미 있는 메시 (`GetNumSourceModels() > 1`) — 덮어쓰기 기본 OFF
- `IsRawMeshEmpty()` 또는 MeshDescription 유효성 실패

---

## LOD 기준 프리셋

### 공통 설정

| LOD | ScreenSize | 누적 감소율 | 설명 |
|---|---|---|---|
| LOD0 | 1.0 | 0% | 원본 |
| LOD1 | 0.30 | 50% | 중간 거리 |
| LOD2 | 0.10 | 75% | 먼 거리 |
| LOD3 | 0.05 | 90% | 최원거리 |
| LOD4 | 0.02 | 95% | 초원거리 |

### 프리셋 3종

| 프리셋 | 포함 LOD | 주 사용 케이스 |
|---|---|---|
| `Small` | LOD0~2 | 소품, 장식물 (버텍스 < 1000) |
| `Medium` | LOD0~3 | 일반 배경 메시 (버텍스 1000~10000) |
| `Large` | LOD0~4 | 대형 배경, 건물 (버텍스 > 10000) |

> 감소율은 PercentTriangles 기준.  
> 머티리얼 슬롯이 2개 이상인 메시는 감소율을 각 프리셋에서 10%p 완화(오탐 방지).  
> Lightmap UV(채널 1)는 LOD별 `bGenerateLightmapUVs = true` 유지.

---

## 구현 방향

```
모듈 의존성 (Build.cs PrivateDependencyModuleNames):
  "AssetRegistry", "AssetTools", "UnrealEd",
  "MeshUtilities", "MeshReductionInterface",
  "MeshDescription", "StaticMeshDescription",
  "Slate", "SlateCore", "ToolMenus"

[패스 1 — 드라이런: 후보 목록 수집]
1. IAssetRegistry::Get().WaitForCompletion() (미스캔 방지)
2. GetAssets(Filter): ClassPaths = /Script/Engine.StaticMesh, bRecursiveClasses=true
   제외 경로 필터링
3. 각 메시에 대해:
   - GetNumSourceModels() == 1 체크
   - NaniteSettings.bEnabled 체크 → Nanite 메시 분리
   - MeshDescription 유효성 체크 (GetMeshDescription(0) != nullptr)
   - 버텍스 수 하한 체크
4. 후보 목록 → 에디터 패널 표시 + 드라이런 CSV 출력
   → 사용자 확인 후 [배치 실행] 버튼 클릭 시에만 패스 2 진행

[패스 2 — 배치 LOD 생성]
5. ISourceControlModule로 사전 체크아웃 시도
   → 실패 메시: 별도 "체크아웃 실패" 목록으로 분리
6. 각 메시에 대해 FScopedTransaction:
   a. UStaticMesh::SetNumSourceModels(N) — 프리셋 LOD 수
   b. 각 LOD 슬롯: GetSourceModel(i).ReductionSettings 설정
      - PercentTriangles 설정
      - ScreenSize 설정
      - bGenerateLightmapUVs = true
   c. UStaticMesh::Build()  ← 내부적으로 IMeshReductionInterface 호출
   d. UStaticMesh::MarkPackageDirty()
   e. 빌드 성공 시 SaveAsset
7. N개(기본: 20)마다 FAssetCompilingManager::Get().FinishAllCompilation()
   → 메모리 스파이크 방지
8. MinLOD(FPerPlatformInt) 검증: 0이 아닌 값 발견 시 경고 리포트
9. FScopedSlowTask + 취소 지원 (취소 시 미처리 메시는 건드리지 않음)

[패스 3 — 결과 집계]
10. 성공 / 스킵(Nanite/HLOD/이미있음) / 실패 / 체크아웃 실패 집계
11. 에디터 패널 업데이트
12. CSV 저장
```

---

## 에디터 패널 구성

```
[드라이런 스캔] 버튼  |  [배치 실행] 버튼 (드라이런 후 활성화)  |  [취소] 버튼

드라이런 결과: 후보 142개 | Nanite 제외 38개 | 이미 LOD 있음 21개

[배치 실행 전 반드시 후보 목록을 확인하세요]

[탭: 처리 후보] [탭: Nanite 제외] [탭: 스킵] [탭: 결과]

──────────────────────────────────────────────────────────────
메시명              | 버텍스 수 | 프리셋   | 머티리얼 수 | 상태
──────────────────────────────────────────────────────────────
SM_Rock_Large       | 4,210    | Medium  | 1          | 후보
SM_Tree_01          | 8,890    | Large   | 3          | 후보 (완화율)
SM_Char_Body        | Nanite   | -       | 4          | 스킵 (Nanite)
──────────────────────────────────────────────────────────────

클릭 → Content Browser에서 선택
```

---

## 입출력

**입력**
- 스캔 경로 (기본: `/Game/`)
- 프리셋 (Small / Medium / Large) — 수동 지정 또는 버텍스 수 기준 자동 선택
- 덮어쓰기 허용 여부 (기본: OFF)
- 버텍스 수 하한 (기본: 50)
- Nanite Fallback 처리 포함 (기본: OFF)
- 청크 크기 (기본: 20개)

**출력**
- 에디터 결과 패널 (드라이런 → 승인 → 배치 실행 흐름)
- `Saved/LODDryRun_YYYYMMDD_HHmmss.csv` (드라이런 후보 목록)
- `Saved/LODReport_YYYYMMDD_HHmmss.csv` (배치 실행 결과)
  - 컬럼: PackagePath / MeshName / VertexCount / Preset / LODsGenerated / Status / Notes

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| Nanite 메시 | `NaniteSettings.bEnabled == true` 시 기본 스킵. 강제 적용 시 Fallback Mesh와 혼선 위험 |
| Cooked-only 메시 | SourceModel 없는 메시는 `Build()` 실패 → MeshDescription 유효성 선행 체크 |
| MinLOD per-platform | FPerPlatformInt가 0 이상이면 새 LOD가 런타임 미출력 — 생성 후 경고 표시 |
| 소스 컨트롤 | 체크아웃 실패 메시 건너뜀, 별도 목록 리포트 |
| Build() 비용 | 메시당 수백ms~수초 — 청크 단위 처리 + FAssetCompilingManager |
| AssetRegistry 초기화 | WaitForCompletion() 미호출 시 누락 에셋 발생 |
| 머티리얼 슬롯 | 다중 머티리얼 메시에서 reduction 후 슬롯 매핑 깨짐 가능 — 감소율 완화 + 리포트 |

---

## 완료 기준

### 1차 릴리스
- [ ] IAssetRegistry 기반 StaticMesh 목록 수집 (WaitForCompletion, 제외 경로)
- [ ] 대상 선정: `GetNumSourceModels() == 1` + MeshDescription 유효성 + 버텍스 수 하한
- [ ] Nanite 메시 자동 제외 (`NaniteSettings.bEnabled`) + HLOD 경로 제외
- [ ] 드라이런 패스 + 후보 CSV 출력 + 승인 게이트
- [ ] FMeshReductionSettings 기반 프리셋 3종 LOD 자동 생성
- [ ] `SetNumSourceModels` → `ReductionSettings` → `Build()` → `MarkPackageDirty()` → 저장
- [ ] `bGenerateLightmapUVs = true` 유지
- [ ] 다중 머티리얼 메시 감소율 완화
- [ ] MinLOD 검증 + 경고
- [ ] 소스 컨트롤 사전 체크아웃 + 실패 메시 분리
- [ ] FScopedTransaction per mesh
- [ ] 청크 단위 처리 + FAssetCompilingManager::FinishAllCompilation
- [ ] FScopedSlowTask + 취소 버튼
- [ ] 에디터 패널 (드라이런 탭 + 결과 탭, 클릭 → Content Browser)
- [ ] 드라이런 CSV + 결과 CSV 출력

### 2차 릴리스
- [ ] 버텍스 수 기준 프리셋 자동 선택
- [ ] Nanite Fallback Mesh 전용 처리 옵션
- [ ] 메시 유형(동적/정적, 스키닝 여부) 감지 후 프리셋 자동 보정
- [ ] 롤백 매니페스트 (oldSourceModels 스냅샷)
