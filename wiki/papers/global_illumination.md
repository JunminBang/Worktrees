---
name: 실시간 글로벌 일루미네이션
type: paper-collection
tags: global-illumination, GI, indirect-lighting, volumetric, 3DGS, neural, real-time
last_updated: 2026-04-18
source: raw-ingest
scene_verified: false
---

# 실시간 글로벌 일루미네이션 논문 모음

---

## 1. Real-time GI for Dynamic 3D Gaussian Scenes (2025)

| 항목 | 내용 |
|------|------|
| **저자** | Chenxiao Hu, Meng Gai, Guoping Wang, Sheng Li |
| **arXiv** | [2503.17897](https://arxiv.org/abs/2503.17897) |
| **성능** | >40 FPS (3DGS + 메시 혼합 씬) |

3D Gaussian 씬에서 멀티바운스 간접광 실시간 계산. 확률적 Ray Tracing + 최적화 래스터라이저. 머티리얼/조명 인터랙티브 편집 가능.

### Unreal 연결점
UE5 **Lumen**과 동일한 목표 — Lumen은 SW Ray Tracing + Screen-Space 폴백으로 GI 근사.

---

## 2. Photon Field Networks for Dynamic Real-Time Volumetric GI (2023)

| 항목 | 내용 |
|------|------|
| **저자** | David Bauer, Qi Wu, Kwan-Liu Ma |
| **arXiv** | [2304.07338](https://arxiv.org/abs/2304.07338) |

볼류메트릭 데이터에서 GI 실시간 렌더링. 사전 계산된 포톤 캐시를 신경망으로 학습 → 위상 함수 인식 Photon Field Network → 실시간 추론.

---

## GI 접근법 비교

| 방법 | 품질 | 속도 | 사례 |
|------|------|------|------|
| Path Tracing | 최고 | 매우 느림 | 오프라인 |
| Light Probes | 낮음 | 빠름 | UE4 이전 |
| Lumen (UE5) | 중간 | 실시간 | UE5 표준 |
| Photon Field Net | 높음 | 실시간 | 볼류메트릭 전용 |
| 3DGS + RT GI | 높음 | >40 FPS | 위 논문 |

---

## 관련 페이지
- [조명 시스템](../systems/lighting.md)
- [하이브리드 렌더링 논문](hybrid_rendering.md)
- [3D Gaussian Splatting 논문](gaussian_splatting.md)
