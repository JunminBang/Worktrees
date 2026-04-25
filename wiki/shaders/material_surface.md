---
name: 머티리얼 & 표면 셰이더
type: System
tags: unreal-engine, substrate, material, hair, heterogeneous-volumes, skinning, shader
source: engine-source
scene_verified: false
last_updated: 2026-04-25
---

# 머티리얼 & 표면 셰이더

> 소스 경로:  
> `Engine/Shaders/Private/Substrate/` (23개) — 차세대 머티리얼 시스템  
> `Engine/Shaders/Private/HairStrands/` (79개) — 헤어 렌더링  
> `Engine/Shaders/Private/HeterogeneousVolumes/` (33개) — 볼류메트릭  
> `Engine/Shaders/Private/MaterialCache/` (8개) — 머티리얼 캐시  
> `Engine/Shaders/Private/Skinning/` (4개) — GPU 스키닝  
> 공유 정의: `/Engine/Public/SubstrateDefinitions.h`

---

## 1. Substrate (차세대 머티리얼)

Substrate = UE5.2+ 도입된 레이어 기반 머티리얼 시스템. 기존 단일 셰이딩 모델 → 복수 BSDF 레이어 조합으로 대체.

```
기존:  머티리얼 → 셰이딩 모델 1개 선택 (Default Lit / Subsurface / etc.)
Substrate: BSDF 레이어 N개 → 적층(Stack) → 단일 출력
```

### 주요 파일
| 파일 | 역할 |
|------|------|
| `Substrate/SubstrateExport.usf` | GBuffer로 Substrate 데이터 내보내기 |
| `Substrate/SubstrateForward.usf` | Forward Rendering 패스 |
| `Substrate/SubstrateDeferredLighting.ush` | 지연 조명 연동 |
| `Substrate/SubstrateMaterial.ush` | 머티리얼 레이어 구조체 |
| `Substrate/SubstrateVisualize.usf` | 디버그 시각화 |

루트 Public 헤더: `SubstratePublic.ush`  
공유 정의: `SubstrateDefinitions.h` / `SubstrateVisualizeDefinitions.h`

### BSDF 레이어 종류
| BSDF | 용도 |
|------|------|
| Slab (default) | 일반 표면 (금속, 플라스틱) |
| Thin | 얇은 반투명 표면 |
| Volume | 내부 산란 (피부, 왁스) |
| Unlit | 자체 발광 |

> **프로젝트 설정 활성화**: `Rendering → Substrate` 체크 필요.  
> 기존 머티리얼과 **하위 호환** 유지.

---

## 2. HairStrands (79개)

물리 기반 헤어 렌더링 시스템. 가닥(Strand) 단위 시뮬레이션 + 렌더링.

```
Groom 에셋 (헤어 가닥 데이터)
  → 물리 시뮬레이션 (중력, 바람, 충돌)
  → 래스터화 or RT
  → 헤어 전용 BSDF (Marschner, Dual Scattering)
```

### 파일 분류
| 파일 패턴 | 역할 |
|-----------|------|
| `HairStrandsVisibility*.usf` | 가닥 가시성 결정 |
| `HairStrandsDeepShadow*.usf` | 헤어 자체 그림자 (딥 섀도우 맵) |
| `HairStrandsVoxelization*.usf` | 가닥 복셀화 (간접광용) |
| `HairStrandsCluster*.usf` | 클러스터 기반 LOD |
| `HairStrandsEnvironmentLighting*.usf` | 환경광 적용 |

루트 관련 파일: `BoneTransform.ush` (스키닝 연동)  
공유 정의: `/Engine/Public/HairStrandsDefinitions.h`

---

## 3. HeterogeneousVolumes (볼류메트릭, 33개)

연기, 불꽃, 구름 등 이질적(불균일) 볼류메트릭 렌더링.

```
볼류메트릭 에셋 (VDB/SparseVolumeTexture)
  → Ray Marching (볼륨 내 광선 이동)
  → 흡수(Absorption) + 산란(Scattering) 계산
  → Transmittance 누적 → 최종 색상
```

