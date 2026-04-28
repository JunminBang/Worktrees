# 기획서 — Shader Complexity Visualizer

> 작성일: 2026-04-27  
> 수정일: 2026-04-27 (어드바이저 검수 반영)  
> 카테고리: 렌더링 / 머티리얼  
> 우선순위: 중간

---

## 개요

레벨 내 머티리얼의 셰이더 복잡도(인스트럭션 수·텍스처 샘플 수)를 분석해 최적화 후보를 리포트하는 에디터 유틸리티.

---

## 문제 정의

- 복잡한 머티리얼이 어디 있는지 알기 어렵다.
- 아티스트가 머티리얼 에디터에서 개별 확인해야 한다.
- Substrate 전환 이후 인스트럭션 수만으로 비용을 가늠하기 어렵다.

---

## 목표

- 레벨에서 사용 중인 머티리얼 집계 + 인스트럭션 수 / 텍스처 샘플 수 수집
- 복잡도 상위 N개 머티리얼 + 사용 메시 역추적
- Substrate 활성 여부 감지 + 별도 메트릭 표시

---

## 탐지 항목

| 체크 | 기준 | 심각도 |
|---|---|---|
| 고인스트럭션 머티리얼 | Base Pass Pixel 인스트럭션 수 > 300 (설정 가능) | 경고 |
| 텍스처 샘플 과다 | TextureSampler 수 > 16 | 경고 |
| Translucent 머티리얼 다수 | Blend Mode = Translucent인 머티리얼 수 > N (기본: 10, 참고용) | 정보 |
| Substrate 고비용 머티리얼 | Substrate 활성 시 ClosureCount > 4 또는 UintPerPixel > 설정값 | 정보 |

> **인스트럭션 수는 단일 값이 아니다**: 셰이더 종류(Base Pass Vertex/Pixel, Shadow Depth 등)마다 다르며  
> 플랫폼(SM5/SM6/ES3.1)에 따라서도 다르다.  
> 이 도구는 **현재 프로젝트의 주 타깃 플랫폼 + Base Pass Pixel**을 기준 표시값으로 사용한다.

---

## 인스트럭션 수 조회 방식

UE5.7에서 `FMaterialResource::GetInstructionCount()`는 공개 API가 아니다.  
정식 경로는 다음 두 가지 중 하나를 사용한다:

```
경로 A (권장): UMaterialEditingLibrary::GetStatistics(UMaterial*)
  → 에디터 유틸리티 라이브러리. 셰이더 종류별 인스트럭션 수 반환.
  → 의존 모듈: "MaterialEditor", "UnrealEd"

경로 B (fallback): FMaterialStatsUtils::GetRepresentativeInstructionCounts()
  → "MaterialStats" 에디터 모듈 내부. 정확하지만 사설 API 성격.
  → 버전 변경 시 깨질 위험 있음.
```

> Substrate 활성 시(`IsSubstrateEnabled()` 체크):  
> `SubstrateMaterialCompilationOutput::ClosureCount` / `UintPerPixel`을 추가로 수집.

---

## 머티리얼 수집 범위

`TActorIterator<AActor>` + `GetUsedMaterials()`는 기본 경로지만 다음을 추가 처리해야 한다:

| 컴포넌트 | 처리 방법 |
|---|---|
| `UStaticMeshComponent`, `USkeletalMeshComponent` | `GetUsedMaterials()` + `OverrideMaterials` 우선 |
| `UDecalComponent` | `GetDecalMaterial()` |
| `ULandscapeComponent` | `Landscape.h` 기반 별도 머티리얼 수집 |
| `UPostProcessComponent` | 볼륨 블렌더블 머티리얼 |
| `UNiagaraComponent` | 파티클 에미터 머티리얼 |
| `UWidgetComponent` | UI 머티리얼 |

→ `TSet<UMaterial*>` 중복 제거 후 분석 대상 확정.

---

## 구현 방향

