# 기획서 — Wiki Auto-Ingest Hook

> 작성일: 2026-04-26  
> 수정일: 2026-04-26 (어드바이저 검수 반영)  
> 카테고리: 빌드 / 퀄리티 게이트 / Wiki 연동  
> 우선순위: 높음 (지식 축적 자동화 기반 인프라)

---

## 개요

빌드 로그, 디버그 로그, 프로파일링 결과물이 생성될 때 자동으로 감지해 `raw/auto/`에 저장하고, wiki ingest를 트리거해 지식이 대화 없이도 누적되도록 하는 자동화 파이프라인.

**핵심 제약**: `wiki_ingest`는 MCP 도구이므로 Claude 세션 내에서만 호출 가능.  
→ 외부 스크립트는 파일을 파싱해 `raw/auto/`에 Markdown 저장 + 디렉토리 큐에 항목 추가.  
→ Claude가 세션 시작 시 큐를 읽고 `wiki_ingest`를 호출한다.

---

## 문제 정의

- 빌드/디버그 로그는 매번 생성되지만 대부분 `Saved/Logs/`에 쌓이다 사라진다.
- 중요한 에러 패턴, 퍼포먼스 병목, 반복되는 경고가 wiki에 반영되려면 사람이 수동으로 ingest를 호출해야 한다.
- 프로파일링 도구(Draw Call Budget Tracker 등)가 리포트를 저장해도 wiki에 연결되지 않으면 지식이 누적되지 않는다.
- 세션이 끊기면 이전 분석 결과가 사라져 다음 대화에서 재발견해야 한다.

---

## 목표

- 지정된 소스(로그, 리포트, 프로파일링 결과)를 자동 감지 → `raw/auto/`에 저장 → wiki ingest 트리거
- 사람의 개입 없이 지식이 쌓이는 구조 확립
- 기존 TA 도구들(Draw Call Budget Tracker, Foliage Auditor 등)의 출력을 wiki와 자동 연결

---

## 트리거 소스 목록

| 소스 | 감지 방법 | 저장 경로 |
|---|---|---|
| UE 빌드 로그 | `Saved/Logs/*.log` 파일 변경 감시 | `raw/auto/logs/` |
| Blueprint 컴파일 에러 | Commandlet 출력 파싱 | `raw/auto/logs/` |
| Draw Call Budget 리포트 | `Saved/Profiling/GraphicsAudit_*.json` 생성 감지 | `raw/auto/profiling/` |
| Foliage Audit 리포트 | `Saved/FoliageReport_*.csv` 생성 감지 | `raw/auto/profiling/` |
| Collision Audit 리포트 | `Saved/CollisionAudit_*.csv` 생성 감지 | `raw/auto/profiling/` |
| Editor Startup Profile | `Saved/Profiling/StartupProfile_*.json` 생성 감지 | `raw/auto/profiling/` |
| 커스텀 소스 | 설정 파일에 경로/패턴 추가 | 설정에서 지정 |

---

## 파이프라인 흐름

```
① scan.ps1 실행 (세션 시작 시 자동, 또는 수동 실행)
        ↓
② watchTargets 순회 — lastScanTimestamp 이후 새 파일 수집
        ↓
③ 파서 실행 (build-log / profiling-json / profiling-csv)
   - 에러/경고 없으면 $null 반환 → 저장 생략
   - 100MB 초과 처리 규칙 적용
        ↓
④ Markdown → raw/auto/ 에 원자적 저장 (tmp → rename)
        ↓
⑤ 큐 항목 생성 → raw/auto/queue/pending/<guid>.json 에 저장
   (id, rawPath, wikiCategory, wikiTags, sourceFile, dedupKey, status 포함)
        ↓
⑥ Claude 세션 시작 시 session-start.sh 가 pending 수 감지 → 알림
        ↓
⑦ Claude가 컨슈머 프로토콜에 따라 wiki_ingest 호출
        ↓
⑧ 완료 항목: pending/ → done/ 이동 (원자적)
   실패 항목: pending/ → failed/ 이동 (attempts, lastError 기록)
```

---

## 큐 구조 (디렉토리 큐)

> 단일 JSON 배열(pending-ingest.json) 방식은 동시성 위험이 있어 디렉토리 큐로 설계.  
> 항목당 파일 1개 — NTFS `Move-Item`(rename)이 원자적이므로 락 불필요.

