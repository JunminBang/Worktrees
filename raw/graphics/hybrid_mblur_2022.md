---
title: "Hybrid MBlur: Augmenting Rasterization with Ray Tracing for Motion Blur"
source: "https://arxiv.org/abs/2210.06159"
author:
  - "Yu Wei Tan"
  - "Xiaohan Cui"
  - "Anand Bhojan"
published: 2022-10-11
created: 2026-04-18
description: "게임에서 모션 블러의 Partial Occlusion 아티팩트를 Ray Tracing으로 보정하는 하이브리드 기법."
tags:
  - clippings
  - paper
  - hybrid-rendering
  - motion-blur
  - ray-tracing
---

## 핵심 내용

기존 스크린스페이스 모션 블러의 Partial Occlusion Semi-transparency 아티팩트 문제를 HW 가속 Ray Tracing으로 해결. 배경 픽셀을 재귀적으로 추적해 블렌딩.

## 방법

1. 속도 기반 Spatial Sampling으로 방향성 블러
2. 부분 가려짐 영역을 RT 광선으로 재탐색
3. 배경 정보 블렌딩
