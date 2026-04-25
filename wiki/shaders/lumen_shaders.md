---
name: Lumen 셰이더 상세
type: System
tags: unreal-engine, lumen, GI, ray-tracing, screen-probe, radiance-cache, shader
source: engine-source
scene_verified: false
last_updated: 2026-04-25
---

# Lumen 셰이더 상세

> 소스 경로: `Engine/Shaders/Private/Lumen/` (85개 파일)  
> C++ 소스: `Runtime/Renderer/Private/Lumen/`

---

## 아키텍처 개요

Lumen은 4개 하위 시스템으로 구성:

```
① Surface Cache  — 메시를 "카드"로 분할, 씬 조명 캐시
② Radiance Cache — 구체형 프로브에 간접광 저장
③ Screen Probe   — 화면 픽셀 단위 Screen-Space RT
④ Reflections    — 반사 추적 + 디노이즈
```

---

## 1. Card 시스템 (Surface Cache)

| 파일 | 역할 |
|------|------|
| `LumenCardCommon.ush` | `FLumenCardData` 구조체 — OBB, PageTable, 월드 위치 |
| `LumenCardPixelShader.usf` | 카드에 머티리얼 색상 렌더링 |
| `LumenCardVertexShader.usf` | 카드 버텍스 변환 |
| `LumenCardBasePass.ush` | 카드 기반 BasePass 공통 |
| `LumenCardTile.ush` | 타일 단위 카드 처리 |
| `LumenCardTileShadowDownsampleFactor.ush` | 카드 그림자 다운샘플 |
| `SurfaceCache/LumenSurfaceCache.usf` | Surface Cache 업데이트 |
| `SurfaceCache/LumenSurfaceCacheSampling.ush` | 캐시 샘플링 공통 |

**작동 원리**: 메시를 6방향 Oriented Bounding Box "카드"로 분할 → 각 카드에 조명 정보(Albedo, Normal, Emissive) 저장 → 카드 간 광선 추적으로 간접광 합성

---

## 2. Scene Lighting

| 파일 | 역할 |
|------|------|
| `LumenSceneLighting.usf` | 씬 전체 조명 계산 메인 |
| `LumenSceneLighting.ush` | 씬 조명 공통 함수 |
| `LumenSceneDirectLighting.usf` | 직접광 계산 |
| `LumenSceneDirectLightingCulling.usf` | 직접광 라이트 컬링 |
| `LumenSceneDirectLightingShadowMask.usf` | 직접광 그림자 마스크 |
| `LumenSceneDirectLightingStochastic.usf` | 확률적 직접광 |
| `LumenSceneDirectLightingHardwareRayTracing.usf` | HW RT 직접광 |
| `LumenSceneDirectLightingSoftwareRayTracing.usf` | SW RT 직접광 |
| `LumenSceneDirectLightingPerLightShadowCommon.ush` | 라이트별 그림자 공통 |
| `LumenScene.usf` | 씬 데이터 관리 |

---

## 3. Radiance Cache

| 파일 | 역할 |
|------|------|
| `LumenRadianceCacheCommon.ush` | `FRadianceCacheCoverage` 구조체 |
| `LumenRadianceCacheInterpolation.ush` | 프로브 보간 |
| `LumenRadianceCache.usf` | 캐시 빌드 메인 |
| `LumenRadianceCacheUpdate.usf` / `.ush` | 캐시 업데이트 |
| `LumenRadianceCacheHardwareRayTracing.usf` | HW RT 프로브 추적 |
| `LumenRadianceCacheDebug.usf` | 디버그 시각화 |
| `LumenRadianceCacheMarkCommon.ush` | 캐시 마킹 |
| `LumenRadianceCacheTracingCommon.ush` | 추적 공통 |

**Radiance Cache 구조**: 클립맵 계층(여러 해상도)으로 공간 분할 → 각 셀에 구형 조화(SH) 계수 저장 → 먼 거리 간접광 공급

---

## 4. Screen Probe

