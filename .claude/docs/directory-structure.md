# Directory Structure

```text
/
├── CLAUDE.md                    # 마스터 설정
├── .claude/                     # 스킬, 훅, 규칙, 문서
├── wiki/                        # AI 유지 지식 베이스 (주제별 요약)
│   ├── index.md                 # 전체 페이지 인덱스 (매 작업 후 갱신)
│   ├── log.md                   # append-only 작업 로그
│   ├── assets/                  # 에셋 페이지
│   └── systems/                 # 시스템 페이지
├── raw/                         # 원본 소스 자료 — AI 수정 금지 (읽기 전용)
├── src/                         # 게임 소스 코드 (core, gameplay, ai, networking, ui, tools)
├── assets/                      # 게임 에셋 (art, audio, vfx, shaders, data)
├── design/                      # 게임 설계 문서 (gdd, narrative, levels, balance)
├── docs/                        # 기술 문서 (architecture, api, postmortems)
│   └── engine-reference/        # 버전 고정 엔진 API 스냅샷
├── tests/                       # 테스트 스위트 (unit, integration, performance, playtest)
├── tools/                       # 빌드 및 파이프라인 도구 (ci, build, asset-pipeline)
├── prototypes/                  # 임시 프로토타입 (src/와 격리)
└── production/                  # 프로덕션 관리 (sprints, milestones, releases)
    ├── session-state/           # 임시 세션 상태 (active.md — gitignore 대상)
    └── session-logs/            # 세션 감사 로그 (gitignore 대상)
```
