# MetaSound — 절차적 오디오 합성 시스템

> 소스 경로: Engine/Plugins/Runtime/Metasound/Source/MetasoundFrontend/Public/
> 아티스트를 위한 설명

---

## MetaSound란?

MetaSound는 UE5의 **절차적 오디오 합성 시스템**으로, 기존 SoundCue를 대체하는 차세대 사운드 도구입니다. 노드 그래프로 오디오 로직을 프로그래밍하듯 설계할 수 있습니다.

**비유:** Niagara가 파티클 이펙트를 위한 노드 그래프라면, MetaSound는 사운드를 위한 노드 그래프입니다.

---

## MetaSound vs SoundCue 비교

| 항목 | SoundCue | MetaSound |
|------|---------|-----------|
| 구조 | 노드 기반 (제한적) | 완전한 오디오 DSP 그래프 |
| 실시간 파라미터 | 제한적 | 완전 지원 (Float/Int/Bool/Trigger) |
| 절차적 사운드 | 불가 | 수학 연산으로 사운드 합성 가능 |
| 퍼포먼스 | 보통 | 더 효율적 (오디오 렌더 스레드) |
| 추천 | 레거시 프로젝트 | UE5 신규 프로젝트 |

---

## MetaSound Source vs Patch

| 타입 | 역할 | 비유 |
|------|------|------|
| **MetaSound Source** | 독립적으로 재생 가능한 완성된 사운드 | 음악 트랙 |
| **MetaSound Patch** | 다른 MetaSound 안에 삽입하는 재사용 모듈 | 믹서의 이펙트 플러그인 |

---

## 핵심 노드 카테고리

### Wave Player — 오디오 파일 재생

| 노드 | 설명 |
|------|------|
| `Wave Player` | SoundWave 에셋을 재생하는 기본 노드 |
| `Wave Asset` | 재생할 SoundWave 에셋 입력 |
| `Start Time` | 재생 시작 위치 (초) |
| `Loop` | 반복 재생 여부 |

### Envelope (ADSR) — 음량 변화 제어

| 파라미터 | 설명 |
|---------|------|
| `Attack Time` | 소리가 최대 음량에 도달하는 시간 |
| `Decay Time` | 최대 → Sustain 레벨로 감소 시간 |
| `Sustain Level` | 지속 음량 레벨 (0~1) |
| `Release Time` | 노트 오프 후 소리가 사라지는 시간 |

### LFO — 저주파 오실레이터

주기적인 값 변화를 만들어 트레몰로, 비브라토, 워블 효과에 사용합니다.

| 파라미터 | 설명 |
|---------|------|
| `Frequency` | 진동 속도 (Hz) |
| `Amplitude` | 진동 폭 |
| `Shape` | Sine/Square/Saw/Triangle 파형 선택 |

### Trigger — 이벤트 제어

| 노드 | 설명 |
|------|------|
| `On Play` | MetaSound 시작 시 트리거 |
| `On Finished` | 재생 완료 시 트리거 |
| `Trigger Delay` | 지연 후 트리거 |
| `Trigger Repeat` | 주기적 반복 트리거 |

### Random — 랜덤 선택

| 노드 | 설명 |
|------|------|
| `Random Get` | 배열에서 랜덤 선택 |
| `Random Float` | 범위 내 랜덤 float |
| `Random Int` | 범위 내 랜덤 int |
| `Shuffle` | 셔플 재생 (중복 없이 순서 섞기) |

---

## Input/Output 핀 — Blueprint 연동

MetaSound에 Input 핀을 추가하면 Blueprint에서 런타임에 값을 전달할 수 있습니다.

### Input 핀 생성 방법

1. MetaSound 에디터에서 그래프 빈 곳 우클릭
2. `Add Input` → 타입 선택 (Float, Int, Bool, Trigger, Audio)
3. 핀 이름 지정 (예: `"RPM"`, `"IsUnderwater"`)

---

## Blueprint에서 MetaSound 파라미터 변경

```
[엔진 소리 RPM 변경]
→ Get Audio Component
→ Set Float Parameter  (Audio Component 노드)
    In Name: "RPM"
    In Float: 현재 RPM 값

[물속 진입 시]
→ Set Bool Parameter
    In Name: "IsUnderwater"
    In Bool: true

[폭발 트리거]
→ Send Trigger Parameter
    In Name: "Explode"
```

