# 언리얼 엔진 5.7 — 아티스트 레퍼런스 인덱스

> 소스 기반: C:/Program Files/Epic Games/UE_5.7/Engine/Source/
> 대상 독자: 게임 아티스트 (비프로그래머)
> 마지막 업데이트: 2026-04-24

---

## 문서 목록

| # | 파일 | 다루는 내용 |
|---|------|-----------|
| 00 | [00_overview.md](00_overview.md) | 엔진 전체 구조, 시스템 지도, 아티스트 치트시트 |
| 01 | [01_gameplay_framework.md](01_gameplay_framework.md) | 액터/폰/캐릭터 계층, GameMode/PlayerController, Enhanced Input |
| 02 | [02_rendering.md](02_rendering.md) | 렌더링 파이프라인, 셰이더, Lumen, Nanite, 포스트 프로세싱 |
| 03 | [03_animation_physics.md](03_animation_physics.md) | 애니메이션 시스템, IK, State Machine, Chaos 물리, 클로스 |
| 04 | [04_audio_effects.md](04_audio_effects.md) | 사운드 에셋, Submix, Niagara VFX, 레거시 Cascade |
| 05 | [05_ai_navigation.md](05_ai_navigation.md) | AIController, Behavior Tree, EQS, AI Perception, NavMesh |
| 06 | [06_ui_cinematics.md](06_ui_cinematics.md) | UMG 위젯, Sequencer, LevelSequence, 시네마틱 카메라 |
| 07 | [07_world_network_assets.md](07_world_network_assets.md) | World/Level 구조, World Partition, Landscape, Foliage, 에셋 관리 |
| 08 | [08_editor_systems.md](08_editor_systems.md) | 143개 에디터 모듈 목록, 핵심 에디터 상세, 단축키 |
| 09 | [09_gameplay_ability_system.md](09_gameplay_ability_system.md) | GAS 구조, AbilitySystemComponent, GameplayEffect, Attribute |
| 10 | [10_chaos_destruction.md](10_chaos_destruction.md) | Chaos 파괴 물리, GeometryCollection, Fracture 설정 |
| 11 | [11_pcg_procedural.md](11_pcg_procedural.md) | PCG 절차적 콘텐츠 생성, 노드 그래프, 자동 배치 |
| 12 | [12_groom_hair.md](12_groom_hair.md) | Groom 머리카락/털 시스템, Alembic 임포트, 렌더링 모드 |
| 13 | [13_online_multiplayer.md](13_online_multiplayer.md) | 온라인 서브시스템, 세션 관리, EOS/Steam 플러그인 |
| 14 | [14_textures_advanced.md](14_textures_advanced.md) | Virtual Texture, RVT, RenderTarget, 텍스처 압축/스트리밍 |
| 15 | [15_control_rig.md](15_control_rig.md) | Control Rig, 절차적 리깅, Full Body IK, 애니메이션 BP 연결 |
| 16 | [16_data_management.md](16_data_management.md) | Gameplay Tags, DataAsset, DataTable, CurveTable |
| 17 | [17_camera_system.md](17_camera_system.md) | SpringArm, PlayerCameraManager, CameraShake, FOV/NearClip |
| 18 | [18_save_load.md](18_save_load.md) | USaveGame, 슬롯 관리, 비동기 저장, GameInstance 캐싱 |
| 19 | [19_decals.md](19_decals.md) | DecalComponent, Deferred/DBuffer 블렌드 모드, Fade, 스폰 패턴 |
| 20 | [20_ray_tracing.md](20_ray_tracing.md) | RT Shadows/Reflections/GI, Lumen vs HW RT, Path Tracing, TSR |
| 21 | [21_blueprint_advanced.md](21_blueprint_advanced.md) | 함수 라이브러리, Interface, Cast, Event Dispatcher, Timeline |
| 22 | [22_plugins.md](22_plugins.md) | 플러그인 구조, .uplugin 포맷, 역할별 주요 플러그인 목록 |
| 23 | [23_water_volumes.md](23_water_volumes.md) | WaterBody, Gerstner Wave, 부력, PostProcessVolume, 볼륨 액터 |
| 24 | [24_material_advanced.md](24_material_advanced.md) | Material Instance, MID, Material Function/Layer, MPC |
| 25 | [25_lighting_system.md](25_lighting_system.md) | 광원 5종, 공통 속성, Sky Atmosphere, 라이트 채널 |
| 26 | [26_skeletal_mesh_lod.md](26_skeletal_mesh_lod.md) | 스켈레탈 메시 LOD, Morph Target, ChaosCloth |
| 27 | [27_mass_entity.md](27_mass_entity.md) | Mass Entity ECS, 군중 시뮬레이션, ZoneGraph |
| 28 | [28_motion_warping.md](28_motion_warping.md) | Motion Warping, Warp Target, Root Motion Modifier |
| 29 | [29_metasounds.md](29_metasounds.md) | MetaSound 노드 그래프, 절차적 오디오, Blueprint 연동 |
| 30 | [30_geometry_script.md](30_geometry_script.md) | Geometry Script, 절차적 메시 생성, Boolean 연산 |
| 31 | [31_level_instance.md](31_level_instance.md) | Level Instance, Packed Level Actor, 모듈형 레벨 워크플로우 |
| 32 | [32_niagara_advanced.md](32_niagara_advanced.md) | Niagara GPU Sim, Data Interface, Ribbon/Beam/Mesh 파티클 |
| 35 | [35_landscape_advanced.md](35_landscape_advanced.md) | 랜드스케이프 레이어, 페인팅, 스컬프트, LOD, RVT 연동 |
| 36 | [36_sequencer_advanced.md](36_sequencer_advanced.md) | Sequencer 트랙, CineCameraActor, DOF, Movie Render Queue |
| 39 | [39_volumetric_clouds.md](39_volumetric_clouds.md) | 볼류메트릭 구름, Exponential Height Fog, 빛줄기, Sky 연동 |
| 40 | [40_world_partition.md](40_world_partition.md) | World Partition, HLOD, Data Layer, 스트리밍 그리드 |
| 42 | [42_staticmesh_advanced.md](42_staticmesh_advanced.md) | Nanite 설정, LOD, Lightmap UV, 소켓, 콜리전 복잡도 |
| 43 | [43_foliage_system.md](43_foliage_system.md) | Foliage Tool, ISM 인스턴싱, 배치 규칙, Landscape 레이어 연동 |
| 44 | [44_character_movement.md](44_character_movement.md) | CharacterMovementComponent, 점프/수영/비행, 래그돌 전환 |
| 45 | [45_physics_ragdoll.md](45_physics_ragdoll.md) | Physics Asset, 래그돌, Constraint, 부분 물리, Hit Reaction |
| 47 | [47_socket_system.md](47_socket_system.md) | 소켓 생성, 무기 부착, AttachToComponent, AnimNotify 연동 |
| 48 | [48_collision_trace.md](48_collision_trace.md) | Collision Preset, 채널, Line/Shape Trace, Hit Result, Overlap |
| 50 | [50_physical_material.md](50_physical_material.md) | Physical Material, Surface Type, 발걸음/총탄 충격 반응 연동 |
| 53 | [53_profiling_optimization.md](53_profiling_optimization.md) | stat 명령어, 드로우콜 최적화, Unreal Insights, Blueprint 최적화 |

