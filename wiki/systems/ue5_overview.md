---
name: UE5.7 소스코드 전체 개요
type: System
tags: unreal-engine, ue5, source-structure, runtime, editor, overview
source: raw-ingest
scene_verified: false
last_updated: 2026-04-19
---

# UE5.7 소스코드 전체 개요 (아티스트용)

> 소스 경로: C:/Program Files/Epic Games/UE_5.7/Engine/Source/

---

## 엔진 구조

```
Engine/Source/
├── Runtime/   ← 게임 실행 시 동작하는 핵심 시스템 (188개 모듈)
├── Editor/    ← 에디터 전용 기능 (143개 모듈)
├── Developer/ ← 빌드·툴 관련
├── Programs/  ← 독립 실행 프로그램 (UnrealBuildTool 등)
└── ThirdParty/← 외부 라이브러리
```

---

## 전체 흐름

```
플레이어 입력 → InputCore → PlayerController → Character
→ Physics (충돌·중력) ←→ AI (적 행동)
→ Animation (뼈대 움직임)
→ Renderer (화면에 그리기)
→ PostProcessing (영상 효과)
→ AudioMixer (소리 재생)
→ 최종 화면 + 소리
```

---

## 주요 시스템 목록

| 시스템 | 소스 경로 | 역할 |
|--------|-----------|------|
| 게임플레이 뼈대 | Runtime/Engine/Classes/GameFramework/ | Actor/Pawn/Character/Controller |
| 렌더링 | Runtime/Renderer/, Runtime/RenderCore/ | 3D → 화면 픽셀 변환 |
| 물리 | Runtime/PhysicsCore/, Runtime/Engine/ | 충돌·중력·파괴 |
| 애니메이션 | Runtime/AnimGraphRuntime/, Runtime/AnimationCore/ | 뼈대 애니메이션 |
| 오디오 | Runtime/AudioMixer/, Runtime/AudioMixerCore/ | 소리 믹싱·3D 공간음 |
| AI | Runtime/AIModule/, Runtime/NavigationSystem/ | 적 행동·길찾기 |
| 입력 | Runtime/InputCore/ | 키보드·패드 매핑 |
| UI | Runtime/UMG/ | 메뉴·HUD |
| 네트워크 | Runtime/Net/ | 멀티플레이어 동기화 |
| 레벨 관리 | Runtime/Engine/ (World/Level) | 3D 공간 관리 |
| 이펙트 | Runtime/Niagara/, Runtime/Particles/ | 파티클·VFX |
| 에셋 관리 | Runtime/AssetRegistry/ | 파일 로드·언로드 |
| 시네마틱 | Runtime/LevelSequence/, Runtime/MovieScene/ | 컷씬·카메라 연출 |
| 에디터 | Editor/UnrealEd/ | 에디터 UI 전체 |

---

## 아티스트 관점 매핑

| 에디터에서 하는 것 | 동작하는 엔진 시스템 |
|-------------------|---------------------|
| 머티리얼 만들기 | Renderer + Shader |
| 애니메이션 블렌딩 설정 | AnimGraphRuntime |
| 나이아가라 이펙트 | Niagara |
| 지형 스컬팅 | Landscape |
| 사운드 큐 설정 | AudioMixer |
| Blueprint 노드 연결 | Kismet Compiler |
| 컷씬 제작 | Sequencer |
| 라이트맵 굽기 | Lightmass |

---

## 관련 페이지
- [게임플레이 프레임워크](ue5_gameplay_framework.md)
- [렌더링 & 셰이더](ue5_rendering_shader.md)
- [애니메이션 & 물리](ue5_animation_physics.md)
- [오디오 & VFX](ue5_audio_vfx.md)
- [AI & 내비게이션](ue5_ai_navigation.md)
- [UI & 시네마틱](ue5_ui_cinematics.md)
- [월드 & 네트워크 & 에셋](ue5_world_network.md)
- [에디터 시스템](ue5_editor.md)
