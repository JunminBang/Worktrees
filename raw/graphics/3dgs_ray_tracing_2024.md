---
title: "3D Gaussian Ray Tracing: Fast Tracing of Particle Scenes"
source: "https://arxiv.org/abs/2407.07090"
author:
  - "Nicolas Moenne-Loccoz"
  - "Ashkan Mirzaei"
  - "Or Perel"
  - "Riccardo de Lutio"
  - "Janick Martinez Esturo"
  - "Gavriel State"
  - "Sanja Fidler"
  - "Nicholas Sharp"
  - "Zan Gojcic"
published: 2024-07-09
created: 2026-04-18
description: "3DGS를 래스터화 대신 Ray Tracing으로 렌더링. BVH + Bounding Mesh로 GPU RT 하드웨어 가속. SIGGRAPH Asia 2024."
tags:
  - clippings
  - paper
  - 3DGS
  - ray-tracing
  - BVH
  - SIGGRAPH
---

## 핵심 내용

가우시안 입자를 Bounding Mesh로 감싸 BVH 구축 → GPU RT Core 활용. 2차 조명·왜곡 카메라·확률적 샘플링 지원. 래스터 3DGS와 동등 성능.
