---
name: UE5 셰이더 시스템 전체 구조
type: System
tags: unreal-engine, shader, HLSL, usf, ush, rendering
source: engine-source
scene_verified: false
last_updated: 2026-04-25
---

# UE5 셰이더 시스템 전체 구조

> 소스 경로: `C:/Program Files/Epic Games/UE_5.7/Engine/Shaders/`

---

## 폴더 구조

```
Engine/Shaders/
├── Private/   ← 엔진 내부 셰이더 (직접 수정 불가)
│   ├── (루트 파일들)   ← Common, BRDF, BasePass 등 핵심
│   ├── Lumen/          ← 실시간 GI (85개)
│   ├── Nanite/         ← 가상화 지오메트리 (48개)
│   ├── RayTracing/     ← 레이 트레이싱 (64개)
│   ├── PathTracing/    ← 패스 트레이싱 (28개)
│   ├── TemporalSuperResolution/ ← TSR 업스케일 (23개)
│   ├── VirtualShadowMaps/       ← VSM 그림자 (37개)
│   ├── HairStrands/    ← 헤어 시뮬레이션 (79개)
│   ├── Substrate/      ← 차세대 머티리얼 (23개)
│   ├── HeterogeneousVolumes/    ← 볼류메트릭 (33개)
│   ├── MegaLights/     ← 대규모 조명 (23개)
│   ├── PostProcessing/ ← 포스트 프로세스
│   ├── DiaphragmDOF/   ← 피사계심도 (22개)
│   ├── Bloom/          ← 블룸 (11개)
│   ├── MotionBlur/     ← 모션 블러 (10개)
│   ├── ScreenSpaceDenoise/ ← 디노이저 (20개)
│   ├── ACES/           ← 색공간 변환 (8개)
│   ├── SMAA/           ← 안티앨리어싱 (7개)
│   ├── DistanceField/  ← 거리장 (9개)
│   ├── GPUScene/       ← GPU 씬 데이터 (2개)
│   ├── InstanceCulling/ ← 인스턴스 컬링 (7개)
│   ├── SceneCulling/   ← 씬 컬링 (3개)
│   ├── MaterialCache/  ← 머티리얼 캐시 (8개)
│   ├── Landscape/      ← 랜드스케이프 (6개)
│   ├── Skinning/       ← 스키닝 (4개)
│   └── (기타 소규모 폴더들)
├── Public/    ← 외부 노출 헤더 (플랫폼, 바인드리스 등)
└── Shared/    ← C++/셰이더 공유 정의 (.h 파일들)
```

---

## 확장자 의미

| 확장자 | 역할 |
|--------|------|
| `.usf` | 완전한 셰이더 파일 (진입점 함수 포함) |
| `.ush` | 셰이더 헤더 — 공유 함수·구조체 라이브러리 (`#include`용) |
| `.h` | C++/셰이더 공유 정의 (Shared/ 폴더) |

---

## 핵심 루트 파일

| 파일 | 역할 |
|------|------|
| `Common.ush` | 모든 셰이더의 공통 기반 — 플랫폼 매크로, MaterialFloat 정의 |
| `BRDF.ush` | 표면 반사 모델 — BxDFContext, GGX, Cloth, Hair BRDF |
| `BasePassPixelShader.usf` | GBuffer 기록 메인 셰이더 — 머티리얼 색상 계산 |
| `BasePassVertexShader.usf` | 버텍스 변환 (MVP Matrix 적용) |
| `DeferredLightPixelShaders.usf` | 지연 조명 계산 |
| `ShadowDepthPixelShader.usf` | 그림자 맵 생성 |
| `VelocityShader.usf` | 모션 블러용 속도 벡터 |
| `TemporalAA.usf` | TAA (TSR 이전 세대) |
| `SkyAtmosphere.usf` | 하늘·대기 렌더링 |
| `VolumetricCloud.usf` | 볼류메트릭 구름 |
| `TonemapCommon.ush` | 톤 매핑 공통 함수 |
| `ColorSpace.ush` | 색 공간 변환 (Linear, sRGB, Rec.709) |

---

## 렌더링 파이프라인과 셰이더 대응

```
1. Depth Prepass        → ShadowDepthPixelShader.usf
2. GBuffer (BasePass)   → BasePassPixelShader.usf (머티리얼 출력)
3. Lumen GI             → Lumen/*.usf (Screen Probe, Radiance Cache)
4. Shadow               → VirtualShadowMaps/*.usf
5. Deferred Lighting    → DeferredLightPixelShaders.usf
6. Translucency         → TranslucencyVolumeInjection*.usf
7. PostProcess          → PostProcessing/, Bloom/, DiaphragmDOF/
8. TSR Upscale          → TemporalSuperResolution/*.usf
9. Tonemap + UI         → TonemapCommon.ush, Slate*.usf
```

---

## Public/ 주요 헤더

| 파일 | 용도 |
|------|------|
| `Platform.ush` | 플랫폼별 분기 매크로 |
| `BindlessResources.ush` | 바인드리스 텍스처/버퍼 접근 |
| `WaveBroadcastIntrinsics.ush` | SIMD Wave 연산 |
| `LaneVectorization.ush` | GPU Lane 벡터화 |
| `NaniteDefinitions.h` | Nanite C++/셰이더 공유 상수 |
| `LumenDefinitions.h` | Lumen C++/셰이더 공유 상수 |
| `VirtualShadowMapDefinitions.h` | VSM 공유 상수 |
| `RayTracingDefinitions.h` | RT 공유 상수 |
| `SubstrateDefinitions.h` | Substrate 공유 상수 |

---

## 관련 페이지 (상세 시스템)
- [Lumen 셰이더](lumen_shaders.md)
- [Nanite 셰이더](nanite_shaders.md)
- [Ray Tracing & Path Tracing 셰이더](ray_tracing_path_tracing.md)
- [Post Processing & TSR 셰이더](post_processing_tsr.md)
- [Virtual Shadow Maps & 조명 셰이더](shadow_lighting.md)
- [머티리얼 & 표면 셰이더](material_surface.md)
- [UE5 렌더링 & 셰이더 시스템](../systems/ue5_rendering_shader.md)
