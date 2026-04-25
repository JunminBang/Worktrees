---
name: Neural Avatar & 캐릭터 렌더링
type: paper-collection
tags: avatar, character, gaussian-splatting, skinning, animatable, real-time, CVPR
source: raw-ingest
scene_verified: false
last_updated: 2026-04-19
---

# Neural Avatar & 캐릭터 렌더링 논문 모음

3DGS·신경망 기반으로 실시간 애니메이션 가능한 인체 아바타를 렌더링하는 연구.

---

## 전통 캐릭터 렌더링 vs Neural Avatar

```
전통 방식
  Skeletal Mesh + LBS(Linear Blend Skinning) + 텍스처
  → UE AnimBP/State Machine 제어

Neural Avatar
  멀티뷰 영상 학습 → 3D Gaussian/NeRF 표현
  → Novel Pose/View 합성
  → 실시간 렌더링
```

---

## 1. Human Gaussian Splatting (HuGS) — Animatable Avatars (CVPR 2024)

| 항목 | 내용 |
|------|------|
| **저자** | Arthur Moreau et al. (Samsung AI) |
| **연도** | 2023 (CVPR 2024) |
| **arXiv** | 2311.17113 |
| **성능** | 80 FPS @ 512×512, +1.5 dB PSNR |

멀티뷰 영상으로 학습한 3D Gaussian 기반 인체 아바타.
Forward Skinning + 로컬 비선형 Refinement (Coarse-to-Fine 결합).

**UE 연결**: UE5 Skeletal Mesh + AnimBP의 Forward Skinning과 동일한 개념. 메시 대신 3D Gaussian을 변형.

---

## 2. SplattingAvatar: Mesh-Embedded Gaussian Splatting (CVPR 2024)

| 항목 | 내용 |
|------|------|
| **저자** | Zhijing Shao et al. |
| **연도** | 2024 (CVPR 2024) |
| **arXiv** | 2403.05087 |
| **성능** | 300+ FPS (GPU) / 30 FPS (모바일) |

삼각형 메시에 Gaussian 임베드. **메시=저주파 모션, Gaussian=고주파 외관** 분리.
Barycentric 좌표+변위로 메시 위 Gaussian 정의. 스켈레탈 애니메이션·블렌드셰이프 호환.

**UE 연결**: UE5 Skeletal Mesh + Morph Target(Blend Shape)과 동일한 구조.

---

## 아바타 기법 비교

| 기법 | 표현 | FPS | 편집 | 특징 |
|------|------|-----|------|------|
| Textured Mesh (UE 기본) | 메시+텍스처 | 수백 FPS | 쉬움 | 프로덕션 표준 |
| NeRF Avatar | 볼류메트릭 MLP | <5 FPS | 어려움 | 고품질 |
| HuGS | 3D Gaussian | 80 FPS | 중간 | 포즈 일반화 |
| SplattingAvatar | 메시+Gaussian | 300+ FPS | 쉬움 | 스켈레탈 호환 |

---

## 관련 페이지
- [3D Gaussian Splatting 논문](gaussian_splatting.md)
- [Neural Rendering 논문](neural_rendering.md)
- [애니메이션 시스템](../systems/animation.md)
