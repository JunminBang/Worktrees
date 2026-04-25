---
title: "볼류메트릭 렌더링 & 실시간 그림자"
tags: ["volumetric", "clouds", "fog", "shadow", "soft-shadow", "unreal-engine", "neural", "ray-marching", "mobile"]
created: 2026-04-19T04:07:33.028Z
updated: 2026-04-19T04:07:33.028Z
sources: ["https://arxiv.org/abs/2502.08107", "https://arxiv.org/abs/2308.01613", "https://arxiv.org/abs/2401.14051"]
links: []
category: reference
confidence: high
schemaVersion: 1
---

# 볼류메트릭 렌더링 & 실시간 그림자

# 볼류메트릭 렌더링 & 실시간 그림자

구름·안개·연기 등 볼류메트릭 매질과 실시간 그림자 계산 연구.

## 1. ML-Driven Volumetric Cloud Rendering in Unreal Engine (2025) ⭐ UE 직접 구현
- **저자**: Shruti Singh, Shantanu Kumar | **arXiv**: 2502.08107
- **성능**: 평균 35ms/frame @ Unreal Engine
- UE 내 ML 기반 볼류메트릭 구름 셰이더. 기존 2D 날씨 텍스처 제거 → 이중 레이어 절차적 노이즈
- 전통 2D 기법 대비 구름 사실성 **15% 향상**
- **UE 연결**: UE5 Volumetric Cloud Component + Ray-marching 방식에 ML 노이즈 개선 적용

## 2. Real-time Light Estimation and Neural Soft Shadows for AR (2023)
- **저자**: Alexander Sommer, Ulrich Schwanecke, Elmar Schömer | **arXiv**: 2308.01613
- **성능**: 조명 추정 9ms + 소프트 그림자 5ms (iPhone 11 Pro)
- 실내 AR에서 조명 방향 추정 DNN + MLP 기반 소프트 그림자 텍스처 생성 → 모바일 실시간

## 3. Real-time Rendering of High Albedo Anisotropic Volumetric Media (2024)
- **저자**: Shun Fang, Xing Feng, Ming Cui | **arXiv**: 2401.14051
- 구름·연기·안개 다중 산란 실시간 근사. 계층적 3D-CNN + 어텐션 모듈

## 그림자 기법 비교
| 기법 | 소프트 그림자 | 비용 | UE 구현 |
|------|-------------|------|---------|
| Shadow Map | 불가(계단) | 낮음 | 기본 |
| PCF | 근사 | 중간 | UE 표준 |
| PCSS | 가능 | 높음 | UE 옵션 |
| RT Shadow | 정확 | 매우 높음 | UE5 RT 모드 |
| Neural Soft Shadow | 가능(모바일) | 낮음 | 이 논문 |

