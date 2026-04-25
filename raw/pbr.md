---
title: "PBR & 물리 기반 셰이딩"
tags: ["PBR", "BRDF", "microfacet", "material", "OpenPBR", "shading", "metallic", "roughness"]
created: 2026-04-19T04:07:19.164Z
updated: 2026-04-19T04:07:19.164Z
sources: ["https://arxiv.org/abs/2512.23696", "https://arxiv.org/abs/2304.05472"]
links: []
category: reference
confidence: high
schemaVersion: 1
---

# PBR & 물리 기반 셰이딩

# PBR & 물리 기반 셰이딩

빛의 물리적 거동을 수학적으로 모델링. UE 머티리얼 시스템의 이론적 기반.

## PBR 핵심 파라미터 (UE 머티리얼과 동일)
- **Base Color**: 알베도(확산 반사색)
- **Metallic**: 금속성 (0=비금속, 1=금속)
- **Roughness**: 거칠기 (0=완전반사, 1=완전확산)
- **Specular**: 비금속 Fresnel 반사율 (기본값 0.5 권장)

## 1. OpenPBR: Novel Features and Implementation Details (SIGGRAPH 2025)
- **저자**: Jamie Portsmouth, Peter Kutz, Stephen Hill (Autodesk + Adobe) | **arXiv**: 2512.23696
- VFX·애니메이션·디자인 시각화 상호운용 표준 PBR 셰이더
- Slab 기반 레이어링, 미세면 이론, 박막 홀로그래픽 무지개빛(Thin-film Iridescence), 코팅/퍼즈 레이어
- **UE 연결**: UE5 머티리얼 시스템(Base Color/Metallic/Roughness/Specular)이 동일한 미세면 이론 기반

## 2. Light Sampling Field and BRDF for Physically-based Neural Rendering (2023)
- **arXiv**: 2304.05472
- Neural Rendering에 물리 기반 BRDF 통합. 조명 샘플링 필드 + BRDF를 신경망으로 학습

## BRDF 모델 비교
| 모델 | 특징 | UE 사용 |
|------|------|---------|
| Lambert | 완전 확산, 빠름 | 저급 |
| Phong | 정반사 근사 | 레거시 |
| GGX/Trowbridge-Reitz | 물리적 미세면 | UE/Unity PBR 표준 |
| OpenPBR | 다층 레이어 표준 | VFX/애니메이션 |

## PBR 버그 패턴
| 증상 | 원인 | 해결 |
|------|------|------|
| 플라스틱처럼 보임 | Specular 너무 높음 | Specular 0.5 유지 |
| 금속인데 색이 없음 | Base Color 어두움 | 금속은 Base Color가 반사색 |
| 거친 표면에 핫스팟 | Roughness 0에 가까움 | Roughness 값 올리기 |

