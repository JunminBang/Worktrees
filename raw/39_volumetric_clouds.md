# 볼류메트릭 구름 & 안개

> 소스 경로: Runtime/Engine/Classes/Components/VolumetricCloudComponent.h, ExponentialHeightFogComponent.h
> 아티스트를 위한 설명

---

## 볼류메트릭 구름 시스템 개요

UE5의 **VolumetricCloud** 는 실시간으로 3D 부피 구름을 렌더링합니다. 평면 텍스처 구름과 달리 내부에 빛이 산란하고 그림자가 생기며, 씬 조명(태양/달)과 완전 연동됩니다.

**비유:** 코튼볼(솜사탕)처럼 내부에 빛이 스며들고, 보는 각도에 따라 다른 두께감을 가지는 진짜 구름입니다.

---

## VolumetricCloudComponent 설정

### 기본 배치

1. Place Actors → **Volumetric Cloud** 검색 → 배치
2. Sky Atmosphere + Directional Light (`bUsedAsAtmosphereSunLight` ON) 필요
3. Sky Light (`Real Time Capture` ON) 권장

### 주요 프로퍼티

| 프로퍼티 | 설명 |
|---------|------|
| `Layer Bottom Altitude` | 구름 레이어 하단 고도 (km, 기본 5km) |
| `Layer Height` | 구름 레이어 두께 (km, 기본 10km) |
| `Tracing Start Max Distance` | 구름 추적 시작 최대 거리 |
| `Tracing Max Distance` | 구름 내부 추적 최대 거리 |
| `Planet Radius` | 행성 반경 (기본 6360km = 지구) |
| `Ground Albedo` | 지면 반사율 (구름 아래쪽 밝기에 영향) |

---

## 구름 머티리얼 (Cloud Material)

볼류메트릭 구름의 외형은 **전용 Cloud Material**로 제어합니다.

### 기본 내장 머티리얼

`/Engine/EngineSky/VolumetricClouds/`에 기본 구름 머티리얼이 포함되어 있습니다. 이를 복사해 커스터마이징하는 것을 권장합니다.

### 핵심 머티리얼 노드

| 노드 | 설명 |
|------|------|
| `Cloud Sample` | 구름 밀도·색상을 계산하는 핵심 입력 |
| `Volumetric Advanced Output` | 구름 출력 (Albedo, Extinction, Emissive 등) |
| `SampleCloudNoise` | 구름 노이즈 텍스처 샘플링 |

### 주요 머티리얼 파라미터

| 파라미터 | 설명 |
|---------|------|
| `CloudDensity` | 구름 밀도 전체 배율 |
| `BaseNoiseScale` | 기본 구름 형태 노이즈 스케일 |
| `DetailNoiseScale` | 세부 표면 노이즈 스케일 |
| `ErosionNoiseScale` | 구름 경계 침식 노이즈 스케일 |
| `CloudCoverage` | 구름이 하늘을 덮는 비율 (0=맑음, 1=흐림) |
| `WindDirection` | 구름 흐름 방향 |
| `WindSpeed` | 구름 이동 속도 |

---

## 구름 유형별 설정

| 유형 | 설정 |
|------|------|
| **적운 (뭉게구름)** | 높은 밀도, 낮은 레이어 고도, 좁은 Layer Height |
| **층운 (층구름)** | 낮은 밀도, 넓은 Coverage, 낮은 고도 |
| **권운 (새털구름)** | 매우 낮은 밀도, 높은 고도, 얇은 두께 |
| **뇌우 구름** | 매우 높은 밀도, 넓은 Layer Height, 어두운 색상 |

---

## Blueprint에서 날씨 제어

Material Parameter Collection(MPC)으로 런타임에 구름 상태를 변경합니다:

```
MPC_Weather
  ├─ CloudCoverage: Float (0~1)
  ├─ WindSpeed: Float
  ├─ WindDirection: Vector

[날씨 변화 트리거]
→ Timeline (30초 동안 서서히 변화)
  → Set Scalar Parameter Value (MPC_Weather, "CloudCoverage", 0.9)
  → 맑음 → 흐림 전환
```

---

## Exponential Height Fog — 고도 기반 안개

`ExponentialHeightFog`는 **고도에 따라 밀도가 지수적으로 변하는 안개**입니다. 낮은 곳은 짙고 높은 곳은 옅어지는 자연스러운 안개를 표현합니다.

