---
name: 라이팅 & PostProcessVolume 시스템
type: system
tags: lighting, postprocess, gamma, exposure, fog
last_updated: 2026-04-09
source: scene-scan + user-report
scene_verified: true
---

# 라이팅 & PostProcessVolume 시스템

## 현재 씬 조명 액터 (2026-04-09 기준)

| 액터 | 위치 | 비고 |
|------|------|------|
| DirectionalLight | (0, 0, 920) | 회전 (-60.8, -15.0, 25.6) / 스케일 2.5 (광량 무관) |
| SkyLight | (0, 0, 690) | 정상 |
| SkyAtmosphere | (0, 0, 1020) | 정상 |
| VolumetricCloud | (0, 0, 820) | 정상 |
| ExponentialHeightFog | (-5600, -50, **-6850**) | ⚠️ Z값 비정상 — 씬 전체가 안개 속 |
| PostProcessVolume | (100, 100, 500) | 스케일 (1,1,1) — Unbound 여부 확인 필요 |

---

## 에디터 직접 확인 항목

> ⚠️ 아래 항목들은 씬 스캔으로 읽히지 않으므로 에디터에서 직접 확인 필요:

| 항목 | 에디터 경로 |
|------|------------|
| PostProcess Gamma | Color Grading > Global > Gamma |
| PostProcess Exposure | Lens > Exposure > ... |
| PPV 범위 | Infinite Extent (Unbound) 체크 여부 |
| Fog Density | ExponentialHeightFog > Fog Density |
| Light Intensity | DirectionalLight > Intensity |

---

## 씬이 어두울 때 체크리스트

1. **PostProcessVolume > Global Gamma** 값 확인 (기본값: 1.0)
2. **PostProcessVolume > Unbound** 체크 여부 (미체크 시 볼륨 범위 밖 영향 없음)
3. **ExponentialHeightFog Z 위치** 확인 (씬보다 높으면 전체 안개 적용)
4. **DirectionalLight Intensity** 확인
5. **라이팅 빌드 여부** — Static 라이트는 빌드 전 미리보기 상태로 어두울 수 있음

## 자주 발생하는 버그

| 증상 | 원인 | 해결 |
|------|------|------|
| 씬 전체 어두움 | Global Gamma 낮게 설정 | Gamma → 1.0 복원 |
| 씬 전체 뿌옇고 어두움 | HeightFog Z가 씬보다 낮음 | Fog Density 줄이거나 Z 위치 조정 |
| 특정 구역만 PPV 적용 | PPV Unbound 미체크 | Infinite Extent 체크 |
| 카메라 노출 불안정 | Auto Exposure 활성화 | Min/Max Brightness 고정 |

## 관련 페이지
- [레벨 개요](../overview.md)
- [렌더링 파이프라인 & 기법](rendering.md)
- [UE5 렌더링 & 셰이더 시스템](ue5_rendering_shader.md)
- [볼류메트릭 & 그림자 논문](../papers/volumetric_and_shadow.md)
