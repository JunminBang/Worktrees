# 기획서 — Material Instance Batcher

> 작성일: 2026-04-26  
> 수정일: 2026-04-26 (어드바이저 검수 반영)  
> 카테고리: 에셋 파이프라인  
> 우선순위: 중간

---

## 개요

같은 부모 Material을 공유하는 Material Instance Constant(MIC) 묶음을 분석하고,  
정리가 필요한 계층 구조·중복·무변경 인스턴스·방치된 Redirector를 리포트로 출력하는 에디터 유틸리티.  
**1차 릴리스는 탐지/리포트 전용 — 일괄 정리는 2차 릴리스.**

---

## 문제 정의

- 같은 마스터 머티리얼을 쓰는 MI가 수백 개일 때 어떤 파라미터 조합이 실제로 쓰이는지 파악하기 어렵다.
- MI가 MI를 부모로 두는 다중 계층 구조가 생기면 파라미터 추적이 복잡해진다.
- 이름이 바뀐 머티리얼의 Redirector가 방치되면 빌드 경고가 누적된다.
- 파라미터를 하나도 바꾸지 않은 MI는 실질적으로 부모를 직접 사용하는 것과 같다.

---

## 목표

- 마스터 머티리얼별 MI 묶음 현황 집계
- MI 계층 깊이 이상 탐지 (3단 이상)
- 파라미터 변경 없는 MI(기본값만 사용) 탐지
- 중복(동일 파라미터 조합) MI 탐지
- 방치된 Redirector 탐지 (머티리얼 계열만)
- 리포트 출력

---

## 탐지 항목

| 체크 | 기준 | 심각도 |
|---|---|---|
| MI 계층 과다 | Parent 체인 깊이 ≥ 3 | 경고 |
| 파라미터 무변경 MI | 모든 파라미터 유효값이 부모와 동일 | 정보 |
| 중복 MI | 동일 파라미터 시그니처(해시) MI 2개 이상 | 경고 |
| 방치된 Redirector | 패키지 경로 내 UObjectRedirector + 타겟이 UMaterialInterface 파생 + Referencer 0 | 정보 |

---

## 파라미터 시그니처 정의

중복/무변경 판정의 **해시 입력은 다음 파라미터 전체를 포함**해야 한다.  
Static Switch 누락 시 셰이더 퍼뮤테이션이 다른 MI를 중복으로 오탐한다.

| 파라미터 종류 | 소스 |
|---|---|
| `ScalarParameterValues` | `UMaterialInstance::ScalarParameterValues` |
| `VectorParameterValues` | `UMaterialInstance::VectorParameterValues` |
| `DoubleVectorParameterValues` | `UMaterialInstance::DoubleVectorParameterValues` |
| `TextureParameterValues` | `UMaterialInstance::TextureParameterValues` |
| `RuntimeVirtualTextureParameterValues` | `UMaterialInstance::RuntimeVirtualTextureParameterValues` |
| `SparseVolumeTextureParameterValues` | `UMaterialInstance::SparseVolumeTextureParameterValues` |
| `FontParameterValues` | `UMaterialInstance::FontParameterValues` |
| **`StaticParametersRuntime`** | `UMaterialInstance::StaticParametersRuntime` ← Static Switch/ComponentMask/MaterialLayer |

> **비교 단위**: 단순 Name 비교 금지.  
> `FMaterialParameterInfo`(Name + Association + Index) 단위로 비교해야 그룹/레이어 인덱스 혼동 오탐을 방지한다.

### 파라미터 유효값 조회

단순 UPROPERTY 배열 직접 비교 대신 **인터페이스 메서드**로 유효값을 가져와 부모와 비교한다.  
(오버라이드 후 해제된 잔존 항목의 거짓 양성 방지)

```cpp
// 예시 — Scalar
float ChildVal, ParentVal;
MI->GetScalarParameterValue(ParamInfo, ChildVal);
MI->Parent->GetScalarParameterValue(ParamInfo, ParentVal);
// 같으면 "무변경"
```

---

## 구현 방향

```
모듈 의존성 (Build.cs PrivateDependencyModuleNames):
  "AssetRegistry", "AssetTools", "UnrealEd",
  "Slate", "SlateCore", "ToolMenus"

  ※ "MaterialEditor" 모듈은 UX에 필요 없으면 불필요

[패스 1 — 수집]
1. IAssetRegistry::IsLoadingAssets() → true이면 "스캔 미완료" 경고 후 중단
   IAssetRegistry::WaitForCompletion() 호출
2. EnumerateAssets(FARFilter) — 메모리 스파이크 방지를 위해 EnumerateAssets 사용
   ClassPaths: /Script/Engine.MaterialInstanceConstant
   bSearchSubClasses: false  ← UMaterialInstanceDynamic(런타임 전용) 제외
   PackagePaths: /Game, bRecursivePaths=true

[패스 2 — 계층 순회 + 파라미터 수집]
3. 각 MIC에 대해:
   a. Parent 체인 순회:
      - 방문 집합(TSet<FName>) + 최대 깊이 16 가드 → 순환 참조 무한 루프 방지
      - 루트 UMaterial까지 추적, 깊이 카운트
   b. 모든 파라미터 종류 수집 (위 표 8종)
   c. FMaterialParameterInfo 단위 유효값 조회 (Get*ParameterValue 인터페이스)
   d. 파라미터 시그니처 해시 산출

[패스 3 — 탐지 룰 적용]
4. 계층 깊이 ≥ 3 → 경고
5. 모든 유효값 == 부모 유효값 → 정보 (무변경)
6. 동일 시그니처 해시 그룹에 MIC 2개 이상 → 경고 (중복)
7. Redirector 수집: ClassPaths = UObjectRedirector
   → 타겟이 UMaterialInterface 파생 + GetReferencers(All Categories) == 0 → 정보 (방치)

[패스 4 — 집계 + 출력]
8. 마스터 머티리얼별 MI 그룹핑
9. 에디터 패널 표시
10. Content Browser 선택: FContentBrowserModule::SyncBrowserToAssets
11. CSV 저장
```

