# 카메라 시스템 — SpringArm, CameraShake, PlayerCameraManager

> 소스 경로: Runtime/Engine/Classes/GameFramework/, Runtime/Engine/Classes/Camera/
> 아티스트를 위한 설명

---

## SpringArmComponent (스프링 암 / 카메라 붐)

**비유:** 캐릭터와 카메라 사이에 붙는 "셀카봉" 같은 컴포넌트입니다. 벽이나 장애물에 카메라가 파고드는 것을 자동으로 막아주고, 카메라가 캐릭터를 자연스럽게 따라가도록 지연(Lag) 효과를 줄 수 있습니다.

---

### 팔 길이 설정

| 프로퍼티 | 설명 |
|---------|------|
| `TargetArmLength` | 카메라와 캐릭터 사이의 기본 거리. 충돌 없을 때의 자연스러운 길이 (보통 200~400) |
| `SocketOffset` | 스프링 암 끝(카메라 위치)의 로컬 오프셋 — 카메라를 오른쪽/위로 미세 조정 |
| `TargetOffset` | 스프링 암 시작점(캐릭터)의 월드 오프셋 — 머리 위를 기준점으로 삼을 때 |

### 충돌 보정

| 프로퍼티 | 설명 |
|---------|------|
| `bDoCollisionTest` | ON이면 카메라가 벽을 통과하지 않도록 자동으로 당겨옴 (거의 항상 ON) |
| `ProbeSize` | 충돌 감지 구체의 반지름 (기본값 12) |
| `ProbeChannel` | 어떤 충돌 채널에 반응할지 (기본: `ECC_Camera`) |

### 지연 (Lag) 설정

| 프로퍼티 | 설명 |
|---------|------|
| `bEnableCameraLag` | 위치 지연 ON/OFF — 캐릭터가 갑자기 움직여도 카메라가 부드럽게 따라옴 |
| `CameraLagSpeed` | 낮을수록 더 느리게 따라옴. 5~15 정도가 자연스러움 |
| `CameraLagMaxDistance` | 카메라가 목표 지점에서 최대 뒤처질 수 있는 한계 거리 |
| `bEnableCameraRotationLag` | 회전 지연 ON/OFF |
| `CameraRotationLagSpeed` | 회전 지연 속도 |
| `bDrawDebugLagMarkers` | 에디터에서 지연 디버그 마커 표시 (조정할 때만 ON) |

### 회전 상속

| 프로퍼티 | 설명 |
|---------|------|
| `bUsePawnControlRotation` | 플레이어 시점(컨트롤 회전)을 스프링 암이 따라갈지 여부. 3인칭이면 보통 ON |
| `bInheritPitch/Yaw/Roll` | 부모로부터 각 회전축을 개별적으로 상속할지 설정 |

---

## PlayerCameraManager

플레이어 1명당 1개씩 자동으로 생성되는 "카메라 두뇌"입니다. 렌더러가 최종적으로 사용하는 시점을 결정하며, 카메라 블렌딩·셰이크·페이드를 통합 관리합니다.

### 카메라 블렌딩 함수

| 블렌드 함수 | 설명 |
|-----------|------|
| `VTBlend_Linear` | 일정 속도로 전환 |
| `VTBlend_Cubic` | 부드럽게 가속/감속 (기본값) |
| `VTBlend_EaseIn` | 빠르게 출발해서 천천히 도착 |
| `VTBlend_EaseOut` | 천천히 출발해서 빠르게 도착 |
| `VTBlend_EaseInOut` | 천천히 출발, 천천히 도착 (가장 부드러운 느낌) |

블렌드 파라미터:
- `BlendTime`: 전환에 걸리는 총 시간(초). 0이면 즉시 전환
- `BlendExp`: EaseIn/Out 계열 곡선 강도 (기본값 2.0)
- `bLockOutgoing`: 이전 카메라를 마지막 프레임 위치에 고정한 채 블렌드

### 시야각 및 회전 제한

| 프로퍼티 | 설명 |
|---------|------|
| `DefaultFOV` | 기본 시야각 (CameraComponent의 FOV가 우선) |
| `ViewPitchMin/Max` | 위아래 시선 회전 제한 |
| `ViewYawMin/Max` | 좌우 시선 회전 제한 |

### 카메라 페이드

Blueprint에서 `StartCameraFade` 노드 사용:
- `FromAlpha → ToAlpha`: 0=투명, 1=완전 불투명
- `Duration`: 페이드 지속 시간 (초)
- `bShouldFadeAudio`: 오디오도 함께 페이드할지

---

## CameraShake (카메라 셰이크)

### 셰이크 종류

