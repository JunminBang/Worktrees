---
name: UE5 에디터 시스템
type: System
tags: unreal-engine, editor, content-browser, blueprint, material-editor, sequencer, static-mesh-editor
source: raw-ingest
scene_verified: false
last_updated: 2026-04-19
---

# UE5 에디터 시스템

> 소스 경로: Editor/ (143개 모듈)

---

## 에디터 구조

```
Editor/
├── UnrealEd/           ← 핵심 에디터 엔진 (GEditor, EditorDelegates)
├── LevelEditor/        ← 레벨 뷰포트 & 월드 편집
├── ContentBrowser/     ← 에셋 관리 & 브라우징
├── BlueprintGraph/     ← 블루프린트 그래프 시스템
├── MaterialEditor/     ← 머티리얼 노드 편집기
├── AnimationEditor/    ← 애니메이션 에디터
├── StaticMeshEditor/   ← 스태틱 메시 편집기
├── SkeletalMeshEditor/ ← 스켈레탈 메시 편집기
└── Sequencer/          ← 시네마틱 타임라인
```

---

## 아티스트 에디터 사용 우선순위

### 1순위 — 매일 사용

| 에디터 | 주 작업 |
|--------|---------|
| 레벨 에디터 | 월드 구축, 액터 배치, 조명 |
| 콘텐츠 브라우저 | 에셋 관리, 검색, 배치 |
| 머티리얼 에디터 | 표면 외형 제작 |
| 스태틱 메시 에디터 | 메시 임포트, LOD, 콜리전 |

### 2순위 — 특화 작업

| 에디터 | 주 작업 |
|--------|---------|
| 스켈레탈 메시 에디터 | 캐릭터 리깅 검증 |
| 애니메이션 에디터 | 시퀀스, State Machine, Montage |
| Sequencer | 컷씬 및 카메라 연출 |
| 블루프린트 에디터 | 게임 이벤트 로직 |

---

## 에디터 단축키

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

## 에디터 아키텍처 패턴

| 패턴 | 설명 |
|------|------|
| 모듈 기반 | 모든 에디터는 IModuleInterface 상속 |
| FWorkflowCentricApplication | 탭 기반 멀티 모드 에디터 기반 클래스 |
| Slate UI | 모든 에디터 UI가 Slate 프레임워크로 구현 |
| Undo/Redo | FTransaction으로 모든 변경 추적 |

---

## 관련 페이지
- [UE5 전체 개요](ue5_overview.md)
- [렌더링 & 셰이더 시스템](ue5_rendering_shader.md)
- [애니메이션 & 물리 시스템](ue5_animation_physics.md)
- [UI & 시네마틱 시스템](ue5_ui_cinematics.md)
- [StaticMesh 시스템](static_mesh.md)
