# 기획서 — Streaming Level Validator

> 작성일: 2026-04-27  
> 수정일: 2026-04-27 (어드바이저 검수 반영)  
> 카테고리: 씬 / 레벨 관리  
> 우선순위: 중간

---

## 개요

World Partition / Level Streaming의 **월드 설정 일관성**을 검사하는 에디터 유틸리티.  
액터 인스턴스 품질은 Level Health Checker가 담당하며, 이 도구는 **스트리밍/WP 설정 파일·메타데이터**에 집중한다.

### Level Health Checker와의 역할 분리

| 검사 대상 | Level Health Checker | Streaming Level Validator |
|---|---|---|
| 액터 위치·스케일·참조 | ✅ | ❌ |
| Null 메시·PlayerStart 등 | ✅ | ❌ |
| WP 셀 크기·HLOD 설정 | ❌ | ✅ |
| Data Layer 인스턴스 일관성 | ❌ | ✅ |
| Sublevel 스트리밍 설정 | ❌ | ✅ |

---

## 문제 정의

- Level Streaming 볼륨/트리거 설정이 누락된 서브레벨이 있으면 런타임에 로드되지 않는다.
- World Partition Data Layer 설정 불일치가 퍼포먼스 문제를 일으킨다.
- 스트리밍 설정 전체 그림을 한눈에 보기 어렵다.
- UE5.5+에서 Data Layer API가 재구조화됐는데 기존 레거시 설정이 남아있을 수 있다.

---

## 목표 — WP 활성/비활성 분기

이 도구는 **WP 활성 여부에 따라 코드패스를 분리**한다. 두 모드가 검사하는 대상이 근본적으로 다르다.

```
World::GetWorldPartition() != nullptr
    → WP 활성 경로 (셀/Data Layer/HLOD 레이어 설정 검사)
    → WP 비활성 경로 (ULevelStreaming 서브레벨 설정 검사)
```

---

## 탐지 항목

### WP 비활성 경로 — Sublevel 스트리밍 검사

| 체크 | 기준 | 심각도 |
|---|---|---|
| 트리거 의심 서브레벨 | `ULevelStreamingDynamic` + `bInitiallyLoaded=false` + 레벨 내 `ALevelStreamingVolume` 0개 | 정보 |
| 비활성 서브레벨 | `bShouldBeLoaded=false` AND `bShouldBeVisible=false` | 정보 |
| LevelInstance 미검사 | `ALevelInstance` / `APackedLevelActor` → 별도 탭에 목록만 표시 | 정보 |

> **트리거 판정 한계**: BP/C++ 코드로 로드하는 서브레벨은 정적 분석으로 탐지 불가.  
> `ULevelStreamingAlwaysLoaded` 타입은 트리거가 없어도 정상 → 명시적 제외.  
> 판정은 "의심 사례 정보" 등급으로만 표시. 실제 문제 여부는 사용자가 판단한다.

### WP 활성 경로 — World Partition 설정 검사

| 체크 | 기준 | 심각도 |
|---|---|---|
| 런타임 해시 미설정 | `UWorldPartition::RuntimeHash == nullptr` | 오류 |
| 셀 크기 임계값 초과 | `CellSize` > 설정값 (기본: 없음, 프로젝트 입력값 기준) | 정보 |
| Data Layer 인스턴스 고아 | `UDataLayerInstance`가 있으나 대응 `UDataLayerAsset` 없음 | 경고 |
| Data Layer 중복 이름 | 다른 인스턴스인데 DisplayName 동일 | 경고 |
| HLOD 레이어 미설정 | WP 활성 + HLOD 빌드 설정 없음 | 정보 |
| 레거시 Data Layer | `UDataLayer`(deprecated) 사용 감지 (UE5.5+ 기준) | 경고 |

> **Data Layer API (UE5.5+)**: `UDataLayer` → `UDataLayerAsset` + `UDataLayerInstance`로 분리됨.  
> 액터 Data Layer 조회: `AActor::GetDataLayerInstances()` 사용. 구 `GetDataLayerObjects()`는 deprecated.

---

## 제외 대상 (공통)

WP 환경에서 자동 생성되는 메타 액터는 Data Layer 미할당이 정상이므로 제외:

- `AWorldPartitionHLOD`
- `AWorldDataLayers`
- `ALevelInstanceEditorInstanceActor`
- `APackedLevelActor`
- `IsEditorOnly() == true` / `HasAllFlags(RF_Transient)`

---

## 구현 방향

