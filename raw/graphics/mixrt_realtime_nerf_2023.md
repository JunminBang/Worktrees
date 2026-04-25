---
title: "MixRT: Mixed Neural Representations For Real-Time NeRF Rendering"
source: "https://arxiv.org/abs/2312.11841"
author:
  - "Chaojian Li"
  - "Bichen Wu"
  - "Peter Vajda"
  - "Yingyan Celine Lin"
published: 2023-12-19
created: 2026-04-18
description: "저품질 메시 + View-dependent Displacement Map + 압축 NeRF 혼합 표현으로 엣지 기기 실시간 렌더링. 3DV'24 채택."
tags:
  - clippings
  - paper
  - nerf
  - real-time
  - edge-device
---

## 핵심 내용

고품질 메시 없이도 포토리얼 렌더링 가능. WebGL 기반 HW 가속.

## 성능

- >30 FPS @ 1280×720, MacBook M1 Pro
- 저장 용량 80% 이하 (SOTA 대비)
- Unbounded-360 실내 씬 +0.2 PSNR
