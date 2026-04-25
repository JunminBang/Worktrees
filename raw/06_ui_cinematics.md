# UI & 시네마틱 시스템

> 소스 경로: Runtime/UMG/, Runtime/MovieScene/, Runtime/LevelSequence/, Runtime/CinematicCamera/
> 아티스트를 위한 설명

---

## UMG (언리얼 모션 그래픽) 개요

```
Runtime/UMG/Public/Components/     ← 84개 위젯 클래스
Runtime/UMG/Public/Blueprint/      ← UserWidget 기반 클래스
Runtime/UMG/Public/Animation/      ← UI 애니메이션 클래스
```

게임 내 모든 UI (메뉴, HUD, 스크린 오버레이)를 만드는 시스템.
Blueprint 기반으로 프로그래머 없이도 아티스트가 제작 가능.

---

## 위젯 종류

### 레이아웃 (Container) 위젯

자식 위젯을 배치하고 정렬하는 컨테이너

| 위젯 | 설명 |
|------|------|
| Canvas Panel | 절대 좌표 기반 자유 배치 (가장 유연) |
| Vertical Box | 세로 자동 정렬 |
| Horizontal Box | 가로 자동 정렬 |
| Grid Panel | 행/열 격자 배치 |
| Overlay | 위젯 레이어 겹치기 |
| Scroll Box | 스크롤 가능 영역 |
| Wrap Box | 화면 넘치면 자동 줄바꿈 |
| Stack Box | 스택 기반 배치 (UE5 최신) |
| Border | 테두리 + 배경 |
| Size Box | 크기 제약 |

### 입력(Interactive) 위젯

| 위젯 | 이벤트 |
|------|--------|
| Button | OnClicked, OnPressed, OnHovered |
| CheckBox | OnCheckStateChanged |
| ComboBoxString | OnSelectionChanged (드롭다운) |
| Slider | OnValueChanged |
| EditableText | OnTextChanged, OnTextCommitted |
| InputKeySelector | OnKeySelected |

### 디스플레이 위젯

| 위젯 | 용도 |
|------|------|
| TextBlock | 텍스트 표시 (점수, 라벨) |
| Image | 아이콘, 배경, 스프라이트 |
| ProgressBar | 체력바, 로딩 진행도 |
| Throbber | 로딩 인디케이터 (원형) |
| Spacer | 간격 조정 (빈 공간) |

### 목록(List) 위젯

| 위젯 | 용도 |
|------|------|
| ListView | 아이템 목록 (선택 지원) |
| TileView | 썸네일 그리드 목록 |
| TreeView | 계층 구조 목록 |
| DynamicEntryBox | 런타임 항목 추가/제거 |

### 기타 유용한 위젯

| 위젯 | 용도 |
|------|------|
| WidgetComponent | 3D 월드에 UI 렌더링 (적 HP바 등) |
| WidgetSwitcher | 여러 패널 중 하나만 표시 |
| BackgroundBlur | 배경 블러 효과 |
| ExpandableArea | 접기/펼치기 영역 |
| InvalidationBox | 정적 UI 성능 최적화 |

---

## HUD vs Widget Blueprint

| 항목 | HUD (레거시) | UserWidget (현대 권장) |
|------|-------------|----------------------|
| 구현 | C++ 전용 | Blueprint 또는 C++ |
| 편집 | 코드만 | 비주얼 에디터 |
| 재사용 | 어려움 | 쉬움 |
| 애니메이션 | 수동 | 내장 애니메이션 에디터 |
| 권장 여부 | 레거시 | ✅ 신규 프로젝트 필수 |

---

## UserWidget 핵심 라이프사이클

```
NativeConstruct()    ← 위젯 생성 시 (초기화)
NativeTick(float)    ← 매 프레임 (실시간 업데이트)
NativeDestruct()     ← 위젯 제거 시 (정리)
```

---

## 애니메이션 위젯

```
소스: Runtime/UMG/Public/Animation/
  WidgetAnimation.h           ← 애니메이션 에셋
  UMGSequencePlayer.h         ← 재생 제어
  WidgetAnimationEvents.h     ← 시작/종료 이벤트
  MovieScene2DTransformTrack.h ← 위치/회전/스케일 트랙
  MovieSceneMarginTrack.h      ← 마진(패딩) 트랙
```

### UI 애니메이션 제작 흐름

```
1. UserWidget 블루프린트 열기
2. Animation 탭 → "+ New Animation"
3. 트랙 추가 (위젯 선택 → Add Track)
   - 2D Transform: 위치, 크기, 회전
   - Margin: 패딩 변화
4. 키프레임 배치 (타임라인)
5. BP에서 PlayAnimation(MyAnim) 호출
```

### 재생 모드

| 모드 | 동작 |
|------|------|
| Play | 처음부터 재생 |
| PlayTo | 지정 시간까지만 |
| Forward | 현재 위치에서 앞으로 |
| Reverse | 현재 위치에서 뒤로 |
| Pause | 일시정지 |

---

## 일반적인 UI 구조 예시

```
Canvas Panel (루트)
├── Image: Background        ← 배경 이미지
├── VerticalBox: HUD
│   ├── ProgressBar: HealthBar ← 체력바
│   └── TextBlock: Score      ← 점수
└── Overlay: Menu             ← 일시정지 메뉴
    ├── Image: MenuBG
    └── VerticalBox: Buttons
        ├── Button: Resume
        ├── Button: Settings
        └── Button: Quit
```

---

## Sequencer (시퀀서) 개요

