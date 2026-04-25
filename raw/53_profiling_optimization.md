# 프로파일링 & 최적화 가이드

> 소스 경로: Runtime/Engine/Classes/Engine/Engine.h (통계 시스템)
> 아티스트를 위한 설명

---

## 왜 최적화가 중요한가?

게임이 60fps를 유지하려면 **한 프레임을 16.6ms 안에 처리**해야 합니다. 30fps는 33.3ms입니다. 병목이 어디에 있는지 찾아야 효율적으로 최적화할 수 있습니다.

**비유:** 요리 주방 — 어느 요리사(CPU/GPU/메모리)가 가장 느린지 알아야 그 사람의 일을 줄일 수 있습니다.

---

## 기본 성능 확인 명령어

게임 뷰포트 또는 콘솔(`~` 키)에서 입력:

| 명령어 | 설명 |
|--------|------|
| `stat fps` | FPS 및 프레임 시간(ms) 표시 |
| `stat unit` | CPU Game / CPU Render / GPU 시간 분리 표시 |
| `stat unitgraph` | 시간 그래프로 표시 |
| `stat game` | 게임스레드 상세 분류 |
| `stat gpu` | GPU 작업별 시간 분류 |
| `stat scenerendering` | 드로우콜, 삼각형 수 등 렌더링 통계 |
| `stat memory` | 메모리 사용량 분류 |
| `stat streaming` | 텍스처 스트리밍 상태 |
| `stat particles` | 파티클 통계 |
| `stat ai` | AI 틱 통계 |
| `r.ScreenPercentage 50` | 해상도 50%로 낮춰 GPU 병목 확인 |

---

## stat unit 읽는 법

`stat unit` 이 가장 먼저 봐야 할 지표입니다:

```
Frame:  16.7ms   ← 전체 프레임 시간
Game:   8.2ms    ← CPU 게임스레드 (Blueprint, AI, Physics)
Draw:   4.1ms    ← CPU 렌더스레드 (드로우콜 준비)
GPU:    14.3ms   ← GPU 렌더링 시간
```

| 병목 위치 | 조치 |
|---------|------|
| **GPU** 가 가장 높음 | 드로우콜 감소, 텍스처 최적화, Lumen/Shadow 품질 낮춤 |
| **Game** 이 가장 높음 | Blueprint Tick 줄이기, AI 최적화, Physics 단순화 |
| **Draw** 가 가장 높음 | 드로우콜 병합, ISM 사용, 오클루전 컬링 확인 |

---

## 뷰포트 최적화 시각화 모드

에디터 뷰포트 → 상단 드롭다운 → **Optimization Viewmodes**:

| 모드 | 표시 내용 | 찾는 문제 |
|------|---------|---------|
| `Shader Complexity` | 셰이더 비용 히트맵 (초록→빨강) | 복잡한 머티리얼 |
| `Quad Overdraw` | 픽셀 오버드로우 | 반투명 레이어 중첩 |
| `Lightmap Density` | 라이트맵 해상도 밀도 | 라이트맵 낭비 |
| `LOD Coloration` | 현재 렌더되는 LOD 레벨 | LOD 전환 거리 확인 |
| `Nanite Visualization` | Nanite 활성 메시 표시 | Nanite 미적용 메시 확인 |
| `Buffer Visualization` | GBuffer 채널 분리 표시 | 머티리얼 디버깅 |

---

## Unreal Insights — 심층 프로파일링

Unreal Insights는 **프레임별 CPU/GPU 작업을 타임라인으로 시각화**하는 고급 프로파일링 툴입니다.

### 실행 방법

1. `[엔진 경로]\Engine\Binaries\Win64\UnrealInsights.exe` 실행
2. 게임 실행 시 자동 연결 (또는 `-trace=cpu,gpu,frame,bookmark` 실행 인자 추가)
3. 세션 선택 → 타임라인 분석

### 주요 분석 항목

- **CPU 트랙**: 각 틱 함수가 얼마나 걸리는지
- **GPU 트랙**: 렌더 패스별 시간 (Shadow, BasePass, Lumen 등)
- **메모리 트랙**: 시간에 따른 메모리 변화

---

## 드로우콜 최적화

