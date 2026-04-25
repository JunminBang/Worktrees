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
│   └── specs/                 # 도구별 상세 기획서
│       ├── draw-call-budget-tracker.md
│       ├── foliage-density-normalizer.md
│       ├── collision-complexity-auditor.md
│       └── editor-startup-profiler.md
├── wiki/                      # AI가 유지하는 지식 베이스
│   ├── index.md               # 위키 인덱스
│   ├── systems/               # UE5 시스템별 요약
│   ├── shaders/               # 셰이더 관련 지식
│   └── papers/                # 그래픽스 논문 요약
├── raw/                       # 원본 소스 자료 (읽기 전용)
│   ├── INDEX.md
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

| 카테고리 | 대표 도구 |
|---|---|
| 에셋 파이프라인 | Asset Naming Validator, Texture Audit Tool |
| 씬 / 레벨 관리 | Level Health Checker, Light Complexity Reporter |
| 렌더링 / 머티리얼 | Shader Complexity Visualizer, UV Density Checker |
| 애니메이션 / 리깅 | Anim Notify Auditor, Root Motion Validator |
| VFX / Niagara | Niagara Budget Monitor, VFX Culling Validator |
| 퍼포먼스 프로파일링 | **Draw Call Budget Tracker**, Collision Complexity Auditor |
| 월드 빌딩 | **Foliage Density & Masked Cost Auditor**, PCG Graph Validator |
| 오디오 | Sound Asset Auditor |
| 에디터 UX | **Editor Startup Profiler**, Hotkey Conflict Detector |
| 버전 관리 | Large Binary Watcher, Changenote Auto-Generator |
| 플랫폼 / 인증 | Icon & Splash Spec Validator, Localization String Auditor |
| 빌드 / QA | Blueprint Compile Watchdog, Cook Report Diff |
| Wiki 연동 | Bug Pattern Extractor, Scene Scan to Wiki |

굵게 표시된 도구는 상세 기획서 작성 완료.

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
