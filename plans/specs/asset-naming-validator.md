# 기획서 — Asset Naming Validator

> 작성일: 2026-04-26  
> 수정일: 2026-04-26 (어드바이저 검수 반영)  
> 카테고리: 에셋 파이프라인  
> 우선순위: 높음 (파이프라인 품질 즉각 향상)

---

## 개요

Content Browser 내 에셋명이 프로젝트 컨벤션(`SM_`, `T_`, `M_` 등)을 준수하는지 자동으로 검사하고, 위반 목록을 리포트로 출력하는 에디터 유틸리티.  
**1차 릴리스는 탐지/리포트 전용 — 일괄 리네임은 2차 릴리스.**

---

## 문제 정의

- 아티스트마다 에셋명 습관이 달라 컨벤션 위반이 지속적으로 발생한다.
- 위반된 에셋명은 참조 파악, 필터링, 자동화 도구 연동을 모두 어렵게 만든다.
- 수작업으로 전체 Content 폴더를 점검하기엔 에셋 수가 너무 많다.

---

## 목표

- 전체 `/Game/` 또는 지정 경로의 에셋명 컨벤션 위반 일괄 탐지
- 위반 에셋에 대해 올바른 이름 제안
- CSV 리포트 출력으로 아티스트 셀프 수정 가능하게
- 1차: 탐지 + 리포트. 2차: 일괄 리네임 (리다이렉터 처리 포함)

---

## 컨벤션 규칙

### 기본 접두사 (Prefix) 규칙

| 에셋 클래스 | 접두사 | matchMode |
|---|---|---|
| `UStaticMesh` | `SM_` | exact |
| `USkeletalMesh` | `SKM_` | exact |
| `UTexture2D` | `T_` | exact |
| `UMaterial` | `M_` | exact |
| `UMaterialInstanceConstant` | `MI_` | exact |
| `UMaterialParameterCollection` | `MPC_` | exact |
| `UAnimBlueprint` | `ABP_` | exact |
| `UAnimSequence` | `A_` | exact |
| `UAnimMontage` | `AM_` | exact |
| `UBlendSpace` | `BS_` | exact |
| `UNiagaraSystem` | `NS_` | exact |
| `UNiagaraEmitter` | `NE_` | exact |
| `USoundWave` | `S_` | exact |
| `USoundCue` | `SC_` | exact |
| `UPhysicsAsset` | `PA_` | exact |
| `UDataAsset` | `DA_` | **child** (서브클래스 포함) |
| `UWidgetBlueprint` | `WBP_` | exact |
| `UBlueprint` (UUserWidget 상속) | `WBP_` | child (NativeParentClass 기반) |
| `UBlueprint` (그 외) | `BP_` | exact |
| `UWorld` | `L_` | exact |

> `matchMode`:
> - `exact` — `AssetClassPath`가 정확히 일치해야 적용
> - `child` — `IsChildOf` 체크 사용 (서브클래스에도 적용)
>
> 위 목록은 `tools/naming-validator/naming-rules.json`으로 관리 — 코드 수정 없이 규칙 추가/변경 가능.

### 판정 방식 (클래스 분류 알고리즘)

```
1. AssetClassPath로 exact 매칭 시도
   → 일치 규칙 있으면 해당 접두사 적용

2. exact 미일치 시:
   - AssetClassPath == "Blueprint":
     → NativeParentClass 또는 GeneratedClass 태그로 IsChildOf(UUserWidget) 체크
        → 해당하면 WBP_ 적용
        → 아니면 BP_ 적용
   - AssetClassPath == "DataAsset" 또는 그 서브클래스:
     → matchMode=child 규칙에서 IsChildOf 체크 → DA_ 적용

3. 규칙 없는 클래스 → "규칙 없음" 분류 (위반 아님)
4. UObjectRedirector → 항상 스킵 (FARFilter에서 제외)
```

