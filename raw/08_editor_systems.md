# 에디터 시스템

> 소스 경로: Editor/ (143개 모듈)
> 아티스트를 위한 설명

---

## 에디터 전체 구조

```
Editor/
├── UnrealEd/           ← 핵심 에디터 엔진 (GEditor, EditorDelegates)
├── EditorFramework/    ← 탭/툴바/메뉴 인프라
├── LevelEditor/        ← 레벨 뷰포트 & 월드 편집
├── ContentBrowser/     ← 에셋 관리 & 브라우징
├── BlueprintGraph/     ← 블루프린트 그래프 시스템
├── MaterialEditor/     ← 머티리얼 노드 편집기
├── AnimationEditor/    ← 애니메이션 에디터
├── StaticMeshEditor/   ← 스태틱 메시 편집기
├── SkeletalMeshEditor/ ← 스켈레탈 메시 편집기
├── Sequencer/          ← 시네마틱 타임라인
└── [80개+ 특화 에디터]
```

---

## 발견된 전체 에디터 모듈 목록

```
AIGraph, ActionableMessage, ActorPickerMode, AddContentDialog,
AdvancedPreviewScene, AnimGraph, AnimationBlueprintEditor,
AnimationEditor, AnimationEditorWidgets, AnimationModifiers,
AssetDefinition, AssetTagsEditor, AudioEditor, BehaviorTreeEditor,
BlueprintEditorLibrary, BlueprintGraph, Blutility,
ClassViewer, ClothPainter, ClothingSystemEditor,
ComponentVisualizers, ContentBrowser, ContentBrowserData,
CurveAssetEditor, CurveEditor, CurveTableEditor,
DataLayerEditor, DataTableEditor, DetailCustomizations,
DerivedDataEditor, Documentation, EditorConfig,
EditorFramework, EditorStyle, EditorSubsystem,
EditorWidgets, FoliageEdit, FontEditor,
GeometryCollectionEditor, GeometryMode,
GraphEditor, InputBindingEditor, IntroTutorials,
Kismet, KismetCompiler, KismetWidgets,
LandscapeEditor, LevelEditor, LevelSequenceEditor,
LightmassEditor, LocalizationDashboard, MaterialEditor,
MeshEditor, MeshPaint, MovieSceneTools,
NiagaraEditor, PackagesDialog, PhysicsAssetEditor,
PhysicsEditor, PropertyEditor, SceneOutliner,
Sequencer, SequenceRecorder, SkeletalMeshEditor,
SoundCueEditor, StaticMeshEditor, StringTableEditor,
SubobjectEditor, Subsystem, TextureEditor,
TranslationEditor, UATHelper, UMGEditor,
UnrealEd, VirtualTexturingEditor, WorldBrowser,
WorldPartitionEditor, ... (143개 총)
```

---

## 핵심 에디터 상세 설명

### 1. UnrealEd — 에디터 핵심

```
소스: Editor/UnrealEd/
  Public/Editor.h         ← GEditor 전역 포인터
  Public/EditorEngine.h   ← UEditorEngine 클래스
```

- 모든 에디터 기능의 기반
- 맵 로드/저장, Undo/Redo, 에셋 임포트
- `FEditorDelegates`: 맵 변경, 모드 변경, PIE 시작/종료 이벤트

---

### 2. LevelEditor — 레벨 편집

```
소스: Editor/LevelEditor/Public/
  ILevelEditor.h    ← 에디터 인터페이스
  SLevelViewport.h  ← 3D 뷰포트 위젯
```

**아티스트 주요 기능**

| 기능 | 설명 |
|------|------|
| 3D 뷰포트 | Perspective/Top/Front/Side 뷰 |
| 액터 배치 | 에셋 드래그 앤 드롭으로 스폰 |
| 트랜스폼 | W(위치) E(회전) R(스케일) |
| 아웃라이너 | 씬 계층 구조, 가시성/잠금 토글 |
| Details 패널 | 선택 액터 속성 조정 |

---

### 3. ContentBrowser — 에셋 관리

```
소스: Editor/ContentBrowser/Public/
  IContentBrowserSingleton.h  ← 싱글톤 인터페이스
  SAssetView.h                ← 에셋 뷰 위젯
```

