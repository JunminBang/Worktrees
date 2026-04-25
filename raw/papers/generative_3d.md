---
name: 생성형 3D & Diffusion 렌더링
type: paper-collection
tags: diffusion, generative, 3D-generation, mesh-generation, image-based-rendering, reconstruction
last_updated: 2026-04-18
source: raw-ingest
scene_verified: false
---

# 생성형 3D & Diffusion 렌더링 논문 모음

Diffusion 모델을 활용한 3D 씬/메시 생성 및 재구성 연구.

---

## Diffusion 모델 개요

```
노이즈 이미지
  → Denoising Step × N회
  → 깨끗한 이미지 or 3D 표현
```

3D 생성에서의 핵심 과제: **2D 이미지 데이터만으로 3D 구조 학습**

---

## 1. Denoising Diffusion via Image-Based Rendering (ICLR 2024)

| 항목 | 내용 |
|------|------|
| **저자** | Titas Anciukevičius, Fabian Manhardt, Federico Tombari, Paul Henderson |
| **연도** | 2024 |
| **발표** | ICLR 2024 |
| **arXiv** | [2402.03445](https://arxiv.org/abs/2402.03445) |

### 핵심 아이디어
**최초의 실세계 3D 씬 생성 가능한 Diffusion 모델**. 마스크·깊이 없이 2D 이미지만으로 3D 씬 Prior 학습. 3D 재구성과 생성을 단일 아키텍처로 통합.

### 기여
1. **IB-planes**: 이미지 디테일 가시성에 따라 동적 용량 할당하는 신경 씬 표현
2. **Image Representation Dropout**: Diffusion과 Image-based Rendering 결합 시 퇴화 솔루션 방지
3. 생성·Novel View Synthesis·3D 재구성 세 태스크 모두 SOTA

### 방법
```
2D 이미지 (마스크/깊이 없음)
  ↓
IB-planes 표현 학습
  ↓
Denoising Diffusion으로 3D Prior 학습
  ↓
실시간 3D 생성 / Novel View 합성 / 재구성
```

---

## 2. MeshFormer: High-Quality Mesh Generation (NeurIPS 2024)

| 항목 | 내용 |
|------|------|
| **저자** | Minghua Liu et al. (UC San Diego, Microsoft) |
| **연도** | 2024 |
| **발표** | NeurIPS 2024 |
| **arXiv** | [2408.10198](https://arxiv.org/abs/2408.10198) |

### 핵심 아이디어
Sparse-view 입력으로 고품질 텍스처 메시 생성. Triplane 표현 대신 **3D Sparse Voxel + Transformer** 구조로 세밀한 지오메트리 직접 생성.

### 기여
1. 3D Sparse Voxel 저장소 — Triplane 한계 극복
2. 2D Diffusion 모델의 Normal Map으로 지오메트리 학습 가이드
3. SDF 기반 지도 학습 + Surface Rendering으로 직접 메시 생성
4. 단일 이미지 / 텍스트 → 3D 태스크와 Diffusion 모델 통합 가능

---

## 3D 생성 기법 비교

| 방법 | 입력 | 출력 | 특징 |
|------|------|------|------|
| **NeRF** | 멀티뷰 이미지 | 볼류메트릭 | 느린 학습/렌더링 |
| **3DGS** | 멀티뷰 이미지 | 가우시안 | 빠른 실시간 렌더링 |
| **IB-planes Diffusion** | 소수 이미지 | 3D 씬 | 생성+재구성 통합 |
| **MeshFormer** | Sparse-view | 메시 | 직접 편집 가능한 메시 |

---

## Unreal 연결점

- 이 논문들의 3D 생성 파이프라인이 **UE 레벨 에셋 자동 생성** 방향의 연구 기반
- 텍스트/이미지 → 3D 메시 → UE Import 워크플로우가 현실화 중
- MeshFormer의 고품질 메시는 Nanite와 직접 호환 가능

---

## 관련 페이지
- [Neural Rendering 논문](neural_rendering.md)
- [3D Gaussian Splatting 논문](gaussian_splatting.md)
- [렌더링 파이프라인 시스템](../systems/rendering.md)
