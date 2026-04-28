# 기획서 — Orphan Asset Finder

> 작성일: 2026-04-26  
> 수정일: 2026-04-26 (어드바이저 검수 반영)  
> 카테고리: 에셋 파이프라인  
> 우선순위: 중간

---

## 개요

참조(레퍼런스)가 없는 에셋을 탐지해 삭제 후보 목록을 생성하는 에디터 유틸리티.  
**탐지/리포트 전용 — 실제 삭제는 사용자 수동 처리 (2차 릴리스에서 일괄 삭제 지원 예정).**

> ⚠️ 이 도구는 **정적 참조만 탐지**한다.  
> Soft Path를 런타임에 문자열로 조립하거나 C++에서 동적 로드(`LoadObject`, `StreamableManager`)하는 에셋은 탐지 범위 밖이다.  
> 최종 판단은 반드시 사람이 해야 한다.

---

## 문제 정의

- 삭제/교체된 에셋이 참조만 끊긴 채 디스크에 남아 프로젝트를 비대하게 만든다.
- 수작업으로 사용 여부를 파악하기 어렵다.
- 의도치 않은 삭제 방지를 위해 최종 판단은 반드시 사람이 해야 한다.

---

## 목표

- 전체 `/Game/` 에셋 중 아무도 참조하지 않는 에셋 탐지
- 신뢰도(High/Medium/Low)별 분류로 사용자 결정 비용 최소화
- 카테고리(메시/텍스처/블루프린트 등)별 분류
- 예상 절감 디스크 용량 표시
- 리포트 출력

---

## 고아 에셋 탐지 방식

### 의존성 카테고리 (모두 조회)

UE5의 의존성은 4가지 카테고리로 나뉜다. **전부 확인해야 오탐이 줄어든다.**

| 카테고리 | 내용 | 예 |
|---|---|---|
| `Package` (Hard) | 직접 하드 참조 | 머티리얼→텍스처, BP→메시 |
| `SearchableName` (Soft) | `TSoftObjectPtr`, 에셋 경로 문자열 | DataTable Row, SoftRef |
| `Manage` | AssetManager Primary Asset 등록 | PrimaryDataAsset, AssetBundle |
| `All` | 위 전체 | 고아 판정 기준 |

```cpp
FAssetIdentifier AssetId(PackageName);
TArray<FAssetIdentifier> Referencers;
IAssetRegistry::Get().GetReferencers(
    AssetId, Referencers,
    UE::AssetRegistry::EDependencyCategory::Package
        | UE::AssetRegistry::EDependencyCategory::SearchableName
        | UE::AssetRegistry::EDependencyCategory::Manage,
    UE::AssetRegistry::EDependencyQuery::NoRequirements
);
// Referencers.IsEmpty() → 고아 후보
```

---

## 시스템 화이트리스트 (자동 제외)

다음 항목은 참조가 없어 보여도 **의도된 루트 에셋**이므로 자동 제외한다.

| 항목 | 이유 |
|---|---|
| `UWorld` (레벨 파일) | 루트 에셋 — 참조 역방향이 없음 |
| `UMapBuildDataRegistry` (`_BuiltData`) | 맵 라이팅 빌드 데이터 |
| `UObjectRedirector` | 리네임/이동 후 남는 리다이렉터 — FixUpRedirects 전까지 필요 |
| `__ExternalActors__/` 경로 | World Partition OFPA(One File Per Actor) |
| `__ExternalObjects__/` 경로 | World Partition 외부 오브젝트 |
| `HLOD/` 경로 prefix | World Partition HLOD 프록시 |
| AssetManager Primary Asset 타입 등록 경로 | `DefaultGame.ini`의 `AssetManagerSettings` 등록 경로 |
| `UEditorUtilityWidget` 파생 | BP 컴파일 캐시에서만 참조 가능 |

> 추가 화이트리스트 prefix는 `tools/orphan-finder/whitelist.json`에서 설정 가능.

---

## 보조 탐지: C++ / INI 경로 스캔 (선택 옵션)

AssetRegistry는 C++ 하드코딩 경로와 INI 경로를 알지 못한다.  
옵션 활성 시 다음 패턴을 그렙해 화이트리스트에 합산한다:

```
대상: Source/**/*.{cpp,h}, Config/*.ini
패턴: ["/]Game/[A-Za-z0-9_/\.]+
```

> ※ 정규식 false positive 가능. 보조 수단으로만 활용하며 최종 판단은 사람이 한다.

---

## 신뢰도(Confidence) 분류

단순 목록 대신 신뢰도 등급을 부여해 사용자 결정 비용을 줄인다.

| 신뢰도 | 기준 | 권장 처리 |
|---|---|---|
| **High** | 모든 카테고리 Referencer 0 + 알려진 시스템 클래스 아님 + 경로 화이트리스트 미해당 | 삭제 검토 우선 |
| **Medium** | Referencer 0이지만 AssetManager 후보 클래스(`UDataAsset` 파생 등) | 수동 확인 후 결정 |
| **Low** | World Partition 외부 액터/HLOD 패턴 또는 C++ 스캔에서 일부 경로 발견 | 유지 권장 |

---

## 구현 방향

