# Blueprint 고급 — 함수 라이브러리, 인터페이스, 이벤트 디스패처

> 소스 경로: Runtime/Engine/Classes/Kismet/, Runtime/CoreUObject/Public/UObject/Interface.h
> 아티스트를 위한 설명

---

## BlueprintFunctionLibrary — 전역 유틸리티 함수

`UBlueprintFunctionLibrary`는 특정 액터나 컴포넌트에 속하지 않고 **어디서든 호출할 수 있는 정적 함수 묶음**입니다.

**비유:** "툴박스" — 어떤 블루프린트에서든 꺼내 쓸 수 있는 도구 모음입니다.

### 언리얼 기본 제공 예시

| 라이브러리 | 역할 |
|-----------|------|
| `KismetMathLibrary` | 수학 함수 (삼각함수, 벡터 연산, 보간 등) |
| `KismetSystemLibrary` | 디버그 드로우, 트레이스, 타이머, 클래스 타입 체크 |
| `KismetStringLibrary` | 문자열 분리·결합·변환 |
| `GameplayStatics` | SpawnActor, GetAllActorsOfClass, 씬 관련 글로벌 함수 |
| `WidgetBlueprintLibrary` | UI 위젯 관련 유틸리티 |

### 아티스트 활용 예시
- `GameplayStatics → SpawnDecalAtLocation` — 데칼 스폰
- `KismetSystemLibrary → DrawDebugSphere` — 디버그 시각화
- `KismetMathLibrary → VInterpTo` — 벡터 부드러운 보간

---

## UInterface — 블루프린트 인터페이스

### 인터페이스란?

인터페이스는 서로 다른 클래스가 **같은 이름의 함수를 각자 다르게 구현**할 수 있도록 하는 약속입니다.

**비유:** "표준 플러그" — TV든 냉장고든 220V 콘센트(인터페이스)에 꽂으면 동작하지만 내부 동작은 각자 다릅니다.

### 실용 예시: 상호작용 인터페이스

```
BPI_Interactable (인터페이스 정의)
  └─ Interact() 함수 선언

BP_Door    → Interact() 구현: 문 열기
BP_Switch  → Interact() 구현: 전원 켜기
BP_NPC     → Interact() 구현: 대화 시작

플레이어 BP:
  Line Trace Hit → 결과 오브젝트에
  "Does Implement Interface BPI_Interactable?" → Yes
  → "Interact (Message)" 호출
```

### Blueprint에서 인터페이스 사용법

1. Content Browser → 우클릭 → **Blueprint Interface** 생성
2. 함수 추가 (입력/출력 핀 정의)
3. 구현할 BP 클래스 열기 → Class Settings → **Interfaces에 추가**
4. 함수 이벤트가 Event Graph에 자동 생성됨
5. 호출 시: `Does Implement Interface` 체크 후 Message 방식으로 호출

---

## Cast — 타입 변환 노드

### Cast란?

Cast는 "이 오브젝트가 특정 클래스인지 확인하고, 맞으면 그 클래스처럼 사용"하는 노드입니다.

**비유:** 상자 안에 뭔가가 들어있는데, 열어보니 사과면 사과처럼 다루고 아니면 다른 처리를 하는 것.

```
[Actor 레퍼런스]
  → Cast to BP_Enemy
    ├─ 성공: As BP_Enemy → TakeDamage() 호출 가능
    └─ 실패: 다른 처리
```

### Cast 비용 주의

| 방식 | 성능 | 권장 시기 |
|------|------|---------|
| Cast To | 낮은 비용 | 대부분의 경우 |
| Interface 호출 | 더 낮은 비용 | 다양한 클래스 대상 |
| `IsValid` 후 Cast | 안전하지만 2단계 | 널 체크 필요 시 |

> **팁:** Tick처럼 매 프레임 실행되는 곳에서 Cast를 반복 호출하지 마세요. 레퍼런스를 캐싱해두는 것이 좋습니다.

---

## Event Dispatcher — 이벤트 방송

### Event Dispatcher란?

이벤트 디스패처는 **"방송국"** 입니다. 한 오브젝트가 이벤트를 알리면, 구독한 모든 오브젝트가 각자 반응합니다.

**비유:** 라디오 방송 — 방송국(Event Dispatcher 소유자)이 신호를 보내면 라디오(구독자)들이 동시에 수신.

### 작동 흐름

```
[문이 열림 이벤트 발생]
  → Door BP: Call OnDoorOpened (Dispatcher 호출)
    ├─ 적 AI: 플레이어 위치로 이동
    ├─ 사운드 매니저: 문 소리 재생
    └─ 이벤트 로그: "문 열림" 기록
```

### Blueprint 연결 방법

**구독(Bind):**
```
Event BeginPlay
  → Get Reference to Door
  → Bind Event to OnDoorOpened
  → 이벤트 (내 커스텀 이벤트 연결)
```

**방송(Call):**
```
Door BP 내부:
  → [문 열리는 조건 충족]
  → Call OnDoorOpened (Dispatcher 호출)
```

**해제(Unbind):**
```
Event EndPlay / 오브젝트 파괴 시:
  → Unbind Event from OnDoorOpened
```

