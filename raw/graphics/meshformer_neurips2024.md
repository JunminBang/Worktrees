---
title: "MeshFormer: High-Quality Mesh Generation with 3D-Guided Reconstruction Model"
source: "https://arxiv.org/abs/2408.10198"
author:
  - "Minghua Liu"
  - "Chong Zeng"
  - "Xinyue Wei"
  - "Ruoxi Shi"
  - "Linghao Chen"
  - "Chao Xu"
  - "Mengqi Zhang"
  - "Zhaoning Wang"
  - "Xiaoshuai Zhang"
  - "Isabella Liu"
  - "Hongzhi Wu"
  - "Hao Su"
published: 2024-08-19
created: 2026-04-18
description: "Sparse-view 입력으로 고품질 텍스처 메시 생성. 3D Sparse Voxel + Transformer. SDF 지도 학습으로 직접 메시 출력. NeurIPS 2024."
tags:
  - clippings
  - paper
  - mesh-generation
  - 3D-reconstruction
  - diffusion
  - transformer
---

## 핵심 내용

Triplane 대신 3D Sparse Voxel. 2D Diffusion Normal Map으로 지오메트리 가이드. 단일 이미지·텍스트→3D 통합. 출력 메시가 Nanite와 직접 호환.
