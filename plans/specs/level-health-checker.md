# 기획서 — Level Health Checker

> 작성일: 2026-04-26  
> 수정일: 2026-04-26 (어드바이저 검수 반영)  
> 카테고리: 씬 / 레벨 관리  
> 우선순위: 높음 (씬 스캔 공식화, Wiki Auto-Ingest Hook 연동)

---

## 개요

레벨 내 액터를 순회해 자주 발생하는 품질 문제를 자동 탐지하고, 결과를 리포트로 출력하는 에디터 유틸리티.  
씬 스캔 작업을 표준화하고 Wiki Auto-Ingest Hook과 연동해 발견된 패턴을 wiki에 자동 누적한다.

---

## 문제 정의

- 레벨 규모가 커질수록 겹친 액터, 잘못된 위치, 극단 스케일 등 실수가 묻히기 쉽다.
- 아티스트마다 씬 정리 기준이 달라 일관성이 없다.
- 수동으로 전체 레벨을 점검하는 데 시간이 너무 많이 걸린다.
- 반복되는 문제 패턴이 wiki에 축적되지 않아 같은 실수가 반복된다.

---

## 목표

- 레벨 열 때마다 또는 요청 시 자동으로 건강 상태 점검
- 발견된 문제를 심각도별로 분류해 리포트 출력
- Wiki Auto-Ingest Hook과 연동해 패턴을 wiki에 자동 누적
- 결과를 클릭하면 에디터에서 해당 액터로 이동

---

## 검사 대상 클래스 정책

> ⚠️ 모든 `AActor`를 무조건 검사하면 오탐이 폭증한다.  
> 검사별로 적용 대상 클래스를 명시하고, 메타 액터는 제외한다.

### 제외 대상 (블랙리스트)
- `AWorldPartitionHLOD`
- `AWorldDataLayers`
- `ALevelInstanceEditorInstanceActor`
- `APackedLevelActor`
- `ABrush` / `AVolume` 계열 (위치·스케일 검사 제외)
- `ADecalActor` (Null 메시 검사 제외)
- `IsEditorOnly() == true` 또는 `bIsEditorOnlyActor == true` 또는 `HasAllFlags(RF_Transient)`

### 검사별 대상 범위
| 검사 항목 | 대상 범위 |
|---|---|
| 위치/스케일 이상 | 모든 배치 가능 액터 (블랙리스트 제외) |
| Null 메시 | `UStaticMeshComponent`를 가진 액터만 (ABrush, ADecal 제외) |
| 액터 겹침 | `AStaticMeshActor` 및 SM 컴포넌트를 가진 BP 액터 |
| PlayerStart | `APlayerStart` 전용 |
| 기본 액터명 | 배치 가능 액터 전체 (기본 OFF, 옵션 설정 시 활성) |

---

## 탐지 항목

### 카테고리 A — 위치 / 변환

> UU = 언리얼 유닛 (1 UU = 1 cm)

| 체크 | 기준 | 심각도 | 비고 |
|---|---|---|---|
| 음수 Z 위치 | `GetActorLocation().Z < -10` UU | 경고 | 지하 구조물 의도적 배치 가능 — 임계값 설정 가능 |
| 원점 정확 배치 | 위치가 `(0,0,0)` 정확히 일치 + Movable/배치 가능 클래스 | 정보 | 싱글톤 액터(DirectionalLight 등) 제외 |
| 극단 스케일 (과대) | `GetActorScale3D()` 성분 중 하나라도 `> 100` | 경고 | |
| 극단 스케일 (과소) | 성분 중 하나라도 `< 0.01` | 경고 | |
| 음수 스케일 | 성분 중 하나라도 `< 0` | 경고 | 미러링은 표준 기법 — "오류"는 과함. `Use Complex As Simple` 콜리전 조합 시 별도 표시 |
| 비균등 스케일 | `Max성분 / Min성분 > 10` | 정보 | 기본 OFF (의도적 왜곡 다수) |

### 카테고리 B — 중복 / 충돌

| 체크 | 기준 | 심각도 | 비고 |
|---|---|---|---|
| PlayerStart 중복 | `APlayerStart` 인스턴스 2개 이상 + `PlayerStartTag` 동일 | 정보 | 멀티플레이·체크포인트에서 다수 정상 — Tag로 구분되면 제외 |
| 액터 겹침 | 동일 `UStaticMesh*` 포인터 + 두 액터 위치 거리 < 1 UU | 경고 | 메시 포인터 버킷별 비교로 효율화 (아래 구현 참조) |
| 액터명 중복 | `GetActorLabel()` 동일한 액터 쌍 | 정보 | |