---

## 빠른 참조 — "이걸 하고 싶다면?"

| 작업 | 관련 문서 |
|------|---------|
| 캐릭터를 레벨에 배치하고 싶다 | 01, 08 |
| 머티리얼/셰이더 만들고 싶다 | 02, 08 |
| 캐릭터 애니메이션 설정하고 싶다 | 03, 15 |
| 이펙트/파티클 만들고 싶다 | 04 |
| 사운드 배치하고 싶다 | 04 |
| AI 적 캐릭터 배치하고 싶다 | 05 |
| UI/HUD 만들고 싶다 | 06 |
| 컷씬/카메라 연출하고 싶다 | 06 |
| 오픈 월드 지형/식생 배치 | 07, 11 |
| 멀티플레이 게임 작업 | 07, 13 |
| 능력치/스킬 시스템 설정 | 09 |
| 오브젝트 파괴 이펙트 | 10 |
| 자동 오브젝트 배치 (나무, 돌 등) | 11 |
| 캐릭터 머리카락 설정 | 12 |
| 리깅/IK 설정 | 03, 15 |
| 데이터 테이블로 스탯 관리 | 16 |
| 게임플레이 태그 관리 | 16 |
| 텍스처 Virtual Streaming 설정 | 14 |
| 랜드스케이프 블렌딩 최적화 | 14 |
| 카메라 흔들림(CameraShake) 추가 | 17 |
| 3인칭 카메라 스프링 암 설정 | 17 |
| 게임 세이브/로드 구현 | 18 |
| 총탄 자국·데칼 스폰 | 19 |
| 레이 트레이싱/Path Tracing | 20 |
| 이벤트 디스패처 연결 | 21 |
| Blueprint 인터페이스 사용 | 21 |
| 플러그인 활성화 방법 | 22 |
| 강/호수/바다 물 배치 | 23 |
| 용암·독 피해 구역 설정 | 23 |
| 화면 후처리(블룸·DOF) 설정 | 23 |
| Material Instance 파라미터 변경 | 24 |
| 런타임 머티리얼 색상 변경 (MID) | 24 |
| 전역 바람/환경 파라미터 제어 (MPC) | 24 |
| 조명 배치 (Directional/Point/Spot/Rect/Sky) | 25 |
| IES 프로파일 조명 설정 | 25 |
| 라이트 채널로 조명 분리 | 25 |
| 스켈레탈 메시 LOD 설정 | 26 |
| 얼굴 표정 Morph Target 설정 | 26 |
| 옷/망토 헝겊 시뮬레이션 | 26 |
| 수천 명 군중 배치 | 27 |
| 애니메이션 위치 자동 보정 (오르기/처형) | 28 |
| 절차적 사운드 디자인 | 29 |
| Blueprint로 메시 생성/변형 | 30 |
| 레벨 프리팹 재사용 (모듈형 건물) | 31 |
| 파티클 대량 스폰 (GPU Sim) | 32 |
| 리본/빔 파티클 (칼 궤적, 번개) | 32 |
| 지형 레이어 페인팅 | 35 |
| 랜드스케이프 머티리얼 설정 | 35 |
| 시네마틱/컷씬 제작 | 36 |
| 영화 카메라 DOF/아웃포커스 | 36 |
| Movie Render Queue 고품질 출력 | 36 |
| 하늘 구름 배치 | 39 |
| 지표면 안개/빛줄기 설정 | 39 |
| 오픈 월드 스트리밍 구성 | 40 |
| Data Layer로 낮/밤 전환 | 40 |
| 스태틱 메시 Lightmap UV | 42 |
| Nanite 활성화 설정 | 42 |
| 나무/풀/바위 대량 배치 | 43 |
| 캐릭터 이동 속도/점프 조정 | 44 |
| 더블 점프 구현 | 44 |
| 래그돌 사망 구현 | 45 |
| 총격 히트 리액션 | 45 |
| 무기 손에 부착 | 47 |
| 총구 이펙트 소켓 설정 | 47 |
| 총기 레이캐스트 구현 | 48 |
| 근접 공격 판정 범위 | 48 |
| 표면별 발걸음 소리 | 50 |
| 총탄 충격 파티클/데칼 분기 | 50 |
| FPS 병목 찾기 | 53 |
| 드로우콜 줄이기 | 53 |

