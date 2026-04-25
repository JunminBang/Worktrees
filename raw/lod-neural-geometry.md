---
title: "LOD & Neural Geometry — 레벨 오브 디테일 연구"
tags: ["LOD", "level-of-detail", "neural-SDF", "implicit-surface", "large-scale", "Nanite", "3DGS", "octree"]
created: 2026-04-19T04:07:00.046Z
updated: 2026-04-19T04:07:00.046Z
sources: ["https://arxiv.org/abs/2101.10994", "https://arxiv.org/abs/2406.12080"]
links: []
category: reference
confidence: high
schemaVersion: 1
---

# LOD & Neural Geometry — 레벨 오브 디테일 연구

# LOD & Neural Geometry — 레벨 오브 디테일 연구

거리/뷰에 따라 지오메트리 복잡도를 동적으로 조절. UE5 Nanite의 이론적 배경과 직결.

## 1. Neural Geometric Level of Detail (CVPR 2021)
- **저자**: Towaki Takikawa et al. (NVIDIA, U of Toronto) | **arXiv**: 2101.10994
- **성능**: 기존 대비 100~1000배 빠른 SDF 렌더링
- Octree 기반 피처 볼륨으로 신경 SDF를 여러 LOD로 표현. 희소 Octree 순회로 불필요 노드 스킵
- SDF 보간으로 연속 LOD 달성
- **UE 연결**: UE5 Nanite 클러스터 DAG LOD와 방향성 유사 (Nanite=명시적 메시, 이 논문=암묵적 SDF)

## 2. Hierarchical 3DGS for Very Large Datasets (SIGGRAPH 2024)
- **저자**: Bernhard Kerbl et al. | **arXiv**: 2406.12080
- 대규모 씬(수만 장 이미지, 수 km 궤적) → 청크 분할 독립 학습 → 계층 통합
- LOD 시스템: 카메라 거리별 디테일 자동 전환 + 부드러운 전환
- **UE 연결**: World Partition + Nanite 조합과 동일한 목표

## LOD 기법 비교
| 기법 | 전환 방식 | UE 사례 |
|------|----------|---------|
| 이산 LOD | 팝핑(거리 교체) | UE4 기본 |
| Nanite (UE5) | 마이크로폴리곤 연속 | UE5 표준 |
| Neural LOD | SDF 보간(연속) | 연구 단계 |
| Hierarchical 3DGS | 가우시안 블렌딩 | 연구 단계 |

## LOD 버그 패턴
| 증상 | 원인 | 해결 |
|------|------|------|
| 거리에서 팝핑 깜빡임 | LOD 전환 임계값 너무 가까움 | Screen Size 기반 거리 조정 |
| 멀리서 메시 너무 단순 | LOD 단계 부족 | LOD 단계 추가 |
| Nanite 씬 성능 저하 | 투명 머티리얼이 Nanite 비활성화 | 투명 오브젝트 Nanite 제외 |

