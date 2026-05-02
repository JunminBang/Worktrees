# 오디오 & 비주얼 이펙트 시스템

> 소스 경로: Runtime/AudioMixer/, Runtime/Engine/Classes/Sound/, Engine/Plugins/FX/Niagara/
> 아티스트를 위한 설명

---

## 오디오 시스템 개요

```
Runtime/AudioMixer/Public/          ← 믹서 & 서브믹스 처리
Runtime/AudioMixerCore/             ← 핵심 믹싱 알고리즘
Runtime/Engine/Classes/Sound/       ← 사운드 에셋 클래스
Runtime/AudioExtensions/Public/     ← 공간 오디오 확장
```

### 전체 구조

```
SoundWave / SoundCue / MetaSound  (에셋)
    ↓
UAudioComponent  (월드에서 재생)
    ↓
AudioBus / Submix  (믹싱 & 라우팅)
    ↓
Master Submix  (최종 출력)
    ↓
스피커/헤드폰
```

---

## 사운드 에셋 종류

### USoundWave — 원본 오디오 파일

```
소스: Engine/Classes/Sound/SoundWave.h
```

- WAV, OGG, FLAC 등을 언리얼이 읽을 수 있는 형태로 저장
- 실시간 디코딩 또는 스트리밍 선택 가능
- **주요 설정 (에디터)**:
  - `Compression Settings` — 플랫폼별 음질/크기 조정
  - `Loading Behavior` — 온디맨드 vs 프리로드
  - `Looping` — 루프 재생
  - `Duration` — 재생 시간

### USoundCue — 사운드 로직 그래프

```
소스: Engine/Classes/Sound/SoundCue.h
```

여러 SoundWave를 조합하는 노드 기반 에디터.

| 노드 | 기능 |
|------|------|
| SoundNodeWavePlayer | 기본 사운드 재생 |
| SoundNodeAttenuation | 거리 기반 감쇠 |
| SoundNodeRandom | 랜덤 사운드 선택 |
| SoundNodeConcatenator | 순차 재생 (대사 등) |
| SoundNodeBranch | 조건부 분기 |
| SoundNodeEnveloper | 음량 엔벨로프 (ADSR) |
| SoundNodeDoppler | 도플러 효과 |
| SoundNodeDelay | 재생 지연 |

### MetaSound — 절차적 오디오 합성

- 노드 기반 신스/이펙트 그래프
- 실시간 파라미터 바인딩 가능
- 게임 상황에 따라 동적으로 소리 생성
- 고급 사용자 권장

### DialogueWave — 대사 관리

```
소스: Engine/Classes/Sound/DialogueWave.h
```

- 다언어 대사 저장
- DialogueVoice (화자 정보)와 연결
- 자막 시스템과 통합

---

## 3D 공간 오디오

### 음성 감쇠 (Sound Attenuation)

```
소스: Engine/Classes/Sound/SoundAttenuation.h
```

거리에 따라 음량을 자동으로 줄이는 시스템.

```
리스너(카메라) ← 거리 → 사운드 위치
  거리 = Min Distance 이내: 최대 음량
  거리 = Max Distance 초과: 무음
  사이: 감쇠 곡선에 따라 보간
```

**감쇠 형태**: Sphere (기본), Box, Cone

### 공간화 (Spatialization)

| 방식 | 특징 |
|------|------|
| Default (Linear Pan) | 표준 스테레오, 저 CPU |
| HRTF | 머리 관련 전달 함수, 현실감 높음, 고 CPU |

### Soundfield (서라운드)

```
소스: Runtime/AudioExtensions/Public/ISoundfieldFormat.h
```

- Ambisonics, 5.1, 7.1 채널 지원
- VR/공간 음향에 사용

---

## 오디오 믹서 & 서브믹스

### 서브믹스 계층

```
Master Submix (최종 출력)
├── Music Submix     (배경 음악)
├── SFX Submix       (효과음)
├── Dialog Submix    (대사)
└── Ambient Submix   (환경음)
```

**클래스**: `USoundSubmix` (Runtime/AudioMixer/Public/AudioMixerSubmix.h)

### 오디오 버스 (Audio Bus)

여러 사운드를 하나의 채널로 모아 일괄 제어.

```
발소리 ─┐
총소리 ─┼→ SFX AudioBus → SFX Submix → Master
폭발음 ─┘
```

**클래스**: `UAudioBus` (Engine/Classes/Sound/AudioBus.h)

### 서브믹스 이펙트

| 이펙트 | 용도 |
|--------|------|
| Reverb | 공간감 (동굴, 홀, 실내) |
| Dynamics Processor | 컴프레서/익스팬더 |
| EQ | 주파수 조정 |

---

## 사운드 에셋 선택 가이드

| 상황 | 사용할 에셋 |
|------|-----------|
| 단순 효과음 (발소리, 클릭) | SoundWave → UAudioComponent |
| 여러 음 조합 (환경음, 무기 소리 변형) | SoundCue |
| 게임 상황별 동적 사운드 | MetaSound |
| 대사 관리 | DialogueWave |
| 배경음악 (대형 파일) | SoundWave (스트리밍 설정) |

