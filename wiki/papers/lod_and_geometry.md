---
name: LOD & Neural Geometry
type: paper-collection
tags: LOD, level-of-detail, neural-SDF, mesh-simplification, 3DGS, large-scale
last_updated: 2026-04-18
source: raw-ingest
scene_verified: false
---

# LOD & Neural Geometry 논문 모음

---

## 1. Neural Geometric Level of Detail (CVPR 2021)

| 항목 | 내용 |
|------|------|
| **저자** | Towaki Takikawa et al. (NVIDIA, U of Toronto) |
| **arXiv** | [2101.10994](https://arxiv.org/abs/2101.10994) |
| **성능** | 기존 대비 100~1000배 빠름 |

Octree 기반 피처 볼륨으로 신경 SDF를 여러 LOD로 표현. 희소 Octree 순회로 렌더링 중 불필요한 노드 스킵 → 실시간 SDF 렌더링.

### Unreal 연결점
UE5 **Nanite**의 클러스터 DAG LOD와 방향성 유사. Nanite는 명시적 메시, 이 논문은 암묵적 SDF 기반.

---

## 2. Hierarchical 3DGS for Very Large Datasets (SIGGRAPH 2024)

| 항목 | 내용 |
|------|------|
| **저자** | Bernhard Kerbl et al. (Inria, TU Wien) |
| **출판** | ACM ToG 43(4), SIGGRAPH 2024 |
| **arXiv** | [2406.12080](https://arxiv.org/abs/2406.12080) |

대규모 씬(수만 장 이미지, 수 km 궤적)을 위한 계층적 3DGS. 청크 분할 학습 → 계층 통합 → LOD 자동 전환.

### Unreal 연결점
UE5 **World Partition + Nanite** 조합과 동일한 목표 — 대규모 오픈월드 실시간 렌더링.

---

## LOD 기법 비교

| 기법 | 전환 방식 | 프로덕션 사례 |
|------|----------|--------------|
| 이산 LOD | 팝핑 (거리 교체) | UE4 이전 기본 |
| Nanite (UE5) | 마이크로폴리곤 연속 | UE5 표준 |
| Neural LOD | SDF 보간 (연속) | 연구 단계 |
| Hierarchical 3DGS | 가우시안 블렌딩 | 연구 단계 |

---

## 관련 페이지
- [렌더링 파이프라인 시스템](../systems/rendering.md)
- [3D Gaussian Splatting 논문](gaussian_splatting.md)
