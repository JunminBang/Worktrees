---
title: "글로벌 일루미네이션 — 실시간 GI 연구"
tags: ["global-illumination", "GI", "indirect-lighting", "Lumen", "photon-mapping", "3DGS", "neural", "volumetric"]
created: 2026-04-19T04:06:46.341Z
updated: 2026-04-19T04:06:46.341Z
sources: ["https://arxiv.org/abs/2503.17897", "https://arxiv.org/abs/2304.07338"]
links: []
category: reference
confidence: high
schemaVersion: 1
---

# 글로벌 일루미네이션 — 실시간 GI 연구

# 글로벌 일루미네이션 — 실시간 GI 연구

GI = 직접광 + 간접광(멀티바운스). 실시간화가 핵심 과제.

## 1. Real-time GI for Dynamic 3D Gaussian Scenes (2025)
- **저자**: Chenxiao Hu, Meng Gai, Guoping Wang, Sheng Li | **arXiv**: 2503.17897
- **성능**: >40 FPS (3DGS + 메시 혼합 씬)
- 3D Gaussian 씬에서 멀티바운스 간접광 실시간 계산. 확률적 RT + 최적화 래스터라이저
- 머티리얼/조명 인터랙티브 편집 가능
- **UE 연결**: UE5 Lumen과 동일한 목표 (SW Ray Tracing + Screen-Space 폴백)

## 2. Photon Field Networks for Dynamic Real-Time Volumetric GI (2023)
- **저자**: David Bauer, Qi Wu, Kwan-Liu Ma | **arXiv**: 2304.07338
- 볼류메트릭 데이터(연기/구름)에서 GI 실시간 렌더링
- 멀티-위상 포톤 캐시 학습(수 초) → Photon Field Network 추론으로 인터랙티브 FPS

## GI 접근법 비교
| 방법 | 품질 | 속도 | UE 사례 |
|------|------|------|---------|
| Path Tracing | 최고 | 매우 느림 | 오프라인 |
| Light Probes | 낮음 | 빠름 | UE4 이전 |
| Lumen (UE5) | 중간 | 실시간 | UE5 표준 |
| 3DGS + RT GI | 높음 | >40 FPS | 위 논문 |
| Photon Field Net | 높음 | 실시간 | 볼류메트릭 전용 |

