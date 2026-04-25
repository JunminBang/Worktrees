---
name: Post Processing & TSR 셰이더
type: System
tags: unreal-engine, post-process, TSR, bloom, DOF, motion-blur, SMAA, ACES, denoise, shader
source: engine-source
scene_verified: false
last_updated: 2026-04-25
---

# Post Processing & TSR 셰이더

> 소스 경로:  
> `Engine/Shaders/Private/TemporalSuperResolution/` (23개)  
> `Engine/Shaders/Private/DiaphragmDOF/` (22개)  
> `Engine/Shaders/Private/ScreenSpaceDenoise/` (20개)  
> `Engine/Shaders/Private/Bloom/` (11개)  
> `Engine/Shaders/Private/MotionBlur/` (10개)  
> `Engine/Shaders/Private/ACES/` (8개)  
> `Engine/Shaders/Private/SMAA/` (7개)  
> `Engine/Shaders/Private/PostProcessing/` (2개)

---

## 포스트 프로세스 파이프라인 순서

```
GBuffer 완성
  → Screen Space GI / AO
  → ScreenSpaceDenoise (노이즈 제거)
  → Bloom (글로우 생성)
  → DiaphragmDOF (피사계심도)
  → MotionBlur (움직임 흐림)
  → TSR 업스케일 (저해상도 → 고해상도)
  → SMAA (추가 안티앨리어싱, 옵션)
  → Tonemap + ACES (HDR → SDR 변환)
  → UI 합성
```

---

## 1. TSR (Temporal Super Resolution)

23개 파일로 구성된 UE5 기본 업스케일러.

### 핵심 파일
| 파일 | 역할 |
|------|------|
| `TSRCommon.ush` | 공통 함수·상수. `Common.ush`, `Random.ush`, `MonteCarlo.ush` 포함 |
| `TSRUpdateHistory.usf` | 히스토리 누적 업데이트 — 핵심 TAA 루프 |
| `TSRRejectShading.usf` | 셰이딩 변화 감지 → 히스토리 기각 |
| `TSRDecimateHistory.usf` | 히스토리 다운샘플 |
| `TSRResolveHistory.usf` | 최종 고해상도 출력 생성 |
| `TSRSpatialAntiAliasing.usf` / `.ush` | 공간적 AA 패스 |
| `TSRDilateVelocity.usf` | 속도 벡터 팽창 (에지 처리) |

### 분석 패스
| 파일 | 역할 |
|------|------|
| `TSRDepthVelocityAnalysis.ush` | 깊이·속도 분석 |
| `TSRShadingAnalysis.ush` | 셰이딩 변화량 분석 |
| `TSRMeasureCoverage.usf` | 픽셀 커버리지 측정 |
| `TSRMeasureFlickeringLuma.usf` | 플리커링 루마 측정 |
| `TSRDetectThinGeometry.usf` | 얇은 지오메트리 감지 |
| `TSRThinGeometryCommon.ush` | 얇은 지오메트리 공통 |
| `TSRReprojectionField.ush` | 재투영 필드 |

### 커널 & 색공간
| 파일 | 역할 |
|------|------|
| `TSRKernels.ush` | 재구성 커널 (Lanczos, Catmull-Rom 등) |
| `TSRColorSpace.ush` | TSR 전용 색공간 변환 |
| `TSRConvolutionNetwork.ush` / `Pass.ush` | 컨볼루션 네트워크 레이어 |
| `TSRWeightRelaxation.usf` | 가중치 완화 |
| `TSRClosestOccluder.ush` | 가장 가까운 오클루더 |
| `TSRClearPrevTextures.usf` | 이전 프레임 텍스처 초기화 |
| `TSRVisualize.usf` | 디버그 시각화 |

> **TSR vs DLSS/FSR**: TSR은 추가 플러그인 없이 모든 GPU에서 동작. DLSS(Nvidia 전용), FSR(AMD, 크로스플랫폼)은 플러그인으로 TSR 대체 가능.

---

## 2. Bloom

| 파일 | 역할 |
|------|------|
| `Bloom/` (11개) | Gaussian + Convolution Bloom |

**종류**:
- **Gaussian Bloom**: 빠름, 반경 제한. 기본값.
- **Convolution Bloom**: 렌즈 플레어 형태 커스텀 가능. 고비용.

PostProcessVolume 설정: `Lens > Bloom > Method`

---

## 3. DiaphragmDOF (피사계심도)

22개 파일. UE5 DOF 구현 = **Diaphragm DOF** (물리 기반 조리개).

### 주요 단계
```
1. CoC 계산 (Circle of Confusion)
2. Scatter-as-Gather 방식 흐림 적용
3. 전경/배경 분리 처리
4. 재구성 + 합성
```

관련 `Common.ush`: `CircleDOFCommon.ush` (루트 Private/)

카메라 설정 연동: `CineCameraComponent` → Focal Length, Aperture(f-stop), Focus Distance

---

## 4. ScreenSpaceDenoise

20개 파일. 레이 트레이싱 결과물의 노이즈 제거.

**적용 대상**:
| 노이즈 소스 | 디노이저 |
|------------|---------|
| RT 그림자 | Shadow Denoiser |
| RT AO | AO Denoiser |
| RT 반사 | Reflection Denoiser |
| Lumen 반사 | `LumenReflectionDenoiser*.usf` |

공간적(Spatial) + 시간적(Temporal) 2단계 적용.

---

## 5. MotionBlur

10개 파일. 속도 벡터(`VelocityShader.usf` 출력) 기반.

**방식**: Tile-Max 속도 계산 → 인접 픽셀 속도 분산 → 방향별 샘플 누적

설정: PostProcessVolume `Motion Blur > Amount`, `Max Distortion`

---

## 6. ACES (색공간 & 톤맵)

8개 파일. Academy Color Encoding System.

```
Linear HDR 색 → ACES RRT (Reference Rendering Transform)
              → ODT (Output Device Transform) → sRGB/HDR10
```

`TonemapCommon.ush` (루트 Private/)와 연동. 영화 색역 표준.

---

## 7. SMAA (안티앨리어싱)

7개 파일. Subpixel Morphological Anti-Aliasing.

TSR 이후 추가 에지 스무딩용. 기본 설정에서는 TSR이 AA를 담당하므로 SMAA는 선택적.

---

## 관련 루트 파일

| 파일 | 역할 |
|------|------|
| `TemporalAA.usf` | 구세대 TAA (TSR 이전) |
| `TonemapCommon.ush` | 톤맵 공통 |
| `ColorSpace.ush` | 색공간 변환 |
| `ColorDeficiency.ush` | 색맹 시뮬레이션 |
| `VelocityShader.usf` | 모션 블러용 속도 벡터 |

---

## 관련 페이지
- [셰이더 전체 개요](overview.md)
- [UE5 렌더링 & 셰이더 시스템](../systems/ue5_rendering_shader.md)
- [업스케일링 & 반사 논문](../papers/super_resolution_reflection.md)
- [렌더링 파이프라인 최신 연구](../papers/rendering_pipeline_advances.md)
- [UE5 실시간 렌더링 기술 지도](../query_ue5_rendering_map.md)
