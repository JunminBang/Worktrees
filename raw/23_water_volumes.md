# 물 시스템 & 볼륨 액터

> 소스 경로: Plugins/Experimental/Water/Source/, Runtime/Engine/Classes/GameFramework/Volume.h
> 아티스트를 위한 설명

---

## 물 시스템 (Water Plugin)

### WaterBody 4가지 종류

| 타입 | 사용 시기 | 특징 |
|------|---------|------|
| `WaterBodyRiver` | 강, 개울, 흐르는 물 | 스플라인으로 경로 정의, 흐름 방향 제어 |
| `WaterBodyLake` | 호수, 연못 | 스플라인으로 닫힌 구역 정의 |
| `WaterBodyOcean` | 무한 대양 | 경계 없는 수평선, 타일링 파도 |
| `WaterBodyCustom` | 커스텀 형태 | 직접 폴리곤 모양 정의 |

### 물 플러그인 활성화

1. **Edit → Plugins** → `Water` 검색 → 활성화
2. 에디터 재시작
3. Place Actors 패널에서 `WaterBody` 배치 가능

---

## WaterBodyRiver 설정

### 스플라인 기반 경로 정의

1. Place Actors → **WaterBodyRiver** 배치
2. 스플라인 포인트를 드래그해 강 경로 정의
3. 각 포인트에서 너비(Width)와 깊이(Depth) 조정 가능

### 주요 프로퍼티

| 프로퍼티 | 설명 |
|---------|------|
| `Water Velocity` | 물 흐름 속도. 유속 방향 제어 |
| `River Width` | 스플라인 기준 강 너비 |
| `Water Depth` | 물의 깊이 (수면 아래) |
| `Channel Depth` | 하천 바닥까지의 깊이 |

---

## Gerstner Wave — 파도 시뮬레이션

Gerstner Wave는 물리적으로 설득력 있는 파도를 만드는 수학 기반 알고리즘입니다.

### 파라미터

| 파라미터 | 설명 |
|---------|------|
| `Amplitude` | 파고 (물결 높이) |
| `Wavelength` | 파장 (파도 간격) |
| `Speed` | 파도 이동 속도 |
| `Direction` | 파도 진행 방향 (각도) |
| `Steepness` | 파도 끝 날카로움 (너무 높으면 루프 발생) |

WaterBodyOcean에는 여러 Gerstner Wave를 레이어로 쌓아 복잡한 해양 파도를 표현할 수 있습니다.

---

## 물 머티리얼 슬롯

WaterBody는 다음 머티리얼 슬롯을 가집니다:

| 슬롯 | 설명 |
|------|------|
| `Water Material` | 수면 렌더링 머티리얼 |
| `Water Info Material` | 물 정보 텍스처 생성용 (내부용) |
| `Underwater Post Process Material` | 수면 아래에서 보이는 포스트 프로세스 효과 |

---

## UBuoyancyComponent — 부력 시스템

`UBuoyancyComponent`를 캐릭터나 물체에 붙이면 물 위에서 자동으로 뜨고 가라앉는 부력을 시뮬레이션합니다.

### FSphericalPontoon — 부력 포인트

부력은 **구형 폰툰(Pontoon) 포인트** 기준으로 계산됩니다. 보트의 경우 좌우 앞뒤에 4개의 폰툰을 배치합니다.

| 프로퍼티 | 설명 |
|---------|------|
| `Radius` | 폰툰 구체 반지름. 클수록 더 많이 뜸 |
| `RelativeLocation` | 액터 루트 기준 폰툰 위치 |
| `CenterLocation` | 수위 계산 기준점 |

### 부력 설정 예시 (보트)

```
BuoyancyComponent 추가
├─ Pontoon 1: Location (-200, -100, 0), Radius 50  ← 좌전방
├─ Pontoon 2: Location (-200, +100, 0), Radius 50  ← 우전방
├─ Pontoon 3: Location (+200, -100, 0), Radius 50  ← 좌후방
└─ Pontoon 4: Location (+200, +100, 0), Radius 50  ← 우후방
```

---

## PostProcessVolume — 후처리 효과 볼륨

`PostProcessVolume`은 해당 볼륨 안에 있는 카메라에 **후처리(Post-Process) 이펙트**를 적용합니다.

### 주요 효과 카테고리