```
Runtime/MovieScene/Public/          ← MovieScene 핵심 (279개+ 클래스)
Runtime/LevelSequence/Public/       ← LevelSequence 에셋 (20개 클래스)
Editor/Sequencer/Public/            ← 에디터 도구
```

게임 내 컷씬과 카메라 연출을 타임라인으로 제작하는 시스템.
영화 편집 소프트웨어와 유사한 UI.

---

## MovieScene — 타임라인 데이터

```
소스: Runtime/MovieScene/Public/MovieScene.h
```

시퀀서의 모든 데이터 컨테이너.

```
UMovieScene
├── MasterTracks[]          ← 카메라 컷 등 전역 트랙
├── ObjectBindings[]        ← 어떤 액터를 제어할지 바인딩
├── TickResolution          ← 프레임 레이트 (예: 24fps, 30fps)
└── PlaybackRange           ← 재생 시작~끝 범위
```

### 트랙 종류

| 트랙 | 용도 |
|------|------|
| Transform Track | 액터 위치/회전/스케일 키프레임 |
| Camera Cut Track | 카메라 전환 타임라인 |
| Animation Track | 캐릭터 애니메이션 재생 |
| Spawn Track | 액터 스폰/디스폰 시점 |
| Sub Track | 다른 시퀀스 중첩 |
| Event Track | 특정 시점 블루프린트 이벤트 |
| Audio Track | 사운드 재생 |

### Possessable vs Spawnable

| 종류 | 특징 | 사용 |
|------|------|------|
| Possessable | 레벨에 미리 배치된 액터 제어 | 레벨 내 캐릭터 |
| Spawnable | 시퀀서가 런타임에 생성/파괴 | 시네마틱 전용 오브젝트 |

---

## LevelSequence 에셋

```
소스: Runtime/LevelSequence/Public/LevelSequence.h
```

레벨에 배치하고 재생할 수 있는 시퀀스 에셋.

### 런타임 재생 — LevelSequencePlayer

```
소스: Runtime/LevelSequence/Public/LevelSequencePlayer.h
```

| 함수 | 역할 |
|------|------|
| Play() | 재생 시작 |
| Pause() | 일시정지 |
| Stop() | 재생 중지 |
| JumpToFrame(n) | 특정 프레임으로 이동 |

### LevelSequenceActor

레벨에 직접 배치하는 시퀀스 액터.

```
1. 레벨에 LevelSequenceActor 배치
2. Details → Sequence 에셋 선택
3. Auto Play 또는 BP 이벤트로 재생 제어
```

---

## 시네마틱 카메라

```
소스: Runtime/CinematicCamera/Public/CineCameraComponent.h
```

실제 영화 카메라처럼 동작하는 카메라 컴포넌트.

### 주요 설정

| 카테고리 | 속성 | 설명 |
|---------|------|------|
| Filmback | Sensor Size | 필름/센서 크기 (Full Frame, Super 35 등) |
| Lens | Focal Length (mm) | 초점 거리 (28mm=광각, 85mm=망원) |
| Focus | Focus Distance | 초점 거리 (DOF 기준) |
| Focus | Aperture (f/stop) | 조리개 (낮을수록 배경 더 흐림) |

### 카메라 무빙 리그

| 액터 | 용도 |
|------|------|
| CameraRig_Crane | 크레인 카메라 (위에서 아래로) |
| CameraRig_Rail | 레일 카메라 (트래킹 샷) |

---

## 시네마틱 제작 흐름

```
1. LevelSequence 에셋 생성
   콘텐츠 브라우저 → 우클릭 → Level Sequence

2. 액터 바인딩
   Sequencer → "+ Track" → Actor to Possess
   (레벨의 CineCameraActor, 캐릭터 선택)

3. 트랙 추가
   Camera Cut Track: 카메라 전환 타임라인
   Transform Track: 위치/회전 키프레임
   Animation Track: 캐릭터 애니메이션

4. 프레이밍
   Cinematic Viewport로 미리보기
   CineCameraComponent 설정으로 렌즈/포커스 조정

5. 게임 통합
   LevelSequenceActor 레벨에 배치
   또는 BP에서 ULevelSequencePlayer 사용
```

---

## 성능 최적화 팁

### UI

| 문제 | 해결 |
|------|------|
| 복잡한 정적 UI 느림 | `InvalidationBox`로 감싸기 |
| 여러 패널 전환 | `WidgetSwitcher` 사용 |
| 3D 적 HP바 많음 | 거리별 표시/숨김 처리 |
| Canvas 너무 깊음 | 3~4단계 이하로 유지 |

### 시네마틱

| 주의사항 | 이유 |
|---------|------|
| 카메라 전환은 Camera Cut Track만 | 부자연스러운 점프 방지 |
| 라이팅 상태 수동 확인 | 키프레임마다 자동 동기화 안됨 |
| 중요 요소는 안전 영역 내 배치 | 영상 포맷마다 여백 다름 |

---

## 아티스트 체크리스트

```
UI:
✓ Canvas Panel 대신 Anchor 기반 레이아웃 사용 (해상도 대응)
✓ 동적 값 (체력, 점수)은 Variable Binding 연결
✓ 애니메이션은 WidgetAnimation으로 제작
✓ 자주 변경 안 되는 UI 섹션 → InvalidationBox로 감싸기

시네마틱:
✓ 모든 카메라 전환을 Camera Cut Track에서 처리
✓ 캐릭터 Possessable로 바인딩 확인
✓ 시퀀스 프레임레이트 프로젝트와 일치 여부 확인
✓ 배경음악/SFX를 Audio Track으로 동기화
```
