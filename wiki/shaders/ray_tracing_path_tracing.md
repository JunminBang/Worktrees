---
name: Ray Tracing & Path Tracing 셰이더
type: System
tags: unreal-engine, ray-tracing, path-tracing, DXR, HW-RT, shader
source: engine-source
scene_verified: false
last_updated: 2026-04-25
---

# Ray Tracing & Path Tracing 셰이더

> 소스 경로:  
> `Engine/Shaders/Private/RayTracing/` (64개)  
> `Engine/Shaders/Private/PathTracing/` (28개)  
> 공유 정의: `/Engine/Public/RayTracingDefinitions.h`

---

## Ray Tracing 셰이더 타입

| 타입 | 확장자 | 역할 |
|------|--------|------|
| Ray Generation | `RGS.usf` | 광선 발사 진입점 |
| Closest Hit | `CHS.usf` | 가장 가까운 교차점 처리 |
| Miss | `Miss.usf` | 광선이 아무것도 안 맞았을 때 |
| Any Hit | (인라인) | 반투명 처리 |

---

## RayTracing/ 주요 파일

### 핵심 공통
| 파일 | 역할 |
|------|------|
| `RayTracingCommon.ush` | RT 공통 함수·매크로 |
| `RayTracingHitGroupCommon.ush` | Hit Group 공통 처리 |
| `RayTracingDeferredShadingCommon.ush` | 지연 셰이딩 연동 공통 |
| `RayTracingLightingCommon.ush` | RT 조명 계산 공통 |
| `RayGenUtils.ush` | Ray Generation 유틸리티 |
| `MipTreeCommon.ush` | 밉맵 트리 공통 |

### 조명 & 그림자
| 파일 | 역할 |
|------|------|
| `RayTracingDirectionalLight.ush` | 방향광 RT 그림자 |
| `RayTracingCapsuleLight.ush` | 캡슐 라이트 RT |
| `RayTracingLightCullingCommon.ush` | 조명 컬링 |
| `RayTracingLightFunctionCommon.ush` | 라이트 함수 |
| `CompositeSkyLightPS.usf` | 스카이라이트 합성 |
| `GenerateSkyLightVisibilityRaysCS.usf` | 스카이라이트 가시성 광선 |

### Ambient Occlusion
| 파일 | 역할 |
|------|------|
| `RayTracingAmbientOcclusionRGS.usf` | RT AO Ray Generation |
| `CompositeAmbientOcclusionPS.usf` | AO 합성 픽셀 셰이더 |

### 머티리얼 & 히트
| 파일 | 역할 |
|------|------|
| `RayTracingDeferredMaterials.usf` | 지연 머티리얼 처리 |
| `RayTracingDeferredMaterials.ush` | 지연 머티리얼 공통 |
| `RayTracingDynamicMesh.usf` | 동적 메시 RT |
| `RayTracingDecalMaterialShader.usf` | 데칼 RT 히트 |
| `RayTracingDefaultDecalHitShader.usf` | 기본 데칼 히트 |
| `RayTracingMaterialHitShader.usf` | 범용 머티리얼 히트 |
| `RayTracingCalcInterpolants.ush` | 보간 계산 |

### 가속 구조 & 씬
| 파일 | 역할 |
|------|------|
| `RayTracingBuildDecalGrid.usf` | 데칼 그리드 빌드 |
| `RayTracingBuildLightGrid.usf` | 조명 그리드 빌드 |
| `RayTracingInstanceBufferUtil.usf` | 인스턴스 버퍼 |
| `RayTracingDispatchDesc.usf` | RT 디스패치 기술 |
| `RayTracingDecalGrid.ush` | 데칼 그리드 공통 |

### 피드백 & 디버그
| 파일 | 역할 |
|------|------|
| `RayTracingDebug.usf` | RT 디버그 시각화 |
| `RayTracingDebugCHS.usf` | 디버그 CHS |
| `RayTracingDebugTraversal.usf` | BVH 탐색 시각화 |
| `RayTracingFeedback.usf` | RT 피드백 |
| `VisualizeRayBuffer.usf` | 광선 버퍼 시각화 |

---

## PathTracing/ 주요 파일

PathTracing은 **offline-quality** 누적 렌더러. PIE에서 `r.PathTracing 1`로 활성화.

### 핵심
| 파일 | 역할 |
|------|------|
| `PathTracing.usf` | 패스 트레이싱 메인 Ray Generation |
| `PathTracingCore.ush` | 핵심 알고리즘 (MIS, BSDF 샘플링) |
| `PathTracingCommon.ush` | 공통 함수·상수 |
| `PathTracingMaterialHitShader.usf` | 머티리얼 히트 처리 |
| `PathTracingMissShader.usf` | 미스 셰이더 |
| `PathTracingLightingMissShader.usf` | 조명 미스 |
| `PathTracingDefaultHitShader.usf` | 기본 히트 |
| `PathTracingShaderUtils.ush` | 셰이더 유틸 |

### 최적화
| 파일 | 역할 |
|------|------|
| `PathTracingAdaptiveStart.usf` | 적응형 샘플링 시작 |
| `PathTracingBuildAdaptiveError.usf` | 에러 기반 적응형 빌드 |
| `PathTracingAdaptiveUtils.ush` | 적응형 유틸 |
| `PathTracingSpatialTemporalDenoising.usf` | 공간·시간 디노이저 |
| `PathTracingSwizzleScanlines.usf` | 스캔라인 최적화 |

### 환경 & 볼류메트릭
| 파일 | 역할 |
|------|------|
| `PathTracingBuildAtmosphereLUT.usf` | 대기 LUT 빌드 |
| `PathTracingBuildCloudAccelerationMap.usf` | 구름 가속 맵 |
| `PathTracingInitExtinctionCoefficient.usf` | 소멸 계수 초기화 |
| `PathTracingVolumetricCloudMaterialShader.usf` | 볼류메트릭 구름 |
| `PathTracingSkylightPrepare.usf` | 스카이라이트 준비 |
| `PathTracingSkylightMISCompensation.usf` | MIS 보상 |

### 서브폴더
```
PathTracing/
├── Light/      ← 조명 BSDF 샘플러
├── Material/   ← 머티리얼별 BSDF (Diffuse, Specular, Glass 등)
├── Utilities/  ← 수학 유틸
└── Volume/     ← 볼류메트릭 산란
```

---

## HW RT 활성화 조건

```
프로젝트 설정 → Rendering → Ray Tracing 활성화
GPU: DXR 지원 (NVIDIA Turing+, AMD RDNA2+)
```

HW RT 비활성 시 → Lumen, Reflections 등 SW 폴백 사용

---

## 관련 페이지
- [셰이더 전체 개요](overview.md)
- [Lumen 셰이더](lumen_shaders.md)
- [UE5 렌더링 & 셰이더 시스템](../systems/ue5_rendering_shader.md)
- [하이브리드 렌더링 논문](../papers/hybrid_rendering.md)
- [Gaussian Splatting 논문](../papers/gaussian_splatting.md)