---

## 나이아가라 VFX 시스템

```
Engine/Plugins/FX/Niagara/Source/Niagara/Public/
  NiagaraComponent.h    ← 월드에 배치하는 컴포넌트
  NiagaraSystem.h       ← 이펙트 에셋
  NiagaraActor.h        ← 액터 래퍼
  NiagaraEmitter.h      ← 단일 이미터 정의
  NiagaraDataChannel*.h ← 게임 상호작용
```

### 나이아가라 구조

```
UNiagaraSystem (에셋)
├── 이미터 1
│   ├── Spawn Rate     ← 초당 파티클 생성 수
│   ├── Initial Position ← 생성 위치 (구체/박스/원형)
│   ├── Initial Velocity ← 초기 속도
│   ├── Lifetime       ← 수명
│   ├── Update Modules ← 매 프레임 변화 (중력, 충돌)
│   └── Render Module  ← 렌더링 방식
└── 이미터 2, 3...
```

### 렌더러 종류

| 렌더러 | 용도 | 예시 |
|--------|------|------|
| Sprite | 2D 빌보드 | 연기, 불꽃, 마법 |
| Mesh | 3D 메시 파티클 | 파편, 총알 탄흔 |
| Ribbon | 테이프 형태 | 에너지 빔, 번개 |
| Light | 동적 라이트 | 불꽃 빛 |
| Decal | 데칼 | 지면 자국 |

### 데이터 채널 (게임 상호작용)

C++ 또는 Blueprint에서 나이아가라로 게임 데이터 전달:

```
게임: 폭발 위치, 강도 → DataChannel에 쓰기
나이아가라: DataChannel 읽기 → 파티클 개수/크기 조정
```

**관련 클래스**: `UNiagaraDataChannel`, `FNiagaraDataChannelAccessor`

### 성능 최적화

| 기법 | 설명 |
|------|------|
| LOD | 거리에 따라 파티클 수 감소 |
| Scalability | 화질 설정 반영 |
| Fixed Budget | 최대 파티클 수 제한 |
| Component Pool | 자주 쓰는 이펙트 재사용 |

---

## 파티클 시스템 (레거시 Cascade)

```
Engine/Source/Runtime/Engine/Classes/Particles/
  ParticleSystem.h           ← 이펙트 에셋
  ParticleSystemComponent.h  ← 배치 컴포넌트
  ParticleModule.h           ← 모듈 기반 클래스
```

> 새 프로젝트는 Niagara 사용 권장. 레거시 호환성 용도.

### 파티클 모듈 카테고리

```
Spawn/, Location/, Velocity/, Acceleration/,
Color/, Size/, Rotation/, Lifetime/,
Collision/, Event/, Beam/, Trail/, VectorField/
```

---

## 오디오 + VFX 동기화 실전 예제

### 폭발 이펙트

```
게임 코드: Explosion() 호출
  ├─ NiagaraSystem 스폰 (시각 효과 ~2초)
  ├─ SoundCue 재생 (임팩트 + 잔향)
  └─ CameraShake 시작 (선택)
```

---

## 아티스트 체크리스트

```
오디오:
✓ 모든 사운드에 SoundAttenuation 할당 (3D 공간감)
✓ Max Distance 설정 (너무 멀면 들리지 않음)
✓ 효과음 그룹을 SFX Submix로 라우팅
✓ 배경음악을 Music Submix로 라우팅

나이아가라 VFX:
✓ 이미터 Lifetime 설정 (파티클이 영구히 남지 않도록)
✓ 거리별 LOD 설정
✓ Fixed Budget으로 최대 파티클 수 제한
✓ 동적 이펙트는 DataChannel로 게임과 연동
```

---

## 흔한 문제 해결

| 문제 | 원인 | 해결 |
|------|------|------|
| 소리가 왜곡됨 | 여러 사운드 동시 재생으로 음량 초과 | Submix Compression 활성화 |
| 3D 방향감 없음 | Spatialization 미활성화 | SoundAttenuation에서 켜기 |
| 파티클 성능 저하 | 파티클 수 과다 | LOD + Fixed Budget 설정 |
| 이펙트 남아있음 | Lifetime 미설정 | Particle Lifetime 모듈 추가 |
| 나이아가라 메모리 누수 | 컴포넌트 미제거 | Component Pool 사용 |

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [29_metasounds.md](29_metasounds.md) | MetaSound 노드 그래프 — 절차적 오디오 심화 |
| [32_niagara_advanced.md](32_niagara_advanced.md) | Niagara GPU Sim, Ribbon/Beam/Mesh 파티클 심화 |
| [50_physical_material.md](50_physical_material.md) | Physical Material — 표면 타입별 발소리/충격음 분기 |
| [36_sequencer_advanced.md](36_sequencer_advanced.md) | Sequencer 오디오 트랙 — 시네마틱 사운드 동기화 |
| [09_gameplay_ability_system.md](09_gameplay_ability_system.md) | GameplayCue — GAS 이벤트에서 VFX/SFX 연결 |
| [17_camera_system.md](17_camera_system.md) | CameraShake — 폭발/임팩트 시 카메라 진동과 동기화 |
