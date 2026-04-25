---
title: "생성형 3D & Diffusion 렌더링"
tags: ["diffusion", "generative", "3D-generation", "mesh-generation", "image-based-rendering", "reconstruction", "ICLR", "NeurIPS"]
created: 2026-04-19T04:07:46.081Z
updated: 2026-04-19T04:07:46.081Z
sources: ["https://arxiv.org/abs/2402.03445", "https://arxiv.org/abs/2408.10198"]
links: []
category: reference
confidence: high
schemaVersion: 1
---

# 생성형 3D & Diffusion 렌더링

# 생성형 3D & Diffusion 렌더링

Diffusion 모델로 3D 씬·메시를 생성하거나 재구성하는 연구.

## 1. Denoising Diffusion via Image-Based Rendering (ICLR 2024)
- **저자**: Titas Anciukevičius, Fabian Manhardt, Federico Tombari, Paul Henderson | **arXiv**: 2402.03445
- **최초의** 실세계 3D 씬 생성 가능한 Diffusion 모델. 마스크·깊이 없이 2D 이미지만으로 학습
- **IB-planes**: 이미지 디테일 가시성 기반 동적 용량 할당 신경 씬 표현
- Image Representation Dropout으로 퇴화 솔루션 방지
- 생성·Novel View Synthesis·3D 재구성 세 태스크 통합

## 2. MeshFormer: High-Quality Mesh Generation (NeurIPS 2024)
- **저자**: Minghua Liu et al. (UC San Diego) | **arXiv**: 2408.10198
- Sparse-view 입력 → 고품질 텍스처 메시 직접 생성
- Triplane 대신 **3D Sparse Voxel + Transformer** 구조
- 2D Diffusion Normal Map으로 지오메트리 학습 가이드
- SDF 지도 학습 + Surface Rendering으로 직접 메시 출력
- **UE 연결**: 출력 메시가 Nanite와 직접 호환 가능

## 3D 생성 기법 비교
| 방법 | 입력 | 출력 | 특징 |
|------|------|------|------|
| NeRF | 멀티뷰 이미지 | 볼류메트릭 | 느린 학습 |
| 3DGS | 멀티뷰 이미지 | 가우시안 | 실시간 렌더링 |
| IB-planes Diffusion | 소수 이미지 | 3D 씬 | 생성+재구성 통합 |
| MeshFormer | Sparse-view | 메시 | 직접 편집 가능 |

**UE 에셋 자동 생성** 방향의 핵심 기술 기반. 텍스트/이미지 → 3D 메시 → UE Import 워크플로우 현실화 중.

