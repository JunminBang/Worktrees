# 기획서 — Draw Call Budget Tracker (Graphics Performance Auditor)

> 작성일: 2026-04-25  
> 수정일: 2026-04-26 (아키텍트 검토 반영 / 프로젝트 설정 단순화)  
> 카테고리: 퍼포먼스 프로파일링  
> 우선순위: 높음  
> 프로젝트 렌더링 설정: CSM / Legacy Material / Nanite OFF / Megalights OFF / Lumen 옵션

---

## 개요

지정 레벨을 PIE로 자동 실행해 그래픽 퍼포먼스 stat 데이터를 수집하고, 플랫폼 예산과 비교한 뒤 원인별 최적화 후보를 자동 제안하는 통합 그래픽 퍼포먼스 감사 도구.

---

## 문제 정의

- 드로우콜·섀도우·반투명 등 렌더링 병목은 종류가 다양하지만, 원인을 찾으려면 RenderDoc·언리얼 프로파일러를 수동 분석해야 한다.
- `stat` 명령은 PIE 실행 중에만 의미 있는 값이 나와 에디터에서 빠르게 확인하기 어렵다.
- 인디 팀에서는 프로파일링 시점이 늦어져 뒤늦게 대규모 리팩터링이 필요해지는 경우가 많다.

---

## 목표

- 레벨 선택 → PIE 자동 실행 → stat 수집 → 리포트 출력까지 원클릭으로 처리
- 플랫폼별 예산 기준과 비교해 초과 항목 즉시 판정
- 감지된 문제 유형별로 최적화 후보 자동 제안

---

## 실행 흐름

```
① 레벨 선택 + 플랫폼 프리셋 / Lumen On/Off 설정
        ↓
② PIE 자동 실행 (Automation Test 프레임워크)
   ※ 비동기 — ADD_LATENT_AUTOMATION_COMMAND 체인 또는 상태머신으로 구현
        ↓
③ N 프레임 안정화 대기 (기본값: 60 프레임)
   World Partition 씬: IsStreamingCompleted() 폴링으로 완료 감지
        ↓
④ CSV Profiler 캡처 (FCsvProfiler::BeginCapture / EndCapture)
   보조: stat RHI / SceneRendering / GPU / Unit 값 샘플링
        ↓
⑤ PIE 종료 (FEditorDelegates::EndPIE 델리게이트로 정상/크래시/ESC 구분)
        ↓
⑥ 예산 비교 → 문제 유형 분류 → 후보 제안
        ↓
⑦ 에디터 패널 출력 + JSON / CSV 저장
```

---

## 수집 stat 항목

| stat 명령 | 수집 항목 | 설명 |
|---|---|---|
| `stat RHI` | DrawPrimitiveCalls | 전체 드로우콜 수 |
| `stat RHI` | Triangles | 렌더링 삼각형 수 |
| `stat SceneRendering` | MeshDrawCalls | 메시 드로우콜 수 |
| `stat SceneRendering` | ShadowDrawCommands | 섀도우 드로우커맨드 수 (CSM) |
| `stat SceneRendering` | TranslucentMeshDrawCalls | 반투명 드로우콜 수 |
| `stat GPU` | BasePass | 베이스패스 GPU 시간 (ms) |
| `stat GPU` | Shadow | 섀도우 패스 GPU 시간 (ms) |
| `stat GPU` | Translucency | 반투명 패스 GPU 시간 (ms) |
| `stat GPU` | Lumen.SceneUpdate | Lumen 씬 업데이트 비용 (Lumen On 시만 수집) |
| `stat GPU` | Lumen.ScreenProbeGather | Lumen GI 비용 (Lumen On 시만 수집) |
| `stat GPU` | Lumen.Reflections | Lumen 리플렉션 비용 (Lumen On 시만 수집) |
| `stat Unit` | Frame / Game / Draw / GPU / RHIT | 스레드별 프레임 시간 분해 |

---

## 주요 기능

### 1. stat 자동 수집
- **기본 백엔드: CSV Profiler** (`FCsvProfiler::Get()->BeginCapture()`) — 구조화된 numeric 출력 보장
- 보조: `FStatsThreadState` 직접 접근 (STATS=1 에디터 빌드 한정)
- 로그 파싱 방식 사용 금지 (형식 변경에 취약)
- World Partition 레벨은 `UWorldPartitionSubsystem::IsStreamingCompleted()` 폴링으로 안정화 판단

### 2. Nanite 실수 활성화 감지
- 프로젝트에서 Nanite를 사용하지 않으므로, Nanite가 켜진 메시가 있으면 경고
- `UStaticMesh::NaniteSettings.bEnabled == true`인 에셋 목록 추출 → 수동 확인 유도

### 3. 예산 비교 및 경고
- 플랫폼 프리셋 + Lumen On/Off 조합별 기준값과 비교
- 항목별 달성률 표시 (예: DrawCall 1,200 / 1,000 → 120% ⚠️)

### 4. 문제 유형 분류 및 후보 자동 제안

| 감지 패턴 | 분류 | 자동 제안 |
|---|---|---|
| DrawPrimitiveCalls 초과 | 드로우콜 과다 | HISM 전환 후보 / 메시 머지 후보 |
| ShadowDrawCommands 과다 | 섀도우 과부하 | Shadow Distance 축소 대상 / Cascade 수 축소 / Dynamic → Stationary 전환 후보 |
| TranslucentMeshDrawCalls 과다 | 반투명 과다 | 반투명 메시 밀집 구간 탐지 / Overdraw 경고 구간 |
| GPU BasePass 시간 과다 | 머티리얼 복잡도 | Shader Instruction 상위 머티리얼 목록 |
| GPU Lumen 합계 과다 (Lumen On 시) | Lumen 비용 과다 | Lumen 품질 설정 축소 제안 / Screen Trace 전용 전환 후보 |
| GPU Shadow 패스 시간 과다 | 섀도우 연산 과다 | Dynamic Shadow 액터 → Stationary 전환 후보 |
| Draw > Game | 렌더 큐 빌드 병목 | 렌더링 커맨드 생성 과다 컴포넌트 탐지 |
| Game > Draw, GPU | CPU 게임 스레드 병목 | Tick 과다 컴포넌트 / Blueprint 연산 병목 안내 |

