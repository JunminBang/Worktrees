# Sequencer 고급 — 시네마틱 제작 & Movie Render Queue

> 소스 경로: Runtime/MovieScene/Public/, Runtime/LevelSequence/Public/
> 아티스트를 위한 설명

---

## Sequencer 개요

Sequencer는 UE5의 **비선형 시네마틱 편집 툴**입니다. 비디오 편집 소프트웨어(Premiere, After Effects)처럼 타임라인 기반으로 카메라, 애니메이션, 빛, 사운드, 이펙트를 연출할 수 있습니다.

---

## LevelSequence vs MasterSequence

| 타입 | 역할 |
|------|------|
| **Level Sequence** | 단일 시퀀스 에셋. 씬 하나의 시네마틱 |
| **Master Sequence** | 여러 Level Sequence를 하나로 묶는 컨테이너. 영화 전체 |
| **Shot** | Master Sequence 안의 개별 씬 단위 |

---

## 트랙 종류

### 오브젝트 트랙

| 트랙 | 설명 |
|------|------|
| `Transform` | 위치/회전/스케일 키프레임 |
| `Visibility` | 오브젝트 보임/숨김 전환 |
| `Component` | 특정 컴포넌트 속성 제어 |
| `Event` | 특정 프레임에 Blueprint 이벤트 호출 |
| `Attach` | 다른 오브젝트에 부착/분리 |

### 카메라 트랙

| 트랙 | 설명 |
|------|------|
| `Camera Cut` | 씬 전환 (컷 편집). 어느 카메라를 사용할지 지정 |
| `CineCameraActor` | 영화용 카메라 (FOV, 조리개, 초점거리 제어) |
| `Camera Shake Source` | 특정 타임에 카메라 셰이크 트리거 |

### 애니메이션 트랙

| 트랙 | 설명 |
|------|------|
| `Animation` | 애니메이션 클립 배치 및 블렌딩 |
| `Skeletal Animation` | 스켈레탈 메시 직접 애니메이션 키프레임 |
| `Control Rig` | Control Rig 컨트롤을 Sequencer에서 직접 키프레임 |

### 오디오 & 이펙트

| 트랙 | 설명 |
|------|------|
| `Audio` | SoundWave/MetaSound 재생 |
| `Niagara System` | 특정 타임에 Niagara 이펙트 스폰/제어 |
| `Level Visibility` | 서브 레벨 로드/언로드 전환 |
| `Fade` | 화면 페이드 인/아웃 |

### 전역 트랙

| 트랙 | 설명 |
|------|------|
| `Play Rate` | 시간 흐름 속도 변경 (슬로모션/패스트모션) |
| `Time Dilation` | 물리/애니메이션 시간 배율 |
| `Sub Sequence` | 다른 Level Sequence 삽입 |
| `Director Blueprint` | 시퀀스 전용 Blueprint 트리거 |

---

## CineCameraActor — 영화용 카메라

**비유:** 실제 영화 촬영 카메라처럼 렌즈, 조리개, 초점 거리를 세밀하게 제어합니다.

### 주요 설정

| 프로퍼티 | 설명 |
|---------|------|
| `Current Focal Length` | 초점 거리 (mm). 낮을수록 광각, 높을수록 망원 |
| `Current Aperture` | 조리개 (f-stop). 낮을수록 DOF 강함 (f1.8=강한 아웃포커스) |
| `Focus Distance` | 초점이 맞는 피사체까지의 거리 |
| `Manual Focus Distance` | 수동 초점 거리 고정 |
| `Track Focus` | 특정 액터를 자동 추적 초점 |
| `Filmback` | 필름 규격 (16mm/35mm/IMAX 등) |
| `Min/Max FOV` | FOV 제한 범위 |

### DOF (피사계 심도) 활성화

`CineCameraActor` → `Depth of Field` 섹션:
- `Depth of Field Method`: Cinematic (가장 사실적)
- 조리개(Aperture)를 낮추면 DOF 효과 강해짐
- `Focus Distance`를 키프레임으로 애니메이션 가능 (포커스 풀링)

---

## 키프레임 작업

### 기본 키프레임 추가

1. Sequencer 열기 (Window → Cinematics → Sequencer)
2. 타임라인에서 원하는 프레임으로 이동
3. 오브젝트 선택 → 트랙의 **다이아몬드 버튼(◆)** 클릭 → 키프레임 추가
4. 또는 오브젝트 트랜스폼 변경 후 `S` 키로 즉시 키프레임

### 키프레임 보간 방식

키프레임 우클릭 → **Key Interpolation** 변경:

| 방식 | 설명 |
|------|------|
| `Auto` | 자동 스플라인 (부드러운 곡선) |
| `User` | 핸들 수동 조절 |
| `Linear` | 직선 이동 |
| `Constant` | 계단식 (즉시 전환) |
| `Cubic (Auto)` | 베지어 곡선 자동 |

---

## 카메라 전환 (Camera Cut 트랙)

1. Sequencer에 **Camera Cut Track** 추가
2. 해당 트랙에 `+Camera` → 사용할 CineCameraActor 선택
3. 각 씬 구간에 다른 카메라 배치 → 컷 편집

---

## Animation 트랙 활용