```
모듈 의존성 (Build.cs PrivateDependencyModuleNames):
  "Engine", "UnrealEd", "MaterialEditor",
  "AssetRegistry", "Slate", "SlateCore", "ToolMenus"
  (에디터 전용 모듈 — Type: Editor, WITH_EDITOR 가드 필수)

[패스 1 — 머티리얼 수집]
1. GEditor->GetEditorWorldContext().World()
2. TActorIterator<AActor> + 컴포넌트별 머티리얼 수집 → TSet<UMaterial*>
3. MaterialInstance 사용 시 GetBaseMaterial() 로 루트 UMaterial 추적
4. 머티리얼별 "사용 메시 목록" 역매핑 TMap<UMaterial*, TArray<FString>> 구성

[패스 2 — 통계 수집]
5. IsSubstrateEnabled() 확인
6. 각 UMaterial에 대해:
   - UMaterialEditingLibrary::GetStatistics() → 인스트럭션 수 (경로 A)
   - 실패 시 TextureSamplerUsage 직접 카운트 (fallback)
   - Substrate 활성 시 ClosureCount/UintPerPixel 추가
7. FMaterialSample 레코드 생성

[패스 3 — 정렬 + 출력]
8. Base Pass Pixel 인스트럭션 기준 내림차순 정렬 → 상위 N개
9. 탐지 룰 적용 (경고/정보)
10. Content Browser 선택: FContentBrowserModule::SyncBrowserToAssets
11. CSV: {ProjectSaved}/ShaderReports/ShaderReport_YYYYMMDD_HHmmss_N.csv (UTF-8 BOM)
```

---

## 에디터 패널 구성

```
[스캔] 버튼  (현재 레벨 기준)

렌더링 환경: SM6 | Lumen ON | Substrate OFF
⚠ 인스트럭션 수는 Base Pass Pixel / 현재 타깃 플랫폼 기준입니다.

요약: 머티리얼 143개 | 경고 7개 | 정보 12개

[탭: 고인스트럭션] [탭: 텍스처 샘플] [탭: Translucent] [탭: Substrate] [탭: 전체]

─────────────────────────────────────────────────────────────────────
머티리얼명              | 인스트럭션 | 텍스처 | 사용 메시 수 | 이슈
─────────────────────────────────────────────────────────────────────
M_Rock_PBR              | 412       | 18     | 34           | 경고 (고인스트럭션, 과다 샘플)
M_WaterSurface          | 287       | 8      | 5            | -
M_GlassFX               | 155       | 4      | 12           | 정보 (Translucent)
─────────────────────────────────────────────────────────────────────

클릭 → Content Browser 포커스
```

---

## 입출력

**입력 (설정 가능)**
- 인스트럭션 수 경고 임계값 (기본: 300)
- 텍스처 샘플 경고 임계값 (기본: 16)
- Translucent 머티리얼 정보 임계값 (기본: 10)
- 상위 N개 표시 (기본: 20)

**출력**
- 에디터 패널 (탭별, 클릭 → Content Browser)
- `{ProjectSaved}/ShaderReports/ShaderReport_YYYYMMDD_HHmmss_N.csv` (UTF-8 BOM)
  - 컬럼: MaterialPath / BaseMaterial / InstructionCount / TextureSamplerCount / BlendMode / IsSubstrate / ClosureCount / UintPerPixel / UsedMeshCount / Issues

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| 공식 GetInstructionCount API 없음 | `UMaterialEditingLibrary::GetStatistics()` 우선. 실패 시 TextureSampler 카운트로 fallback |
| 인스트럭션 수 = 다차원 | Base Pass Pixel 기준만 표시. 다른 셰이더 종류 생략 명시 |
| Substrate 별도 메트릭 | `IsSubstrateEnabled()` 분기. 없으면 Legacy 경로만 |
| 에디터 전용 | `WITH_EDITOR` 가드 + 에디터 모듈 한정 |
| 셰이더 미컴파일 머티리얼 | 컴파일 전 머티리얼은 인스트럭션 수 0 또는 N/A로 표시 |
| World Partition 미로드 | 로드된 메시 기준. 배너 표시 |

---

## 완료 기준

### 1차 릴리스
- [ ] 컴포넌트별 머티리얼 수집 (SM/SKM/Decal/Landscape/PostProcess/Niagara/Widget)
- [ ] `GetUsedMaterials()` + `OverrideMaterials` 우선 적용
- [ ] `UMaterialEditingLibrary::GetStatistics()` 기반 인스트럭션/샘플 수집
- [ ] `IsSubstrateEnabled()` 분기 + Substrate 메트릭
- [ ] 탐지 룰 4종
- [ ] 머티리얼별 사용 메시 역매핑
- [ ] 에디터 패널 (탭별, 클릭 → Content Browser)
- [ ] FScopedSlowTask + 취소 버튼
- [ ] CSV 출력 (UTF-8 BOM, ProjectSaved 절대화)

### 2차 릴리스
- [ ] 플랫폼별 인스트럭션 수 비교 (SM5/ES3.1)
- [ ] ShaderComplexity viewmode 자동 캡처
- [ ] Translucent overdraw 추정 (화면 픽셀 비율 기반)
