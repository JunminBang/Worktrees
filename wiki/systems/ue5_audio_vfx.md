---
name: UE5 오디오 & VFX 시스템
type: System
tags: unreal-engine, audio, sound, metasound, niagara, vfx, particles, submix
source: raw-ingest
scene_verified: false
last_updated: 2026-04-19
---

# UE5 오디오 & VFX 시스템

> 소스 경로: Runtime/AudioMixer/, Runtime/Engine/Classes/Sound/, Engine/Plugins/FX/Niagara/
> 🔗 Engine Reference (UE5.7 API 변경): [modules/audio.md](../../docs/engine-reference/unreal/modules/audio.md)

---

## 오디오 흐름

```
SoundWave / SoundCue / MetaSound (에셋)
  → UAudioComponent (월드에서 재생)
  → AudioBus / Submix (믹싱 & 라우팅)
  → Master Submix (최종 출력)
  → 스피커/헤드폰
```

---

## 사운드 에셋 종류

| 에셋 | 용도 |
|------|------|
| SoundWave | 원본 오디오 파일 (WAV/OGG) |
| SoundCue | 여러 SoundWave 조합 노드 그래프 |
| MetaSound | 절차적 오디오 합성 (실시간 파라미터) |
| DialogueWave | 다언어 대사 관리 |

**선택 가이드**
- 단순 효과음 → SoundWave
- 여러 음 조합 → SoundCue
- 동적 사운드 → MetaSound
- 대사 관리 → DialogueWave
- 배경음악 (대형 파일) → SoundWave (스트리밍 설정)

---

## 서브믹스 계층

```
Master Submix (최종 출력)
├── Music Submix     (배경 음악)
├── SFX Submix       (효과음)
├── Dialog Submix    (대사)
└── Ambient Submix   (환경음)
```

---

## 3D 공간 오디오

음성 감쇠: 거리에 따라 음량 자동 감소 (Min~Max Distance).
공간화: Default (스테레오) vs HRTF (머리 관련 전달 함수, 현실감 높음, 고 CPU).

---

## 나이아가라 VFX 시스템

```
UNiagaraSystem (에셋)
└── 이미터
    ├── Spawn Rate     ← 초당 파티클 생성 수
    ├── Initial Position, Velocity, Lifetime
    ├── Update Modules ← 매 프레임 변화 (중력, 충돌)
    └── Render Module  ← 렌더링 방식
```

**렌더러 종류**

| 렌더러 | 용도 |
|--------|------|
| Sprite | 2D 빌보드 (연기, 불꽃, 마법) |
| Mesh | 3D 메시 파티클 (파편) |
| Ribbon | 테이프 형태 (에너지 빔, 번개) |
| Light | 동적 라이트 (불꽃 빛) |
| Decal | 데칼 (지면 자국) |

**성능**: LOD + Fixed Budget + Component Pool 필수.

---

## 흔한 문제 해결

| 문제 | 원인 | 해결 |
|------|------|------|
| 소리가 왜곡됨 | 여러 사운드 동시 재생 | Submix Compression 활성화 |
| 3D 방향감 없음 | Spatialization 미활성화 | SoundAttenuation에서 켜기 |
| 파티클 성능 저하 | 파티클 수 과다 | LOD + Fixed Budget 설정 |
| 나이아가라 메모리 누수 | 컴포넌트 미제거 | Component Pool 사용 |

---

## 관련 페이지
- [UE5 전체 개요](ue5_overview.md)
- [UI & 시네마틱 시스템](ue5_ui_cinematics.md)
- [UE5 렌더링 & 셰이더 시스템](ue5_rendering_shader.md)
