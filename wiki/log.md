# Log

작업 이력 (append-only). 최신 항목이 아래에 추가됩니다.

형식: `## [YYYY-MM-DD] 작업유형 | 설명`

---

## [2026-04-09] debug | 씬이 어두운 원인
- 조명 액터 4개 Transform 조회
- ExponentialHeightFog Z=-6850 이상 감지 (1차 의심)
- MCP 한계: PostProcessVolume 내부 파라미터 읽기 불가
- 원인 확인: PostProcessVolume Global Gamma 낮게 설정
- BUG-002 생성 (resolved)
- wiki/systems/lighting.md 생성
- MCP 한계 사항 lighting.md에 기록

## [2026-04-09] query | 캐릭터 애니메이션 동작 방식
- 씬 스캔: SkeletalMeshActor/Character 0개 (StaticMesh 전용 레벨)
- wiki/systems/animation.md 생성
- AnimBP, StateMachine, Montage, IK 구조 및 버그 패턴 기록

## [2026-04-09] query | StaticMesh 클래스 동작 방식
- wiki/systems/static_mesh.md 생성
- 씬 데이터 기반 실제 패턴 3가지 기록
- index.md 업데이트

## [2026-04-18] ingest | 논문 14편 — Computer Graphics 연구 동향
- 검색 출처: Google Scholar, arXiv, ACM Digital Library
- wiki/papers/hybrid_rendering.md 생성 (4편): Hybrid-Rendering in GPU, Hybrid MBlur, DHR+S, Texture Streaming
- wiki/papers/neural_rendering.md 생성 (4편): Neural Rendering HW Review, NeRF Survey, MixRT, UE4-NeRF
- wiki/papers/gaussian_splatting.md 생성 (3편): 3DGS 원조, 3DGS Survey, Gaussian Ray Tracing
- wiki/papers/rendering_pipeline_advances.md 생성 (3편): SIGGRAPH RT Advances, SW Pipeline, DL Optimization
- index.md 업데이트 (Papers 섹션 추가)

## [2026-04-18] ingest | D:/GGGG/Clippings/
- Computer Graphics Tutorial (tutorialspoint.com) 클리핑 수집
- Computer graphics (Wikipedia) 클리핑 수집
- MinCho 네이버 블로그 클리핑 수집 (iframe only — 내용 없음, 스킵)
- wiki/systems/rendering.md 생성: 렌더링 파이프라인, 셰이딩, LOD, Z-Buffer, 알고리즘, API 비교
- index.md 업데이트

## [2026-04-19] ingest | llm_wiki_methodology.md — LLM-Wiki 방법론 문서
- wiki/llm_wiki_design.md 생성: RAG vs LLM-Wiki, 3레이어 아키텍처, Ingest/Query/Lint 정의
- index.md 업데이트

## [2026-04-19] query | UE5 실시간 렌더링 기술 지도
- 참조: ue5_rendering_shader, hybrid_rendering, global_illumination, lod_and_geometry, rendering_pipeline_advances, super_resolution_reflection, pbr_and_shading, volumetric_and_shadow
- wiki/query_ue5_rendering_map.md 생성: 논문 연구 ↔ Lumen/Nanite/TSR/PBR/VSM 매핑 테이블
- index.md 업데이트

## [2026-04-19] lint | 전체 위키 건강 점검
- 발견: 고아 페이지 1개 (generative_3d), 누락 링크 7개, 스테일 경고 1개, 데이터 공백 4개
- 처리: ue5_rendering_shader 논문 링크 6개 추가, ue5_gameplay_framework 링크 추가
- 처리: animation.md ⚠️ 경고 추가, index.md 신규 페이지 등록
- 미처리: BUG-001 재확인 (씬 스캔 필요), 데이터 공백 4개 (소스 추가 시 처리)
- wiki/lint_2026-04-19.md 생성

## [2026-04-19] ingest | raw/ 신규 파일 — Papers 2편 + UE5 소스 시스템 9개
- wiki/papers/neural_avatar.md 생성 (2편): HuGS, SplattingAvatar — 실시간 Gaussian 아바타
- wiki/papers/super_resolution_reflection.md 생성 (2편): Neural SR Radiance Demod, REFRAME
- wiki/systems/ue5_overview.md 생성: UE5.7 소스 전체 구조 개요 (아티스트용)
- wiki/systems/ue5_gameplay_framework.md 생성: Actor/Character/GameMode/Enhanced Input
- wiki/systems/ue5_rendering_shader.md 생성: Lumen, Nanite, 셰이더 폴더, 머티리얼 모델
- wiki/systems/ue5_animation_physics.md 생성: AnimNode, IK, Chaos 물리, 래그돌, 천
- wiki/systems/ue5_audio_vfx.md 생성: SoundWave/Cue/MetaSound, Niagara VFX
- wiki/systems/ue5_ai_navigation.md 생성: BehaviorTree, Blackboard, EQS, NavMesh
- wiki/systems/ue5_ui_cinematics.md 생성: UMG 위젯, Sequencer, CineCameraComponent
- wiki/systems/ue5_world_network.md 생성: World Partition, 네트워크 복제, 에셋 참조
- wiki/systems/ue5_editor.md 생성: 143개 에디터 모듈, 단축키
- index.md 업데이트 (Systems UE5 소스 섹션 추가, Papers 2항목 추가)

