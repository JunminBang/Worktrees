---
name: Neural Rendering / NeRF
type: paper-collection
tags: nerf, neural-rendering, volumetric, real-time, UE4, hardware-acceleration
last_updated: 2026-04-18
source: raw-ingest
scene_verified: false
---

# Neural Rendering / NeRF 논문 모음

딥러닝 기반 씬 표현 및 렌더링 연구. 2D 이미지들로부터 3D 씬을 학습해 novel-view를 합성.

---

## NeRF 개요

```
입력: 멀티뷰 2D 이미지 + 카메라 포즈
  ↓
MLP 네트워크 학습 (위치 + 방향 → RGB + 밀도)
  ↓
Volume Rendering으로 새로운 시점 합성
```

**한계**: 학습/렌더링 모두 느림 → 실시간 렌더링이 주요 연구 과제

---

## 1. Neural Rendering and Its Hardware Acceleration: A Review (2024)

| 항목 | 내용 |
|------|------|
| **저자** | Xinkai Yan, Jieting Xu, Yuchi Huo, Hujun Bao |
| **연도** | 2024 |
| **arXiv** | [2402.00028](https://arxiv.org/abs/2402.00028) |

### 핵심 내용
Neural Rendering을 딥러닝 + 컴퓨터 그래픽스의 융합으로 정의. 조명/카메라 파라미터를 제어 가능한 사실적 씬 생성 가능.

### 다루는 주제
- Neural Rendering 기술 기반 및 연구 동향
- 하드웨어 가속 요구사항 분석
- 현재 GPU 아키텍처의 한계 및 전용 프로세서 설계 방향
- NeRF 변형체, Free-viewpoint Video, Material Editing, Digital Human Avatar 등 응용

---

## 2. Neural Radiance Fields for the Real World: A Survey (2025)

| 항목 | 내용 |
|------|------|
| **저자** | Wenhui Xiao et al. |
| **연도** | 2025 (rev. 2025-12) |
| **arXiv** | [2501.13104](https://arxiv.org/abs/2501.13104) |

### 핵심 내용
실세계 적용을 위한 NeRF 종합 서베이. 2D 이미지에서 복잡한 3D 씬을 효과적으로 재구성.

### 다루는 주제
- 이론적 혁신 및 알고리즘 최적화
- 대안 표현 방식 (3DGS 등과의 비교)
- 씬 이해, 콘텐츠 생성, 로봇공학 응용
- 주요 데이터셋 및 툴킷
- 미해결 연구 과제

---

## 3. MixRT: Mixed Neural Representations For Real-Time NeRF Rendering (3DV'24)

| 항목 | 내용 |
|------|------|
| **저자** | Chaojian Li, Bichen Wu, Peter Vajda, Yingyan Celine Lin |
| **연도** | 2023 (accepted 3DV'24) |
| **arXiv** | [2312.11841](https://arxiv.org/abs/2312.11841) |
| **성능** | >30 FPS @ 1280×720, MacBook M1 Pro |

### 핵심 아이디어
고품질 메시 지오메트리 없이도 포토리얼 렌더링 가능 → 저품질 메시 + 변위 맵 + 압축 NeRF 혼합 표현.

### 기여
- 엣지 디바이스 실시간 렌더링 (>30 FPS @ M1 Pro)
- Unbounded-360 실내 씬 품질 +0.2 PSNR 향상
- 저장 용량 80% 이하로 감소

### 구조
```
저품질 메시 (기본 형태)
  + View-dependent Displacement Map (표면 디테일)
  + 압축 NeRF 모델 (외관)
  → WebGL로 하드웨어 가속 렌더링
```

---

## 4. UE4-NeRF: Large-Scale Scene Real-Time Rendering (NeurIPS 2023) ⭐

| 항목 | 내용 |
|------|------|
| **저자** | Jiaming Gu et al. |
| **연도** | 2023 (NeurIPS 2023) |
| **arXiv** | [2310.13263](https://arxiv.org/abs/2310.13263) |
| **성능** | 4K @ 최대 43 FPS (Unreal Engine 4 내) |

### 핵심 아이디어
**Unreal Engine 4와 직접 통합**. 대규모 씬을 서브-NeRF로 분할 → UE4 래스터화 파이프라인에 통합해 실시간 4K 렌더링.

### 기여
1. 대규모 씬 → 독립적 sub-NeRF 단위로 분할
2. 정팔면체(Octahedra) 기반 메시 초기화 + 학습 중 버텍스 최적화
3. LOD 메시 변형 — 거리별 디테일 자동 조정
4. UE4 래스터화 파이프라인 통합
5. 씬 편집 가능 (기존 NeRF 대비 장점)

### Unreal 연결점
UE4 래스터라이저를 그대로 활용하므로 현재 UE5 프로젝트에서도 응용 가능한 아키텍처.  
→ LOD 전략은 [렌더링 시스템](../systems/rendering.md)의 LOD 섹션과 직결.

---

## 자주 발생하는 NeRF 실용 한계

| 한계 | 내용 | 해결 방향 |
|------|------|-----------|
| 학습 시간 | 씬 1개 학습에 수 시간 | Instant-NGP, 3DGS |
| 실시간 렌더링 | 기본 NeRF는 1 FPS 이하 | MixRT, UE4-NeRF, 3DGS |
| 대규모 씬 | 단일 MLP 용량 한계 | 씬 분할 (UE4-NeRF 방식) |
| 편집 불가 | 암묵적 표현 → 수정 어려움 | 3DGS(명시적) 또는 메시 변환 |

---

## 관련 페이지
- [3D Gaussian Splatting 논문](gaussian_splatting.md)
- [하이브리드 렌더링 논문](hybrid_rendering.md)
- [렌더링 파이프라인 시스템](../systems/rendering.md)
