# 조명 시스템 — 광원 액터 & 설정 가이드

> 소스 경로: Runtime/Engine/Classes/Components/LightComponent.h, DirectionalLightComponent.h 외
> 아티스트를 위한 설명

---

## 광원 액터 5종 비교

| 광원 | 형태 | 대표 용도 | 성능 비용 |
|------|------|---------|---------|
| **Directional Light** | 무한 평행광 | 태양, 달 | 낮음 |
| **Point Light** | 구형 방사 | 전구, 횃불 | 중간 |
| **Spot Light** | 원뿔형 | 손전등, 무대 조명 | 중간 |
| **Rect Light** | 사각형 면광원 | 형광등, TV 화면, 창문 | 높음 |
| **Sky Light** | 전방위 환경광 | 하늘 반사광, 야외 앰비언트 | 낮음 |

---

## 공통 광원 속성

| 프로퍼티 | 설명 |
|---------|------|
| `Intensity` | 빛의 세기. 단위는 광원 타입마다 다름 (cd, lm, lux) |
| `Light Color` | 빛의 색상 (RGB) |
| `Use Temperature` | ON 시 색온도(K)로 색상 설정. 3200K=따뜻한 백열등, 6500K=차가운 형광등 |
| `Temperature` | 색온도 값 (켈빈). `Use Temperature` ON 시 적용 |
| `Cast Shadows` | 그림자 생성 여부 |
| `Indirect Lighting Intensity` | Lumen 간접광 기여 강도 배율 |
| `Volumetric Scattering Intensity` | 볼류메트릭 안개/빛줄기 강도 배율 |
| `Affects World` | OFF이면 이 광원이 씬에 영향 없음 (임시 비활성화) |

---

## Directional Light — 방향광 (태양/달)

씬에서 **무한히 멀리 있는 광원**을 시뮬레이션합니다. 모든 빛줄기가 평행하게 내려옵니다.

### 주요 설정

| 프로퍼티 | 설명 |
|---------|------|
| `bUsedAsAtmosphereSunLight` | ON이면 Sky Atmosphere와 연동 — 태양 위치에 따라 하늘 색 자동 변경 |
| `Light Source Angle` | 태양 원반의 각도 크기. 클수록 소프트한 그림자 (기본 0.5357°) |
| `Shadow Distance` | 동적 그림자가 그려지는 최대 거리 |
| `Cascade Shadow Maps` | 거리별 그림자 LOD (CSM). 가까울수록 고해상도 |
| `Dynamic Shadow Distance` | 움직이는 오브젝트 그림자 거리 |
| `Num Dynamic Shadow Cascades` | CSM 분할 개수 (2~4 권장) |

> **팁:** 오픈 월드에서는 `Dynamic Shadow Distance MovableLight`를 8000~20000 정도로 설정하면 성능과 품질의 균형을 맞출 수 있습니다.

---

## Point Light — 점광원 (전구/횃불)

한 점에서 **구형으로 빛을 방사**합니다.

| 프로퍼티 | 설명 |
|---------|------|
| `Attenuation Radius` | 빛이 닿는 최대 반경. 이 구 밖은 완전히 어두움 |
| `Source Radius` | 광원 구체의 물리적 크기. 클수록 소프트한 그림자와 반사 하이라이트 |
| `Source Length` | 광원을 캡슐(튜브) 형태로 늘림. 형광관 모양 표현 |
| `IES Texture` | IES 조명 프로파일 적용 — 실제 조명 기구의 빛 분포 패턴 |

---

## Spot Light — 스팟 조명 (손전등/무대)

원뿔 형태로 빛을 방사합니다.

| 프로퍼티 | 설명 |
|---------|------|
| `Inner Cone Angle` | 완전한 밝기의 안쪽 원뿔 각도 |
| `Outer Cone Angle` | 빛이 페이드아웃되는 바깥쪽 원뿔 각도 |
| `Attenuation Radius` | 최대 도달 거리 |
| `Source Radius` | 소프트 그림자용 광원 크기 |
| `IES Texture` | 조명 프로파일 텍스처 |

> **Inner/Outer 차이:** Inner~Outer 사이 구간이 부드럽게 페이드되는 링입니다. Outer가 Inner보다 클수록 경계가 부드러워집니다.

---

## Rect Light — 면광원 (TV/창문/형광등)

**사각형 면에서 빛을 방사**합니다. 물리적으로 가장 사실적인 실내 조명 표현에 사용합니다.

| 프로퍼티 | 설명 |
|---------|------|
| `Source Width` | 사각형 너비 |
| `Source Height` | 사각형 높이 |
| `Barn Door Angle` | 빛을 좁히는 차단판 각도 |
| `Barn Door Length` | 차단판 길이 |
| `Source Texture` | 면광원에 텍스처 적용 (TV 화면, 창밖 하늘 등) |

---

## Sky Light — 하늘 환경광

씬 주변 **360도 환경에서 오는 간접광**을 캡처해 오브젝트에 적용합니다.

