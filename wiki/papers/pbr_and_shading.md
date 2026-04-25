---
name: PBR & 물리 기반 셰이딩
type: paper-collection
tags: PBR, BRDF, shading, material, physically-based, microfacet, OpenPBR
last_updated: 2026-04-18
source: raw-ingest
scene_verified: false
---

# PBR & 물리 기반 셰이딩 논문 모음

현실적인 머티리얼 표현을 위한 물리 기반 렌더링(PBR) 이론 및 구현 연구.

---

## PBR 핵심 개념

```
PBR = 빛의 물리적 거동을 수학적으로 모델링
  ├── BRDF (Bidirectional Reflectance Distribution Function)
  │     = 입사광 → 반사광의 방향/강도 분포
  ├── Microfacet Theory (미세면 이론)
  │     = 거친 표면을 수많은 작은 거울로 모델링
  └── Energy Conservation (에너지 보존)
        = 반사 + 흡수 ≤ 입사광
```

**핵심 파라미터** (UE 머티리얼과 동일):
- **Base Color**: 알베도 (확산 반사색)
- **Metallic**: 금속성 (0=비금속, 1=금속)
- **Roughness**: 거칠기 (0=완전 반사, 1=완전 확산)
- **Specular**: 비금속 Fresnel 반사율

---

## 1. OpenPBR: Novel Features and Implementation Details (SIGGRAPH 2025)

| 항목 | 내용 |
|------|------|
| **저자** | Jamie Portsmouth, Peter Kutz, Stephen Hill |
| **연도** | 2025 (rev. 2026-01) |
| **소속** | Autodesk + Adobe 공동 개발 |
| **arXiv** | [2512.23696](https://arxiv.org/abs/2512.23696) |
| **발표** | SIGGRAPH 2025 |

### 핵심 아이디어
VFX·애니메이션·디자인 시각화 전 분야에서 **상호 운용 가능한 표준 PBR 셰이더**. 다른 소프트웨어 간 머티리얼을 동일하게 표현하는 것이 목표.

### 기여
1. **Slab 기반 레이어링**: 머티리얼을 물리적 레이어로 쌓는 구조
2. **통계적 믹싱**: 복수 서브스트레이트 혼합
3. **미세면 이론** 기반 반사/굴절 계산
4. **지원 레이어**:
   - 금속 / 유전체 / 서브서피스 / 광택-확산 기판
   - 박막 홀로그래픽 무지개빛 (Thin-film Iridescence)
   - 코팅(Coat) / 퍼즈(Fuzz) 레이어
5. **고급 기능**: 얇은 벽 오브젝트 렌더링, 서브서피스 산란 파라미터화

### Unreal 연결점
UE5의 머티리얼 시스템(Base Color, Metallic, Roughness, Specular)이 OpenPBR과 동일한 미세면 이론 기반.  
OpenPBR은 그 표준화·확장 버전으로 볼 수 있음.

---

## 2. Light Sampling Field and BRDF for Physically-based Neural Rendering (2023)

| 항목 | 내용 |
|------|------|
| **연도** | 2023 |
| **arXiv** | [2304.05472](https://arxiv.org/abs/2304.05472) |

### 핵심 아이디어
Neural Rendering에 물리 기반 BRDF를 통합. 조명 샘플링 필드와 BRDF 표현을 신경망으로 학습해 물리적으로 정확한 뉴럴 렌더링 구현.

---

## BRDF 모델 비교

| 모델 | 특징 | 사용처 |
|------|------|--------|
| **Lambert** | 완전 확산, 계산 빠름 | 저급 렌더링 |
| **Phong** | 정반사 근사 | 레거시 게임 |
| **GGX/Trowbridge-Reitz** | 물리적 미세면 | UE/Unity PBR 표준 |
| **OpenPBR** | 다층 레이어 표준화 | VFX/애니메이션 상호운용 |
| **Neural BRDF** | 학습 기반 임의 재질 | 연구 단계 |

---

## 자주 발생하는 PBR 버그 패턴

| 증상 | 원인 | 해결 |
|------|------|------|
| 머티리얼이 플라스틱처럼 보임 | Metallic 0인데 Specular 너무 높음 | Specular 0.5(기본값) 유지 |
| 금속인데 색이 없음 | Base Color가 어두움 | 금속은 Base Color가 반사색 |
| 거친 표면에 핫스팟 | Roughness 0에 가까움 | Roughness 값 올리기 |
| 반투명 오브젝트 이상 | Blend Mode 오설정 | Translucent / Masked 구분 확인 |

---

## 관련 페이지
- [렌더링 파이프라인 시스템](../systems/rendering.md)
- [볼류메트릭 & 그림자 논문](volumetric_and_shadow.md)
- [하이브리드 렌더링 논문](hybrid_rendering.md)
