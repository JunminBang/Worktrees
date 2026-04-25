# Claude Code Workspace — 통합 운영 지침서

인디 게임 개발을 위한 Claude Code 서브에이전트 협업 체계.
Harness Engineering 철학 위에서 AI가 직접 지식창고를 유지합니다.

---

## 목차

1. [철학 — Harness Engineering](#1-철학--harness-engineering)
2. [지식 축적 — LLM Wiki](#2-지식-축적--llm-wiki)
3. [프로젝트 구조 및 기술 스택](#3-프로젝트-구조-및-기술-스택)
4. [협업 프로토콜](#4-협업-프로토콜)
5. [Wiki 시스템 운영](#5-wiki-시스템-운영)
6. [참고 자료 경로](#6-참고-자료-경로)

---

## 1. 철학 — Harness Engineering

### 핵심 비유

요리사를 고용했다고 상상해 보세요.

이 요리사는 **엄청나게 빠르고, 지치지 않고, 시키는 건 다 합니다.**
단점이 딱 하나 — **우리 식당의 맛이 뭔지 모릅니다.**

> **A.** 매번 옆에 서서 하나하나 지시한다.
> **B.** 레시피북·플레이팅 규칙·재료 원칙을 먼저 만든다. 요리사는 그걸 읽고 혼자 한다.

**Harness Engineering은 B를 선택하는 것입니다.**

### 두 가지 핵심 능력

**① 내가 아는 걸 꺼낼 수 있는 사람**

오래 일하면 판단이 자동화됩니다. "이건 아니야"는 즉시 느끼지만, 왜인지 설명하기 어렵습니다. Harness를 만든다는 건, 그 자동화된 판단을 **다시 언어로 풀어내는 작업**입니다.

```
몸에 익은 감각 (내 머릿속)  →  누구나 따를 수 있는 규칙 (문서)
```

**② 실행이 아니라 구조를 설계하는 사람**

| 일반적 접근 | Harness 접근 |
|---|---|
| 버튼 이름이 잘못됐다 → 내가 고친다 | → 잘못되면 아예 진행이 안 되게 막는다 |
| AI가 엉뚱하게 만들었다 → 내가 수정한다 | → AI가 읽을 원칙 문서를 먼저 만든다 |

### 실무 적용 4단계

**1단계** — 반복되는 불편함 하나를 고른다.
> "신규 캐릭터마다 레퍼런스 무드보드를 처음부터 만들어야 한다"

**2단계** — "잘된 것"과 "아닌 것"을 가르는 기준을 3가지만 써본다.
> 1. 색상은 채도가 낮은 자연 계열을 기본으로 한다.
> 2. 실루엣은 직업 역할이 한눈에 읽혀야 한다.
> 3. 지나치게 만화적인 과장은 피한다.

**3단계** — AI에게 기준을 먼저 보여주고 작업을 요청한다.

| 기준 없이 요청 | 기준을 먼저 건네고 요청 |
|---|---|
| AI가 자기 판단으로 만든다 | AI가 내 기준 안에서 만든다 |
| 매번 다른 결과 | 결과의 방향이 일정해진다 |

**4단계** — AI의 실수를 기준의 빈칸을 찾는 신호로 읽는다.

```
AI의 실수 = 내 기준의 빈칸을 찾아주는 신호
```

반복이 쌓이면:

| 시점 | 기준 분량 | AI 결과 만족도 |
|---|---|---|
| 처음 | 3줄 | 50% |
| 5회 반복 후 | 10줄 | 80% |
| 20회 반복 후 | 한 페이지 | 95% |

> **한 줄 요약**: 내가 아는 것을 문서로 만들면, AI가 나 대신 실행한다.

---

## 2. 지식 축적 — LLM Wiki

### 문제: AI는 매번 처음부터 다시 읽는다

어제 AI와 함께 분석했던 내용, 지난주에 내린 결론 — 다음 대화가 시작되면 모두 사라집니다. 지식이 쌓이지 않습니다.

### 해결: AI가 위키를 만들고 유지한다

```
기존 방식:  자료 보관 → 질문할 때마다 다시 읽음 → 매번 재발견
LLM Wiki:  자료 추가 → AI가 즉시 위키에 통합 → 지식이 누적됨
```

### 구조: 세 가지 층

| 층 | 내용 | 관리 주체 |
|---|---|---|
| **1층 — 원본 자료** | 기사, 레퍼런스, 회의록 (`raw/`) | 나 (읽기 전용) |
| **2층 — 위키** | 주제별 요약·개념 정리·디버그 패턴 (`wiki/`) | AI가 쓴다 |
| **3층 — 스키마** | 위키 구성 규칙, 처리 순서, 페이지 형식 | CLAUDE.md |

### 세 가지 작업 방식

**Ingest (자료 추가)** — `raw/`에 파일 추가 후 AI 호출 → AI가 위키에 통합

**Query (질문)** — 좋은 답변은 위키에 다시 저장. 질문할 때도 위키가 성장한다.

**Lint (점검)** — 주기적으로 AI에게 모순·고립 페이지·오래된 내용 확인

### 왜 개인 위키는 항상 실패했나

유지 비용이 가치보다 빠르게 늘어나기 때문입니다. **AI는 지루해하지 않습니다.** 교차 참조 15개를 한 번에 업데이트하고, 모순을 빠짐없이 표시합니다.

> **한 줄 요약**: AI가 지식창고를 짓고, 나는 탐색하고 질문한다.

---

## 3. 프로젝트 구조 및 기술 스택

```
workspace/
├── .claude/           # 훅, 규칙, wiki 스킬, 설정
│   ├── hooks/         # session-start/stop, pre/post-compact, notify
│   ├── rules/         # unreal-debug.md
│   ├── skills/        # wiki
│   └── docs/          # coding-standards, context-management, directory-structure, technical-preferences
├── wiki/              # AI 유지 지식 베이스 (Unreal 디버그 위키)
├── raw/               # 원본 소스 자료 (읽기 전용)
└── docs/              # 기술 문서, 레퍼런스
    └── engine-reference/  # Unreal API 스냅샷 (버전 고정)
```

- **Engine**: Unreal Engine 5.7
- **Language**: C++ / Blueprint
- **Version Control**: Git (trunk-based development)

---

## 4. 협업 프로토콜

**사용자 주도 협업, 자율 실행 금지.**
모든 작업은 **질문 → 선택지 → 결정 → 초안 → 승인** 순서로 진행합니다.

- 에이전트는 Write/Edit 전 반드시 `"[filepath]에 저장해도 될까요?"` 질문
- 초안을 먼저 보여주고 승인 요청
- 다중 파일 변경 시 전체 변경 목록에 명시적 승인 필요
- 사용자 지시 없이 커밋 금지

---

## 5. Wiki 시스템 운영

### 워크플로우 명령어

#### Ingest — 소스 추가
`raw/`에 파일을 추가하고 호출:
1. 파일 읽기 → 핵심 정보 추출 (에셋명, 시스템, 버그 등)
2. `wiki/assets/` 또는 `wiki/systems/` 페이지 생성/업데이트
3. `wiki/index.md` 업데이트
4. `wiki/log.md`에 추가: `## [YYYY-MM-DD] ingest | 파일명`

#### Debug — 디버그 질문
1. `wiki/index.md` **만** 읽어서 관련 페이지 파악 (전체 wiki 읽기 금지)
2. 관련 페이지만 선택적으로 읽기 (최대 3개)
3. wiki에 답이 있으면 → 씬 스캔 생략하고 바로 답변
4. wiki에 없을 때만 → `docs/engine-reference/unreal/` 먼저 확인 후 없으면 엔진 소스 Grep
5. 소스 참조 시 → 파일 전체 Read 금지, Grep으로 특정 심볼만 추출
6. `wiki/log.md`에 추가: `## [YYYY-MM-DD] debug | 질문 요약`

#### Scan — 씬 스캔

> ⚠️ **MCP 브릿지 재설치 필요** — 현재 비활성. MCP 설치 후 아래 절차 활성화.

1. **반드시 `filter_class` 지정** — 무필터 호출 금지
   - 예: `list_actors(filter_class="StaticMeshActor")`
2. 의심 패턴 자동 탐지: 겹친 액터, 음수 Z, 극단적 스케일, PlayerStart 이상
3. `wiki/log.md`에 추가: `## [YYYY-MM-DD] scan | 레벨명`

#### Lint — wiki 건강 체크
1. 링크 없는 고립 페이지 탐지
2. `index.md`에 없는 페이지 탐지
3. 구식 내용 확인 (삭제된 기능·변경된 규칙 반영 여부)
4. 추가 조사 필요 항목 제안

### 페이지 형식

**에셋 페이지** (`wiki/assets/[Name].md`)
```yaml
---
name: [에셋명]
type: [StaticMesh / Blueprint / System / ...]
tags: [관련 태그]
source: scene-scan | engine-source | general-knowledge | raw-ingest
scene_verified: true | false
last_updated: YYYY-MM-DD
---
```

### Wiki 규칙

| 규칙 | 내용 |
|---|---|
| `raw/` 수정 금지 | 읽기 전용 소스 — 절대 수정 불가 |
| `wiki/log.md` | append-only — 기존 항목 수정 금지 |
| `wiki/index.md` | 매 작업 후 반드시 업데이트 |
| 컨텍스트 절약 | index.md 먼저 → 필요한 페이지만 최대 3개 |
| 소스 탐색 | Grep만 사용 — 엔진 소스 파일 전체 Read 금지 |
| 씬 스캔 | `filter_class` 필수 — 무필터 `list_actors()` 호출 금지 |
| general-knowledge | 단독 페이지는 본문에 ⚠️ 경고 표시 |

---

## 6. 참고 자료 경로

### Engine Reference (`docs/engine-reference/`)

버전 고정된 엔진 API 스냅샷입니다.
**엔진 API 사용 전 반드시 여기를 먼저 확인하세요** — LLM의 학습 데이터는 고정 버전보다 오래됐을 수 있습니다.

현재 엔진 버전: `docs/engine-reference/unreal/VERSION.md` 참조

### Wiki ↔ Engine Reference 도메인 매핑

같은 서브시스템을 **wiki**는 일반 지식·디버그 패턴으로, **engine-reference**는 UE5.7 버전별 API 변경으로 다룬다. 엔진 API 관련 작업 시 두 곳을 함께 확인할 것.

| Wiki 시스템 페이지 | Engine Reference 모듈 |
|---|---|
| `systems/rendering.md`, `ue5_rendering_shader.md`, `lighting.md` | `modules/rendering.md` |
| `systems/animation.md`, `ue5_animation_physics.md` | `modules/animation.md`, `modules/physics.md` |
| `systems/ue5_audio_vfx.md` | `modules/audio.md` |
| `systems/ue5_ai_navigation.md` | `modules/navigation.md` |
| `systems/ue5_ui_cinematics.md` | `modules/ui.md` |
| `systems/ue5_world_network.md` | `modules/networking.md` |

### 관련 문서
- 코딩 표준: `.claude/docs/coding-standards.md`
- 컨텍스트 관리: `.claude/docs/context-management.md`
- Unreal 디버그 규칙: `.claude/rules/unreal-debug.md`