| 방식 | 특징 | 권장 |
|------|------|------|
| **Perlin Noise** (`UPerlinNoiseCameraShakePattern`) | 유기적, 자연스럽고 불규칙한 흔들림 | ✅ UE5 권장 |
| **Oscillator (구형)** | 사인파 기반 규칙적 흔들림 | 레거시 호환용 |

### Perlin Noise 주요 파라미터

| 파라미터 | 설명 |
|---------|------|
| `LocationAmplitudeMultiplier` | 위치 흔들림 전체 강도 배율 |
| `LocationFrequencyMultiplier` | 위치 흔들림 전체 속도 배율 |
| `X/Y/Z` (Amplitude, Frequency) | 각 축 개별 강도 및 속도 |
| `RotationAmplitudeMultiplier` | 회전 흔들림 전체 강도 배율 |
| `Pitch/Yaw/Roll` (Amplitude, Frequency) | 각 회전축 개별 흔들림 |
| `FOV` (Amplitude, Frequency) | FOV 변화 흔들림 |

### 재생 공간

| 값 | 설명 |
|----|------|
| `CameraLocal` | 카메라 기준 좌표계. 어디를 봐도 동일하게 느껴짐 (기본값) |
| `World` | 월드 기준. 특정 방향에서 느껴지는 충격 표현 |

---

## CameraComponent 주요 설정

| 프로퍼티 | 설명 |
|---------|------|
| `FieldOfView` | 수평 시야각 (기본 90도. 좁을수록 망원, 넓을수록 광각) |
| `ProjectionMode` | `Perspective`(원근) 또는 `Orthographic`(직교) |
| `AspectRatio` | 화면 비율 (16:9 = 1.777) |
| `bConstrainAspectRatio` | ON이면 비율 다를 때 레터박스(검은 띠) 추가 |
| `PostProcessBlendWeight` | 이 카메라의 포스트 프로세스 적용 가중치 (0~1) |
| `PostProcessSettings` | DOF, Bloom, Color Grading 등 개별 오버라이드 |
| `PerspectiveNearClipPlane` | 카메라 앞 가까운 절단 거리 |
| `FirstPersonFieldOfView` | 1인칭 메시(손/무기)에만 적용되는 별도 FOV |

---

## 아티스트 체크리스트

### 3인칭 카메라 설정 시
- [ ] SpringArm의 `TargetArmLength`가 캐릭터 크기에 비례하는가?
- [ ] `bDoCollisionTest`가 ON인가? (OFF이면 카메라가 벽을 통과함)
- [ ] `bUsePawnControlRotation`이 SpringArm에서 ON인가?
- [ ] CameraComponent의 `bUsePawnControlRotation`은 OFF인가? (이중 적용 방지)
- [ ] `bEnableCameraLag`을 켰을 때 `CameraLagSpeed`가 적절한가? (너무 낮으면 카메라가 한참 뒤처짐)

### 카메라 셰이크 추가 시
- [ ] `UPerlinNoiseCameraShakePattern` 기반 새 Blueprint 클래스 생성
- [ ] `bSingleInstance` 고려 (ON이면 동시에 하나만 재생)
- [ ] 셰이크 강도가 게임플레이를 방해하지 않는 수준인가? (특히 Roll 값)

### 카메라 전환 시
- [ ] `SetViewTargetWithBlend` 노드 사용
- [ ] `BlendTime = 0`이면 컷 전환, 0 초과이면 부드러운 전환
- [ ] 씬 전환에 `StartCameraFade`로 페이드 인/아웃 처리

### FOV 설정 시
- [ ] 기본 플레이 FOV는 90도, 경쟁 FPS는 100~110도
- [ ] 시네마틱에서 영화 느낌은 FOV 40~60도로 설정
- [ ] Near Clip 수정 시 캐릭터 메시가 잘리지 않는지 PIE에서 확인

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [36_sequencer_advanced.md](36_sequencer_advanced.md) | CineCameraActor — Sequencer와 연동한 시네마틱 카메라 제작 |
| [06_ui_cinematics.md](06_ui_cinematics.md) | LevelSequence + Camera Cut Track — 카메라 전환 시퀀서 기초 |
| [01_gameplay_framework.md](01_gameplay_framework.md) | PlayerController → PlayerCameraManager — 카메라 관리 계층 |
| [04_audio_effects.md](04_audio_effects.md) | CameraShake와 폭발 SFX 동기화 패턴 |
| [14_textures_advanced.md](14_textures_advanced.md) | Render Target — 백미러/보안카메라 씬 캡처 활용 |
| [23_water_volumes.md](23_water_volumes.md) | PostProcessVolume — 수중 카메라 포스트 이펙트 설정 |