```
모듈 의존성 (Build.cs PrivateDependencyModuleNames):
  "Engine", "UnrealEd", "WorldPartitionEditor",
  "Slate", "SlateCore", "ToolMenus"

[패스 0 — 분기 결정]
1. GEditor->GetEditorWorldContext().World() → EditorWorld
2. PIE 실행 중 차단
3. World->GetWorldPartition() != nullptr 확인 → 코드패스 분기

[WP 비활성 경로]
4. World->GetStreamingLevels() 순회
5. 각 ULevelStreaming에 대해:
   - Cast<ULevelStreamingAlwaysLoaded> 시 스킵
   - Cast<ULevelStreamingDynamic> 시 트리거 의심 체크
   - bShouldBeLoaded / bShouldBeVisible 수집
6. ALevelInstance / APackedLevelActor 목록 수집 (별도 탭)

[WP 활성 경로]
7. UWorldPartition* WP = World->GetWorldPartition()
8. WP->RuntimeHash → 미설정 확인
9. RuntimeHash에서 CellSize 조회
10. Data Layer 인스턴스 수집:
    UDataLayerManager::GetDataLayerInstances() → 고아/중복 검사
    레거시 UDataLayer 감지
11. HLOD 레이어 설정 확인

[공통 출력]
12. 결과 집계 → 에디터 패널 + JSON 메타데이터 + CSV 저장
13. 클릭 → GEditor->SelectActor (해당 설정 액터/볼륨)
```

---

## 리포트 메타데이터 (JSON)

level-health-checker.md 와 정합되는 구조:

```json
{
  "levelName": "World_Main",
  "scanTime": "2026-04-27T10:00:00+09:00",
  "worldPartition": {
    "active": true,
    "runtimeHashClass": "URuntimeHashExternalStreamingObject",
    "cellSize": 12800,
    "dataLayerCount": 4,
    "hlodLayerConfigured": true
  },
  "levelStreaming": {
    "active": false,
    "sublevelCount": 0
  },
  "issueCount": { "error": 1, "warning": 2, "info": 5 }
}
```

---

## 에디터 패널 구성

```
[스캔] 버튼

모드: World Partition 활성 | 셀 크기: 12800 UU | Data Layer: 4개

요약: 오류 1개 | 경고 2개 | 정보 5개

[탭: 설정 오류] [탭: Data Layer] [탭: Sublevel] [탭: LevelInstance] [탭: 전체]

─────────────────────────────────────────────────────────────────────
항목                       | 유형              | 이슈
─────────────────────────────────────────────────────────────────────
WorldPartition             | RuntimeHash       | 미설정 (오류)
DL_Gameplay                | DataLayerInstance | 대응 Asset 없음 (경고)
SubLevel_BossRoom          | LevelStreamingDyn | 트리거 의심 (정보)
─────────────────────────────────────────────────────────────────────

클릭 → 설정 열기 / 액터 선택
```

---

## 입출력

**입력 (설정 가능)**
- 셀 크기 임계값 (기본: 미설정 — 프로젝트 입력값 없으면 룰 비활성)

**출력**
- 에디터 결과 패널
- `{ProjectSaved}/StreamingReports/StreamingReport_YYYYMMDD_HHmmss_N.csv`
- `{ProjectSaved}/StreamingReports/StreamingReport_YYYYMMDD_HHmmss_N.json` (메타데이터)

---

## Wiki Auto-Ingest Hook 연동

```json
{
  "id": "streaming-validator",
  "pattern": "Saved/StreamingReports/StreamingReport_*.json",
  "parser": "profiling-json",
  "rawPath": "raw/auto/profiling/",
  "wikiCategory": "pattern",
  "wikiTags": ["level", "streaming", "world-partition"],
  "minSizeKB": 1,
  "debounceSeconds": 0
}
```

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| BP/C++ 트리거 탐지 불가 | 정적 분석 한계. 트리거 의심은 "정보" 등급으로만 표시 |
| WP 미로드 셀 | 현재 로드된 설정만 스캔. 배너 표시 |
| Data Layer API UE5.5+ | `UDataLayerInstance`/`UDataLayerAsset` 기반. 레거시 `UDataLayer` 감지 시 경고 |
| 셀 크기 임계값 | 프로젝트 입력값 없으면 비활성. 기본값 하드코딩 금지 |
| PIE 차단 | PIE 실행 중 차단 |
| LevelInstance | 1차 릴리스: 목록 표시만. 내부 설정 검사는 2차 |

---

## 완료 기준

### 1차 릴리스
- [ ] WP 활성 여부 0단계 분기
- [ ] PIE 차단 + EditorWorld 명시
- [ ] **WP 비활성 경로**: ULevelStreaming 순회, AlwaysLoaded 제외, 트리거 의심 탐지
- [ ] **WP 활성 경로**: RuntimeHash 미설정 / Data Layer 인스턴스 고아+중복+레거시 / HLOD 레이어
- [ ] `UDataLayerInstance`/`UDataLayerAsset` 기반 API (UE5.5+ 기준)
- [ ] 메타 액터 블랙리스트 제외
- [ ] LevelInstance 목록 탭 (설정 검사는 2차)
- [ ] JSON 메타데이터 + CSV 출력 (ProjectSavedDir 절대화)
- [ ] 에디터 패널 (탭별)
- [ ] Wiki Auto-Ingest Hook config.json watchTarget 추가

### 2차 릴리스
- [ ] ALevelInstance 내부 설정 검사
- [ ] WP 전체 셀 스캔 (청크 로드/언로드)
- [ ] 셀 크기 권장값 자동 산출 (시야거리 기반)