```
raw/auto/
├── queue/
│   ├── pending/    ← Claude가 처리 대기 중인 항목
│   │   └── <guid>.json
│   ├── done/       ← wiki_ingest 완료 항목
│   │   └── <guid>.json
│   └── failed/     ← 실패 항목 (attempts, lastError 기록)
│       └── <guid>.json
├── logs/           ← 빌드 로그 Markdown
└── profiling/      ← 프로파일링 Markdown
```

### 큐 항목 스키마

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "rawPath": "raw/auto/profiling/GraphicsAudit_Level01_20260426_143022.md",
  "wikiCategory": "pattern",
  "wikiTags": ["profiling", "performance", "graphics"],
  "sourceFile": "D:/UEProject/Saved/Profiling/GraphicsAudit_Level01_20260426.json",
  "createdAt": "2026-04-26T14:30:22+09:00",
  "status": "pending",
  "attempts": 0,
  "dedupKey": "sha1(path:size:mtime_ticks)",
  "lastError": null
}
```

---

## 컨슈머 프로토콜 (Claude 처리 절차)

> session-start.sh에서 pending 수가 0보다 크면 Claude가 아래 절차를 따른다.

```
1. raw/auto/queue/pending/ 의 *.json 파일 목록 읽기
2. 각 항목에 대해:
   a. rawPath 파일 읽기 (Markdown 내용 확인)
   b. wiki_ingest 호출 (wikiCategory, wikiTags, rawPath 내용 전달)
   c. 성공 시  → pending/<guid>.json 을 done/<guid>.json 으로 이동
   d. 실패 시  → attempts++ / lastError 기록 후 failed/ 로 이동
3. 같은 dedupKey가 done/ 에 이미 있으면 → 중복 처리 스킵
4. wiki/log.md 에 처리 결과 append
```

**항목 20개 초과 시**: 전체 일괄 처리 대신 카테고리별 우선순위를 사용자에게 물어본 후 처리.

---

## 파싱 규칙

### 빌드 로그 파싱

```
추출 항목:
- Error/Fatal/Assertion/링커 에러 라인 수집 (UE 실제 포맷 커버)
  패턴: (^|\s)(Error:|Fatal error!|Assertion failed:|error LNK|error C\d+)
- 100MB 초과 시 마지막 500줄 파싱 (UE fatal은 로그 끝에 위치)
- 반복 패턴 (숫자 정규화 후 동일 에러 3회 이상 → "반복 에러" 태그)
- 컴파일 완료 시간
- 에러/경고 0건 → $null 반환 (raw 저장 생략)

wiki 카테고리: debugging
태그: ["build", "error", "ue5"]
```

### 프로파일링 리포트 파싱 (JSON)

```
추출 항목:
- 알려진 스키마만 처리 (budgetExceeded / candidates / environment)
- 알 수 없는 스키마 → $null 반환 (민감정보 raw dump 금지)
- 100MB 초과 JSON → 파싱 생략 (부분 파싱 무의미), oversized 메타만 기록
- PS 5.1 호환 (??  연산자 사용 금지)

wiki 카테고리: pattern
태그: ["profiling", "performance", 도구명]
```

### CSV 감사 리포트 파싱

```
추출 항목:
- 헤더 + 상위 20행
- 총 항목 수 요약
- 셀 안 파이프·줄바꿈·탭 escape (마크다운 테이블 보호)

