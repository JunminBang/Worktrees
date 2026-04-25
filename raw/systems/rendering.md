---
name: 렌더링 파이프라인 & 기법
type: system
tags: rendering, shading, ray-tracing, rasterization, LOD, GPU, z-buffer
last_updated: 2026-04-18
source: raw-ingest
source_ref: D:/GGGG/Clippings/Computer Graphics Tutorial.md
source_ref2: D:/GGGG/Clippings/Computer graphics.md
scene_verified: false
---

# 렌더링 파이프라인 & 기법

## 개요

3D 씬을 2D 화면으로 변환하는 일련의 과정.

```
3D Scene
  └── Vertex Shader     ← Transform (MVP Matrix)
        └── Rasterization  ← 삼각형 → 픽셀
              └── Fragment Shader  ← 색상/조명
                    └── Output (Frame Buffer)
```

---

## 렌더링 기법 비교

| 기법 | 설명 | 특징 |
|------|------|------|
| **Rasterization** | 삼각형 메시 → 픽셀 | 실시간 표준, 고속 |
| **Ray Tracing** | 시선 → 광선 역추적 | 자연스러운 조명, 고비용 |
| **Z-Buffer** | 깊이값으로 앞/뒤 판별 | 가시성 결정 필수 |

---

## 셰이딩 모델

| 모델 | 특징 |
|------|------|
| **Gouraud** | 버텍스별 조명 → 보간. 빠르지만 Specular 각짐 |
| **Phong** | 픽셀별 조명 계산. 부드럽고 사실적 |

---

## 최적화 기법

| 기법 | Unreal 연결 |
|------|-------------|
| LOD | Static/Skeletal Mesh LOD |
| Culling | Frustum Culling 자동 |
| Instancing | Instanced Static Mesh |
| Mipmapping | 텍스처 임포트 시 자동 생성 |
| Anti-Aliasing | TAA/TSR |

---

## 렌더링 버그 패턴

| 증상 | 원인 | 해결 |
|------|------|------|
| 오브젝트 투과 | Z-fighting | 오브젝트 겹침 제거 |
| 멀리서 깜빡임 | LOD 팝핑 | Transition Distance 조정 |
| 그림자 끊김 | Shadow Bias | Bias 값 조정 |
| 텍스처 흐림 | Mipmap 과다 | LOD Bias 확인 |
| 씬 전체 어두움 | PostProcess Gamma | → [BUG-002](../bugs/BUG-002.md) |

---

## 관련 페이지
- [조명 시스템](lighting.md)
- [렌더링 파이프라인 논문](../papers/rendering_pipeline_advances.md)
- [하이브리드 렌더링 논문](../papers/hybrid_rendering.md)