---

## 사운드 디자인 예시

### 발걸음 소리 (표면별 랜덤)

```
On Play Trigger
  → 표면 타입 입력 (Int: 0=풀, 1=콘크리트, 2=금속)
  → Switch on Int
    → 0: Grass 발걸음 배열 → Random Get
    → 1: Concrete 발걸음 배열 → Random Get
    → 2: Metal 발걸음 배열 → Random Get
  → Wave Player
    + Random Float (0.9~1.1) → Pitch Shift (랜덤 피치)
    + Random Float (0.8~1.0) → Volume
```

### 엔진 소리 (RPM 연동)

```
Input: Float "RPM" (0~8000)
  → Map Range (0~8000 → 0.5~2.0) → Pitch Multiplier
  → Map Range (0~8000 → 0.3~1.0) → Volume Multiplier
  → Wave Player (엔진 루프 사운드)
    Pitch * Pitch Multiplier
    Volume * Volume Multiplier
```

### 환경음 (날씨 레이어)

```
Input: Float "RainIntensity" (0~1)
  → Wave Player (빗소리) × RainIntensity → Volume

Input: Float "WindStrength" (0~1)
  → Wave Player (바람 소리) × WindStrength → Volume
  → LFO (0.1Hz) → 바람 미세 볼륨 변동
```

---

## Submix 연동

MetaSound Output을 특정 Submix로 라우팅할 수 있습니다:

1. MetaSound Source 에셋 → Details → `Sound Class`/`Attenuation` 설정
2. Blueprint에서 `Set Submix Send` 또는 `Override Submix Send Level`

---

## 공간음향 (Spatialization)

| 설정 | 설명 |
|------|------|
| `Attenuation Settings` | 거리별 음량 감쇠 커브 |
| `Spatialization` | 좌우/높낮이 방향감 |
| `Occlusion` | 벽/장애물 차폐 효과 |
| `Reverb` | 공간 반향 |
| `Focus` | 카메라 방향 강조 |

---

## 아티스트 체크리스트

### MetaSound 설계 시
- [ ] Wave Player의 SoundWave 에셋이 올바르게 연결되어 있는가?
- [ ] On Play 트리거에서 재생이 시작되는가?
- [ ] Input 핀 이름이 Blueprint 노드의 파라미터 이름과 정확히 일치하는가?

### 랜덤/다양성
- [ ] 발걸음/충격 소리에 랜덤 피치 변조가 적용되어 있는가? (+/- 10%)
- [ ] Shuffle 노드로 동일 사운드 연속 재생을 방지했는가?

### 성능
- [ ] 동시에 재생되는 MetaSound 수가 프로젝트 한도를 초과하지 않는가?
- [ ] 루프 사운드에 불필요하게 복잡한 그래프를 사용하지 않는가?

### Blueprint 연동
- [ ] 런타임 파라미터 변경 시 `Set Float/Bool/Int Parameter` 노드를 사용하는가?
- [ ] 오디오 컴포넌트 레퍼런스가 유효한지 (`IsValid`) 확인 후 파라미터를 설정하는가?

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [04_audio_effects.md](04_audio_effects.md) | Sound Cue vs MetaSound — 오디오 시스템 전반 비교 및 전환 가이드 |
| [09_gameplay_ability_system.md](09_gameplay_ability_system.md) | GAS — Ability 발동 시 MetaSound 파라미터 연동 패턴 |
| [32_niagara_advanced.md](32_niagara_advanced.md) | Niagara Audio — 파티클 이벤트와 MetaSound 트리거 연동 |
| [36_sequencer_advanced.md](36_sequencer_advanced.md) | Sequencer — 시네마틱 구간별 MetaSound 파라미터 키프레임 |
| [21_blueprint_advanced.md](21_blueprint_advanced.md) | Blueprint — MetaSound 파라미터 런타임 변경 패턴 |
| [06_ui_cinematics.md](06_ui_cinematics.md) | UI 이벤트 — 메뉴/컷씬 전환 시 오디오 상태 제어 |