### 카테고리 C — 참조 / 설정

| 체크 | 기준 | 심각도 | 비고 |
|---|---|---|---|
| Null 메시 StaticMeshComponent | `GetStaticMesh() == nullptr` | 오류 | ABrush, ADecal 등 제외 |
| 인스턴스 0개 ISM/HISM | `GetInstanceCount() == 0` | 경고 | Foliage/PCG 출력 오브젝트 |
| 기본 액터명 | `ClassName_숫자` 패턴 | 정보 | **기본 OFF**, 설정에서 활성화 |
| 레벨 밖 액터 | 절대 한계값 초과: 위치 성분 `> 2,000,000 UU` | 경고 | `AWorldSettings::WorldBounds` 미존재 → 절대 상한값 사용 |

### 카테고리 D — 게임플레이 설정

| 체크 | 기준 | 심각도 | 비고 |
|---|---|---|---|
| PlayerStart 없음 | `APlayerStart` 0개 | 경고 | |
| DefaultPawn 미설정 | `AWorldSettings::DefaultGameMode`로 GameMode 조회 → `DefaultPawnClass == nullptr` | 정보 | GameModeOverride → 프로젝트 기본 GameMode 폴백 체인 적용 |

---

## 심각도 기준

| 심각도 | 의미 | 처리 |
|---|---|---|
| 오류 (Error) | 런타임 크래시 또는 게임플레이 차단 가능 | 즉시 수정 권장 |
| 경고 (Warning) | 품질 문제, 퍼포먼스 영향 가능 | 검토 후 수정 |
| 정보 (Info) | 의도적일 수 있으나 확인 필요 | 참고용 |

---

## 수집 범위

| 소스 | 포함 여부 | 비고 |
|---|---|---|
| 현재 로드된 레벨의 일반 액터 | ✅ | `TActorIterator<AActor>` |
| World Partition 로드된 셀 | ✅ | 현재 로드 범위만 — 리포트에 로드 메타데이터 포함 |
| World Partition 미로드 셀 | ❌ | 1차 릴리스 제외. WP 감지 시 경고 배너 표시 |
| HLOD 및 WP 메타 액터 | ❌ | 블랙리스트 클래스 참조 |
| 에디터 전용 액터 | ❌ | `IsEditorOnly()` / `bIsEditorOnlyActor` / `RF_Transient` |
| Geometry Collection | ❌ | 1차 릴리스 제외 |
| 비활성 Data Layer 액터 | ❌ | 1차 릴리스: 현재 활성 레이어만. 리포트에 활성 레이어 목록 기록 |

---

## 구현 방향

```
1. WP 활성 여부 감지
   - UWorld::GetWorldPartition() != nullptr 이면
     → 결과 패널 상단에 "⚠️ World Partition 활성: 로드된 셀만 스캔됨" 배너 표시
     → 리포트 메타데이터에 로드 셀 좌표 범위 + 셀 수 + 활성 Data Layer 목록 기록

2. TActorIterator<AActor>로 현재 레벨 순회
   - 블랙리스트 클래스 필터링
   - IsEditorOnly / RF_Transient 필터링

3. 각 액터에 체크 목록 순차 실행
   - FHealthIssue 레코드: ActorLabel, ActorClass, Location, CheckId, Severity, Message
   - 같은 액터의 여러 이슈는 액터 단위로 그룹핑

4. 액터 겹침 탐지 (2단계 버킷)
   - 1단계: UStaticMesh* 포인터별 버킷 생성
   - 2단계: 각 버킷 내 액터들끼리 위치 거리 비교 (< 1 UU = 완전 겹침)
   - GetComponentsBoundingBox() 대신 GetActorLocation() 사용 (비용 절감)
   - PCG/Foliage 생성 플래그(bIsSpatiallyLoaded=false, Folder "_Generated_") 제외

5. DefaultPawn 폴백 체인
   - AWorldSettings::DefaultGameMode → 없으면 UGameMapsSettings::GlobalDefaultGameMode
   - 해당 GameMode 클래스의 DefaultPawnClass 확인

6. 결과 리스트 → 심각도 정렬 → 액터별 그룹핑

7. 에디터 패널: 항목 클릭 시 GEditor->SelectActor() + 카메라 이동

8. CSV / JSON 저장 (리포트 메타데이터 포함)
```

