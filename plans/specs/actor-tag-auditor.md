# 기획서 — Actor Tag Auditor

> 작성일: 2026-04-27  
> 수정일: 2026-04-27 (어드바이저 검수 반영)  
> 카테고리: 씬 / 레벨 관리  
> 우선순위: 중간

---

## 개요

레벨 내 액터의 GameplayTag 부여 상태를 검사하고, 태그 스키마 위반·미부여·유사 오타를 리포트하는 에디터 유틸리티.  
**1차 릴리스는 정적 검사 한정** — 런타임에 ASC가 동적으로 부여하는 태그는 탐지 범위 밖임을 명시.

---

## 문제 정의

- 게임플레이 로직이 GameplayTag 기반으로 확장되면서 태그 미부여 액터가 런타임 버그를 유발한다.
- 태그 스키마(필수 태그 규칙)가 문서에만 있어 위반이 감지되지 않는다.
- 규모가 커질수록 어떤 액터가 어떤 태그를 가졌는지 전체 그림이 없다.

---

## 목표

- 레벨 내 전체 액터의 GameplayTag 현황 집계
- 태그 미부여 액터 탐지 (설정 기반 필수 태그 클래스)
- 태그 스키마(Project Settings 기반) 위반 탐지
- 중복/오타 가능성 있는 유사 태그 탐지

> ⚠️ 이 도구는 **정적 참조만 탐지**한다.  
> `LoadObject`/`StreamableManager` 또는 ASC가 런타임에 동적으로 부여하는 태그는 범위 밖이다.

---

## 태그 수집 — 다중 출처

UE 액터에는 "태그"가 최소 4가지 출처에 산재한다. **모두 수집해야 오탐이 줄어든다.**

| 출처 | 타입 | 수집 방법 |
|---|---|---|
| `AActor::Tags` | `TArray<FName>` | `Actor->Tags` 직접 |
| `UActorComponent::ComponentTags` | `TArray<FName>` | `Actor->GetComponents<UActorComponent>()` 순회 |
| `IGameplayTagAssetInterface` | `FGameplayTagContainer` | `GetOwnedGameplayTags(Container)` |
| `UAbilitySystemComponent` 보유 태그 | `FGameplayTagContainer` | `Actor->FindComponentByClass<UAbilitySystemComponent>()` → `GetOwnedGameplayTags()` |

```cpp
// 수집기 추상화 — ITagCollector
struct FActorTagSample
{
    FString ActorLabel;
    FString ActorClass;
    TArray<FName>      NameTags;         // Tags + ComponentTags 합산
    FGameplayTagContainer GameplayTags;  // Interface + ASC 합산
};

// 수집 단계
for (TActorIterator<AActor> It(World); It; ++It)
{
    AActor* Actor = *It;
    // 1) AActor::Tags
    // 2) 모든 컴포넌트의 ComponentTags
    // 3) IGameplayTagAssetInterface
    // 4) UAbilitySystemComponent::GetOwnedGameplayTags()
}
```

---

## 태그 스키마 SoT (단일 진실 원천)

**허용 태그 집합**: `UGameplayTagsManager::Get().RequestAllGameplayTags(Container, ...)` — Project Settings/ini에 등록된 태그를 진실 원천으로 사용.  
**별도 JSON은 "클래스 → 필수 태그 매핑 규칙" 전용**으로만 사용한다.

```json
// tools/tag-auditor/tag-rules.json — 허용 태그 목록 아님, 필수 규칙만
{
  "requiredTags": [
    { "class": "AEnemy",   "tags": ["Actor.Enemy"] },
    { "class": "APickup",  "tags": ["Actor.Pickup"] }
  ]
}
```

> `allowed-tags.json`(외부 허용 목록)은 Project Settings와 이중화되어 유지비가 늘어나므로 사용하지 않는다.

---

## 탐지 항목

| 체크 | 기준 | 심각도 |
|---|---|---|
| 필수 태그 미부여 | `tag-rules.json` 기준 클래스인데 필수 태그 없음 | 오류 |
| 스키마 외 태그 | `UGameplayTagsManager`에 등록되지 않은 태그 사용 | 경고 |
| 유사 태그 (오타 의심) | 동일 부모 네임스페이스 내 leaf 토큰 Levenshtein ≤ 2 + 토큰 길이 ≥ 5 | 정보 |

### 유사 태그 탐지 규칙 상세

단순 전체 태그 문자열 비교는 도트 계층 구조에서 노이즈가 폭증한다.

```
비교 범위: 동일 부모 네임스페이스(prefix) 내 leaf 토큰만
  - Ability.Attack.Melee ↔ Ability.Attack.Mlee → leaf "Melee"/"Mlee", 거리 1 → 정보
  - Actor.Enemy ↔ Actor.Enema → leaf "Enemy"/"Enema", 거리 2 + 길이 ≥ 5 → 정보

필터:
  - leaf 토큰 길이 < 5 → 비교 제외 (Hit, Hot 등 단어 충돌 방지)
  - 사용 빈도 1회 태그 우선 표시 (오타 가능성 ↑)
```

---

## 수집 범위 및 제외