```
모듈 의존성 (Build.cs PrivateDependencyModuleNames):
  "AssetRegistry", "ContentBrowser", "UnrealEd",
  "Slate", "SlateCore", "ToolMenus"

[패스 1 — AssetRegistry 준비 + 전체 수집]
1. IAssetRegistry::Get().WaitForCompletion()
2. GetAssetsByPath("/Game", OutAssets, /*bRecursive=*/true, /*bIncludeOnlyOnDiskAssets=*/true)

[패스 2 — 참조 분석]
3. 각 에셋에 대해:
   a. 화이트리스트 경로/클래스 → 즉시 제외
   b. GetReferencers(FAssetIdentifier, All Categories) 호출
   c. Referencers 비어있으면 → 고아 후보
   d. Confidence 등급 산정

[패스 3 — 보조 스캔 (옵션)]
4. C++/INI 경로 패턴 Grep → 화이트리스트에 합산 → 재판정

[패스 4 — 집계 + 출력]
5. Confidence별 분류, 클래스별 그룹핑
6. 디스크 크기: .uasset + .uexp + .ubulk 파일 합산
   IFileManager::Get().FileSize(FilePath)
7. LastModified: IFileManager::Get().GetTimeStamp(PackageFilename)
8. 에디터 패널 + CSV 저장
9. Content Browser에서 선택:
   FContentBrowserModule::SyncBrowserToAssets()
```

---

## 에디터 패널 구성

```
[전체 스캔] 버튼  |  [C++/INI 보조 스캔 포함] 체크박스

요약: 총 에셋 3,241개 | 고아 후보 134개 (High 42 / Medium 55 / Low 37)
예상 절감 디스크 용량: 약 1.2 GB

⚠ 이 도구는 정적 참조만 탐지합니다. 동적 로드 에셋은 포함될 수 있습니다.

[탭: High 신뢰도] [탭: Medium] [탭: Low] [탭: 전체]

───────────────────────────────────────────────────────────────
에셋명              | 클래스       | 크기     | 마지막 수정  | 신뢰도
───────────────────────────────────────────────────────────────
T_OldRock_D         | Texture2D   | 22 MB   | 2025-11-03  | High
SM_PropBox_V2       | StaticMesh  | 1.2 MB  | 2025-08-17  | High
BP_OldEnemy         | Blueprint   | 0.4 MB  | 2025-07-22  | Medium
───────────────────────────────────────────────────────────────

클릭 → Content Browser에서 선택
```

---

## 입출력

**입력**
- 스캔 경로 (기본: `/Game/`)
- C++/INI 보조 스캔 포함 여부 (기본: OFF)
- 추가 화이트리스트 prefix (`tools/orphan-finder/whitelist.json`)

**출력**
- 에디터 결과 패널 (Confidence 탭별 분류, 클릭 → Content Browser)
- `Saved/OrphanAssets_YYYYMMDD_HHmmss.csv`
  - 컬럼: PackagePath / AssetName / AssetClass / DiskSizeKB / LastModified / Confidence / Notes

---

## 2차 릴리스 — 일괄 삭제

| 안전망 | 내용 |
|---|---|
| 삭제 전 dry-run + 승인 | 삭제 목록 확인 후 명시적 승인 |
| Redirector 정리 선행 | 삭제 전 FixUpRedirects 실행 권고 |
| 삭제 매니페스트 | (PackagePath, DiskPath) 기록 — 수동 복원 참조용 |
| 소스 컨트롤 delete 마킹 | Perforce/Git LFS 연동 |
| 100개 상한 | 1회 일괄 삭제 최대 100개 |

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| 동적 로드 | `LoadObject`, `StreamableManager`, 문자열 조립 경로 — 탐지 불가. UI에 명시 |
| Soft Reference 누락 | `EDependencyCategory` All 조회로 최소화. TSoftObjectPtr은 SearchableName으로 등록됨 |
| AssetRegistry 미완료 | `WaitForCompletion()` 필수. 미호출 시 누락 에셋 발생 |
| Redirector 오탐 | 자동 화이트리스트 처리 |
| World Partition OFPA | `__ExternalActors__/`, `__ExternalObjects__/` 경로 자동 제외 |
| C++ 그렙 오탐 | 보조 수단으로만 사용. 최종 판단 사람 몫 |
| 디스크 크기 | `.uasset + .uexp + .ubulk` 3개 합산. `.uasset`만 보면 텍스처/오디오에서 오차 큼 |

---

## 완료 기준

### 1차 릴리스 (탐지/리포트)
- [ ] `IAssetRegistry::WaitForCompletion()` 후 전체 수집
- [ ] `EDependencyCategory::Package | SearchableName | Manage` 전 카테고리 참조 조회
- [ ] 시스템 화이트리스트 자동 제외 (UWorld, BuiltData, Redirector, OFPA, HLOD 등)
- [ ] Confidence (High/Medium/Low) 등급 산정
- [ ] C++/INI 보조 경로 스캔 (선택 옵션)
- [ ] 디스크 크기 (.uasset + .uexp + .ubulk 합산)
- [ ] LastModified 타임스탬프 (IFileManager::GetTimeStamp)
- [ ] 에디터 패널 (Confidence 탭별, 클릭 → FContentBrowserModule::SyncBrowserToAssets)
- [ ] CSV 리포트 저장

### 2차 릴리스 (일괄 삭제)
- [ ] dry-run + 승인 게이트
- [ ] FixUpRedirects 실행 권고 + 자동 실행 옵션
- [ ] 삭제 매니페스트 + 소스 컨트롤 delete 마킹
- [ ] 100개 상한 일괄 삭제
