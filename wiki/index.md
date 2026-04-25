# Wiki Index

마지막 업데이트: 2026-04-20

---

## Overview

| 페이지 | 설명 |
|--------|------|
| [overview.md](overview.md) | 레벨 전체 구조, 액터 목록, 이슈 요약 |

## Query 결과

| 페이지 | 설명 |
|--------|------|
| [query_ue5_rendering_map.md](query_ue5_rendering_map.md) | UE5 실시간 렌더링 기술 지도 — 논문 연구와 Lumen/Nanite/TSR/PBR 구현 연결 |

## Lint 리포트

| 페이지 | 설명 |
|--------|------|
| [lint_2026-04-19.md](lint_2026-04-19.md) | 2026-04-19 위키 건강 점검 — 고아 페이지, 누락 링크, 스테일 콘텐츠, 데이터 공백 |
| [lint_2026-04-19b.md](lint_2026-04-19b.md) | 2026-04-19 2차 점검 — 인덱스 등록 but 파일 없는 페이지 5개 수정, raw 정리 |

---

## Assets

*(에셋별 상세 페이지 — ingest 또는 debug query 시 추가됨)*

---

## Systems

### 씬 디버그 기반
| 페이지 | 설명 |
|--------|------|
| [static_mesh.md](systems/static_mesh.md) | StaticMesh/StaticMeshActor 동작 방식, 콜리전, Mobility, 디버그 패턴 |
| [animation.md](systems/animation.md) | 캐릭터 애니메이션 구조, AnimBP/State Machine/Montage/IK, 버그 패턴 |
| [lighting.md](systems/lighting.md) | 조명/PPV 시스템, 에디터 직접 확인 항목, 어두운 씬 체크리스트 |
| [rendering.md](systems/rendering.md) | 렌더링 파이프라인, 셰이딩, LOD, Z-Buffer, AA, API 비교 |

### UE5 소스코드 기반 (아티스트용)
| 페이지 | 설명 |
|--------|------|
| [ue5_overview.md](systems/ue5_overview.md) | UE5.7 소스 전체 구조, 188개 Runtime 모듈 개요, 시스템 매핑 |
| [ue5_gameplay_framework.md](systems/ue5_gameplay_framework.md) | Actor/Character/GameMode/Controller 계층, Enhanced Input, 멀티플레이 |
| [ue5_rendering_shader.md](systems/ue5_rendering_shader.md) | Lumen, Nanite, 셰이더 폴더 구조, 머티리얼 셰이딩 모델, 그림자 기술 |
| [ue5_animation_physics.md](systems/ue5_animation_physics.md) | AnimNode, IK 종류, Chaos 물리, 래그돌, 천 시뮬레이션 |
| [ue5_audio_vfx.md](systems/ue5_audio_vfx.md) | SoundWave/Cue/MetaSound, 서브믹스 계층, 나이아가라 VFX 구조 |
| [ue5_ai_navigation.md](systems/ue5_ai_navigation.md) | BehaviorTree, Blackboard, StateTree, EQS, Perception, NavMesh |
| [ue5_ui_cinematics.md](systems/ue5_ui_cinematics.md) | UMG 위젯, UserWidget 라이프사이클, Sequencer, CineCameraComponent |
| [ue5_world_network.md](systems/ue5_world_network.md) | World Partition, 레벨 스트리밍, Landscape, 네트워크 복제, 에셋 참조 |
| [ue5_editor.md](systems/ue5_editor.md) | 143개 에디터 모듈, 아티스트 우선순위, 단축키, 에디터 아키텍처 |

---

## Shaders (엔진 소스 기반)

