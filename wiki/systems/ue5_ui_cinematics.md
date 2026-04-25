---
name: UE5 UI & 시네마틱 시스템
type: System
tags: unreal-engine, UMG, widget, UI, HUD, sequencer, cinematic, camera, level-sequence
source: raw-ingest
scene_verified: false
last_updated: 2026-04-19
---

# UE5 UI & 시네마틱 시스템

> 소스 경로: Runtime/UMG/, Runtime/MovieScene/, Runtime/LevelSequence/, Runtime/CinematicCamera/
> 🔗 Engine Reference (UE5.7 API 변경): [modules/ui.md](../../docs/engine-reference/unreal/modules/ui.md)

---

## UMG (언리얼 모션 그래픽)

게임 내 모든 UI (메뉴, HUD, 스크린 오버레이)를 만드는 시스템.

**레이아웃 위젯**: Canvas Panel (자유 배치), Vertical/Horizontal Box, Grid Panel, Overlay, Scroll Box

**입력 위젯**: Button (OnClicked/OnPressed/OnHovered), CheckBox, Slider, EditableText

**디스플레이 위젯**: TextBlock (텍스트), Image (아이콘/배경), ProgressBar (체력바)

**성능**: 정적 UI → InvalidationBox로 감싸기. 여러 패널 전환 → WidgetSwitcher.

---

## UserWidget 라이프사이클

```
NativeConstruct()  ← 위젯 생성 시 (초기화)
NativeTick(float)  ← 매 프레임 (실시간 업데이트)
NativeDestruct()   ← 위젯 제거 시 (정리)
```

---

## HUD vs UserWidget

| 항목 | HUD (레거시) | UserWidget (현대 권장) |
|------|-------------|----------------------|
| 구현 | C++ 전용 | Blueprint 또는 C++ |
| 편집 | 코드만 | 비주얼 에디터 |
| 애니메이션 | 수동 | 내장 애니메이션 에디터 |

---

## Sequencer (시네마틱)

게임 내 컷씬과 카메라 연출을 타임라인으로 제작하는 시스템.

**트랙 종류**

| 트랙 | 용도 |
|------|------|
| Transform Track | 액터 위치/회전/스케일 키프레임 |
| Camera Cut Track | 카메라 전환 타임라인 |
| Animation Track | 캐릭터 애니메이션 재생 |
| Spawn Track | 액터 스폰/디스폰 시점 |
| Audio Track | 사운드 재생 |

**Possessable**: 레벨에 미리 배치된 액터 제어.
**Spawnable**: 시퀀서가 런타임에 생성/파괴.

---

## 시네마틱 카메라 (CineCameraComponent)

| 카테고리 | 속성 | 설명 |
|---------|------|------|
| Filmback | Sensor Size | 필름/센서 크기 |
| Lens | Focal Length (mm) | 28mm=광각, 85mm=망원 |
| Focus | Aperture (f/stop) | 낮을수록 배경 더 흐림 |

카메라 무빙 리그: CameraRig_Crane (크레인), CameraRig_Rail (트래킹 샷)

---

## 아티스트 체크리스트

```
UI:
✓ Canvas Panel 대신 Anchor 기반 레이아웃 (해상도 대응)
✓ 동적 값 (체력, 점수)은 Variable Binding 연결
✓ 자주 변경 안 되는 UI 섹션 → InvalidationBox

시네마틱:
✓ 모든 카메라 전환을 Camera Cut Track에서 처리
✓ 시퀀스 프레임레이트 프로젝트와 일치 확인
✓ 배경음악/SFX를 Audio Track으로 동기화
```

---

## 관련 페이지
- [UE5 전체 개요](ue5_overview.md)
- [오디오 & VFX 시스템](ue5_audio_vfx.md)
- [애니메이션 & 물리 시스템](ue5_animation_physics.md)
- [게임플레이 프레임워크](ue5_gameplay_framework.md)