### 애니메이션 블렌딩

두 애니메이션 클립을 겹쳐 배치하면 자동으로 크로스페이드:

```
[0프레임]────[Walk 애니메이션]────[50프레임]
                          [40프레임]────[Run 애니메이션]────
                          ← 10프레임 블렌드 구간 →
```

### Control Rig 키프레임

Sequencer에서 Control Rig 컨트롤을 직접 키프레임:

1. 캐릭터에 Control Rig 할당
2. Sequencer에 `Control Rig Track` 추가
3. 컨트롤을 선택하고 `S`로 키프레임 → 영화급 애니메이션 제작 가능

---

## Movie Render Queue — 고품질 렌더링 출력

### 개요

Movie Render Queue는 Sequencer의 **고품질 렌더 출력 도구**입니다. 게임 뷰포트 캡처보다 훨씬 높은 품질로 렌더링합니다.

### 실행 방법

1. 상단 메뉴 → **Window → Cinematics → Movie Render Queue**
2. `+Render` → Level Sequence 에셋 선택
3. 렌더 설정 편집 (연필 아이콘)

### 주요 출력 설정

| 카테고리 | 설정 | 설명 |
|---------|------|------|
| **Output** | `Output Directory` | 렌더 파일 저장 경로 |
| **Output** | `File Name Format` | 파일명 패턴 (예: `{sequence}.{frame}`) |
| **Output** | `Output Resolution` | 해상도 (4K: 3840×2160) |
| **Output** | `Frame Rate` | 프레임 레이트 (24/30/60fps) |
| **Anti-Aliasing** | `Spatial Sample Count` | 공간 슈퍼샘플링 횟수 (높을수록 선명, 느림) |
| **Anti-Aliasing** | `Temporal Sample Count` | 시간적 샘플링 (모션블러 품질) |
| **High Res** | `Tile Count` | 이미지를 타일로 나눠 초고해상도 출력 |

### 출력 포맷

| 포맷 | 설명 |
|------|------|
| `PNG Sequence` | 프레임별 PNG (투명도 포함) |
| `JPEG Sequence` | 프레임별 JPEG (용량 작음) |
| `EXR Sequence` | HDR 32비트 (컴포지팅용) |
| `Apple ProRes` | 영상 파일 직접 출력 |
| `AVI` | Windows 영상 파일 |

### Path Tracing 렌더

고품질 Path Tracing 출력:
1. 렌더 설정 → `+Setting` → `Path Tracer`
2. `Samples Per Pixel`: 512~2048 (높을수록 노이즈 없음, 오래 걸림)

---

## 씬 전환 효과

| 효과 | 방법 |
|------|------|
| 페이드 인/아웃 | `Fade Track` 추가 → 0→1(페이드 아웃), 1→0(페이드 인) |
| 슬로모션 | `Play Rate Track` → 0.25 값 (4배 슬로모션) |
| 영화 레터박스 | `CineCameraActor` → `Letterbox` 활성화 |

---

## Blueprint에서 Sequencer 제어

```
[컷씬 시작]
→ Get Level Sequence Player
→ Play
→ Set Playback Position (특정 프레임 이동)
→ Stop / Pause

[완료 이벤트]
→ Level Sequence Player → Bind On Finished
→ 컷씬 완료 후 게임플레이 재개
```

---

## 아티스트 체크리스트

### 카메라 연출
- [ ] CineCameraActor를 사용하는가? (기본 Camera Actor보다 영화적 표현 우수)
- [ ] Focal Length와 Aperture가 씬 분위기에 맞게 설정되어 있는가?
- [ ] DOF 사용 시 `Focus Distance`가 주인공/피사체를 향하는가?
- [ ] Camera Cut 트랙으로 씬 전환이 설정되어 있는가?

### 애니메이션
- [ ] 애니메이션 클립 전환 구간에 블렌딩 처리가 되어 있는가?
- [ ] Control Rig 키프레임과 FBX 애니메이션이 충돌하지 않는가?

### Movie Render Queue
- [ ] 출력 해상도와 프레임 레이트가 납품 사양에 맞는가?
- [ ] Anti-Aliasing Spatial Sample Count가 최소 4 이상인가?
- [ ] EXR 출력 시 컴포지팅 파이프라인과 색공간(ACES)이 일치하는가?
- [ ] Path Tracing 사용 시 Samples Per Pixel이 충분한가? (노이즈 확인)

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [17_camera_system.md](17_camera_system.md) | CineCameraActor — FOV·DOF·셰이크 Sequencer 키프레임 |
| [20_ray_tracing.md](20_ray_tracing.md) | Movie Render Queue — Path Tracing 고품질 시네마틱 출력 |
| [15_control_rig.md](15_control_rig.md) | Control Rig Track — Sequencer에서 컨트롤 직접 키프레임 |
| [04_audio_effects.md](04_audio_effects.md) | Audio Track — Sequencer 내 사운드 재생 및 타이밍 제어 |
| [06_ui_cinematics.md](06_ui_cinematics.md) | 컷씬 재생 — Blueprint에서 Level Sequence Player 제어 |
| [29_metasounds.md](29_metasounds.md) | MetaSound — Sequencer 구간별 파라미터 키프레임 연동 |
