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

3D 씬을 2D 화면으로 변환하는 일련의 과정. Unreal Engine은 Graphics Pipeline을 내부적으로 추상화하며, 직접 노출되는 설정(LOD, Shading Model, PostProcess)이 이 개념들과 직결됨.

---

## 렌더링 파이프라인

```
3D Scene
  └── Vertex Shader     ← Transform (MVP Matrix 적용)
        └── Rasterization  ← 삼각형 → 픽셀 변환
              └── Fragment Shader  ← 색상/조명 계산
                    └── Output (Frame Buffer)
```

- **MVP Matrix**: Model × View × Projection — 오브젝트 → 클립 공간 변환
- **View Matrix**: 월드 공간 → 카메라 시점 변환
- **Projection**: Perspective(원근감) vs Orthographic(평행, CAD/기술 도면용)

---

## 렌더링 기법 비교

| 기법 | 설명 | 특징 |
|------|------|------|
| **Rasterization** | 삼각형 메시 → 픽셀 변환 | 실시간 표준, 고속 |
| **Ray Tracing** | 시선 → 광선 역추적 | 자연스러운 조명/반사, 고비용 |
| **Scanline** | 수평선 단위로 표면 계산 | 전통적 방식 |
| **Z-Buffer** | 깊이값으로 오브젝트 앞/뒤 판별 | 가시성 결정 필수 |

> **Depth Buffer (Z-Buffer)**: 없으면 렌더 순서에 따라 뒤에 있는 면이 앞에 나오는 오류 발생.  
> Unreal에서 Z-fighting 버그의 근본 원인.

---

## 셰이딩 모델

### Gouraud Shading
- 버텍스마다 조명 계산 → 폴리곤 내부 색상 보간
- 빠르지만 Specular highlight가 각지거나 버텍스 사이에서 사라질 수 있음

### Phong Shading
- 폴리곤 내 픽셀마다 조명 계산 (법선 보간)
- 부드러운 Specular, 더 사실적 — 더 무거움

### 관련 Unreal 설정
- `Shading Model` (머티리얼 세팅): Default Lit / Unlit / Subsurface 등
- Normal Map으로 Phong-계열 효과 경량화 가능

---

## 텍스처 & 매핑

| 기법 | 설명 |
|------|------|
| **Texture Mapping** | 이미지를 3D 표면에 투영 |
| **Bump Mapping** | 법선 벡터 변조로 요철 표현 (실제 지오메트리 변경 없음) |
| **Normal Map** | Bump의 발전형, RGB로 법선 방향 저장 |
| **Ambient Occlusion** | 오목한 부위 주변광 차폐 — 접촉감/그림자 사실감 향상 |

---

## 핵심 알고리즘

| 알고리즘 | 용도 |
|----------|------|
| **Bresenham's Line** | 정수 연산으로 픽셀 라인 근사 — 고속 레스터 드로잉 |
| **Midpoint Circle** | Bresenham 확장, 원 픽셀화 |
| **Flood-Fill** | 시드 포인트에서 시작해 경계까지 색상 채우기 |
| **Scanline (Hidden Surface)** | 좌→우 스캔라인 단위 깊이 계산으로 숨겨진 면 제거 |

---

## 최적화 기법

| 기법 | 설명 | Unreal 연결 |
|------|------|-------------|
| **LOD (Level of Detail)** | 거리 따라 메시 단순화 | Static/Skeletal Mesh LOD 설정 |
| **Culling** | 카메라 밖 오브젝트 렌더 건너뜀 | Frustum Culling 자동 적용 |
| **Instancing** | 동일 메시 다수 배치 시 드로우콜 묶음 | Instanced Static Mesh |
| **Mipmapping** | 거리에 따라 텍스처 해상도 자동 감소 | 텍스처 임포트 시 자동 생성 |

---

## 픽셀 & 이미지 개념

- **Pixel**: 디지털 이미지의 최소 단위 (RGB 서브픽셀로 구성)
- **Resolution**: 가로×세로 픽셀 수 — 높을수록 세밀
- **Color Depth (Bit Depth)**: 픽셀당 비트 수 (8bpc, 16bpc, 32bpc HDR)
- **Frame Buffer**: 현재 화면 한 프레임을 담는 메모리 버퍼
- **Anti-Aliasing**: 언더샘플링으로 생기는 계단 현상 제거 — UE의 TAA/TSR

---

## API 비교

| API | 플랫폼 | 특징 |
|-----|--------|------|
| **OpenGL** | 크로스플랫폼 (Windows/Mac/Linux) | 오래된 표준, Apple deprecated |
| **DirectX (Direct3D)** | Windows / Xbox 전용 | UE Windows 빌드 기본 |
| **Vulkan** | 크로스플랫폼, 저수준 | 고성능, 복잡도 높음 |

---

## 자주 발생하는 렌더링 버그 패턴

| 증상 | 원인 | 해결 |
|------|------|------|
| 오브젝트가 서로 투과해 보임 | Z-Buffer 부족 / Z-fighting | 오브젝트 겹침 제거, Near Plane 조정 |
| 멀리서 폴리곤 깜빡임 | LOD 전환 팝핑 | LOD Transition Distance 조정 |
| 그림자 끊김 / 아크니 | Shadow Acne (Shadow Bias 문제) | `Shadow Bias` 값 조정 |
| 텍스처 흐림 | Mipmap 레벨 과다 적용 | `Texture LOD Bias` 또는 Stream Pool 확인 |
| 씬 전체 어두움 | PostProcess Gamma/Exposure | PostProcessVolume > Color Grading > Global > Gamma 확인 |

---

## 관련 페이지
- [조명 시스템](lighting.md)
- [StaticMesh 시스템](static_mesh.md)
- [레벨 개요](../overview.md)
- [UE5 렌더링 & 셰이더 시스템](ue5_rendering_shader.md)
- [UE5 실시간 렌더링 기술 지도](../query_ue5_rendering_map.md)
- [하이브리드 렌더링 논문](../papers/hybrid_rendering.md)
- [Neural Rendering 논문](../papers/neural_rendering.md)