---

## 리포트 메타데이터 (JSON 필수 포함)

```json
{
  "levelName": "Level_Main",
  "scanTime": "2026-04-26T14:30:00+09:00",
  "worldPartition": {
    "active": true,
    "loadedCellsBounds": {"min": [-102400, -102400, 0], "max": [102400, 102400, 10000]},
    "loadedCellCount": 12,
    "activeDataLayers": ["Gameplay", "Environment"]
  },
  "totalActorsScanned": 1423,
  "issueCount": {"error": 2, "warning": 7, "info": 15}
}
```

---

## 입출력

**입력 (설정 가능 임계값)**
- 음수 Z 임계값 (기본: -10 UU)
- 극단 스케일 상한 (기본: 100)
- 극단 스케일 하한 (기본: 0.01)
- 비균등 스케일 비율 (기본: 10, 기본 OFF)
- 기본 액터명 검사 (기본 OFF)
- 레벨 밖 절대 상한 (기본: 2,000,000 UU)

**출력**
- 에디터 결과 패널 (심각도별 정렬, 액터별 그룹핑, 클릭 → 액터 선택)
- `Saved/LevelHealth_레벨명_YYYYMMDD_HHmmss.csv`
- `Saved/LevelHealth_레벨명_YYYYMMDD_HHmmss.json` (메타데이터 포함)

---

## Wiki Auto-Ingest Hook 연동

`tools/auto-ingest/config.json` watchTargets에 추가:

```json
{
  "id": "level-health",
  "pattern": "Saved/LevelHealth_*.json",
  "parser": "profiling-json",
  "rawPath": "raw/auto/profiling/",
  "wikiCategory": "pattern",
  "wikiTags": ["level", "health", "scene-scan"],
  "minSizeKB": 1,
  "debounceSeconds": 0
}
```

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| World Partition 미로드 셀 | 현재 로드 범위만 스캔 — 결과 패널에 배너 + 리포트에 셀 메타데이터 필수 |
| 음수 Z 오탐 | 지하 구조물 의도적 배치 가능 — 임계값 조정 가능 |
| 음수 스케일 | 미러링은 표준 기법 → 경고 수준. Use Complex As Simple 조합에서만 추가 표시 |
| PlayerStart 중복 | 멀티플레이/체크포인트에서 정상 — PlayerStartTag 구분 시 제외 |
| 원점 배치 오탐 | 싱글톤성 액터(DirectionalLight 등)는 "정확히 (0,0,0)" 조건 + 클래스 필터로 완화 |
| 겹침 탐지 오탐 | PCG/Foliage 생성 플래그 기반 제외로 완화 |
| 액터 수 많을 때 | 메시 포인터 2단계 버킷으로 겹침 탐지 최적화 |
| Data Layer 비활성 액터 | 1차 릴리스: 활성 레이어만. 리포트에 활성 레이어 목록 명시 |

---

## 완료 기준

### 1차 릴리스
- [ ] 블랙리스트 클래스 필터링 + IsEditorOnly/RF_Transient 제외
- [ ] 카테고리 A~D 전체 체크 구현 (수정된 API 기준)
- [ ] 메시 포인터 2단계 버킷 겹침 탐지
- [ ] DefaultPawn 폴백 체인 (WorldSettings → GameMode → GlobalDefault)
- [ ] WP 활성 감지 + 경고 배너 + 리포트 메타데이터
- [ ] 심각도별 정렬 + 액터별 그룹핑 결과 패널
- [ ] 클릭 → GEditor->SelectActor() + 카메라 이동
- [ ] CSV / JSON 리포트 저장
- [ ] Wiki Auto-Ingest Hook config.json watchTarget 추가

### 2차 릴리스
- [ ] 제외 태그 지원 (`LHC_Ignore` 태그 부여 시 스킵)
- [ ] World Partition 전체 셀 일괄 스캔 (청크 단위 로드→스캔→언로드→flush)
- [ ] 부분 겹침 탐지 (공간 분할 자료구조 적용)
- [ ] `Use Complex As Simple` + 음수 스케일 조합 오류 격상