> ⚠️ 대소문자 구분: `StartsWith()` 호출 시 **반드시 `ESearchCase::CaseSensitive` 명시**.  
> 기본값(IgnoreCase)은 `sm_Rock`을 통과시킨다.

### 제외 경로 (스캔 제외)

- `/Game/Developers/` — 개발자 개인 폴더
- `/Game/Collections/` — 컬렉션 폴더
- `/Engine/` — 엔진 기본 에셋
- 플러그인 경로 (`/PluginName/`) — 기본 **제외** (Marketplace 에셋은 컨벤션 적용 대상 아님). 설정으로 포함 가능.
- `naming-rules.json`에서 추가 제외 경로 설정 가능

---

## 위반 이름 제안 로직

```
1. 현재 에셋 클래스에 맞는 접두사 조회
2. 기존 이름에서 잘못된 접두사가 있으면 제거
   (예: SM_Rock이 UMaterial이면 → SM_ 제거)
3. 올바른 접두사 + 원본 이름(정제) = 제안 이름
   (예: Rock → M_Rock)
4. 이미 같은 이름이 존재하면 → "_01", "_02" 숫자 접미사 추가
5. 접두사 규칙이 없는 클래스 → "규칙 없음" 표시, 위반 아님
```

---

## 구현 방향

```
모듈 의존성 (Build.cs PrivateDependencyModuleNames):
  "AssetRegistry", "AssetTools", "ContentBrowser",
  "EditorScriptingUtilities", "UnrealEd"

1. AssetRegistry 초기 스캔 완료 대기
   - IAssetRegistry::Get().WaitForCompletion() 또는
     OnFilesLoaded 델리게이트 바인딩 후 실행

2. IAssetRegistry::Get().GetAssets(Filter, AssetList)
   FARFilter 구성:
     - Filter.PackagePaths: 스캔 대상 경로
     - Filter.bRecursivePaths = true
     - Filter.bRecursiveClasses = true          ← DataAsset 서브클래스 포함 필수
     - Filter.bIncludeOnlyOnDiskAssets = false
     - Filter.RecursiveClassPathsExclusionSet에 UObjectRedirector 추가  ← Redirector 제외

3. naming-rules.json 로드 → 클래스별 규칙 맵 구성 (matchMode 포함)

4. 각 에셋에 대해 클래스 분류 알고리즘 적용
   - StartsWith(ExpectedPrefix, ESearchCase::CaseSensitive) 검사
   - 위반 시 FNamingIssue 레코드 생성:
     {PackagePath, AssetName, AssetClass, ExpectedPrefix, SuggestedName}

5. 에디터 패널: 위반 목록 표시
   - 클릭 시 Content Browser 포커스:
     FContentBrowserModule& CB = FModuleManager::LoadModuleChecked<FContentBrowserModule>("ContentBrowser")
     CB.Get().SyncBrowserToAssets(SelectedAssets)

6. CSV 저장: Saved/NamingReport_YYYYMMDD_HHmmss.csv
```

---

## 설정 파일 (`tools/naming-validator/naming-rules.json`)

```json
{
  "excludePaths": [
    "/Game/Developers/",
    "/Game/Collections/"
  ],
  "includePluginPaths": false,
  "rules": [
    { "class": "StaticMesh",               "prefix": "SM_",  "matchMode": "exact" },
    { "class": "SkeletalMesh",             "prefix": "SKM_", "matchMode": "exact" },
    { "class": "Texture2D",                "prefix": "T_",   "matchMode": "exact" },
    { "class": "Material",                 "prefix": "M_",   "matchMode": "exact" },
    { "class": "MaterialInstanceConstant", "prefix": "MI_",  "matchMode": "exact" },
    { "class": "Blueprint",                "prefix": "BP_",  "matchMode": "exact" },
    { "class": "WidgetBlueprint",          "prefix": "WBP_", "matchMode": "exact" },
    { "class": "AnimBlueprint",            "prefix": "ABP_", "matchMode": "exact" },
    { "class": "DataAsset",                "prefix": "DA_",  "matchMode": "child" },
    { "class": "NiagaraSystem",            "prefix": "NS_",  "matchMode": "exact" },
    { "class": "World",                    "prefix": "L_",   "matchMode": "exact" }
  ]
}
```

