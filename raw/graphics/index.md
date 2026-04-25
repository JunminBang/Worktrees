# Clippings Index

## Computer Graphics

| 제목 | 출처 | 저장일 | 내용 요약 |
|------|------|--------|-----------|
| [Computer Graphics Tutorial](Computer%20Graphics%20Tutorial.md) | tutorialspoint.com | 2026-04-18 | CG 기초 개념 튜토리얼 — 렌더링, 알고리즘, 파이프라인, FAQ 38개 |
| [Computer graphics](Computer%20graphics.md) | Wikipedia | 2026-04-18 (원문 2008-07-24) | CG 개요 및 역사 (1950s~현재) |

## 기타

| 제목 | 출처 | 저장일 | 내용 요약 |
|------|------|--------|-----------|
| [MinCho 네이버 블로그](MinCho%20%20%EB%84%A4%EC%9D%B4%EB%B2%84%20%EB%B8%94%EB%A1%9C%EA%B7%B8.md) | blog.naver.com | 2026-04-18 | iframe 클리핑 — 원문 접근 필요 |

---

## 논문 클리핑 (arXiv / ACM)

### 하이브리드 렌더링

| 파일 | 연도 | 요약 |
|------|------|------|
| [hybrid_rendering_gpu_2023.md](hybrid_rendering_gpu_2023.md) | 2023 | RT+Raster+Denoising 하이브리드, Vulkan RTX |
| [hybrid_mblur_2022.md](hybrid_mblur_2022.md) | 2022 | RT로 모션 블러 Partial Occlusion 보정 |
| [dhrs_distributed_rendering_2024.md](dhrs_distributed_rendering_2024.md) | 2024 | 분산 하이브리드 렌더링 + 실시간 그림자 |
| [rt_rendering_advances_siggraph2025.md](rt_rendering_advances_siggraph2025.md) | 2025 | SIGGRAPH 2025 RT 게임 렌더링 Course |
| [sw_graphics_pipeline_siggraph2018.md](sw_graphics_pipeline_siggraph2018.md) | 2018 | GPU 소프트웨어 파이프라인, 동적 로드밸런싱 |
| [dl_rendering_optimization_2024.md](dl_rendering_optimization_2024.md) | 2024 | DL 기반 렌더링 최적화 |

### Neural Rendering / NeRF

| 파일 | 연도 | 요약 |
|------|------|------|
| [neural_rendering_hw_review_2024.md](neural_rendering_hw_review_2024.md) | 2024 | Neural Rendering + HW 가속 종합 리뷰 |
| [nerf_real_world_survey_2025.md](nerf_real_world_survey_2025.md) | 2025 | 실세계 NeRF 서베이 |
| [mixrt_realtime_nerf_2023.md](mixrt_realtime_nerf_2023.md) | 2023 | 혼합 표현으로 엣지 기기 실시간 NeRF |
| [ue4_nerf_2023.md](ue4_nerf_2023.md) | 2023 | UE4 직접 통합 NeRF, 4K@43FPS ⭐ |

### 3D Gaussian Splatting

| 파일 | 연도 | 요약 |
|------|------|------|
| [3dgs_original_2023.md](3dgs_original_2023.md) | 2023 | 원조 3DGS, SIGGRAPH 2023 |
| [3dgs_survey_2024.md](3dgs_survey_2024.md) | 2024 | 3DGS 파생 연구 서베이 |
| [3dgs_ray_tracing_2024.md](3dgs_ray_tracing_2024.md) | 2024 | 3DGS에 RT 적용, SIGGRAPH Asia 2024 |
| [hierarchical_3dgs_2024.md](hierarchical_3dgs_2024.md) | 2024 | 대규모 씬 계층적 3DGS, SIGGRAPH 2024 |

### 글로벌 일루미네이션 / 볼류메트릭 / 그림자

| 파일 | 연도 | 요약 |
|------|------|------|
| [gi_3dgs_realtime_2025.md](gi_3dgs_realtime_2025.md) | 2025 | 3DGS 씬 실시간 GI, >40 FPS |
| [photon_field_networks_2023.md](photon_field_networks_2023.md) | 2023 | 볼류메트릭 GI 신경 표현 |
| [ml_cloud_unreal_2025.md](ml_cloud_unreal_2025.md) | 2025 | UE에서 ML 구름 렌더링 ⭐ |
| [neural_soft_shadow_ar_2023.md](neural_soft_shadow_ar_2023.md) | 2023 | AR 소프트 그림자 신경망, 5ms |
| [volumetric_anisotropic_2024.md](volumetric_anisotropic_2024.md) | 2024 | 고알베도 볼류메트릭 실시간 렌더링 |

### LOD & Geometry / PBR / 생성형 3D

| 파일 | 연도 | 요약 |
|------|------|------|
| [neural_geometric_lod_2021.md](neural_geometric_lod_2021.md) | 2021 | Neural SDF LOD, 100~1000배 빠름 |
| [openpbr_2025.md](openpbr_2025.md) | 2025 | 표준 PBR 셰이더 (Autodesk+Adobe) |
| [diffusion_ibr_iclr2024.md](diffusion_ibr_iclr2024.md) | 2024 | 3D 씬 생성 Diffusion 모델, ICLR 2024 |
| [meshformer_neurips2024.md](meshformer_neurips2024.md) | 2024 | Sparse-view 고품질 메시 생성, NeurIPS 2024 |

---

## Computer Graphics 핵심 개념 (Tutorial 기준)

- **렌더링**: Scanline, Z-Buffer, Ray Tracing, Shading, Texture Mapping
- **알고리즘**: Bresenham's Line, Midpoint Circle, Flood-Fill, Scanline
- **변환**: Translation, Scaling, Rotation, Homogeneous Coordinates, MVP Matrix
- **셰이딩**: Gouraud vs Phong, Ambient Occlusion, Normal Vectors
- **최적화**: LOD, Instancing, Culling, Depth Buffer
- **API**: OpenGL (크로스플랫폼) vs DirectX (Windows 전용)
