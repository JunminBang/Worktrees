# TA 플러그인 / 스크립트 제작 계획

> 생성일: 2026-04-25  
> 대상 엔진: Unreal Engine 5.7  
> 목적: 반복 작업 자동화, 품질 게이트 강화, Wiki 연동

---

## 진행 상태 기준

- `[ ]` 미착수
- `[~]` 진행 중
- `[x]` 완료

---

## 1. 에셋 파이프라인

| 상태 | 도구명 | 설명 |
|---|---|---|
| `[ ]` | **Asset Naming Validator** | 에셋명 컨벤션(`SM_`, `T_`, `M_` 등) 위반 자동 탐지 + 일괄 리네임 |
| `[ ]` | **LOD Auto Generator** | StaticMesh 임포트 시 LOD 자동 생성 및 기준치 적용 |
| `[ ]` | **Texture Audit Tool** | 해상도 pow2 미준수, 과다 메모리 텍스처 탐지, 압축 포맷 일괄 변경 |
| `[ ]` | **Orphan Asset Finder** | 참조 없는 에셋 탐지 → 삭제 목록 생성 |
| `[ ]` | **Material Instance Batcher** | 같은 부모 Material 공유 MI 묶음 분석 + 리다이렉트 정리 |

---

## 2. 씬 / 레벨 관리

| 상태 | 도구명 | 설명 |
|---|---|---|
| `[ ]` | **Level Health Checker** | 겹친 액터, 음수 Z, 극단 스케일, PlayerStart 중복 자동 탐지 |
| `[ ]` | **Light Complexity Reporter** | Dynamic Light 수, 영향 반경 중복 구간 시각화 |
| `[ ]` | **Actor Tag Auditor** | GameplayTag 미부여 액터 목록, 태그 스키마 위반 탐지 |
| `[ ]` | **Streaming Level Validator** | World Partition / Level Streaming 설정 일관성 검사 |

---

## 3. 렌더링 / 머티리얼

| 상태 | 도구명 | 설명 |
|---|---|---|
| `[ ]` | **Shader Complexity Visualizer** | 지정 레벨 머티리얼 인스트럭션 수 상위 N개 리포트 |
| `[ ]` | **Material Param Propagator** | 부모 Material 파라미터 변경 → 연결된 MI 전체 일괄 반영 |
| `[ ]` | **UV Density Checker** | Texel Density 기준치 벗어난 메시 탐지 + 힌트맵 출력 |
| `[ ]` | **Vertex Color Painter Batch** | 선택 메시 전체에 동일 Vertex Color 레이어 일괄 도포 |

---

## 4. 애니메이션 / 리깅

| 상태 | 도구명 | 설명 |
|---|---|---|
| `[ ]` | **Anim Notify Auditor** | AnimBP 전체 순회 → 미사용 / 중복 Notify 탐지 |
| `[ ]` | **Root Motion Validator** | Root Motion 활성화 여부 + 애니메이션 오프셋 이상값 검사 |
| `[ ]` | **Blend Space Grid Checker** | BlendSpace 샘플 밀도 불균형, 빈 구간 탐지 |

---

## 5. VFX / Niagara

| 상태 | 도구명 | 설명 |
|---|---|---|
| `[ ]` | **Niagara Budget Monitor** | 파티클 시스템별 GPU/CPU 비용 상한 초과 경보 |
| `[ ]` | **VFX Culling Validator** | 화면 밖 Niagara 시스템의 Culling 설정 누락 탐지 |

---

## 6. 빌드 / 퀄리티 게이트

| 상태 | 도구명 | 설명 |
|---|---|---|
| `[ ]` | **Cook Report Diff** | 두 빌드 간 패키지 크기 변동 자동 비교 + 원인 에셋 지목 |
| `[ ]` | **Blueprint Compile Watchdog** | Commandlet로 전체 BP 컴파일 → 에러/경고 CSV 출력 |
| `[ ]` | **Wiki Auto-Ingest Hook** | 빌드/디버그 로그 자동으로 `raw/`에 저장 후 wiki ingest 트리거 |

---

## 8. 퍼포먼스 프로파일링

| 상태 | 도구명 | 설명 |
|---|---|---|
| `[ ]` | **Draw Call Budget Tracker** | 지정 레벨 드로우콜 수 측정 + 머지 후보 메시 제안 |
| `[ ]` | **Memory Budget Snapshot** | 텍스처 / 메시 / 오디오 카테고리별 메모리 점유 스냅샷 비교 |
| `[ ]` | **Tick Dependency Visualizer** | TickGroup 별 컴포넌트 체인 시각화 — 불필요한 Tick 탐지 |
| `[ ]` | **Collision Complexity Auditor** | Per-Poly 콜리전 사용 메시 탐지 → Simple 대체 후보 목록 |