wiki 카테고리: pattern
태그: ["profiling", 도구명]
```

---

## 중복 / 노이즈 방지 규칙

| 상황 | 처리 방식 |
|---|---|
| 동일 파일 재처리 | dedupKey(SHA1) 검사 — pending/done/failed에 이미 있으면 스킵 |
| 파일 크기 1KB 미만 | 무시 (빈 로그 필터링) |
| 빌드 성공 로그 (에러/경고 0건) | raw/ 저장 생략 ($null 반환) |
| debounceSeconds 이내 재트리거 | 마지막 변경만 처리 |
| pending 20개 초과 | 자동 일괄 처리 대신 수동 우선순위 선택 요청 |
| wiki_ingest 실패 | failed/ 이동 + attempts 기록. 3회 초과 시 수동 검토 안내 |

---

## 설정 파일

`tools/auto-ingest/config.json` — 코드 수정 없이 소스 추가 가능.

```json
{
  "ueProjectPath": "",
  "workspacePath": "D:/workspace",
  "watchTargets": [
    {
      "id": "build-log",
      "pattern": "Saved/Logs/*.log",
      "parser": "build-log",
      "rawPath": "raw/auto/logs/",
      "wikiCategory": "debugging",
      "wikiTags": ["build", "ue5"],
      "minSizeKB": 1,
      "debounceSeconds": 600
    }
  ]
}
```

새 TA 도구 추가 시 → `watchTargets`에 항목 하나 추가로 연동 완료.

---

## 구현 방향

- **파일 감시**: PowerShell `FileSystemWatcher` (watcher.ps1) 또는 원샷 스캔 (scan.ps1)
- **권장 운용 방식**: `scan.ps1` 단독 (세션 시작 시 자동 실행). 인디 프로젝트 규모에서 실시간 감시 불필요
- **watcher.ps1 v1 제한**: 이벤트 핸들러 runspace 분리로 인해 scan.ps1을 별도 프로세스로 호출하는 방식으로 우회 구현. v2에서 개선 예정
- **wiki ingest 호출**: OMC `wiki_ingest` MCP 도구 (Claude 세션 내에서만 가능)

---

## 다른 TA 도구와의 연동

| TA 도구 | Auto-Ingest 연동 |
|---|---|
| Draw Call Budget Tracker | 리포트 저장 시 자동 ingest → `wiki/pattern/graphics-budget.md` 누적 |
| Foliage Density & Masked Cost Auditor | CSV 저장 시 자동 ingest → `wiki/pattern/foliage-hotspot.md` 누적 |
| Collision Complexity Auditor | CSV 저장 시 자동 ingest → `wiki/pattern/collision-audit.md` 누적 |
| Editor Startup Profiler | 프로파일 저장 시 자동 ingest → `wiki/pattern/startup-bottleneck.md` 누적 |
| Blueprint Compile Watchdog | 에러 CSV 저장 시 자동 ingest → `wiki/debugging/bp-errors.md` 누적 |

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| wiki_ingest 세션 의존 | 외부 스크립트 단독으로는 ingest 불가 → 큐 + 세션 시작 알림으로 해결 |
| UE 로그 쓰기 중 트리거 | 파일 락 또는 부분 쓰기 상태에서 파서 실행 가능 → 파싱 실패 시 $null 반환으로 안전하게 스킵 |
| `Saved/Logs/*.log` 백업 파일 | UE가 백업 로그를 같은 폴더에 생성 → 세션당 N개가 한꺼번에 큐 진입. debounceSeconds 600으로 완화 |
| raw/ 쓰기 금지 원칙 | 자동 변환 파일은 `raw/auto/` 서브폴더에 저장, git 제외 (`.gitignore`) |
| watcher.ps1 v1 | runspace 분리로 Start-Process 우회 사용. v2 예정 (trigger.txt append + polling) |
| 100MB+ JSON | 부분 파싱 무의미 → oversized 메타만 기록하고 직접 확인 안내 |
| 민감정보 노출 | 알 수 없는 JSON 스키마는 raw dump 금지, 알려진 필드만 추출 |

---

## 완료 기준

### 1차 릴리스 (현재 구현 중)
- [x] `config.json` 기반 watchTargets 설정
- [x] 빌드 로그 파서 (UE 에러 포맷 커버, 마지막 500줄, PS 5.1 호환)
- [x] 프로파일링 JSON 파서 (알려진 스키마 + oversized 처리 + 민감정보 보호)
- [x] CSV 파서 (셀 escape, 100MB 처리)
- [x] scan.ps1 — 디렉토리 큐, dedupKey 중복 검사, 원자적 쓰기
- [x] watcher.ps1 v1 — Start-Process 우회로 closure 버그 회피
- [x] session-start.sh — pending 수 감지 + 20개 초과 분기
- [x] 어드바이저 검수 훅 (session-start.sh — [기] 상태 기획서 경고)
- [ ] ueProjectPath 실 경로 설정 후 end-to-end 검증
- [ ] wiki ingest 완료 시 done/ 이동 + wiki/log.md append

### 2차 릴리스
- [ ] watcher.ps1 v2 (trigger.txt append + scan.ps1 polling 분리)
- [ ] Pixel Shader Instruction 수집 (FMaterialStatsUtils)
- [ ] 에디터 내 Auto-Ingest 상태 패널 (Editor Utility Widget)
- [ ] failed/ 항목 retry UI