| 소스 | 포함 여부 | 비고 |
|---|---|---|
| 현재 로드된 레벨 액터 | ✅ | `TActorIterator<AActor>` |
| World Partition 미로드 셀 | ❌ | 1차 범위 밖. 결과 패널에 배너 표시 |
| Sublevel (미로드) | ❌ | 동일 |
| Child Actor Component 자식 액터 | ❌ | 중복 카운트 방지 — `GetParentActor() != nullptr` 제외 |
| Editor-only / RF_Transient 액터 | ❌ | `IsEditorOnly()` / `HasAllFlags(RF_Transient)` |
| PIE World | ❌ | `GEditor->GetEditorWorldContext().World()` 명시 사용 |

---

## 구현 방향

```
모듈 의존성 (Build.cs PrivateDependencyModuleNames):
  "Engine", "UnrealEd", "GameplayTags", "GameplayAbilities",
  "GameplayTagsEditor", "AssetRegistry",
  "Json", "JsonUtilities",
  "Slate", "SlateCore", "ToolMenus"

[패스 1 — 준비]
1. EditorWorld 취득: GEditor->GetEditorWorldContext().World()
2. PIE 실행 중 차단
3. WP 활성 여부 감지 → 결과 패널에 "로드된 셀만 스캔됨" 배너
4. UGameplayTagsManager::Get().RequestAllGameplayTags() → 허용 태그 집합 구성
5. tag-rules.json 로드 → 필수 태그 규칙 맵 구성

[패스 2 — 수집]
6. TActorIterator<AActor> 순회 (제외 조건 필터링)
7. 각 액터에 대해 4개 출처 태그 수집 → FActorTagSample 생성

[패스 3 — 탐지]
8. 필수 태그 미부여 룰 적용 (tag-rules.json 기준)
9. 스키마 외 태그 룰 적용 (UGameplayTagsManager 기준)
10. 유사 태그 탐지 (같은 네임스페이스 내 leaf 비교)

[패스 4 — 출력]
11. CSV 경로: FPaths::ProjectSavedDir() / "TagAudit" / "TagAuditReport_YYYYMMDD_HHmmss_N.csv"
    IFileManager::Get().MakeDirectory(Dir, /*Tree=*/true) 자동 생성
12. 에디터 패널 (클릭 → GEditor->SelectActor + 카메라 이동)
    Content Browser: FContentBrowserModule::SyncBrowserToAssets
```

---

## 에디터 패널 구성

```
[스캔] 버튼

⚠ World Partition 활성: 현재 로드된 셀만 스캔됩니다.
⚠ 이 도구는 정적 참조만 탐지합니다. 런타임 동적 태그는 포함되지 않습니다.

요약: 액터 총 432개 | 오류 7개 | 경고 12개 | 정보 23개

[탭: 필수 태그 누락] [탭: 스키마 위반] [탭: 유사 태그] [탭: 전체]

─────────────────────────────────────────────────────────────────
액터명             | 클래스     | 태그                   | 이슈
─────────────────────────────────────────────────────────────────
BP_Enemy_01        | AEnemy    | (없음)                 | 필수 태그 누락
BP_Pickup_Health   | APickup   | Actor.Pkup             | 스키마 외 태그
BP_Door_Main       | AActor    | Actor.Dor, Actor.Door  | 유사 태그 의심
─────────────────────────────────────────────────────────────────

클릭 → 액터 선택
```

---

## 입출력

**입력**
- 현재 열린 레벨
- `tools/tag-auditor/tag-rules.json` (필수 태그 규칙)

**출력**
- 에디터 결과 패널 (탭별, 클릭 → 액터 선택)
- `{ProjectSaved}/TagAudit/TagAuditReport_YYYYMMDD_HHmmss_N.csv`
  - 컬럼: ActorLabel / ActorClass / OwnerLevel / NameTags / GameplayTags / HasRequiredTags / HasSchemaViolation / SimilarTagPairs / Issues

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| 동적 태그 탐지 불가 | ASC 런타임 부여 태그는 정적 스캔에서 보이지 않음. UI에 명시 |
| WP 미로드 셀 | 1차 범위 밖. 배너로 표시 |
| Child Actor 중복 | `GetParentActor()` 체크로 제외 |
| PIE World 혼동 | `GEditor->GetEditorWorldContext().World()` 명시 사용 |
| 유사 태그 노이즈 | leaf 길이 ≥ 5, 동일 네임스페이스 한정으로 제어 |
| UGameplayTagsManager SoT | 등록되지 않은 사용자 정의 FName 태그는 별도 분류 |

---

## 완료 기준

### 1차 릴리스
- [ ] `GEditor->GetEditorWorldContext().World()` + PIE 차단 + WP 배너
- [ ] 태그 4개 출처 수집 (Actor::Tags / ComponentTags / IGameplayTagAssetInterface / ASC)
- [ ] Child Actor / Editor-only / RF_Transient 제외
- [ ] `UGameplayTagsManager::RequestAllGameplayTags()` 기반 허용 태그 집합
- [ ] `tag-rules.json` 기반 필수 태그 규칙 로드
- [ ] 탐지 룰 3종 (필수 미부여 / 스키마 외 / 유사 태그)
- [ ] 유사 태그: 동일 네임스페이스 leaf + 길이 ≥ 5 + 거리 ≤ 2
- [ ] CSV 경로 절대화 + 디렉터리 자동 생성
- [ ] 에디터 패널 (탭별, 클릭 → 액터 선택)
- [ ] FScopedSlowTask + 취소 버튼

### 2차 릴리스
- [ ] WP 전체 셀 External Actor 패키지 스캔 (AssetRegistry 기반)
- [ ] 런타임 ASC 태그 스냅샷 (PIE 후 캡처 방식)
- [ ] 태그 사용 빈도 히트맵
