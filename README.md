# Worktrees — UE5 인디 게임 개발 워크스페이스

Unreal Engine 5.7 기반 인디 게임 개발을 위한 Claude Code 서브에이전트 협업 체계.
**Harness Engineering** 철학 위에서 AI가 직접 지식창고를 유지하고, TA 도구 기획을 누적합니다.

---

## 철학 — Harness Engineering

> 요리사를 고용했다면, 매번 옆에서 지시하는 대신 **레시피북을 먼저 만들어라.**

AI는 빠르고 지치지 않지만, 우리 프로젝트의 기준을 모릅니다.  
Harness Engineering은 그 기준을 문서로 만들어 AI가 스스로 따르게 하는 방식입니다.

```
몸에 익은 감각 (내 머릿속)  →  누구나 따를 수 있는 규칙 (문서)  →  AI가 실행
```

---

## 프로젝트 구조

```
workspace/
├── CLAUDE.md                  # AI 협업 운영 지침 (Harness 핵심 문서)
├── plans/                     # TA 도구 기획서
│   ├── ta-tools-plan.md       # 전체 도구 목록 (41개)
│   └── specs/                 # 도구별 상세 기획서 (15개)
│       ├── asset-naming-validator.md
│       ├── actor-tag-auditor.md
│       ├── blueprint-compile-watchdog.md
│       ├── collision-complexity-auditor.md
│       ├── draw-call-budget-tracker.md
│       ├── editor-startup-profiler.md
│       ├── foliage-density-normalizer.md
│       ├── level-health-checker.md
│       ├── light-complexity-reporter.md
│       ├── lod-auto-generator.md
│       ├── material-instance-batcher.md
│       ├── material-param-propagator.md
│       ├── orphan-asset-finder.md
│       ├── shader-complexity-visualizer.md
│       ├── streaming-level-validator.md
│       ├── texture-audit-tool.md
│       ├── uv-density-checker.md
│       └── vertex-color-painter-batch.md
├── tools/
│   └── auto-ingest/           # Wiki Auto-Ingest Hook [완료]
│       ├── config.json        # 감시 대상 설정 (UE 프로젝트 경로 포함)
│       ├── scan.ps1           # 원샷 스캔 (session-start에서 호출)
│       ├── watcher.ps1        # 실시간 FileSystemWatcher
│       └── parsers/
│           ├── build-log.ps1
│           ├── profiling-json.ps1
│           └── profiling-csv.ps1
├── wiki/                      # AI가 유지하는 지식 베이스
│   ├── index.md               # 위키 인덱스
│   ├── systems/               # UE5 시스템별 요약
│   ├── shaders/               # 셰이더 관련 지식
│   └── papers/                # 그래픽스 논문 요약
├── raw/                       # 원본 소스 자료 (읽기 전용)
│   ├── INDEX.md
│   ├── auto/                  # Auto-Ingest 자동 생성 Markdown (git 제외)
│   └── graphics/              # 그래픽스 연구 논문
└── docs/
    └── engine-reference/      # UE5.7 버전 고정 API 레퍼런스
        └── unreal/
            ├── VERSION.md
            ├── breaking-changes.md
            └── modules/
```

---

## 기술 스택

| 항목 | 내용 |
|---|---|
| **Engine** | Unreal Engine 5.7 |
| **Language** | C++ / Blueprint |
| **Rendering** | CSM / Legacy Material / Lumen (옵션) |
| **Version Control** | Git (trunk-based) |

---

## TA 도구 기획 목록

총 **13개 카테고리 / 41개 도구** 기획 중. 상세 목록은 [plans/ta-tools-plan.md](plans/ta-tools-plan.md) 참조.

| 카테고리 | 대표 도구 | 기획서 |
|---|---|---|
| 에셋 파이프라인 | Asset Naming Validator, LOD Auto Generator, Texture Audit Tool | `[검]` |
| 씬 / 레벨 관리 | Level Health Checker, Light Complexity Reporter | `[검]` |
| 렌더링 / 머티리얼 | Shader Complexity Visualizer, UV Density Checker, Vertex Color Painter Batch | `[검]` |
| 애니메이션 / 리깅 | Anim Notify Auditor, Root Motion Validator | `[ ]` |
| VFX / Niagara | Niagara Budget Monitor, VFX Culling Validator | `[ ]` |
| 퍼포먼스 프로파일링 | Draw Call Budget Tracker, Collision Complexity Auditor | `[검]` |
| 월드 빌딩 | Foliage Density Normalizer, PCG Graph Validator | `[검]` / `[ ]` |
| 오디오 | Sound Asset Auditor | `[ ]` |
| 에디터 UX | Editor Startup Profiler, Hotkey Conflict Detector | `[검]` / `[ ]` |
| 버전 관리 | Large Binary Watcher, Changenote Auto-Generator | `[ ]` |
| 플랫폼 / 인증 | Icon & Splash Spec Validator, Localization String Auditor | `[ ]` |
| 빌드 / QA | Blueprint Compile Watchdog, Cook Report Diff | `[검]` / `[ ]` |
| Wiki 연동 | **Wiki Auto-Ingest Hook** ✅ | `[x]` |

### 진행 상태 기준

| 상태 | 의미 |
|---|---|
| `[ ]` | 미착수 |
| `[기]` | 기획서 작성 완료 (어드바이저 검수 전) |
| `[검]` | 기획서 검수 완료 (구현 대기) |
| `[~]` | 구현 중 |
| `[x]` | 완료 |

---

## Wiki Auto-Ingest Hook

빌드 로그 / 프로파일링 결과물을 자동으로 `raw/auto/`에 저장하고, 세션 시작 시 wiki ingest를 트리거하는 파이프라인.

```
UE 프로젝트 파일 변경
        ↓
tools/auto-ingest/scan.ps1   ← session-start 훅에서 자동 호출
        ↓
raw/auto/queue/pending/      ← 처리 대기 큐 (디렉토리 큐, 원자적)
        ↓
Claude 세션 시작 시 알림 → wiki_ingest 호출
        ↓
raw/auto/queue/done/         ← 완료 항목
```

**사용 방법**:
1. `tools/auto-ingest/config.json`에서 `ueProjectPath` 설정
2. 세션 시작 시 자동으로 scan.ps1 실행 (pending 항목 알림)
3. 실시간 감시가 필요하면 별도 터미널에서 `watcher.ps1` 실행

---

## LLM Wiki 시스템

AI가 지식창고를 짓고, 사람은 탐색하고 질문한다.

```
기존 방식:  자료 보관 → 질문할 때마다 다시 읽음 → 매번 재발견
LLM Wiki:  자료 추가 → AI가 즉시 위키에 통합  → 지식이 누적됨
```

| 층 | 내용 | 관리 주체 |
|---|---|---|
| 1층 — 원본 자료 | 기사, 레퍼런스, 회의록 (`raw/`) | 사람 (읽기 전용) |
| 2층 — 위키 | 주제별 요약·개념 정리 (`wiki/`) | AI가 쓴다 |
| 3층 — 스키마 | 위키 구성 규칙, 처리 순서 | CLAUDE.md |

---

## Engine Reference

`docs/engine-reference/unreal/`은 **UE 5.7 버전 고정** API 레퍼런스입니다.  
LLM의 학습 데이터는 UE 5.3까지만 커버하므로, 엔진 API 사용 전 반드시 여기를 먼저 확인합니다.

---

## 협업 프로토콜

- 모든 작업은 **질문 → 선택지 → 결정 → 초안 → 승인** 순서로 진행
- Write/Edit 전 반드시 저장 경로 확인
- 사용자 지시 없이 커밋 금지
