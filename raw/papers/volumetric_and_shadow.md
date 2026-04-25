---
name: 볼류메트릭 렌더링 & 실시간 그림자
type: paper-collection
tags: volumetric, clouds, fog, atmosphere, shadow, soft-shadow, neural, unreal-engine
last_updated: 2026-04-18
source: raw-ingest
scene_verified: false
---

# 볼류메트릭 렌더링 & 실시간 그림자 논문 모음

구름·안개·연기 등 볼류메트릭 매질과 실시간 그림자 계산 연구.

---

## 1. ML-Driven Volumetric Cloud Rendering in Unreal Engine (2025) ⭐ UE 직접 연관

| 항목 | 내용 |
|------|------|
| **저자** | Shruti Singh, Shantanu Kumar |
| **연도** | 2025 |
| **arXiv** | [2502.08107](https://arxiv.org/abs/2502.08107) |
| **엔진** | Unreal Engine (직접 구현) |
| **성능** | 평균 35ms/frame |

### 핵심 아이디어
**Unreal Engine 내에서** 머신러닝 기반 볼류메트릭 구름 셰이더 개발. 기존 2D 날씨 텍스처를 제거하고 절차적 노이즈로 구름 형태를 실시간 생성.

### 기여
- 전통 2D 기법 대비 **구름 사실성 15% 향상**
- 이중 레이어 절차적 노이즈 모델 — 2D 날씨 텍스처 불필요
- Ray-casting 알고리즘 + 동적 조명 처리
- 예술적/사실적 시뮬레이션 모두 지원하는 파라미터 설정

### UE 구현 세부
- UE 전용 커스텀 셰이더로 구현
- 절차적으로 구성 가능한 하늘 시스템
- Volumetric Cloud Component와 통합

### Unreal 연결점
UE5의 **Volumetric Cloud** 컴포넌트가 이 논문과 동일한 Ray-marching 방식 사용.  
이 논문은 ML을 추가해 노이즈 품질을 향상시킨 확장 연구.

---

## 2. Real-time Light Estimation and Neural Soft Shadows for AR (2023)

| 항목 | 내용 |
|------|------|
| **저자** | Alexander Sommer, Ulrich Schwanecke, Elmar Schömer |
| **연도** | 2023 |
| **arXiv** | [2308.01613](https://arxiv.org/abs/2308.01613) |
| **성능** | 조명 추정 9ms + 그림자 5ms (iPhone 11 Pro) |

### 핵심 아이디어
실내 AR 씬에서 가상 오브젝트를 실사처럼 합성. 조명 방향 추정 + 소프트 그림자 신경망 생성을 모바일에서 실시간 처리.

### 기여
1. **조명 추정 네트워크**: 주 조명 방향, 색상, 주변광 색상, 그림자 불투명도 예측
2. **신경 소프트 그림자**: MLP가 빛 방향에 따른 소프트 그림자 텍스처 생성
3. 전체 파이프라인이 현재 모바일 기기에서 실시간 구동

### 파이프라인
```
입력 이미지 (AR 실내 씬)
  ↓
조명 추정 DNN → 주광 방향, 색상 (9ms)
  ↓
Neural Soft Shadow MLP → 방향 의존 그림자 텍스처 (5ms)
  ↓
가상 오브젝트 + 그림자 합성 출력
```

---

## 3. Real-Time Rendering of High Albedo Anisotropic Volumetric Media (2024)

| 항목 | 내용 |
|------|------|
| **저자** | Shun Fang, Xing Feng, Ming Cui |
| **연도** | 2024 |
| **arXiv** | [2401.14051](https://arxiv.org/abs/2401.14051) |

### 핵심 아이디어
구름·연기·안개 등 **고 알베도 이방성 볼류메트릭 매질**의 다중 산란을 실시간으로 근사. 경로 추적 대신 신경망으로 복사 전달 방정식 가속.

### 기여
1. **피처 생성 파이프라인**: 밀도, 투과율, 위상 특성 샘플링 피처 추출
2. **계층적 3D-CNN**: 투과율 피처 처리로 향상된 투과율 맵 계산
3. **레이어드 샘플링 템플릿**: 확산/정반사 구분 처리
4. **어텐션 모듈**: 중요 채널 선택으로 산란/하이라이트/그림자 품질 향상

---

## 볼류메트릭 렌더링 기법 비교

| 기법 | 품질 | 속도 | 동적 | 사례 |
|------|------|------|------|------|
| **Ray Marching** | 높음 | 중간 | 가능 | UE5 Volumetric Cloud |
| **Voxel 기반** | 중간 | 빠름 | 제한 | UE4 Volumetric Fog |
| **신경망 근사** | 높음 | 빠름 | 가능 | 이 논문들 |
| **Path Tracing** | 최고 | 매우 느림 | 가능 | 오프라인 |

---

## 실시간 그림자 기법 비교

| 기법 | 소프트 그림자 | 비용 | UE 구현 |
|------|-------------|------|---------|
| **Shadow Map** | 불가(계단) | 낮음 | 기본 |
| **PCF (Percentage Closer Filtering)** | 근사 | 중간 | UE 표준 |
| **PCSS (Percentage Closer Soft Shadow)** | 가능 | 높음 | UE 옵션 |
| **Ray Traced Shadow** | 정확 | 매우 높음 | UE5 RT 활성화 시 |
| **Neural Soft Shadow** | 가능 (모바일) | 낮음 | 이 논문 |

---

## Unreal 연결점 정리

| UE 기능 | 관련 논문 기법 |
|---------|--------------|
| Volumetric Cloud Component | ML-Driven Cloud (2502.08107) |
| Lumen GI | Global Illumination 논문들 |
| Ray Traced Shadows | Hybrid Rendering 논문들 |
| PCSS / Contact Shadow | Neural Soft Shadow 연구 방향 |

---

## 관련 페이지
- [렌더링 파이프라인 시스템](../systems/rendering.md)
- [조명 시스템](../systems/lighting.md)
- [글로벌 일루미네이션 논문](global_illumination.md)
- [PBR & 셰이딩 논문](pbr_and_shading.md)