드로우콜(Draw Call)은 **CPU가 GPU에게 "이거 그려"라고 명령하는 횟수**입니다. 많을수록 CPU 오버헤드가 커집니다.

| 방법 | 설명 |
|------|------|
| **Nanite** | 폴리곤 수 관계없이 드로우콜 최소화 |
| **ISM (Instanced Static Mesh)** | 같은 메시 수천 개 = 드로우콜 1~수 개 |
| **Merge Actors** | 여러 정적 메시를 하나로 합치기 (`Tools → Merge Actors`) |
| **LOD** | 원거리에서 단순 메시로 전환 |
| **Cull Distance Volume** | 거리 밖 오브젝트 자동 숨김 |
| **Material 통합** | 머티리얼 슬롯 수 최소화 |

### 목표 드로우콜 수 (stat scenerendering)

| 플랫폼 | 권장 드로우콜 |
|--------|-----------|
| PC (고사양) | 2000~3000 이하 |
| 콘솔 (PS5/XSX) | 1500~2000 이하 |
| 모바일 | 200~500 이하 |

---

## 텍스처 메모리 최적화

| 방법 | 설명 |
|------|------|
| `stat streaming` | 스트리밍 풀 사용량 확인 |
| `r.Streaming.PoolSize` | 텍스처 스트리밍 풀 크기 설정 (MB) |
| Mip 설정 | LOD Bias 높이면 낮은 해상도 Mip 로드 |
| 텍스처 압축 | BC7 대신 BC1/BC5로 압축률 높이기 |
| `Virtual Texture` | 대형 텍스처를 스트리밍으로 처리 |

---

## Blueprint 성능 최적화

| 문제 | 해결 |
|------|------|
| Tick에 무거운 로직 | 타이머(`SetTimer`)로 간격 실행 |
| 매 프레임 `GetAllActorsOfClass` | BeginPlay에서 한 번만 실행 후 캐싱 |
| 매 프레임 Cast | 변수에 레퍼런스 저장 후 재사용 |
| 많은 Tick 이벤트 | `Set Tick Interval`로 간격 늘리기 |
| 불필요한 오브젝트 Tick | `Set Actor Tick Enabled: false` |

---

## Lumen / Shadow 품질 조정

성능 문제 시 점진적으로 낮추는 순서:

```
1. Shadow Distance 단축
   r.Shadow.MaxCSMResolution 1024 → 512

2. Lumen 품질 낮추기
   r.Lumen.DiffuseIndirect.Allow 0  (Lumen GI 끄기)
   r.Lumen.Reflections.Allow 0      (Lumen 반사 끄기)

3. Screen Percentage 낮추기
   r.ScreenPercentage 75  (75% 해상도 렌더 후 업스케일)

4. 볼류메트릭 끄기
   r.VolumetricFog 0
   r.VolumetricCloud 0
```

---

## 메모리 누수 확인

| 명령어 | 설명 |
|--------|------|
| `stat memory` | 카테고리별 메모리 사용량 |
| `memreport -full` | 전체 메모리 덤프 파일 생성 |
| `obj list class=Texture2D` | 로드된 텍스처 목록 |

---

## 아티스트 체크리스트

### 첫 번째 확인
- [ ] `stat unit`으로 병목이 CPU/GPU 중 어디인지 확인했는가?
- [ ] 목표 프레임(60fps=16.6ms, 30fps=33.3ms)을 설정했는가?

### 렌더링
- [ ] `Shader Complexity` 뷰에서 빨간 영역이 없는가?
- [ ] 드로우콜 수가 플랫폼 목표 이하인가? (`stat scenerendering`)
- [ ] 반복 배치 오브젝트에 ISM/Nanite/Foliage를 사용하는가?
- [ ] `LOD Coloration`으로 원거리에서 LOD 전환이 동작하는가?

### 텍스처
- [ ] `stat streaming`에서 스트리밍 풀 초과(`Over Budget`)가 없는가?
- [ ] 화면에 거의 보이지 않는 오브젝트에 4K 텍스처를 사용하지 않는가?

### Blueprint
- [ ] Tick에서 무거운 작업(Cast, GetAllActors)을 하지 않는가?
- [ ] 사용하지 않는 액터의 Tick이 비활성화되어 있는가?
