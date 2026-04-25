---
name: 하이브리드 렌더링 (Ray Tracing + Rasterization)
type: paper-collection
tags: ray-tracing, rasterization, hybrid-rendering, real-time, denoising, motion-blur
last_updated: 2026-04-18
source: raw-ingest
scene_verified: false
---

# 하이브리드 렌더링 논문 모음

Ray Tracing의 품질과 Rasterization의 속도를 결합하는 하이브리드 렌더링 연구.

---

## 1. Hybrid-Rendering Techniques in GPU (2023)

| 항목 | 내용 |
|------|------|
| **저자** | Pedro Granja, João Pereira |
| **연도** | 2023 |
| **arXiv** | [2312.06827](https://arxiv.org/abs/2312.06827) |
| **API** | Vulkan + Nvidia RTX |

### 핵심 아이디어
Ray Tracing + Rasterization + Denoising 세 요소를 결합해 포토리얼한 품질을 실시간(>30 fps)으로 달성.

### 기여
- Temporal Denoising에서 History Rectification(Variance Color Clamping)의 영향 분석 및 아티팩트 완화
- 공간 필터링에서 Separable Blur + Reinhard Tone Mapping 적용 방식 제안
- 하이브리드 시스템 구현 및 성능 벤치마크

### 방법
```
Rasterization (G-Buffer 생성)
  ↓
Ray Tracing (그림자, 반사, AO 계산)
  ↓
Temporal Denoising (Variance Color Clamping)
  ↓
Spatial Filter (Separable Blur)
  ↓
Tone Mapping (Reinhard)
```

### Unreal 연결점
UE5의 Lumen이 유사한 하이브리드 구조 사용 — SW Ray Tracing + Screen-Space 폴백

---

## 2. Hybrid MBlur: Ray Tracing으로 모션 블러 개선 (2022)

| 항목 | 내용 |
|------|------|
| **저자** | Yu Wei Tan, Xiaohan Cui, Anand Bhojan |
| **연도** | 2022 |
| **arXiv** | [2210.06159](https://arxiv.org/abs/2210.06159) |

### 핵심 아이디어
기존 스크린 스페이스 모션 블러는 부분 가려짐(Partial Occlusion) 아티팩트 발생 → Ray Tracing으로 배경 정보를 재귀적으로 추적해 보정.

### 기여
- Rasterization 기반 파이프라인에 RT를 최소 비용으로 추가하는 방식
- Partial Occlusion Semi-Transparency 문제 해결
- 성능 오버헤드 분석

### 방법
1. 속도 기반 Spatial Sampling으로 방향성 블러 렌더
2. 부분 가려짐 영역을 RT 광선으로 재탐색
3. 배경 픽셀 정보를 블렌딩

### Unreal 연결점
UE의 `Motion Blur` 설정이 유사한 스크린스페이스 방식 — 이 논문의 기법은 차세대 접근법

---

## 3. DHR+S: 분산 하이브리드 렌더링 + 실시간 그림자 (2024)

| 항목 | 내용 |
|------|------|
| **연도** | 2024 |
| **arXiv** | [2406.06963](https://arxiv.org/abs/2406.06963) |
| **대상** | Metaverse / 모바일 씬 클라이언트 |

### 핵심 아이디어
클라우드에서 RT로 고품질 렌더링 → 씬 클라이언트(모바일/XR 기기)로 스트리밍. 불량 네트워크 환경에서도 인터랙티브 프레임레이트 유지.

### 방법
- 클라우드: Ray Tracing으로 그림자 포함 고품질 프레임 생성
- 클라이언트: Rasterization으로 로컬 렌더링
- 두 결과 합성 후 표시

---

## 4. Texture Streaming Pipeline for Real-Time GPU Ray Tracing (SIGGRAPH 2025)

| 항목 | 내용 |
|------|------|
| **소속** | Disney Animation |
| **발표** | SIGGRAPH 2025 |
| **ACM** | [10.1145/3721239.3734098](https://dl.acm.org/doi/10.1145/3721239.3734098) |

### 핵심 아이디어
실시간 GPU Ray Tracing 환경에서 텍스처 캐시 효율을 극대화하는 스트리밍 파이프라인.

### 방법
- GPU 캐시 coherency를 고려한 텍스처 스트리밍 설계
- RT 특성(비연속 메모리 접근)에 맞춘 캐시 관리

---

## 관련 페이지
- [렌더링 파이프라인 시스템](../systems/rendering.md)
- [Neural Rendering 논문](neural_rendering.md)
- [3D Gaussian Splatting 논문](gaussian_splatting.md)