---

## 에디터 패널 구성

```
[전체 스캔] 버튼  |  [선택 폴더만] 버튼

요약: MI 총 847개 | 경고 34개 | 정보 91개
마스터 머티리얼 수: 42개 | Redirector 방치: 12개

[탭: 계층 과다] [탭: 중복 MI] [탭: 무변경 MI] [탭: Redirector] [탭: 전체]

────────────────────────────────────────────────────────────────────
MI명                  | 마스터 머티리얼   | 계층 깊이 | 파라미터 | 이슈
────────────────────────────────────────────────────────────────────
MI_Rock_Wet_Dark      | M_Rock          | 3        | 4        | 계층 과다
MI_Wall_01            | M_Wall          | 1        | 0        | 무변경
MI_Rock_Dry_A         | M_Rock          | 1        | 3        | 중복(B와 동일)
────────────────────────────────────────────────────────────────────

클릭 → Content Browser에서 선택
```

---

## 입출력

**입력**
- 스캔 경로 (기본: `/Game/`)

**출력**
- 에디터 결과 패널 (탭별 분류, 클릭 → Content Browser)
- `Saved/MaterialInstanceReport_YYYYMMDD_HHmmss.csv`
  - 컬럼: PackagePath / MIName / RootMaterial / HierarchyDepth / ParameterCount / HasDeepHierarchy / IsParameterless / IsDuplicate / DuplicateGroupId / Notes

> **위반 종류별 boolean 컬럼 분리**: Issues 단일 컬럼 대신 `HasDeepHierarchy`, `IsParameterless`, `IsDuplicate` 별도 컬럼 → 복수 위반 파악 용이.

---

## 2차 릴리스 — 일괄 정리

| 작업 | 안전망 |
|---|---|
| Redirector 일괄 정리 | `IAssetTools::FixupReferencers(..., ERedirectFixupMode::DeleteFixedUpRedirectors)` |
| 무변경 MI 부모로 교체 | 참조 에셋 리스트 사전 확인 + dry-run + 승인 |
| 중복 MI 통합 | 어떤 MI를 대표로 남길지 사용자 선택 후 참조 일괄 교체 |
| 계층 평탄화 | MI 체인을 루트 기준으로 평탄화 — 플랫폼 오버라이드 주의 |

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| StaticParametersRuntime 누락 시 오탐 | Static Switch가 다른 MI가 "중복"으로 분류됨. 반드시 해시에 포함 |
| UMaterialInstanceDynamic | 런타임 전용, 디스크 미저장 → `bSearchSubClasses=false`로 자동 제외 |
| 순환 참조 | 방문 집합 + 깊이 16 가드로 처리 |
| AssetRegistry 준비 | WaitForCompletion() 필수. 미호출 시 결과 누락 |
| Redirector 판정 | "타겟이 UMaterialInterface 파생" + "Referencer 0" 두 조건 모두 충족 시만 "방치"로 분류 |
| 파라미터 비교 | 배열 직접 비교 금지 — Get*ParameterValue() 인터페이스 사용 필수 |
| 대규모 프로젝트 | EnumerateAssets + FScopedSlowTask + 취소 버튼 |

---

## 완료 기준

### 1차 릴리스 (탐지/리포트)
- [ ] `WaitForCompletion()` + `EnumerateAssets(UMaterialInstanceConstant, bSearchSubClasses=false)`
- [ ] Parent 체인 순회: 방문 집합 + 깊이 16 가드
- [ ] 파라미터 8종 전체 수집 (StaticParametersRuntime 포함)
- [ ] `FMaterialParameterInfo` 단위 + `Get*ParameterValue()` 인터페이스로 유효값 비교
- [ ] 파라미터 시그니처 해시 (Static Switch 포함)
- [ ] 탐지 룰 4종 (계층 과다 / 무변경 / 중복 / Redirector 방치)
- [ ] 마스터 머티리얼별 MI 그룹핑
- [ ] 에디터 패널 (탭별 분류, 클릭 → FContentBrowserModule::SyncBrowserToAssets)
- [ ] FScopedSlowTask + 취소 버튼
- [ ] CSV 리포트 (위반 종류별 boolean 컬럼 분리)

### 2차 릴리스 (일괄 정리)
- [ ] Redirector 일괄 정리 (IAssetTools::FixupReferencers)
- [ ] 무변경 MI 부모 교체 (dry-run + 승인)
- [ ] 중복 MI 통합 (대표 선택 + 참조 교체)
- [ ] 계층 평탄화
