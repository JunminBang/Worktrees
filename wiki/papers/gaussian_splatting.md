---
name: 3D Gaussian Splatting
type: paper-collection
tags: 3DGS, gaussian-splatting, real-time, radiance-field, novel-view-synthesis, ray-tracing
last_updated: 2026-04-18
source: raw-ingest
scene_verified: false
---

# 3D Gaussian Splatting 논문 모음

2023년 등장한 새로운 씬 표현 방식. NeRF의 암묵적 표현을 대체하는 **명시적** 방법으로 실시간 렌더링 가능.

---

## 3DGS vs NeRF 비교

| 항목 | NeRF | 3D Gaussian Splatting |
|------|------|----------------------|
| **표현 방식** | 암묵적 (MLP 네트워크) | 명시적 (수백만 개 3D 가우시안) |
| **렌더링 속도** | 느림 (< 1 FPS) | 빠름 (≥ 30 FPS @ 1080p) |
| **편집 가능성** | 어려움 | 쉬움 (가우시안 직접 조작) |
| **학습 시간** | 수 시간 | 수십 분 |
| **메모리** | 적음 (MLP 파라미터) | 많음 (수백만 가우시안) |

---

## 1. 3D Gaussian Splatting for Real-Time Radiance Field Rendering (2023) ⭐ 원조 논문

| 항목 | 내용 |
|------|------|
| **저자** | Bernhard Kerbl, Georgios Kopanas, Thomas Leimkühler, George Drettakis |
| **연도** | 2023 |
| **출판** | ACM Transactions on Graphics 42(4) — SIGGRAPH 2023 |
| **arXiv** | [2308.04079](https://arxiv.org/abs/2308.04079) |
| **성능** | ≥30 FPS @ 1080p |

### 핵심 아이디어
Sparse 포인트 클라우드(SfM 결과)에서 시작 → 3D 가우시안으로 씬 표현 → 빠른 Visibility-aware Splatting으로 렌더링.

### 기여
1. 이방성(Anisotropic) 공분산 최적화로 씬 형태를 정확히 표현
2. 가우시안 밀도 제어(Densification/Pruning) 자동화
3. CUDA 기반 빠른 Visibility-aware Splatting 알고리즘

### 파이프라인
```
SfM Sparse Points (초기화)
  ↓
3D Gaussian 최적화 (위치, 회전, 스케일, 불투명도, SH 색상)
  ↓
가우시안 정렬 (카메라 거리 순)
  ↓
Alpha Compositing Splatting (GPU 타일 래스터라이저)
  ↓
출력 이미지
```

---

## 2. A Survey on 3D Gaussian Splatting (2024)

| 항목 | 내용 |
|------|------|
| **저자** | Guikun Chen, Wenguan Wang (Zhejiang University) |
| **연도** | 2024 (최신 업데이트 2026-04) |
| **arXiv** | [2401.03890](https://arxiv.org/abs/2401.03890) |

### 핵심 내용
3DGS 등장 이후 급증한 파생 연구를 최초로 체계적으로 정리한 서베이.

### 다루는 주제
- 3DGS 원리 및 등장 배경 분석
- 렌더링 속도 / 편집 가능성의 획기적 개선 원인
- VR, 인터랙티브 미디어 적용 사례
- 주요 벤치마크 비교
- 미해결 과제 및 연구 방향

### 주요 파생 연구 카테고리
- **압축**: 저장 용량 축소
- **편집**: 가우시안 직접 수정
- **동적 씬**: 시간축 추가
- **SLAM**: 실시간 맵핑
- **로봇공학**: 씬 이해

---

## 3. 3D Gaussian Ray Tracing: Fast Tracing of Particle Scenes (SIGGRAPH Asia 2024)

| 항목 | 내용 |
|------|------|
| **저자** | Nicolas Moenne-Loccoz et al. (NVIDIA, University of Toronto) |
| **연도** | 2024 |
| **발표** | SIGGRAPH Asia 2024 |
| **arXiv** | [2407.07090](https://arxiv.org/abs/2407.07090) |

### 핵심 아이디어
기존 3DGS는 래스터화 방식 → **Ray Tracing** 으로 전환해 2차 조명, 왜곡 카메라, 확률적 샘플링 등 유연한 효과 지원.

### 기여
1. 가우시안 입자를 **Bounding Mesh로 감싸** BVH 구축 → GPU RT 하드웨어 가속 활용
2. 깊이 순서로 배치 셰이딩 → 반투명 처리 정확도 향상
3. 일반화된 커널 함수로 가우시안 교차 횟수 감소
4. 래스터화 3DGS와 동등한 성능 유지

### 방법
```
3D Gaussian 입자
  → Bounding Mesh 생성
  → BVH 구축 (GPU RT Core 활용)
  → Ray casting per pixel
  → 깊이 순 배치 셰이딩 (Alpha Compositing)
  → 2차 조명 효과 처리 가능
```

### 래스터 3DGS와 비교

| 항목 | 래스터 3DGS | Gaussian Ray Tracing |
|------|-------------|----------------------|
| 2차 반사/굴절 | 불가 | 가능 |
| 왜곡 카메라 | 어려움 | 쉬움 |
| 확률적 샘플링 | 불가 | 가능 |
| 속도 | 빠름 | 비슷 (HW RT 덕분) |

---

## Unreal Engine 연결점

- UE5 Nanite는 마이크로폴리곤 래스터라이저 — 3DGS의 Splatting 파이프라인과 유사한 방향성
- 3DGS를 UE에서 활용하는 플러그인 연구 진행 중
- [UE4-NeRF](neural_rendering.md#4-ue4-nerf) 와 달리 3DGS는 공식 UE 통합 없음 (2026-04 기준)

---

## 관련 페이지
- [Neural Rendering 논문](neural_rendering.md)
- [하이브리드 렌더링 논문](hybrid_rendering.md)
- [렌더링 파이프라인 시스템](../systems/rendering.md)
