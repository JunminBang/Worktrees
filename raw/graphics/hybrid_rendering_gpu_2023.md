---
title: "Hybrid-Rendering Techniques in GPU"
source: "https://arxiv.org/abs/2312.06827"
author:
  - "Pedro Granja"
  - "João Pereira"
published: 2023-12-11
created: 2026-04-18
description: "Ray Tracing + Rasterization + Denoising 하이브리드로 >30 FPS 포토리얼 렌더링. Vulkan + Nvidia RTX 구현."
tags:
  - clippings
  - paper
  - hybrid-rendering
  - ray-tracing
  - rasterization
  - denoising
---

## 핵심 내용

Ray Tracing의 품질과 Rasterization의 속도를 결합한 하이브리드 시스템. Temporal Denoising에서 History Rectification(Variance Color Clamping) 분석 및 아티팩트 완화 방법 제안.

## 파이프라인

```
Rasterization (G-Buffer)
  → Ray Tracing (그림자/반사/AO)
  → Temporal Denoising (Variance Color Clamping)
  → Spatial Filter (Separable Blur)
  → Tone Mapping (Reinhard)
```

## 성능

>30 FPS (Nvidia RTX, Vulkan API)

## 관련 개념

Lumen (UE5)이 유사한 하이브리드 구조를 프로덕션 레벨로 구현.