### 셰이더 시스템 상세
| 페이지 | 설명 |
|--------|------|
| [shaders/overview.md](shaders/overview.md) | UE5 셰이더 폴더 구조, 확장자, 핵심 루트 파일, 파이프라인 대응표 |
| [shaders/lumen_shaders.md](shaders/lumen_shaders.md) | Lumen 85개 파일 — Card, Scene, ScreenProbe, RadianceCache, Reflections, Radiosity |
| [shaders/nanite_shaders.md](shaders/nanite_shaders.md) | Nanite 48개 파일 — 컬링, 래스터라이저, 스트리밍, 셰이딩 |
| [shaders/ray_tracing_path_tracing.md](shaders/ray_tracing_path_tracing.md) | RayTracing 64개 + PathTracing 28개 — DXR, 광선 타입, 머티리얼 히트 |
| [shaders/post_processing_tsr.md](shaders/post_processing_tsr.md) | TSR 23개 + Bloom/DOF/MotionBlur/SMAA/ACES/ScreenSpaceDenoise |
| [shaders/shadow_lighting.md](shaders/shadow_lighting.md) | VirtualShadowMaps 37개 + MegaLights 23개 + StochasticLighting |
| [shaders/material_surface.md](shaders/material_surface.md) | Substrate 23개 + HairStrands 79개 + HeterogeneousVolumes 33개 + BRDF |

---

## Papers

### 하이브리드 렌더링 (Ray Tracing + Rasterization)

| 페이지 | 논문 수 | 설명 |
|--------|---------|------|
| [hybrid_rendering.md](papers/hybrid_rendering.md) | 4편 | Hybrid RT+Raster, Motion Blur RT, 분산 렌더링, 텍스처 스트리밍 |

### Neural Rendering / NeRF

| 페이지 | 논문 수 | 설명 |
|--------|---------|------|
| [neural_rendering.md](papers/neural_rendering.md) | 4편 | Neural Rendering 리뷰, NeRF 서베이, MixRT, UE4-NeRF |

### 3D Gaussian Splatting

| 페이지 | 논문 수 | 설명 |
|--------|---------|------|
| [gaussian_splatting.md](papers/gaussian_splatting.md) | 3편 | 원조 3DGS, 서베이, Gaussian Ray Tracing |

### 렌더링 파이프라인 최신 연구

| 페이지 | 논문 수 | 설명 |
|--------|---------|------|
| [rendering_pipeline_advances.md](papers/rendering_pipeline_advances.md) | 3편 | SIGGRAPH RT Advances, SW 파이프라인, DL 최적화 |

### 글로벌 일루미네이션

| 페이지 | 논문 수 | 설명 |
|--------|---------|------|
| [global_illumination.md](papers/global_illumination.md) | 2편 | 실시간 GI for 3DGS, Photon Field Networks 볼류메트릭 GI |

### LOD & Geometry / PBR / 볼류메트릭

| 페이지 | 논문 수 | 설명 |
|--------|---------|------|
| [lod_and_geometry.md](papers/lod_and_geometry.md) | 2편 | Neural LOD (CVPR 2021), Hierarchical 3DGS (SIGGRAPH 2024) |
| [pbr_and_shading.md](papers/pbr_and_shading.md) | 2편 | OpenPBR (SIGGRAPH 2025), Neural BRDF |
| [volumetric_and_shadow.md](papers/volumetric_and_shadow.md) | 3편 | ML 볼류메트릭 구름 (UE 직접 구현), Neural 소프트 그림자, 이방성 볼류메트릭 |

### 생성형 3D / 업스케일링 & 반사 / 캐릭터 렌더링

| 페이지 | 논문 수 | 설명 |
|--------|---------|------|
| [generative_3d.md](papers/generative_3d.md) | 2편 | Diffusion IBR (ICLR 2024), MeshFormer (NeurIPS 2024) |
| [super_resolution_reflection.md](papers/super_resolution_reflection.md) | 2편 | Neural SR with Radiance Demodulation, REFRAME 반사 |
| [neural_avatar.md](papers/neural_avatar.md) | 2편 | HuGS, SplattingAvatar — 실시간 Gaussian 기반 인체 아바타 |