> **주의:** Bind 후 오브젝트가 파괴될 때 반드시 Unbind 처리해야 합니다. 안 하면 이미 파괴된 오브젝트를 참조하게 됩니다.

---

## Timeline 노드

### Timeline이란?

Timeline은 **시간에 따라 값을 변화시키는 애니메이션 커브 플레이어**입니다. C++ 코드 없이 커브 에디터로 모션이나 값 변화를 만들 수 있습니다.

**사용 예시:**
- 문이 서서히 열리는 애니메이션 (위치/회전 보간)
- 체력 바가 서서히 감소하는 UI 효과
- 아이템 습득 시 반짝이는 이미시브 강도 변화

### 주요 핀

| 핀 | 방향 | 설명 |
|----|------|------|
| `Play` | 입력 | 처음부터 재생 |
| `Play from Start` | 입력 | 리셋 후 재생 |
| `Reverse` | 입력 | 역방향 재생 |
| `Stop` | 입력 | 현재 위치에서 정지 |
| `Update` | 출력 실행 | 매 프레임 값 갱신 시 실행 |
| `Finished` | 출력 실행 | 재생 완료 시 실행 |
| `Direction` | 출력 값 | 현재 재생 방향 |
| (커브 핀들) | 출력 값 | 각 커브의 현재 값 |

---

## Blueprint 변수 타입 요약

| 타입 | 설명 | 예시 |
|------|------|------|
| `Boolean` | 참/거짓 | isAlive, isDead |
| `Integer` | 정수 | 아이템 개수, 레벨 |
| `Float` | 소수 | 체력, 속도, 각도 |
| `String` | 문자열 | 플레이어 이름 |
| `Name` | 최적화된 문자열 | 본 이름, 소켓 이름 |
| `Text` | 현지화 지원 문자열 | UI에 표시되는 텍스트 |
| `Vector` | 3D 좌표 (X,Y,Z) | 위치, 방향 |
| `Rotator` | 회전 (Pitch,Yaw,Roll) | 각도 |
| `Transform` | 위치+회전+스케일 세트 | 트랜스폼 |
| `Object Reference` | 특정 클래스 오브젝트 참조 | BP_Enemy 인스턴스 |
| `Class Reference` | 클래스 자체 (인스턴스 아님) | SpawnActor 클래스 지정 |
| `Array` | 같은 타입 요소의 리스트 | 인벤토리 아이템 목록 |
| `Map` | 키-값 쌍 | 아이템ID → 개수 |
| `Set` | 중복 없는 집합 | 활성화된 버프 목록 |

---

## Blueprint vs C++ 선택 기준

| 기준 | Blueprint 권장 | C++ 권장 |
|------|--------------|---------|
| 제작자 | 아티스트·디자이너 | 프로그래머 |
| 게임플레이 로직 | 단순한 이벤트·상호작용 | 복잡한 알고리즘 |
| 성능 민감 | Tick이 많지 않은 경우 | Tick마다 처리, 대량 오브젝트 |
| 재사용성 | 프로젝트 내부 | 엔진 확장, 플러그인 |
| 프로토타이핑 | 빠른 이터레이션 필요 시 | 최적화가 완료된 최종 구현 |

---

## 아티스트 체크리스트

### Event Dispatcher 사용 시
- [ ] Bind는 BeginPlay, Unbind는 EndPlay 또는 파괴 시 처리했는가?
- [ ] 구독자가 이미 Destroy된 오브젝트를 참조하지 않는가?
- [ ] Dispatcher가 같은 이벤트에 중복 바인딩되지 않았는가?

### Interface 사용 시
- [ ] Class Settings에 Interface가 추가되어 있는가?
- [ ] 인터페이스 함수가 해당 블루프린트에 구현되어 있는가?
- [ ] 호출 전 `Does Implement Interface` 체크를 했는가?

### Cast 사용 시
- [ ] Tick이나 빈번한 루프 안에서 Cast를 반복 호출하지 않는가?
- [ ] 캐스팅 결과를 변수에 저장해 재사용하는가?

### Timeline 사용 시
- [ ] `Finished` 핀을 활용해 애니메이션 완료 후 처리를 연결했는가?
- [ ] Loop 모드가 의도치 않게 켜져 있지 않은가?
- [ ] Reverse 재생이 필요한 경우 `Reverse` 핀을 사용했는가?

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [09_gameplay_ability_system.md](09_gameplay_ability_system.md) | GAS — Blueprint Interface로 GA 발동 및 상태 조회 패턴 |
| [16_data_management.md](16_data_management.md) | DataTable Row 읽기 — Blueprint에서 DataTable 활용 |
| [53_profiling_optimization.md](53_profiling_optimization.md) | Tick 최적화 — Cast 캐싱, SetTimer 패턴, TickInterval 설정 |
| [01_gameplay_framework.md](01_gameplay_framework.md) | Event Dispatcher — 게임플레이 프레임워크 간 이벤트 전달 |
| [06_ui_cinematics.md](06_ui_cinematics.md) | UI 위젯과 Blueprint 인터페이스 연동 패턴 |
| [22_plugins.md](22_plugins.md) | 플러그인 — Blueprint Function Library를 플러그인으로 배포 |