| 프로퍼티 | 설명 |
|---------|------|
| `Source Type` | `SLS_CapturedScene`: 현재 씬을 큐브맵으로 캡처 / `SLS_SpecifiedCubemap`: HDR 큐브맵 직접 지정 |
| `Cubemap` | `SLS_SpecifiedCubemap` 모드에서 사용할 HDR 텍스처 |
| `Sky Distance Threshold` | 이 거리 이상의 오브젝트를 하늘로 간주해 캡처 |
| `Real Time Capture` | ON이면 매 프레임 씬을 재캡처 (Lumen 환경에서 권장, 성능 비용 있음) |
| `Recapture Sky` | 수동으로 씬 재캡처 트리거 |

> **Lumen 환경:** Real Time Capture = ON이면 하늘 변화(시간대 변경 등)가 Sky Light에 즉시 반영됩니다.

---

## Sky Atmosphere — 물리 기반 대기

`SkyAtmosphereComponent`는 레일리(Rayleigh) 산란과 미(Mie) 산란으로 사실적인 하늘 색을 만듭니다.

| 파라미터 | 설명 |
|---------|------|
| `Rayleigh Scattering` | 파란 하늘, 노을 빨간색 — 파장별 산란 강도 |
| `Rayleigh Exponential Distribution` | 대기 밀도 감쇠 높이 |
| `Mie Scattering` | 안개, 연기, 먼지에 의한 흰 빛 산란 |
| `Mie Absorption` | 미 입자에 의한 빛 흡수 |
| `Atmosphere Height` | 대기권 상단 높이 (기본 60km) |
| `Ground Albedo` | 지표면 반사율 (노을색에 영향) |

---

## 라이트 채널 (Light Channels)

라이트 채널은 **특정 광원이 특정 메시에만 영향을 미치도록** 분리하는 기능입니다.

**비유:** 무대 조명처럼 배우(메시)마다 다른 조명(광원)을 독립 적용.

| 채널 | 기본값 |
|------|--------|
| Channel 0 | 기본 — 모든 오브젝트와 광원 |
| Channel 1 | 보조 채널 |
| Channel 2 | 보조 채널 |

**설정 방법:**
1. 광원 디테일 → `Light Channels` → 원하는 채널 체크
2. 메시 액터 디테일 → `Lighting` → `Light Channels` → 동일 채널 체크
3. 같은 채널을 가진 광원과 메시만 서로 영향

**사용 예시:**
- 캐릭터 전용 Fill Light (배경 오브젝트에 영향 없음)
- 무기 발광 이펙트를 특정 캐릭터에만 적용

---

## Lumen 설정과 조명 연동

| 항목 | 권장 설정 |
|------|---------|
| Directional Light | `bUsedAsAtmosphereSunLight` ON |
| Sky Light | `Real Time Capture` ON (동적 환경), OFF (성능 최적화) |
| Point/Spot Light | `Intensity Unit`을 `Candelas`로 통일 |
| Indirect Lighting Intensity | 너무 높으면 Lumen GI가 과도하게 밝아짐 |
| Static Light | 베이크드 라이팅 레벨에서는 Static, 동적 레벨에서는 Movable |

---

## 아티스트 체크리스트

### 야외 씬 설정
- [ ] Directional Light에 `bUsedAsAtmosphereSunLight`가 ON인가?
- [ ] Sky Atmosphere 액터가 배치되어 있는가?
- [ ] Sky Light의 `Real Time Capture`가 프로젝트 요구에 맞게 설정되어 있는가?
- [ ] Directional Light의 `Light Source Angle`로 그림자 소프트니스를 조정했는가?

### 실내 씬 설정
- [ ] Point/Spot Light의 `Attenuation Radius`가 공간 크기에 적합한가?
- [ ] Rect Light를 형광등/창문에 사용했는가?
- [ ] IES 프로파일 텍스처가 있는 경우 적용했는가?
- [ ] `Source Radius`를 0보다 크게 설정해 소프트 그림자를 만들었는가?

### 성능 검토
- [ ] 씬에 Movable 광원이 너무 많지 않은가? (동시 오버랩 4개 이하 권장)
- [ ] 불필요한 `Cast Shadows`를 OFF 처리했는가?
- [ ] 원거리 오브젝트에 그림자 캐스팅이 필요한가?

### 라이트 채널
- [ ] 광원과 메시의 채널 번호가 일치하는가?
- [ ] Channel 0 이외 채널을 쓸 때 의도치 않은 오브젝트가 제외되지 않았는가?

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [02_rendering.md](02_rendering.md) | 그림자 기술 비교 (CSM/VSM/RT Shadow) — 렌더링 파이프라인 맥락 |
| [20_ray_tracing.md](20_ray_tracing.md) | RT Shadows — 레이 트레이싱 그림자로 전환 시 광원 설정 영향 |
| [39_volumetric_clouds.md](39_volumetric_clouds.md) | Sky Atmosphere + Directional Light 연동 — 시간대 변화 하늘 |
| [23_water_volumes.md](23_water_volumes.md) | PostProcessVolume — 실내/수중 조명 환경 설정 |
| [35_landscape_advanced.md](35_landscape_advanced.md) | 야외 Directional Light + Sky Light — 지형 조명 셋업 |
| [53_profiling_optimization.md](53_profiling_optimization.md) | 불필요한 Cast Shadows OFF — 성능 최적화 |
