---
title: "UE4-NeRF: Neural Radiance Field for Real-Time Rendering of Large-Scale Scene"
source: "https://arxiv.org/abs/2310.13263"
author:
  - "Jiaming Gu"
  - "Minchao Jiang"
  - "Hongsheng Li"
  - "Xiaoyuan Lu"
  - "Guangming Zhu"
  - "Syed Afaq Ali Shah"
  - "Liang Zhang"
  - "Mohammed Bennamoun"
published: 2023-10-20
created: 2026-04-18
description: "Unreal Engine 4와 직접 통합된 대규모 씬 NeRF 실시간 렌더링. NeurIPS 2023 채택."
tags:
  - clippings
  - paper
  - nerf
  - unreal-engine
  - large-scale
  - real-time
---

## 핵심 내용

씬을 sub-NeRF로 분할, 정팔면체 메시 초기화, LOD 변형, UE4 래스터화 파이프라인 통합.

## 성능

4K @ 최대 43 FPS (Unreal Engine 4 내부)

## UE 연결점

UE4 래스터라이저 그대로 활용 — UE5에도 응용 가능한 아키텍처.