---

## 9. 월드 빌딩 / 프로시저럴

| 상태 | 도구명 | 설명 |
|---|---|---|
| `[ ]` | **Foliage Density Normalizer** | 레벨 구역별 폴리지 밀도 편차 탐지 + 균등화 제안 |
| `[ ]` | **PCG Graph Validator** | PCG 그래프 내 누락 입력핀, 무한 루프 위험 노드 정적 분석 |
| `[ ]` | **Landscape Layer Weight Checker** | 레이어 가중치 합산이 1.0 미만/초과인 구간 히트맵 출력 |

---

## 10. 오디오

| 상태 | 도구명 | 설명 |
|---|---|---|
| `[ ]` | **Sound Asset Auditor** | 압축 미설정 사운드, 스트리밍 미사용 대형 파일 탐지 |
| `[ ]` | **Attenuation Override Finder** | 기본 Attenuation 상속 대신 개별 오버라이드된 SoundCue 목록 — 규칙 위반 검사 |

---

## 11. 에디터 UX / 생산성

| 상태 | 도구명 | 설명 |
|---|---|---|
| `[ ]` | **Custom Asset Thumbnail Generator** | 규격 통일된 썸네일 일괄 렌더 + 저장 |
| `[ ]` | **Editor Startup Profiler** | 에디터 시작 시간 단계별 측정 → 느린 플러그인/모듈 지목 |
| `[ ]` | **Hotkey Conflict Detector** | 에디터 단축키 충돌 목록 자동 추출 |
| `[ ]` | **Content Browser Bookmark Manager** | 자주 쓰는 폴더 경로를 단축 메뉴로 등록하는 에디터 유틸리티 |

---

## 12. 버전 관리 / 협업

| 상태 | 도구명 | 설명 |
|---|---|---|
| `[ ]` | **Large Binary Watcher** | 커밋 전 50MB 초과 uasset 탐지 + LFS 등록 안내 |
| `[ ]` | **Asset Checkout Conflict Reporter** | 동일 에셋 동시 체크아웃 감지 (Perforce / Git LFS 환경) |
| `[ ]` | **Changenote Auto-Generator** | 빌드 간 변경된 에셋 목록 → 릴리즈 노트 초안 자동 생성 |

---

## 13. 플랫폼 / 인증

| 상태 | 도구명 | 설명 |
|---|---|---|
| `[ ]` | **Icon & Splash Spec Validator** | 플랫폼별(Steam, Epic, 콘솔) 아이콘 해상도·포맷 규격 자동 검사 |
| `[ ]` | **Localization String Auditor** | 하드코딩된 UI 문자열 탐지 + LOCTABLE 누락 항목 리포트 |
| `[ ]` | **Screenshot Capture Batch** | 지정 카메라 위치 목록 → 스크린샷 일괄 캡처 (스토어 페이지용) |

---

## 7. Wiki 연동 (프로젝트 특화)

| 상태 | 도구명 | 설명 |
|---|---|---|
| `[ ]` | **Bug Pattern Extractor** | 빌드/로그 파싱 → `wiki/bugs/BUG-NNN.md` 자동 생성 |
| `[ ]` | **Engine Reference Updater** | UE 릴리즈 노트 ingest → `docs/engine-reference/` 페이지 diff 업데이트 |
| `[ ]` | **Scene Scan to Wiki** | 씬 스캔 결과를 `wiki/log.md` + 에셋 페이지에 자동 기록 |

---

## 우선순위 메모

작업을 시작할 때 아래 순서를 참고:

1. **Level Health Checker** — 씬 스캔 공식화, CLAUDE.md와 직접 연동
2. **Asset Naming Validator** — 즉각적인 파이프라인 품질 향상
3. **Blueprint Compile Watchdog** — 빌드 안정성 조기 확보
4. **Wiki Auto-Ingest Hook** — 지식 축적 자동화

---

## 참고

- 엔진 API 사용 전 `docs/engine-reference/unreal/` 먼저 확인
- 구현 결과물은 `wiki/`에 ingest 필수
- 에셋 컨벤션 기준은 `.claude/docs/coding-standards.md` 참조
