---
name: UE5 실시간 렌더링 기술 지도
type: Query-Result
tags: rendering, UE5, lumen, nanite, TSR, GI, LOD, shadow, PBR, query-synthesis
source: query-synthesis
scene_verified: false
last_updated: 2026-04-19
query: "UE5 실시간 렌더링 기술 지도 — 최신 논문 연구와 UE5 엔진 구현의 연결점"
---

# UE5 실시간 렌더링 기술 지도

> 참조 페이지: [ue5_rendering_shader](systems/ue5_rendering_shader.md) · [rendering](systems/rendering.md) · [hybrid_rendering](papers/hybrid_rendering.md) · [global_illumination](papers/global_illumination.md) · [lod_and_geometry](papers/lod_and_geometry.md) · [rendering_pipeline_advances](papers/rendering_pipeline_advances.md) · [super_resolution_reflection](papers/super_resolution_reflection.md) · [pbr_and_shading](papers/pbr_and_shading.md) · [volumetric_and_shadow](papers/volumetric_and_shadow.md)

---

## 전체 연결 지도

```
학술 연구                              UE5 구현
─────────────────────────────────────────────────────────
Hybrid RT+Raster (2022~2024) ───────▶ Lumen (SW RT + Screen-Space fallback)
3DGS RT GI (2025)           ───────▶ Lumen GI (동일 목표, 다른 표현)
Photon Field Networks (2023) ───────▶ Volumetric Cloud (ML 노이즈 적용)
─────────────────────────────────────────────────────────
Neural Geometric LOD (2021)  ───────▶ Nanite (클러스터 DAG LOD — 명시적 메시)
Hierarchical 3DGS (2024)     ───────▶ World Partition + Nanite 조합
─────────────────────────────────────────────────────────
Radiance Demod SR (2024)     ───────▶ TSR (Temporal Super Resolution)
DLSS/FSR/XeSS               ───────▶ UE5 플러그인으로 통합 가능
─────────────────────────────────────────────────────────
OpenPBR (SIGGRAPH 2025)      ───────▶ UE5 머티리얼 (Base Color/Metallic/Roughness/Specular)
BRDF Neural Rendering (2023) ───────▶ UE5 BRDF.ush — 미세면 GGX 모델
─────────────────────────────────────────────────────────
RT Advances (SIGGRAPH 2025)  ───────▶ UE5 파이프라인 전체 (GI·RT·TAA·업스케일)
SW Graphics Pipeline (2018)  ───────▶ Nanite 마이크로폴리곤 이론적 선행 연구
DL Rendering Optim (2024)    ───────▶ TSR의 DL 기반 최적화 방향
─────────────────────────────────────────────────────────
ML Cloud Unreal (2025) ⭐    ───────▶ UE5 Volumetric Cloud + Ray-marching (직접 구현)
Neural Soft Shadow AR (2023) ───────▶ UE5 PCSS의 미래 방향 (모바일 실시간)
```

---

## 1. 전역 조명 (GI) — Lumen의 이론적 기반

UE5 Lumen은 **SW Ray Tracing + Screen-Space fallback** 하이브리드 구조.

최신 연구 동향:
- **3DGS + RT GI (2025, arXiv 2503.17897)**: >40 FPS, 확률적 RT + 최적화 래스터라이저 → Lumen의 성능 목표와 동일한 방향
- **Photon Field Networks (2023, arXiv 2304.07338)**: 볼류메트릭(연기/구름) 특화 GI → UE5 Volumetric Cloud 시스템에 ML로 적용한 논문(2025)이 이미 존재

**실무 연결**: Lumen Quality를 낮출 때 발생하는 품질 저하는 SW RT 샘플 수 감소 때문. Max Trace Distance 조정이 가장 효과적.

---

## 2. 지오메트리 LOD — Nanite의 이론적 기반

UE5 Nanite = **명시적 클러스터 DAG + GPU-Driven 마이크로폴리곤 래스터화**.

최신 연구 동향:
- **Neural Geometric LOD (CVPR 2021)**: SDF 기반 암묵적 표현. Nanite(명시적)와 방향성 유사, 구현 방식 상이. 100~1000배 빠른 SDF 렌더링
- **Hierarchical 3DGS (SIGGRAPH 2024)**: 대규모 씬 청크 분할 + LOD 자동 전환 → World Partition + Nanite의 연구 버전

**실무 주의**: 반투명 머티리얼 → Nanite 자동 비활성화. 투명 오브젝트는 Nanite 제외 처리 필수.

---

## 3. 업스케일링 — TSR의 이론적 기반

UE5 TSR(Temporal Super Resolution) = **Temporal Accumulation 기반 AI 업스케일**.

최신 연구:
- **Radiance Demod SR (CVPR 2024)**: 조명/머티리얼 분리 → 각각 최적화 후 재결합. TSR의 발전 방향
- **DLSS 3+/FSR 3/XeSS**: UE5 플러그인으로 TSR 대체 가능

**성능 비교**: TSR(기본) < DLSS 3(Nvidia 전용, 프레임 생성 포함) / FSR 3(크로스플랫폼)

---

## 4. PBR 머티리얼 — UE5 BRDF 표준

UE5 머티리얼은 **GGX/Trowbridge-Reitz 미세면 이론** 기반.

최신 연구:
- **OpenPBR (SIGGRAPH 2025)**: VFX·애니메이션 상호운용 표준. UE5와 동일한 미세면 이론, 다층 레이어 추가
- **Neural BRDF (2023)**: 신경망으로 BRDF 학습 → UE5 Shader에 Neural 레이어 추가 가능성

**실무 버그 패턴**: Specular 0.5 유지 / 금속 Base Color가 반사색 / Roughness 0 근접 → 핫스팟

---

## 5. 그림자 & 볼류메트릭

UE5 기본 → Shadow Maps → CSM → **Virtual Shadow Maps (권장)** → RT Shadow(최고 품질).

최신 연구:
- **ML Cloud Unreal (2025)** ⭐: UE 내 직접 구현. 15% 품질 향상 @ 35ms/frame
- **Neural Soft Shadow (2023)**: 9ms 조명 추정 + 5ms 소프트 그림자 (모바일)

---

## 요약 테이블

| UE5 기능 | 최신 연구 | 성숙도 |
|---------|----------|--------|
| Lumen | 3DGS RT GI (2025) | 연구 단계 |
| Nanite | Neural Geometric LOD (2021), Hierarchical 3DGS (2024) | 연구 단계 |
| TSR | Radiance Demod SR (2024) | 연구 단계 |
| PBR | OpenPBR (SIGGRAPH 2025) | 표준화 진행 중 |
| Volumetric Cloud | ML Cloud Unreal (2025) | **UE 직접 구현** |
| Virtual Shadow Maps | Neural Soft Shadow (2023) | 연구 단계 |

---

## 관련 페이지

### 시스템
- [UE5 렌더링 & 셰이더 시스템](systems/ue5_rendering_shader.md)
- [렌더링 파이프라인 & 기법](systems/rendering.md)
- [라이팅 & PostProcess](systems/lighting.md)

### 논문
- [하이브리드 렌더링](papers/hybrid_rendering.md)
- [글로벌 일루미네이션](papers/global_illumination.md)
- [LOD & Geometry](papers/lod_and_geometry.md)
- [PBR & 셰이딩](papers/pbr_and_shading.md)
- [볼류메트릭 & 그림자](papers/volumetric_and_shadow.md)
- [업스케일링 & 반사](papers/super_resolution_reflection.md)
- [Gaussian Splatting](papers/gaussian_splatting.md)
- [Neural Rendering](papers/neural_rendering.md)