**아티스트 주요 기능**

| 기능 | 단축키/방법 |
|------|-----------|
| 에셋 검색 | Ctrl+F |
| 타입별 필터 | 필터 버튼 (메시/텍스처/머티리얼 등) |
| 레벨에 배치 | 에셋 → 뷰포트 드래그 |
| 썸네일 크기 | 우하단 슬라이더 |
| 컬렉션 만들기 | 자주 쓰는 에셋 그룹화 |

**뷰 모드**: List / Tile / Column

---

### 4. BlueprintGraph — 블루프린트 에디터

```
소스: Editor/BlueprintGraph/Public/
  BlueprintActionDatabase.h  ← 사용 가능한 노드 목록
  BlueprintNodeSpawner.h     ← 노드 생성
```

**아티스트 관점**

- 노드 기반 시각 프로그래밍
- 드래그 앤 드롭으로 게임 로직 구성
- C++ 함수를 블루프린트 노드로 노출 가능
- 저장 시 자동 컴파일 (Kismet Compiler)

**주요 관련 에디터**

| 에디터 | 용도 |
|--------|------|
| AnimationBlueprintEditor | AnimBP 그래프 편집 |
| BehaviorTreeEditor | AI 행동 트리 편집 |
| NiagaraEditor | VFX 이미터 그래프 |
| UMGEditor | UI 위젯 블루프린트 |

---

### 5. MaterialEditor — 머티리얼 편집기

```
소스: Editor/MaterialEditor/Public/
  IMaterialEditor.h          ← 에디터 인터페이스
  MaterialEditingLibrary.h   ← 편집 유틸리티
```

**핵심 기능 (IMaterialEditor)**

| 함수 | 역할 |
|------|------|
| CreateNewMaterialExpression() | 새 노드 추가 |
| DeleteSelectedNodes() | 선택 노드 삭제 |
| ForceRefreshExpressionPreviews() | 프리뷰 갱신 |
| JumpToExpression() | 특정 노드로 이동 |

**아티스트 작업 흐름**

```
1. 노드 그래프로 셰이더 로직 구성
2. 실시간 3D 프리뷰 확인
3. 파라미터 노드로 인스턴스에서 수정 가능하게
4. Material Function으로 재사용 가능한 서브그래프 패키징
```

---

### 6. AnimationEditor — 애니메이션 편집기

```
소스: Editor/AnimationEditor/Public/
  IAnimationEditor.h       ← 에디터 인터페이스
  IAnimationEditorModule.h ← 모듈 인터페이스
```

**Persona 통합 에디터 (AnimationEditor + SkeletalMeshEditor 공유)**

| 탭 | 기능 |
|----|------|
| Skeleton Tree | 뼈 계층 구조 확인/편집 |
| Asset Details | 시퀀스/Montage 속성 |
| Anim Notifies | 프레임 타이밍 이벤트 설정 |
| Curves | 파라미터 커브 편집 |
| Preview Scene | 3D 프리뷰 |

---

### 7. StaticMeshEditor — 스태틱 메시 편집기

```
소스: Editor/StaticMeshEditor/Public/
  IStaticMeshEditor.h           ← 에디터 인터페이스
  StaticMeshEditorSubsystem.h   ← 서브시스템
```

**아티스트 주요 기능**

| 기능 | 설명 |
|------|------|
| LOD 설정 | 거리별 디테일 레벨 구성 |
| 콜리전 | 물리 충돌 형태 설정/시각화 |
| UV 미리보기 | 라이트맵 UV 검증 |
| 소켓 | 무기/부착물 소켓 위치 설정 |
| 머티리얼 | 섹션별 머티리얼 슬롯 |

---

### 8. SkeletalMeshEditor — 스켈레탈 메시 편집기

```
소스: Editor/SkeletalMeshEditor/Public/
  ISkeletalMeshEditor.h            ← 에디터 인터페이스
  SkeletalMeshEditorSubsystem.h    ← 서브시스템
```

**FPersonaAssetEditorToolkit 기반** (애니메이션 에디터와 공유)

**아티스트 주요 기능**

