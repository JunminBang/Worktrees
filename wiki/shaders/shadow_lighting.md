---
name: Virtual Shadow Maps & 조명 셰이더
type: System
tags: unreal-engine, shadow, VSM, mega-lights, lighting, shader
source: engine-source
scene_verified: false
last_updated: 2026-04-25
---

# Virtual Shadow Maps & 조명 셰이더

> 소스 경로:  
> `Engine/Shaders/Private/VirtualShadowMaps/` (37개)  
> `Engine/Shaders/Private/MegaLights/` (23개)  
> `Engine/Shaders/Private/StochasticLighting/` (3개)  
> `Engine/Shaders/Private/LightFunctionAtlas/` (2개)  
> 공유 정의: `/Engine/Public/VirtualShadowMapDefinitions.h`

---

## Virtual Shadow Maps (VSM)

VSM = 페이지 기반 가상 텍스처 그림자 시스템. UE5 기본 그림자 기술.

```
라이트 뷰 → 가상 페이지 테이블 (Physical Pool에 매핑)
  → 카메라 근처 / 화면 픽셀이 요청한 페이지만 렌더
  → 페이지 캐시 → 변경된 페이지만 업데이트
```

### 페이지 관리
| 파일 | 역할 |
|------|------|
| `VirtualShadowMapPageManagement.usf` | 페이지 할당·해제 |
| `VirtualShadowMapPhysicalPageManagement.usf` | 물리 페이지 풀 관리 |
| `VirtualShadowMapPageMarking.usf` / `.ush` | 필요 페이지 마킹 |
| `VirtualShadowMapPageAccessCommon.ush` | 페이지 접근 공통 |
| `VirtualShadowMapPageCacheCommon.ush` | 페이지 캐시 공통 |
| `VirtualShadowMapPageOverlap.ush` | 페이지 겹침 처리 |
| `VirtualShadowMapHandle.ush` | VSM 핸들 구조체 |
| `VirtualShadowMapPerPageDispatch.ush` | 페이지별 디스패치 |

### 캐시 무효화
| 파일 | 역할 |
|------|------|
| `VirtualShadowMapCacheGPUInvalidation.usf` | GPU 이벤트 캐시 무효화 |
| `VirtualShadowMapCacheInvalidation.ush` | 캐시 무효화 공통 |
| `VirtualShadowMapCacheLoadBalancer.usf` | 캐시 로드밸런싱 |
| `VirtualShadowMapThrottle.usf` | 무효화 스로틀링 |

### 그림자 투영
| 파일 | 역할 |
|------|------|
| `VirtualShadowMapProjection.usf` | 그림자 투영 메인 |
| `VirtualShadowMapProjectionCommon.ush` | 투영 공통 |
| `VirtualShadowMapProjectionComposite.usf` | 그림자 합성 |
| `VirtualShadowMapProjectionDirectional.ush` | 방향광 투영 |
| `VirtualShadowMapProjectionSpot.ush` | 스팟라이트 투영 |
| `VirtualShadowMapProjectionFilter.ush` | 소프트 그림자 필터 |
| `VirtualShadowMapSMRTCommon.ush` | SMRT (Ray-Traced Soft) 공통 |
| `VirtualShadowMapSMRTTemplate.ush` | SMRT 템플릿 |
| `VirtualShadowMapScreenRayTrace.ush` | 화면 공간 RT 그림자 |
| `VirtualShadowMapTransmissionCommon.ush` | 반투명 그림자 |

### 뷰 & 컬링
| 파일 | 역할 |
|------|------|
| `VirtualShadowMapCompactViews.usf` | 뷰 압축 |
| `VirtualShadowMapLightGrid.ush` | 조명 그리드 |
| `VirtualShadowMapShadowCasterBounds.usf` | 그림자 캐스터 바운드 |
| `VirtualShadowMapShadowCasterColor.usf` | 그림자 캐스터 색상 |
| `VirtualShadowMapBuildPerPageDrawCommands.usf` | 페이지별 드로우 커맨드 빌드 |
| `VirtualShadowMapComputeExplicitChunkDrawsViewMask.usf` | 청크 뷰마스크 |

### 디버그
| 파일 | 역할 |
|------|------|
| `VirtualShadowMapDebug.usf` | 디버그 시각화 |
| `VirtualShadowMapVisualize.ush` | 시각화 공통 |
| `VirtualShadowMapPrintStats.usf` | 통계 출력 |
| `VirtualShadowMapCopyStats.usf` | 통계 복사 |
| `VirtualShadowMapMaskBitsCommon.ush` | 마스크 비트 |
| `VirtualShadowMapStats.ush` | 통계 구조체 |
| `Desaturate.usf` | 그림자 채도 제거 |

### 기존 그림자 기술 비교

| 기술 | 품질 | GPU 비용 | UE5 권장 |
|------|------|---------|---------|
| Shadow Maps | 보통 | 낮음 | ❌ 레거시 |
| Cascaded Shadow Maps (CSM) | 높음 | 중간 | 선택적 |
| **Virtual Shadow Maps (VSM)** | **높음** | **낮음** | **✅ 기본값** |
| Distance Field Shadows | 매우 높음 | 높음 | 특수 목적 |
| Ray Tracing Shadows | 최고 | 매우 높음 | 고사양 전용 |

---

## MegaLights

23개 파일. 수천 개 조명을 GPU-Driven으로 효율적 처리.

```
씬의 모든 라이트 → 타일/클러스터 분류
→ 해당 타일에 영향 주는 라이트만 셰이딩
→ 스토캐스틱 샘플링으로 비용 분산
```

| 파일 패턴 | 역할 |
|-----------|------|
| `MegaLights*.usf/ush` | 대규모 조명 처리 파이프라인 |

공유 정의: `/Engine/Public/MegaLightsDefinitions.h`

---

## StochasticLighting

3개 파일. 확률적 조명 평가 — 많은 라이트를 무작위 샘플링으로 처리.

MegaLights와 연동하여 고밀도 조명 씬에서 성능 유지.

---

## LightFunctionAtlas

2개 파일. 라이트 함수(빛 모양 마스크)를 텍스처 아틀라스로 일괄 관리.

기존 방식은 라이트마다 별도 렌더 패스 → 아틀라스로 1회 패스 처리.

---

## 관련 루트 파일

| 파일 | 역할 |
|------|------|
| `ShadowDepthPixelShader.usf` | 기본 그림자 맵 생성 |
| `CapsuleShadowShaders.usf` | 캡슐 그림자 |
| `CopyShadowMaps.usf` | 그림자 맵 복사 |
| `DeferredLightPixelShaders.usf` | 지연 조명 계산 |
| `AreaLightCommon.ush` | 면적광 공통 |
| `CapsuleLight.ush` | 캡슐 라이트 |

---

## 관련 페이지
- [셰이더 전체 개요](overview.md)
- [Nanite 셰이더](nanite_shaders.md)
- [UE5 렌더링 & 셰이더 시스템](../systems/ue5_rendering_shader.md)
- [볼류메트릭 & 그림자 논문](../papers/volumetric_and_shadow.md)
- [라이팅 & PostProcess 시스템](../systems/lighting.md)
