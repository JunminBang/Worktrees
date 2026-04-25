---
name: 업스케일링 & 반사 렌더링
type: paper-collection
tags: super-resolution, upscaling, DLSS, FSR, TSR, reflection, screen-space, mobile, CVPR, ECCV
source: raw-ingest
scene_verified: false
last_updated: 2026-04-19
---

# 업스케일링 & 반사 렌더링 논문 모음

저해상도 렌더링 후 신경망으로 업스케일하거나, 반사 표면을 실시간 렌더링하는 연구.

---

## 1. Neural Super-Resolution with Radiance Demodulation (CVPR 2024)

| 항목 | 내용 |
|------|------|
| **저자** | Jia Li, Ziling Chen et al. |
| **연도** | 2023 (CVPR 2024) |
| **arXiv** | 2308.06699 |
| **배율** | 4×4 업스케일 |

렌더링 결과를 **조명(Lighting) + 머티리얼(Material)** 로 분해.
- 조명은 부드러워 SR이 쉽고, 고해상도 머티리얼은 그대로 유지 → 재결합
- Reliable Warping Module: 가려진 영역 명시 마킹 → Ghosting 방지
- Frame-recurrent Network + Temporal Loss: 프레임 간 시간 안정성

**UE 연결**: UE5 TSR(Temporal Super Resolution)이 동일한 Temporal Accumulation 기반.

---

## 2. REFRAME: Reflective Surface Real-Time Rendering for Mobile (ECCV 2024)

| 항목 | 내용 |
|------|------|
| **저자** | Chaojian Ji, Yufeng Li, Yiyi Liao |
| **연도** | 2024 (ECCV 2024) |
| **arXiv** | 2403.16481 |
| **대상** | 스마트폰 등 모바일 기기 |

반사 표면 Novel View Synthesis를 모바일에서 실시간으로.
- Diffuse + Specular 분리 분해
- 반사 방향으로 파라미터화한 신경 환경맵

---

## 업스케일링 기법 비교

| 기법 | 유형 | 특징 | 엔진 지원 |
|------|------|------|----------|
| DLSS 3+ | AI (Nvidia) | 프레임 생성 포함 | UE5 플러그인 |
| FSR 3 | 비AI (AMD) | 크로스플랫폼 | UE5 내장 |
| XeSS | AI (Intel) | 크로스 GPU | UE5 플러그인 |
| TSR (UE5) | AI | UE 전용, 내장 | UE5 기본 |
| Radiance Demod SR | AI+물리 분해 | 연구 단계 | 연구 단계 |

---

## 반사 렌더링 기법 비교

| 기법 | 정확도 | 속도 | UE 구현 |
|------|--------|------|---------|
| SSR (Screen-Space Reflection) | 낮음 (화면 밖 누락) | 빠름 | UE 기본 |
| Planar Reflection | 높음 (평면 한정) | 중간 | UE 내장 |
| RT Reflection (DXR) | 높음 | 느림 | UE5 RT 모드 |
| Lumen Reflection | 중간 | 실시간 | UE5 기본 |
| Neural Env Map (REFRAME) | 높음 (모바일) | 실시간 | 연구 단계 |

---

## 관련 페이지
- [렌더링 파이프라인 시스템](../systems/rendering.md)
- [하이브리드 렌더링 논문](hybrid_rendering.md)
- [PBR & 셰이딩 논문](pbr_and_shading.md)