### 5. 머지 / 인스턴싱 후보 제안

**머지 후보 조건 (AND)**
- 동일 Base Material + 동일 Material Parameter Hash (MID 파라미터가 다르면 제외)
- 인접 거리 500 UU 이내
- 동일 HLOD 클러스터 및 World Partition 셀에 속할 것

**HISM 전환 후보 조건 (AND)**
- 동일 `UStaticMesh` **15개 이상** 배치
- Mobility = Static인 메시만 대상 (Movable 제외)
- Custom Primitive Data / BP 개별 로직 미사용 메시만 대상

### 6. 히스토리 비교
- JSON 스키마 사전 확정 후 이전 측정값과 diff
- 항목별 변화율 표시 (개선 / 악화 / 유지)

---

## 입출력

**입력**
- 대상 레벨
- 플랫폼 프리셋 (PC High / PC Low / 콘솔 / 모바일)
- Lumen On / Off
- 안정화 프레임 수 (기본: 60) 또는 WP 스트리밍 완료 폴링
- 카메라 Waypoint 목록 (선택, WP 오픈월드 다지점 측정용)
- 예산값 수동 오버라이드 (선택)

**출력**
- 에디터 내 결과 패널 (탭: 요약 / stat 상세 / 후보 목록 / 히스토리)
- `Saved/Profiling/GraphicsAudit_레벨명_YYYYMMDD.json`
- `Saved/Profiling/GraphicsAudit_레벨명_YYYYMMDD.csv`

---

## 플랫폼별 기본 예산 기준 (초기값)

### Lumen Off

| 항목 | PC High | PC Low / 콘솔 | 모바일 |
|---|---|---|---|
| DrawPrimitiveCalls | 2,000 | 1,000 | 300 |
| ShadowDrawCommands | 500 | 250 | 50 |
| TranslucentMeshDrawCalls | 200 | 100 | 30 |
| GPU Frame 시간 | 16ms | 16ms | 33ms |
| GPU BasePass | 8ms | 6ms | 15ms |
| GPU Shadow | 4ms | 3ms | 5ms |

### Lumen On

| 항목 | PC High | PC Low / 콘솔 |
|---|---|---|
| DrawPrimitiveCalls | 2,000 | 1,000 |
| ShadowDrawCommands | 500 | 250 |
| TranslucentMeshDrawCalls | 200 | 100 |
| GPU Frame 시간 | 16ms | 16ms |
| GPU BasePass | 6ms | 4ms |
| GPU Shadow | 4ms | 3ms |
| GPU Lumen 합계 | 6ms | 4ms |

> Lumen On은 모바일 미지원

---

## 구현 단계 (Phase)

### Phase 1 — 기반
1. CSV Profiler 캡처 wrapper + `EndPIE` 델리게이트 안전 종료
2. 비동기 PIE 상태머신 (`Idle → Loading → Stabilizing → Sampling → Done`)
3. JSON 출력 스키마 확정
4. **stat 수집 목록을 DataAsset(또는 ini)으로 관리** — 코드 수정 없이 항목 추가 가능하도록 설계
   - 수집할 stat 카테고리 / 항목명 / 예산 기준값을 데이터로 분리
   - 새 stat 추가 = config 한 줄 추가로 끝남
   - 진단 룰(최적화 제안 로직)은 별도 코드로 관리 — stat 수집과 독립

### Phase 2 — 계측
4. stat 항목 수집 + Lumen On/Off 분기
5. World Partition 스트리밍 완료 폴링
6. Nanite 실수 활성화 감지

### Phase 3 — 제안 로직 (Phase 2 완료 후 착수)
7. 예산 비교 + 문제 유형 분류
8. HISM / 머지 후보 (오탐 필터 적용)
9. 히스토리 diff

### Phase 4 — UI
10. Editor Utility Widget 패널 (탭 구조 + 경고 배지 + 히스토리 그래프)

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| 측정 환경 | stat 값은 PIE 기준 — 패키지 빌드와 수치 차이 있음. 리포트에 측정 환경 명시 필수 |
| 안정화 노이즈 | 초기 셰이더 컴파일 구간 stat 버림 처리 필수 |
| WP 레벨 | 고정 프레임 안정화 불가 — 스트리밍 완료 폴링 또는 Waypoint 사용 |
| Lumen | GPU BasePass와 Lumen 패스 비용 분리 집계 필수. Lumen Off 씬에서 Lumen 항목 비활성화 |
| 모바일 | 에디터 에뮬레이션과 실기기 수치 오차 큼 → 참고값으로만 사용 |
| API 변동 | Automation Test API는 엔진 버전마다 다를 수 있음 → `docs/engine-reference/unreal/` 확인 필수 |

---

## 완료 기준

- [ ] Phase 1: CSV Profiler 기반 PIE 비동기 캡처 + JSON 스키마 확정
- [ ] Phase 2: stat 수집 + Lumen 분기 + WP 폴링 + Nanite 감지
- [ ] Phase 3: 예산 비교 + 오탐 필터 적용된 HISM/머지 후보 출력 + 히스토리 diff
- [ ] Phase 4: Editor Utility Widget 패널
- [ ] JSON / CSV 저장
- [ ] wiki에 결과 패턴 ingest
