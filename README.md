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
│   └── specs/                 # 도구별 상세 기획서 (19개)
├── tools/
│   └── auto-ingest/           # Wiki Auto-Ingest Hook [완료]
│       ├── config.json
│       ├── scan.ps1
│       ├── watcher.ps1
│       └── parsers/
├── wiki/                      # AI가 유지하는 지식 베이스
│   ├── index.md
│   ├── systems/
│   ├── shaders/
│   └── papers/
├── raw/                       # UE5.7 엔진 레퍼런스 문서 (45개, 크로스링크 완료)
│   ├── INDEX.md
│   ├── 00_overview.md ~ 53_profiling_optimization.md
│   ├── auto/                  # Auto-Ingest 자동 생성 (git 제외)
│   └── graphics/              # 그래픽스 연구 논문
└── docs/
    └── engine-reference/      # UE5.7 버전 고정 API 레퍼런스
```

---

## 기술 스택

| 항목 | 내용 |
|---|---|
| **Engine** | Unreal Engine 5.7 (5.5 호환) |
| **Language** | C++ / Blueprint |
| **Rendering** | Lumen / Nanite / TSR |
| **Version Control** | Git (trunk-based) |

---

## UE5 엔진 레퍼런스 문서 (`raw/`)

총 **45개** UE5.7 시스템별 레퍼런스 문서. 모든 문서에 `## 관련 문서` 양방향 크로스링크 완료.

| 카테고리 | 문서 |
|---|---|
| **게임플레이** | `00_overview` `01_gameplay_framework` `09_gameplay_ability_system` `16_data_management` `18_save_load` |
| **렌더링 & 라이팅** | `02_rendering` `20_ray_tracing` `25_lighting_system` `39_volumetric_clouds` |
| **머티리얼 & 텍스처** | `14_textures_advanced` `24_material_advanced` `19_decals` |
| **애니메이션 & 캐릭터** | `03_animation_physics` `15_control_rig` `26_skeletal_mesh_lod` `28_motion_warping` `44_character_movement` `45_physics_ragdoll` |
| **월드 빌딩** | `07_world_network_assets` `11_pcg_procedural` `31_level_instance` `35_landscape_advanced` `40_world_partition` `43_foliage_system` |
| **메시 & 소켓** | `42_staticmesh_advanced` `47_socket_system` `48_collision_trace` `50_physical_material` |
| **VFX & 오디오** | `04_audio_effects` `29_metasounds` `32_niagara_advanced` `12_groom_hair` |
| **UI & 카메라** | `06_ui_cinematics` `17_camera_system` `36_sequencer_advanced` |
| **AI & 시스템** | `05_ai_navigation` `27_mass_entity` `10_chaos_destruction` `13_online_multiplayer` |
| **엔진 & 에디터** | `08_editor_systems` `21_blueprint_advanced` `22_plugins` `30_geometry_script` |
| **환경** | `23_water_volumes` `39_volumetric_clouds` |
| **최적화** | `53_profiling_optimization` |

> 모든 문서는 UE5.5 이상과 호환됩니다.

---

## TA 도구 기획

### 기획 완료 도구 (19개 기획서)

| 카테고리 | 도구 | 상태 |
|---|---|---|
| 에셋 파이프라인 | Asset Naming Validator | `[검]` |
| 에셋 파이프라인 | LOD Auto Generator | `[검]` |
| 에셋 파이프라인 | Texture Audit Tool | `[검]` |
| 에셋 파이프라인 | Orphan Asset Finder | `[검]` |
| 에셋 파이프라인 | Material Instance Batcher | `[검]` |
| 에셋 파이프라인 | Material Param Propagator | `[검]` |
| 씬 / 레벨 | Level Health Checker | `[검]` |
| 씬 / 레벨 | Light Complexity Reporter | `[검]` |
| 씬 / 레벨 | Streaming Level Validator | `[검]` |
| 씬 / 레벨 | Actor Tag Auditor | `[검]` |
| 렌더링 | Shader Complexity Visualizer | `[검]` |
| 렌더링 | UV Density Checker | `[검]` |
| 렌더링 | Vertex Color Painter Batch | `[검]` |
| 퍼포먼스 | Draw Call Budget Tracker | `[검]` |
| 퍼포먼스 | Collision Complexity Auditor | `[검]` |
| 월드 빌딩 | Foliage Density Normalizer | `[검]` |
| 에디터 UX | Editor Startup Profiler | `[검]` |
| 빌드 / QA | Blueprint Compile Watchdog | `[검]` |
| Wiki 연동 | **Wiki Auto-Ingest Hook** | `[x]` ✅ |

### 레퍼런스 기반 추가 후보 도구 (구현 대기)

`raw/` 문서 분석을 통해 도출한 추가 도구 아이디어:

| 도구 | 기반 문서 |
|---|---|
| 머티리얼 컨벤션 체커 (Instruction Count, 네이밍) | `24_material_advanced` |
| 라이팅 씬 오디터 (Movable 광원 수, Cast Shadows) | `25_lighting_system` |
| 데칼 헬스 모니터 (DBuffer/Deferred 혼용, LifeSpan) | `19_decals` |
| Niagara 예산 트래커 | `32_niagara_advanced` |
| Physics Asset 자동 생성 보조 | `45_physics_ragdoll` |
| Physical Material 자동 할당기 | `50_physical_material` |
| World Partition 설정 체커 | `40_world_partition` |
| Socket 네이밍 컨벤션 체커 | `47_socket_system` |
| 씬 복잡도 대시보드 | `53_profiling_optimization` |

### 진행 상태 기준

| 상태 | 의미 |
|---|---|
| `[ ]` | 미착수 |
| `[기]` | 기획서 작성 완료 (검수 전) |
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
raw/auto/queue/pending/      ← 처리 대기 큐
        ↓
Claude 세션 시작 시 알림 → wiki_ingest 호출
        ↓
raw/auto/queue/done/         ← 완료 항목
```

**사용 방법**:
1. `tools/auto-ingest/config.json`에서 `ueProjectPath` 설정
2. 세션 시작 시 자동으로 scan.ps1 실행
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

## 협업 프로토콜

- 모든 작업은 **질문 → 선택지 → 결정 → 초안 → 승인** 순서로 진행
- Write/Edit 전 반드시 저장 경로 확인
- 사용자 지시 없이 커밋 금지
