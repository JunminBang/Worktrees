---
title: "3D Gaussian Splatting for Real-Time Radiance Field Rendering"
source: "https://arxiv.org/abs/2308.04079"
author:
  - "Bernhard Kerbl"
  - "Georgios Kopanas"
  - "Thomas Leimkühler"
  - "George Drettakis"
published: 2023-08-08
created: 2026-04-18
description: "3DGS 원조 논문. SfM Sparse Points → 3D Gaussian 최적화 → Visibility-aware Splatting. ≥30 FPS @ 1080p."
tags:
  - clippings
  - paper
  - 3DGS
  - gaussian-splatting
  - real-time
  - SIGGRAPH
---

## 핵심 내용

이방성 공분산 최적화 + 가우시안 밀도 제어(Densification/Pruning) + CUDA 타일 래스터라이저.

## 출판

ACM Transactions on Graphics 42(4) — SIGGRAPH 2023

## 성능

≥30 FPS @ 1080p, 경쟁적인 학습 시간