### 파일 분류
| 파일 패턴 | 역할 |
|-----------|------|
| `HeterogeneousVolumes*.usf` | 볼류메트릭 렌더링 메인 |
| `HeterogeneousVolumesAdaptive*.ush` | 적응형 볼류메트릭 샘플링 |
| `HeterogeneousVolumesShadow*.usf` | 볼류메트릭 그림자 |
| `HeterogeneousVolumesLighting*.usf` | 볼류메트릭 조명 |

루트 관련 파일: `VolumetricFog.usf`, `VolumetricCloud.usf`

> `BasePassPixelShader.usf`는 `HeterogeneousVolumesAdaptiveVolumetricShadowMapSampling.ush`를 포함해 볼류메트릭 그림자를 BasePass에 통합.

---

## 4. MaterialCache

8개 파일. GPU 머티리얼 평가 결과 캐시 — 동일 머티리얼의 중복 계산 방지.

공유 정의: `/Engine/Public/MaterialCacheDefinitions.h`

---

## 5. Skinning

4개 파일. 캐릭터 메시 GPU 스키닝.

| 파일 | 역할 |
|------|------|
| `Skinning/GpuSkinCacheComputeShader.usf` | GPU 스킨 캐시 Compute |
| `Skinning/GpuSkinVertexFactory.ush` | 스키닝 버텍스 팩토리 |

루트 관련 파일: `BoneTransform.ush` (본 행렬 변환)

---

## 루트 Private/ 관련 머티리얼 파일

| 파일 | 역할 |
|------|------|
| `BRDF.ush` | BxDFContext, GGX, Cloth BRDF 핵심 |
| `ClearCoatCommon.ush` | 클리어코트 (자동차 페인트) |
| `BurleyNormalizedSSSCommon.ush` | Burley SSS (피부 산란) |
| `SubsurfaceBurleyNormalized.ush` | SSS 정규화 |
| `SubsurfaceProfileCommon.ush` | SSS 프로파일 공통 |
| `ThinFilmBSDF.ush` | 박막 간섭 (비누방울, 기름막) |
| `ThinTranslucentCommon.ush` | 얇은 반투명 공통 |
| `SingleLayerWaterShading.ush` | 물 표면 셰이딩 |
| `SphericalGaussian.ush` | 구형 가우시안 조명 모델 |
| `SpecularProfileCommon.ush` | Specular 프로파일 |
| `TransmissionCommon.ush` | 투과 공통 |
| `TransmissionThickness.ush` | 투과 두께 |
| `AnisotropyPassShader.usf` | 이방성 (머리카락, 브러시 금속) |

---

## UE5 셰이딩 모델 vs 셰이더 파일 대응

| 셰이딩 모델 | 관련 셰이더 |
|------------|-----------|
| Default Lit | `BRDF.ush` (GGX) |
| Subsurface | `BurleyNormalizedSSSCommon.ush` |
| Clear Coat | `ClearCoatCommon.ush` |
| Cloth | `BRDF.ush` (Cloth BSDF) |
| Hair | `HairStrands/` |
| Eye | `SubsurfaceProfileCommon.ush` |
| Thin Translucent | `ThinTranslucentCommon.ush` |
| Single Layer Water | `SingleLayerWaterShading.ush` |
| Substrate (신규) | `Substrate/` |

---

## 관련 페이지
- [셰이더 전체 개요](overview.md)
- [UE5 렌더링 & 셰이더 시스템](../systems/ue5_rendering_shader.md)
- [UE5 애니메이션 & 물리 시스템](../systems/ue5_animation_physics.md)
- [PBR & 셰이딩 논문](../papers/pbr_and_shading.md)
- [Neural Avatar 논문](../papers/neural_avatar.md)
- [볼류메트릭 & 그림자 논문](../papers/volumetric_and_shadow.md)