## [2026-04-19] lint | 2차 위키 건강 점검 + raw 정리
- 발견: wiki/index.md 등록 but 파일 없는 페이지 5개 (generative_3d, lod_and_geometry, pbr_and_shading, volumetric_and_shadow, global_illumination)
- 처리: raw/papers/ 소스에서 5개 wiki/papers/ 페이지 생성
- 처리: index.md global_illumination 섹션 추가, LOD/PBR/볼류메트릭/생성형 3D 섹션 재편
- raw 정리: 이미 wiki에 존재하는 소스 파일 14개 삭제, MinCho 빈 파일 삭제
- wiki/lint_2026-04-19b.md 생성
- 미처리: BUG-001 재확인 (씬 스캔 필요), 데이터 공백 4개

## [2026-04-09] scan | 초기 씬 스캔 — TestLevel
- 총 51개 액터 감지
- StaticMeshActor: 43개 (Cube 20, Cylinder 9, Ramp 8, QuarterCylinder 6)
- 환경 액터: DirectionalLight, SkyLight, SkyAtmosphere, VolumetricCloud, ExponentialHeightFog, PostProcessVolume
- PlayerStart @ (0, 0, 302)
- BUG-001 발견: Cylinder 쌍 4곳이 동일 위치에 겹침
- 위키 초기 구조 생성

## [2026-04-20] lint | 전체 wiki 건강 점검
- BUG-001.md, BUG-002.md 생성 (bugs/ 디렉토리 누락 수정)
- lighting.md MCP 참조 제거 → '에디터 직접 확인 항목'으로 변경
- index.md 날짜 갱신 (2026-04-19 → 2026-04-20), lighting 설명 수정

## [2026-04-20] lint | CLAUDE.md 잔여 이슈 수정 및 문서 교차 연결
- wiki systems 6개 페이지에 engine-reference 모듈 링크 추가
- unreal-debug.md 소스 탐색 규칙에 engine-reference 우선 확인 추가
- CLAUDE.md: 매핑 테이블, Debug 4번, Lint 2번, VERSION 경로, 버그 기록 표현 수정

## [2026-04-25] lint | 전체 wiki 건강검진
- 발견: bugs/BUG-001.md, bugs/BUG-002.md 파일 없음 (4개 페이지에서 데드링크)
- 발견: llm_wiki_design.md 파일 없음 (lint 리포트 내 히스토리 참조만 → 허용)
- 발견: engine-reference/modules/*.md 모두 정상 ✅
- 발견: papers/ 관련 페이지 섹션 모두 있음 ✅
- 처리: wiki/bugs/BUG-001.md 생성 (Cylinder 겹침, open)
- 처리: wiki/bugs/BUG-002.md 생성 (Gamma 어두움, resolved)
- 처리: index.md Bugs 섹션 추가

## [2026-04-25] ingest | UE5.7 Engine/Shaders/ 소스 분석 — 셰이더 wiki 7개 생성
- 소스: C:/Program Files/Epic Games/UE_5.7/Engine/Shaders/
- 분석 범위: Private/ 33개 서브폴더 + 루트 파일, Public/, Shared/
- wiki/shaders/overview.md 생성: 폴더 구조, 확장자, 핵심 루트 파일, 파이프라인 대응
- wiki/shaders/lumen_shaders.md 생성: Lumen 85개 파일 (Card/Scene/ScreenProbe/RadianceCache/Reflections/Radiosity)
- wiki/shaders/nanite_shaders.md 생성: Nanite 48개 파일 (컬링/래스터/스트리밍/셰이딩/RT연동)
- wiki/shaders/ray_tracing_path_tracing.md 생성: RayTracing 64 + PathTracing 28개 파일
- wiki/shaders/post_processing_tsr.md 생성: TSR 23 + Bloom/DOF/MotionBlur/SMAA/ACES/Denoise
- wiki/shaders/shadow_lighting.md 생성: VirtualShadowMaps 37 + MegaLights 23 + Stochastic
- wiki/shaders/material_surface.md 생성: Substrate 23 + HairStrands 79 + HeterogeneousVolumes 33 + BRDF
- index.md Shaders 섹션 추가 (7개 항목)
- systems/ue5_rendering_shader.md 셰이더 소스 링크 7개 추가

## [2026-04-25] lint | 전체 wiki 교차 링크 정리
- 발견: 관련 페이지 섹션 없는 페이지 4개 (ue5_audio_vfx, ue5_ai_navigation, ue5_ui_cinematics, ue5_world_network)
- 발견: ue5_gameplay_framework.md 아티스트 체크리스트 코드블록이 관련 페이지 뒤에 잘못 배치됨 → 수정
- 처리: rendering.md — ue5_rendering_shader, query 지도, 논문 2편 링크 추가
- 처리: lighting.md — rendering, ue5_rendering_shader, 볼류메트릭 논문 링크 추가
- 처리: static_mesh.md — rendering, ue5_rendering_shader, ue5_world_network 링크 추가
- 처리: ue5_animation_physics.md — ue5_overview, ue5_gameplay_framework, ue5_ui_cinematics 링크 추가
- 처리: ue5_gameplay_framework.md — 구조 수정 + ai_navigation, world_network 링크 추가
- 처리: ue5_audio_vfx.md — 관련 페이지 섹션 신규 생성
- 처리: ue5_ai_navigation.md — 관련 페이지 섹션 신규 생성
- 처리: ue5_ui_cinematics.md — 관련 페이지 섹션 신규 생성
- 처리: ue5_world_network.md — 관련 페이지 섹션 신규 생성
- 처리: ue5_editor.md — rendering, animation, ui, static_mesh 링크 추가
- 처리: query_ue5_rendering_map.md — 관련 페이지 섹션 신규 생성 (시스템 3개, 논문 8개)
- 처리: overview.md — systems 4개 링크 추가