| 카테고리 | 대표 파라미터 | 설명 |
|---------|------------|------|
| **Bloom** | `Intensity`, `Threshold` | 밝은 영역 번짐 효과 |
| **Exposure** | `Min/Max EV100`, `Metering Mode` | 자동 노출 제어 |
| **Depth of Field** | `Focal Distance`, `Depth Blur Amount` | 아웃포커스 효과 |
| **Color Grading** | `Saturation`, `Contrast`, `Gamma` | 색조 보정 |
| **Vignette** | `Vignette Intensity` | 화면 가장자리 어두움 |
| **Lens Flare** | `Intensity`, `BokehSize` | 렌즈 반사 효과 |
| **Film Grain** | `Intensity` | 필름 노이즈 질감 |
| **Motion Blur** | `Amount`, `Max` | 이동 시 블러 |

### 무한 범위 (전역 적용)

PostProcessVolume의 디테일 패널 → `Infinite Extent (Unbound)` 체크 시 레벨 전체에 적용됩니다.

### 블렌드 가중치

- `Blend Radius`: 다른 볼륨과 블렌딩되는 경계 반지름
- `Blend Weight`: 이 볼륨의 효과 강도 (0=무효, 1=완전 적용)
- `Priority`: 여러 볼륨이 겹칠 때 우선순위

---

## 볼륨 액터 종류

### TriggerVolume — 이벤트 트리거

캐릭터나 오브젝트가 볼륨에 들어가거나 나올 때 이벤트를 발생시킵니다.

| 이벤트 | 설명 |
|--------|------|
| `OnActorBeginOverlap` | 오브젝트가 볼륨에 진입 |
| `OnActorEndOverlap` | 오브젝트가 볼륨을 벗어남 |

**사용 예시:**
- 체크포인트 진입 감지
- 특정 구역에서 음악 변경
- 컷씬 자동 트리거
- 적 스폰 구역 활성화

### PhysicsVolume — 물리 환경 볼륨

| 프로퍼티 | 설명 |
|---------|------|
| `Terminal Velocity` | 볼륨 내 최대 낙하 속도 |
| `Gravity Scale` | 중력 배율 (0=무중력, 2=2배 중력) |
| `Fluid Friction` | 유체 저항 (물속 느린 이동 등) |
| `bWaterVolume` | ON이면 물 속 물리 적용 (수영 가능) |
| `Priority` | 여러 PhysicsVolume 겹칠 때 우선순위 |

**사용 예시:**
- 달 표면 (낮은 중력)
- 우주 구역 (무중력)
- 수중 구역 (유체 저항 + 수영)

### PainCausingVolume — 피해 볼륨

| 프로퍼티 | 설명 |
|---------|------|
| `DamagePerSec` | 초당 피해량 |
| `DamageType` | 피해 타입 클래스 (불, 독, 폭발 등) |
| `bPainCausing` | 피해 활성화 여부 |
| `EntryPain` | 진입 시 즉시 피해 여부 |

**사용 예시:**
- 용암 구역
- 독가스 지역
- 방사능 구역

### KillZVolume — 즉사 볼륨

플레이어가 이 볼륨에 닿으면 즉시 사망 처리합니다. 맵 경계 밖 낙사 영역에 사용.

> **주의:** `WorldSettings`에도 `KillZ` 높이 설정이 있습니다. 이 값 이하로 내려가면 KillZ 이벤트가 발생합니다.

---

## 아티스트 체크리스트

### 물 시스템 설정 시
- [ ] Water 플러그인이 활성화되어 있는가?
- [ ] WaterBodyRiver의 스플라인 포인트가 올바른 높이에 배치되어 있는가?
- [ ] Gerstner Wave의 `Steepness`가 0.5 이하인가? (루핑 방지)
- [ ] Underwater Post Process Material이 설정되어 있는가?

### 부력 설정 시
- [ ] BuoyancyComponent의 Pontoon이 오브젝트 형태에 맞게 배치되어 있는가?
- [ ] Pontoon Radius가 오브젝트 크기에 비례하는가?
- [ ] 물리 시뮬레이션(Simulate Physics)이 해당 메시 컴포넌트에 활성화되어 있는가?

### PostProcessVolume 설정 시
- [ ] Infinite Extent 설정이 의도적인가? (ON이면 레벨 전체에 적용)
- [ ] Blend Weight가 올바른 강도로 설정되어 있는가?
- [ ] 여러 볼륨이 겹치는 구역에서 Priority 순서가 맞는가?
- [ ] Depth of Field 사용 시 Focal Distance가 씬에 맞게 조정되어 있는가?

### TriggerVolume 설정 시
- [ ] Overlap 이벤트가 Blueprint에서 바인딩되어 있는가?
- [ ] Collision 설정에서 적절한 오브젝트 타입만 오버랩되도록 필터링했는가?
- [ ] 볼륨 크기가 트리거 의도 구역과 일치하는가?