---

## 시스템 의존성 다이어그램

```
[캐릭터 등장]
  ├─ Gameplay Framework (01) ← 액터/폰/캐릭터 기본
  ├─ Animation System (03)   ← 애니메이션 재생
  ├─ Control Rig (15)        ← IK/절차적 리깅
  └─ GAS (09)                ← 능력/효과 처리

[월드 구성]
  ├─ World/Level (07)        ← 씬 관리
  ├─ Landscape (07)          ← 지형
  ├─ PCG (11)                ← 자동 오브젝트 배치
  └─ Foliage (07)            ← 식생

[비주얼]
  ├─ Rendering (02)          ← Lumen/Nanite/셰이더
  ├─ Textures (14)           ← 텍스처/VT/RVT
  ├─ Niagara VFX (04)        ← 파티클 이펙트
  ├─ Groom (12)              ← 머리카락
  └─ Chaos Destruction (10)  ← 파괴 이펙트

[사운드]
  └─ Audio System (04)       ← 사운드/믹싱

[게임플레이]
  ├─ AI (05)                 ← 적 AI
  ├─ UI (06)                 ← HUD/메뉴
  ├─ Cinematics (06)         ← 컷씬
  ├─ Online (13)             ← 멀티플레이
  └─ Data (16)               ← 게임 데이터

[에디터 도구]
  └─ Editor Systems (08)     ← 143개 에디터 모듈
```

---

## UE5.7 주요 신기능 요약

| 기능 | 문서 | 설명 |
|------|------|------|
| Nanite | 02 | 버추얼 지오메트리 — 폴리곤 수 제한 사실상 없음 |
| Lumen | 02 | 실시간 글로벌 일루미네이션 |
| World Partition | 07 | 자동 스트리밍 오픈 월드 |
| PCG | 11 | 절차적 콘텐츠 생성 그래프 |
| Chaos | 03, 10 | 차세대 물리 엔진 (파괴 포함) |
| Control Rig | 15 | 에디터 내 절차적 리깅 |
| Groom | 12 | 실사 수준 머리카락/털 렌더링 |
| MetaSound | 04 | 절차적 오디오 합성 시스템 |
| GAS | 09 | 확장 가능한 게임플레이 능력 프레임워크 |
| RVT | 14 | 런타임 버추얼 텍스처 — 지형 블렌딩 최적화 |
| Modular Rig | 15 | 모듈 조립식 캐릭터 리그 시스템 |