### 주요 프로퍼티

| 프로퍼티 | 설명 |
|---------|------|
| `Fog Density` | 안개 전체 밀도 (0.02 정도가 자연스러운 시작) |
| `Fog Height Falloff` | 고도에 따른 밀도 감쇠 속도 |
| `Fog Cutoff Distance` | 이 거리 이상에만 안개 적용 (근거리 안개 제거) |
| `Start Distance` | 안개 시작 거리 |
| `Fog Inscattering Color` | 안개 자체 색상 (새벽=주황, 야간=남색) |
| `Sun Extinction` | 태양 방향으로의 안개 감쇠 |
| `Directional Inscattering` | 태양 방향 빛줄기 강도 |

### 볼류메트릭 안개 (Volumetric Fog)

Exponential Height Fog에서 볼류메트릭 모드 활성화:

| 프로퍼티 | 설명 |
|---------|------|
| `Volumetric Fog` | ON/OFF — 진짜 3D 부피 안개 활성화 |
| `Scattering Distribution` | 0=균일 산란, 0.9=전방 산란 (빛줄기 표현) |
| `Albedo` | 안개 입자 색상 |
| `Extinction Scale` | 안개 두께/불투명도 |
| `View Distance` | 볼류메트릭 안개 계산 최대 거리 |

> **성능 팁:** 볼류메트릭 안개는 비용이 높습니다. `View Distance`를 제한하거나 `Temporal Reprojection`을 활용하세요.

---

## 빛줄기 (God Rays / Light Shafts)

| 방법 | 설명 |
|------|------|
| **Directional Light → Light Shafts** | Directional Light 속성에서 `Occlusion Mask Darkness`, `Light Shaft Bloom` 활성화 |
| **Volumetric Fog + Scattering** | Directional Inscattering으로 물리적 빛줄기 |

```
빛줄기 설정 (Directional Light):
  Light Shafts:
    - Enable Light Shaft Occlusion: ON
    - Enable Light Shaft Bloom: ON
    - Occlusion Mask Darkness: 0.05
    - Bloom Scale: 0.05
```

---

## Sky Atmosphere와 연동

구름, 안개, 하늘이 자연스럽게 연동되려면:

```
필수 조합:
  ✅ DirectionalLight (bUsedAsAtmosphereSunLight ON)
  ✅ SkyAtmosphere
  ✅ VolumetricCloud
  ✅ SkyLight (Real Time Capture ON)
  ✅ ExponentialHeightFog (선택)
```

Directional Light의 방향(태양 각도)을 바꾸면:
- 하늘 색이 자동 변경 (낮→노을→밤)
- 구름이 태양 방향에서 내부 광산란
- 안개 색이 태양 색온도에 영향

---

## 성능 최적화

| 최적화 | 설명 |
|--------|------|
| `Tracing Max Distance` 단축 | 먼 구름 상세 계산 제한 |
| `Shadow View Sample Count` 감소 | 구름 그림자 품질 vs 성능 |
| 볼류메트릭 안개 `View Distance` 제한 | 100000cm 이하 권장 |
| r.VolumetricCloud.ShadowMap.RaymarchingSteps | 콘솔 변수로 품질 조정 |

---

## 아티스트 체크리스트

### 구름 설정 시
- [ ] Sky Atmosphere, Directional Light, Sky Light가 모두 씬에 있는가?
- [ ] Directional Light의 `bUsedAsAtmosphereSunLight`가 ON인가?
- [ ] `Layer Bottom Altitude`와 `Layer Height`가 씬 스케일에 맞는가?
- [ ] Cloud Material에서 CloudCoverage 파라미터가 날씨 컨셉에 맞는가?

### 안개 설정 시
- [ ] `Fog Height Falloff`로 지표면과 상공의 농도 차이가 자연스러운가?
- [ ] `Fog Inscattering Color`가 시간대/날씨 분위기에 맞는가?
- [ ] 볼류메트릭 안개 활성화 시 `View Distance`가 적절히 제한되어 있는가?

### 성능
- [ ] 볼류메트릭 구름 + 볼류메트릭 안개 동시 사용 시 GPU 비용을 확인했는가?
- [ ] 모바일/저사양 플랫폼에서는 볼류메트릭 기능 비활성화 경로가 있는가?
- [ ] `Stat GPU` 명령으로 VolumetricCloud 비용을 측정했는가?