| 기능 | 설명 |
|------|------|
| 리깅 확인 | 뼈와 메시 바인딩 검증 |
| 모르프 타겟 | 얼굴 표정 등 버텍스 변형 |
| Physics Asset | 래그돌 충돌/관절 설정 |
| 소켓 | 부착 포인트 배치 |
| LOD | 거리별 폴리곤 수 관리 |

---

### 9. Sequencer — 시네마틱 타임라인 에디터

```
소스: Editor/Sequencer/Public/
  ISequencer.h                    ← 메인 인터페이스
  ISequencerModule.h              ← 모듈
  ISequencerTrackEditor.h         ← 트랙 에디터 기반
  SequencerCommands.h             ← 단축키/커맨드
```

**아티스트 주요 기능**

| 기능 | 설명 |
|------|------|
| 타임라인 편집 | 프레임 단위 키프레임 |
| 다중 트랙 | 카메라/캐릭터/라이트 동시 |
| 섹션 블렌드 | 클립 간 부드러운 전환 |
| 렌더링 | 시네마 품질 영상 내보내기 |
| MVVM 구조 | Model-View-ViewModel 기반 |

---

## 아티스트 에디터 사용 우선순위

### 1순위 — 매일 사용

| 에디터 | 주 작업 |
|--------|---------|
| **레벨 에디터** | 월드 구축, 액터 배치, 조명 |
| **콘텐츠 브라우저** | 에셋 관리, 검색, 배치 |
| **머티리얼 에디터** | 표면 외형 제작 |
| **스태틱 메시 에디터** | 메시 임포트, LOD, 콜리전 |

### 2순위 — 특화 작업

| 에디터 | 주 작업 |
|--------|---------|
| **스켈레탈 메시 에디터** | 캐릭터 리깅 검증 |
| **애니메이션 에디터** | 시퀀스, State Machine, Montage |
| **Sequencer** | 컷씬 및 카메라 연출 |
| **블루프린트 에디터** | 간단한 게임 이벤트 로직 |

### 3순위 — 보조 도구

| 에디터/패널 | 용도 |
|------------|------|
| Niagara 에디터 | VFX 이펙트 |
| Sound Cue 에디터 | 사운드 로직 |
| Landscape 에디터 | 지형 스컬팅 |
| Foliage 에디터 | 나무/식생 배치 |
| UMG 에디터 | UI 위젯 |

---

## 에디터 아키텍처 패턴

| 패턴 | 설명 |
|------|------|
| 모듈 기반 | 모든 에디터는 `IModuleInterface` 상속 |
| FWorkflowCentricApplication | 탭 기반 멀티 모드 에디터 기반 클래스 |
| AssetEditorToolkit | 에셋 편집 에디터 기반 클래스 |
| Slate UI | 모든 에디터 UI가 Slate 프레임워크로 구현 |
| Undo/Redo | FTransaction으로 모든 변경 추적 |

---

## 유용한 에디터 단축키

| 단축키 | 기능 |
|--------|------|
| W / E / R | 이동 / 회전 / 스케일 |
| F | 선택 액터로 포커스 |
| G | 게임 뷰 토글 |
| Ctrl+Z / Y | Undo / Redo |
| Ctrl+D | 복제 |
| Alt+드래그 | 복제 이동 |
| P | NavMesh 시각화 토글 |
| Ctrl+F | 콘텐츠 브라우저 검색 |
| Ctrl+P | 에셋 빠른 열기 |
| Shift+F1 | 마우스 커서 해제 (PIE 중) |

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [22_plugins.md](22_plugins.md) | 플러그인 — 에디터 전용 모듈 및 Editor Utility Widget 확장 |
| [36_sequencer_advanced.md](36_sequencer_advanced.md) | Sequencer 에디터 — 시네마틱 타임라인 편집기 심화 |
| [15_control_rig.md](15_control_rig.md) | Control Rig 에디터 — Persona 기반 리깅 편집기 |
| [24_material_advanced.md](24_material_advanced.md) | 머티리얼 에디터 — Material Function·Instance 작업 흐름 |
| [21_blueprint_advanced.md](21_blueprint_advanced.md) | 블루프린트 에디터 — Graph 편집·Compiler 패턴 |
| [02_rendering.md](02_rendering.md) | 렌더링 — 에디터 뷰포트 모드(Lit/Unlit/Complexity) 활용 |
