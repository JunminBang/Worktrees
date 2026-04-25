---
name: UE5 렌더링 & 셰이더 시스템
type: System
tags: unreal-engine, rendering, shader, lumen, nanite, post-process, material, GI
source: raw-ingest
scene_verified: false
last_updated: 2026-04-19
---

# UE5 렌더링 & 셰이더 시스템

> 소스 경로: Runtime/Renderer/, Runtime/RenderCore/, Engine/Shaders/
> 🔗 Engine Reference (UE5.7 API 변경): [modules/rendering.md](../../docs/engine-reference/unreal/modules/rendering.md)

---

## 렌더링 파이프라인

```
메시 수집 → 컬링 (카메라에 안 보이는 것 제거)
→ 셰이더 바인딩 → 래스터화 (3D→픽셀)
→ 픽셀 셰이더 (색상 계산) → 포스트 프로세싱 → 최종 출력
```

---

## 셰이더 폴더 구조

```
Engine/Shaders/Private/
├── Common.ush              ← 모든 셰이더 공통 함수
├── BRDF.ush                ← 표면 반사 모델
├── BasePassPixelShader.usf ← 기본 색상 계산
├── DeferredLightPixelShaders.usf ← 조명 계산
├── PostProcess*/           ← 포스트 이펙트 (40개+)
├── Lumen/                  ← 실시간 전역 조명 (30개+)
├── Nanite/                 ← 가상화 지오메트리 (26개)
└── RayTracing/             ← 레이 트레이싱
```

확장자: `.usf` = 완전한 셰이더 / `.ush` = 헤더(공유 함수 라이브러리)

---

## 머티리얼 셰이딩 모델

| 셰이딩 모델 | 용도 |
|------------|------|
| Default Lit | 일반 표면 (금속, 플라스틱, 나무) |
| Unlit | 자체 발광 (UI, LED) |
| Subsurface | 빛이 스며드는 표면 (피부, 왁스) |
| Clear Coat | 다층 코팅 (자동차 페인트) |
| Cloth | 직물 (옷, 카펫) |
| Eye | 눈 전용 |

---

## 라이트 종류

| 라이트 | 특징 | GPU 비용 |
|--------|------|---------|
| Directional Light | 태양, 무한 거리 | 중간 |
| Point Light | 한 점에서 모든 방향 | 높음 |
| Spot Light | 원뿔형 | 높음 |
| Sky Light | 하늘 환경 조명 | 낮음 |
| Rect Light | 직사각형 라이트 | 매우 높음 |

---

## 그림자 기술

| 기술 | 품질 | 비용 |
|------|------|------|
| Shadow Maps | 보통 | 낮음 |
| Cascaded Shadow Maps (CSM) | 높음 | 중간 |
| Virtual Shadow Maps (VSM) | 높음 | 낮음 |
| Distance Field Shadows | 매우 높음 | 높음 |
| Ray Tracing Shadows | 최고 | 매우 높음 |

---

## Lumen (실시간 GI)

```
소스: Runtime/Renderer/Private/Lumen/ (26개 C++ 파일)
셰이더: Shaders/Private/Lumen/ (30개+ 파일)
```

작동: 메시를 "카드"로 분할 → 카드에 빛 정보 저장 → 카드 간 광선 추적 → 최종 간접광 합성

| 설정 | 설명 |
|------|------|
| Enable Lumen GI | 활성화/비활성화 |
| Lumen Quality | 0.5~2.0 (품질 vs 성능) |
| Max Trace Distance | 최대 추적 거리 |

---

## Nanite (가상화 지오메트리)

```
소스: Runtime/Renderer/Private/Nanite/ (26개 C++ 파일)
```

| 지원 ✅ | 미지원 ❌ |
|---------|---------|
| 불투명 메시 | 반투명 메시 |
| 스태틱 메시 | 스켈레탈 메시 |
| 복잡한 실내 환경 | 디플레이스먼트 맵 |

투명 머티리얼이 Nanite를 비활성화함 — 주의.

---

## 렌더링 패스 종류

```
DepthPass         — 깊이 버퍼만 생성
BasePass          — 기본 색상/노말/거칠기
SkyPass           — 하늘 렌더링
CSMShadowDepth    — 캐스케이드 그림자
Distortion        — 화면 왜곡 (유리, 열)
Velocity          — 모션 블러용 벡터
Translucency      — 반투명 처리
```

---

## 성능 최적화

| 문제 | 해결책 |
|------|--------|
| 폴리곤 과다 | Nanite 활성화 |
| 조명 무거움 | Lumen 품질 낮추기 |
| 그림자 무거움 | Virtual Shadow Maps 사용 |
| 포스트 무거움 | 불필요한 효과 비활성화 |
| 텍스처 메모리 | 해상도 낮추기 + Virtual Texturing |

---

## 관련 페이지

### 셰이더 소스 상세 (engine-source)
- [셰이더 전체 구조](../shaders/overview.md)
- [Lumen 셰이더 상세](../shaders/lumen_shaders.md)
- [Nanite 셰이더 상세](../shaders/nanite_shaders.md)
- [Ray Tracing & Path Tracing 셰이더](../shaders/ray_tracing_path_tracing.md)
- [Post Processing & TSR 셰이더](../shaders/post_processing_tsr.md)
- [Virtual Shadow Maps & 조명 셰이더](../shaders/shadow_lighting.md)
- [머티리얼 & 표면 셰이더](../shaders/material_surface.md)

### 시스템 & 논문
- [렌더링 파이프라인 시스템 (일반 CG)](rendering.md)
- [전역 조명 논문](../papers/global_illumination.md)
- [하이브리드 렌더링 논문](../papers/hybrid_rendering.md)
- [렌더링 파이프라인 최신 연구](../papers/rendering_pipeline_advances.md)
- [LOD & Neural Geometry 논문](../papers/lod_and_geometry.md)
- [PBR & 물리 기반 셰이딩 논문](../papers/pbr_and_shading.md)
- [볼류메트릭 & 그림자 논문](../papers/volumetric_and_shadow.md)
- [업스케일링 & 반사 논문](../papers/super_resolution_reflection.md)
- [생성형 3D & Diffusion 논문](../papers/generative_3d.md)