---

## 입출력

**입력**
- 스캔 경로 (기본: `/Game/`, 지정 하위 폴더도 가능)
- `naming-rules.json` (접두사 규칙, 제외 경로, matchMode)

**출력**
- 에디터 결과 패널 (위반 목록, 클릭 → Content Browser 선택)
- `Saved/NamingReport_YYYYMMDD_HHmmss.csv`
  - 컬럼: PackagePath / AssetName / AssetClass / ExpectedPrefix / SuggestedName

---

## 2차 릴리스 — 일괄 리네임 안전망

| 안전망 | 내용 |
|---|---|
| dry-run + diff 보고서 | 실제 변경 전 (oldName → newName) 전체 목록을 CSV로 export 후 별도 승인 |
| 리네임 매니페스트 저장 | `Saved/NamingRename_YYYYMMDD/manifest.json`에 (oldPath, newPath) 기록 → 역방향 롤백 가능 |
| SCC 체크아웃 검증 | Perforce/Git LFS 환경에서 read-only 파일 확인 후 리네임 진행 |
| 소프트 레퍼런스 영향 스캔 | `FAssetRegistry::GetReferencers()`로 전체 의존성 수집. DataTable 행·Config INI·FSoftObjectPath 포함 영향 범위 사전 표시 |
| 미로드 레벨 참조 경고 | 리네임 대상이 언로드된 레벨에서 참조되면 경고 + 해당 레벨 목록 표시 |
| Redirector 정리 정책 | `ObjectTools::RenameObjects()` → 리다이렉터 생성 → `UEditorAssetLibrary::ConsolidateAssets()` 또는 `FixUpRedirects` Commandlet으로 정리 |
| 100개 상한 | 1회 일괄 적용 상한 (실수 방지 — dry-run 승인 후에만 적용) |

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| Blueprint 서브클래스 | `GeneratedClass`/`NativeParentClass` 태그 로드 시 동기 로드 발생 가능 — BP/WBP 수가 많으면 주의 |
| DataAsset 서브클래스 | matchMode=child + bRecursiveClasses=true 조합으로 처리 |
| UObjectRedirector | FARFilter RecursiveClassPathsExclusionSet에 추가해 명시 제외 |
| Redirector 정리 | FixupReferencers 후에도 미저장 레벨 참조는 남을 수 있음 |
| 플러그인 에셋 | 기본 제외 — 포함 시 naming-rules.json의 includePluginPaths: true |
| AssetRegistry 초기화 | WaitForCompletion() 호출로 미스캔 에셋 방지 |

---

## 완료 기준

### 1차 릴리스 (탐지/리포트)
- [ ] `naming-rules.json` 기반 접두사 규칙 로드 (matchMode 포함)
- [ ] IAssetRegistry::Get() + FARFilter (bRecursiveClasses, Redirector 제외)
- [ ] 클래스 분류 알고리즘 (AssetClassPath exact → Blueprint/DataAsset child 분기)
- [ ] `StartsWith(ESearchCase::CaseSensitive)` 판정
- [ ] 위반 이름 제안 + 중복 접미사 처리
- [ ] 결과 패널 (클릭 → FContentBrowserModule::SyncBrowserToAssets)
- [ ] CSV 리포트 저장

### 2차 릴리스 (일괄 리네임)
- [ ] dry-run + diff CSV export + 승인 단계
- [ ] 리네임 매니페스트 기록 + 역방향 롤백
- [ ] SCC 체크아웃 상태 검증
- [ ] GetReferencers() 기반 소프트 레퍼런스 영향 범위 스캔
- [ ] Redirector 정리 (ObjectTools::RenameObjects + ConsolidateAssets)
- [ ] 100개 상한 일괄 적용
