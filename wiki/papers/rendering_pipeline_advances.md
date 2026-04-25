---
name: 실시간 렌더링 파이프라인 최신 연구
type: paper-collection
tags: rendering-pipeline, real-time, GPU, software-rasterization, deep-learning, SIGGRAPH
last_updated: 2026-04-18
source: raw-ingest
scene_verified: false
---

# 실시간 렌더링 파이프라인 최신 연구 모음

GPU 파이프라인 구조, 딥러닝 최적화, 프로덕션 렌더링 기법 관련 논문.

---

## 1. Advances in Real-Time Rendering in Games (SIGGRAPH 2025)

| 항목 | 내용 |
|------|------|
| **발표** | SIGGRAPH 2025 Course |
| **ACM** | [Part I](https://dl.acm.org/doi/10.1145/3721241.3744989) / [Part II](https://dl.acm.org/doi/10.1145/3721241.3744991) |
| **특이사항** | 20주년 기념 특집 |

### 핵심 내용
프로덕션 게임 렌더링에서 검증된 최신 기법 모음. 매년 SIGGRAPH에서 발표되는 실시간 렌더링 연구의 집대성.

### 다루는 주제 (역대 주제 포함)
- 글로벌 일루미네이션 근사 (Lumen류)
- 실시간 Ray Tracing 통합
- Temporal AA / Upscaling (DLSS, FSR류)
- 가상 텍스처 / 스트리밍
- GPU-Driven 렌더링

### Unreal 연결점
UE5의 Lumen, Nanite, TSR 등이 이 코스에서 소개된 기법들을 프로덕션 레벨로 구현한 사례.

---

## 2. A High-Performance Software Graphics Pipeline Architecture for the GPU (SIGGRAPH 2018)

| 항목 | 내용 |
|------|------|
| **출판** | ACM Transactions on Graphics (SIGGRAPH 2018) |
| **ACM** | [10.1145/3197517.3201374](https://dl.acm.org/doi/abs/10.1145/3197517.3201374) |

### 핵심 아이디어
GPU 위에서 전체 그래픽 파이프라인을 **소프트웨어**로 구현. 완전 동시 멀티스테이지 스트리밍 설계 + 동적 로드 밸런싱.

### 기여
- 고정 하드웨어 파이프라인의 유연성 한계 극복
- 동적 로드밸런싱으로 스테이지 간 병목 제거
- 소프트웨어 정의 파이프라인에서 하드웨어 수준 성능 달성

### 구조
```
Vertex Shader (Compute)
  ↓ [동적 로드밸런싱]
Primitive Assembly
  ↓
Rasterization (SW)
  ↓
Fragment Shader (Compute)
  → Frame Buffer
```

### 의의
Nanite 마이크로폴리곤 파이프라인의 이론적 선행 연구로 볼 수 있음.

---

## 3. Exploration and Real-time Rendering Optimization via Deep Learning (2024)

| 항목 | 내용 |
|------|------|
| **발표** | 2024 5th International Conference on Computer Science and Management Technology |
| **ACM** | [10.1145/3708036.3708139](https://dl.acm.org/doi/10.1145/3708036.3708139) |

### 핵심 아이디어
딥러닝 방법론을 실시간 렌더링 최적화 경로 탐색에 적용.

### 방향
- 렌더링 파이프라인 내 병목 자동 탐지
- DL 기반 최적화 경로 추천
- DLSS / FSR 등 신경망 업스케일링의 이론적 배경과 연결

### Unreal 연결점
UE5의 TSR(Temporal Super Resolution)이 유사한 DL 기반 접근법을 프로덕션화한 사례.

---

## 렌더링 파이프라인 진화 타임라인

```
전통 고정 파이프라인 (OpenGL 1.x)
  ↓
프로그래머블 셰이더 (OpenGL 2.0, DX9)
  ↓
Compute Shader / GPGPU (DX11, OpenGL 4.x)
  ↓
소프트웨어 정의 파이프라인 (2018 논문)
  ↓
Ray Tracing 하드웨어 (RTX, DX12 DXR, 2018~)
  ↓
하이브리드 RT+Raster (현재 주류)
  ↓
Neural Rendering 통합 (NeRF, 3DGS, 진행 중)
```

---

## 관련 페이지
- [렌더링 파이프라인 시스템](../systems/rendering.md)
- [하이브리드 렌더링 논문](hybrid_rendering.md)
- [Neural Rendering 논문](neural_rendering.md)
- [3D Gaussian Splatting 논문](gaussian_splatting.md)
