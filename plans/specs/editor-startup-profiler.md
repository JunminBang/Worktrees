# 기획서 — Editor Startup Profiler

> 작성일: 2026-04-25  
> 수정일: 2026-04-26 (아키텍트 검수 반영)  
> 카테고리: 에디터 UX / 생산성  
> 우선순위: 중

---

## 개요

UE5 에디터 시작 시 각 단계(플러그인 로드, 모듈 초기화, 에셋 레지스트리 빌드 등)의 소요 시간을 측정하고, 병목 구간을 리포트하는 에디터 유틸리티.

---

## 문제 정의

- 프로젝트 규모가 커질수록 에디터 시작 시간이 늘어나지만 어떤 플러그인/모듈이 원인인지 파악하기 어렵다.
- 개발자마다 설치한 플러그인이 달라 재현이 힘들다.
- 매번 수동으로 로그를 뒤져야 한다.

---

## 목표

- 에디터 시작 시간을 단계별로 측정
- 느린 구간 상위 N개를 자동으로 지목
- 결과를 리포트 파일로 저장

---

## 주요 기능

| 기능 | 설명 |
|---|---|
| 단계별 타이밍 수집 | 모듈 로드 / 에셋 레지스트리 / 셰이더 컴파일 구간 측정 |
| 상위 병목 리포트 | 소요 시간 상위 10개 항목 표시 |
| 비교 모드 | 동일 환경 메타데이터 조건에서 이전 실행 결과와 diff |
| CSV / JSON 출력 | CI 파이프라인 연동 가능한 구조화 출력 |

---

## 구현 방향

### 타이밍 수집 백엔드

> ⚠️ `FEngineLoop` 직접 후킹 불가 (비공개 메서드). `GLog` 파싱 및 `-logcmds` 사용 금지.

| 방법 | 용도 |
|---|---|
| **Unreal Insights `LoadTimeProfiler` 채널** (1차 데이터) | `-trace=loadtime,cpu` 플래그로 `.utrace` 캡처. 모듈/에셋 레지스트리 단계가 이미 마킹됨 |
| `FCoreDelegates::OnPostEngineInit` | 엔진 초기화 완료 시점 마커 |
| `FModuleManager::Get().OnModulesChanged()` | 모듈 로드 전후 콜백 — "module load time" 레이블로 기록 |
| `FAssetRegistryModule::Get().OnFilesLoaded()` | 에셋 레지스트리 완료 시점 |
| `FOutputDevice` 서브클래스 등록 | 보조 로그 수집 (`GLog->AddOutputDevice()`) |

### 플러그인 LoadingPhase 설정 (필수)

- 이 도구 자체를 플러그인으로 패키징하고 `LoadingPhase=EarliestPossible` 지정
- 그렇지 않으면 **도구가 측정 대상보다 늦게 시작**되어 초반 모듈 측정 누락

### 기본 비활성화

- 매 실행마다 측정하면 시작 시간 자체가 늘어남
- 기본 OFF, `-StartupProfile` 커맨드라인 플래그 또는 환경변수로 ON

---

## 환경 메타데이터 (JSON 필수 기록)

diff 모드에서 **동일 환경 메타데이터끼리만 비교**. 다른 환경이면 경고 표시.

```json
{
  "environment": {
    "cache_state": "cold | warm",
    "ddc_mode": "local | shared",
    "live_coding": true,
    "engine_build": "InstalledBuild | SourceBuild",
    "plugin_count": 12,
    "last_level": "Level_Main"
  }
}
```

---

## 측정 불가 / 부정확 구간

| 구간 | 원인 | 처리 |
|---|---|---|
| 셰이더 컴파일 | 별도 프로세스 | Insights LoadTime 채널로 보완 |
| DDC 콜드/웜 차이 | 첫 실행 수십 초 ~ 수 분 차이 | 메타데이터에 `cache_state` 기록 필수 |
| Lumen 초기 캐시 | 뷰포트 진입 시 추가 컴파일 | "에디터 시작" 범위 명시 (PIE 진입 전까지) |
| 에셋 레지스트리 백그라운드 스캔 | `OnFilesLoaded` 후에도 계속 | 완료 이벤트 기준 명시 |
| 소스 컨트롤 초기화 | 네트워크 상태에 따라 수 초 변동 | 메타데이터에 기록, diff 비교 시 참고 |

---

## 비교 모드 (diff) 규칙

- 동일 `environment` 블록끼리만 비교 (다른 환경 = 경고)
- **N회 반복 측정 후 중앙값/분산** 리포트 (1회 측정 diff는 신뢰 불가)
- diff 단위는 절대값(ms) + 상대 비율(%) 함께 표시

---

## 입출력

**입력**
- 없음 (에디터 시작 시 `-StartupProfile` 플래그로 활성화)

**출력**
- `Saved/Profiling/StartupProfile_YYYYMMDD_N.json` (N = 반복 회차)
- 에디터 내 결과 패널 (선택, Phase 4)

---

## 구현 단계 (Phase)

### Phase 1 — 타이밍 수집
1. Unreal Insights `LoadTimeProfiler` wrapper + `FCoreDelegates` / `FModuleManager` 델리게이트 등록
2. `LoadingPhase=EarliestPossible` 플러그인 구조 확립

### Phase 2 — JSON 출력
3. 환경 메타데이터 포함 JSON 스키마 확정
4. N회 반복 측정 지원

### Phase 3 — diff 비교
5. 동일 환경 메타데이터 매칭 로직
6. 중앙값 / 분산 / 상대 비율 계산

### Phase 4 — UI (가장 마지막)
7. Editor Utility Widget 결과 패널

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| 측정 사각지대 | EarliestPossible 이전 로드 모듈은 측정 불가 |
| Insights 의존 | `.utrace` 파싱 학습 곡선. Insights 미실행 시 fallback 필요 |
| diff 노이즈 | DDC 상태, Live Coding, 안티바이러스 등 환경 변수 통제 필수 |
| API 변동 | `FCoreDelegates` 시그니처는 `docs/engine-reference/unreal/` 확인 필수 |

---

## 완료 기준

- [ ] Phase 1: Insights + 델리게이트 타이밍 수집, EarliestPossible 플러그인
- [ ] Phase 2: 환경 메타데이터 포함 JSON 출력, N회 반복
- [ ] Phase 3: 동일 환경 diff + 중앙값/분산 리포트
- [ ] Phase 4: Editor Utility Widget 패널
- [ ] wiki에 결과 패턴 ingest