| 파일 | 역할 |
|------|------|
| `LumenScreenProbeCommon.ush` | 프로브 포맷, 스레드그룹 크기(8×8) |
| `LumenScreenProbeGather.usf` | 화면 픽셀에 프로브 배치·수집 |
| `LumenScreenProbeGatherTemporal.usf` | 시간적 재투영·누적 |
| `LumenScreenProbeFiltering.usf` | 프로브 필터링 |
| `LumenScreenProbeTracing.usf` | 프로브에서 광선 추적 |
| `LumenScreenProbeHardwareRayTracing.usf` | HW RT 프로브 추적 |
| `LumenScreenProbeImportanceSampling.usf` | 중요도 샘플링 |
| `LumenScreenProbeImportanceSamplingShared.ush` | 중요도 샘플링 공유 |
| `LumenScreenProbeTileClassication.ush` | 타일 분류 |
| `LumenScreenProbeTracingCommon.ush` | 추적 공통 |
| `LumenScreenSpaceBentNormal.usf` | SSBN 생성 |

**Screen Probe 설정**:
```
PROBE_THREADGROUP_SIZE_2D = 8   (8×8 타일)
PROBE_THREADGROUP_SIZE_1D = 64
PROBE_IRRADIANCE_FORMAT_SH3 = 0  (기본 SH2)
```

---

## 5. Reflections

| 파일 | 역할 |
|------|------|
| `LumenReflections.usf` | 반사 메인 패스 |
| `LumenReflectionTracing.usf` | 반사 광선 추적 |
| `LumenReflectionResolve.usf` | 반사 해상도 복원 |
| `LumenReflectionCommon.ush` | 반사 공통 함수 |
| `LumenReflectionsCombine.ush` | 반사 합성 |
| `LumenReflectionHardwareRayTracing.usf` | HW RT 반사 |
| `LumenReflectionDenoiserSpatial.usf` | 공간적 디노이즈 |
| `LumenReflectionDenoiserTemporal.usf` | 시간적 디노이즈 |
| `LumenReflectionDenoiserCommon.ush` | 디노이저 공통 |
| `LumenReSTIRGather.usf` | ReSTIR 기반 수집 |

---

## 6. Radiosity

| 파일 | 역할 |
|------|------|
| `Radiosity/LumenRadiosity.usf` | 메시 표면 Radiosity 계산 |
| `Radiosity/LumenRadiosity.ush` | Radiosity 공통 |
| `Radiosity/LumenRadiosityCulling.usf` | Radiosity 컬링 |
| `Radiosity/LumenRadiosityHardwareRayTracing.usf` | HW RT Radiosity |

---

## 7. 기타 주요 파일

| 파일 | 역할 |
|------|------|
| `LumenTracingCommon.ush` | 추적 공통 유틸리티 |
| `LumenSoftwareRayTracing.ush` | SW RT (메시 SDF 기반) |
| `LumenHardwareRayTracingCommon.ush` | HW RT 공통 |
| `LumenMaterial.ush` | Lumen용 머티리얼 접근 |
| `LumenPosition.ush` | 월드 위치 인코딩/디코딩 |
| `LumenBufferEncoding.ush` | 버퍼 데이터 인코딩 |
| `LumenVisualize.usf` | r.Lumen.Visualize 디버그 |
| `LumenTranslucencyVolumeLighting.usf` | 반투명 볼류메트릭 조명 |

---

## HW RT vs SW RT 선택

| 모드 | 조건 | 파일 접미사 |
|------|------|------------|
| Software RT | 기본값 (모든 GPU) | `SoftwareRayTracing.ush` |
| Hardware RT | DXR 지원 GPU + 설정 활성화 | `HardwareRayTracing.usf` |

---

## 성능 튜닝 포인트

| 설정 | 셰이더 영향 |
|------|-----------|
| Lumen Quality 0.5~2.0 | Screen Probe 해상도 |
| Max Trace Distance | `LumenTracingCommon.ush` MaxTraceDistance |
| Lumen.ScreenProbeGather.RadianceCache | Radiance Cache 활성화 여부 |

---

## 관련 페이지
- [셰이더 전체 개요](overview.md)
- [UE5 렌더링 & 셰이더 시스템](../systems/ue5_rendering_shader.md)
- [글로벌 일루미네이션 논문](../papers/global_illumination.md)
- [하이브리드 렌더링 논문](../papers/hybrid_rendering.md)
- [UE5 실시간 렌더링 기술 지도](../query_ue5_rendering_map.md)
