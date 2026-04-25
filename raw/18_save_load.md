# 세이브/로드 시스템

> 소스 경로: Runtime/Engine/Classes/GameFramework/SaveGame.h
> 아티스트를 위한 설명

---

## USaveGame — 세이브 데이터 컨테이너

`USaveGame`은 "세이브 파일에 담을 데이터를 넣는 빈 상자"입니다.

- 아티스트/디자이너는 이 클래스를 **Blueprint로 상속**해 새 SaveGame 에셋을 만들고, 저장하고 싶은 데이터(플레이어 레벨, 체력, 위치 등)를 변수로 추가합니다.
- `ULocalPlayerSaveGame`은 USaveGame의 확장판으로, 로컬 플레이어와 자동 연결되며 버전 관리 기능도 내장되어 있습니다.

**핵심 개념:** SaveGame 오브젝트는 레벨이나 월드와 무관하게 존재하는 순수한 데이터 컨테이너입니다. 씬이 바뀌어도 데이터는 파일로 남습니다.

---

## 세이브/로드 워크플로우 (Blueprint 기준)

### 세이브할 때
```
[세이브 트리거]
  → Create Save Game Object (SaveGameClass 지정)
  → 변수에 데이터 채우기 (Set 노드들)
  → Save Game to Slot (SlotName, UserIndex)
```

### 로드할 때
```
[로드 트리거 / 게임 시작]
  → Does Save Game Exist? (SlotName 확인)
  → Load Game from Slot (SlotName, UserIndex)
  → Cast To [내 SaveGame 클래스]
  → 변수 읽기 (Get 노드들)
```

### Blueprint 노드 목록

| 노드 이름 | 역할 |
|---------|------|
| `Create Save Game Object` | 새 SaveGame 인스턴스 생성 |
| `Save Game to Slot` | 동기(즉시) 저장 — 완료될 때까지 프레임 멈춤 |
| `Load Game from Slot` | 동기(즉시) 로드 |
| `Does Save Game Exist` | 슬롯에 파일이 있는지 확인 |
| `Delete Game in Slot` | 슬롯 삭제 |

---

## 슬롯 이름 관리

슬롯 이름은 **문자열(String)** 로 관리합니다. 파일 이름처럼 생각하면 됩니다.

- `"SaveSlot_1"`, `"AutoSave"`, `"PlayerProfile"` 처럼 의미 있는 이름 사용
- 슬롯 이름이 다르면 별개의 저장 파일이 생성됩니다 → 멀티 세이브 슬롯 구현 가능
- `UserIndex`는 로컬 멀티플레이(분할화면)에서 플레이어 구분용. 싱글은 `0`으로 고정
- **권장 패턴:** GameInstance에 슬롯 이름 상수를 변수로 선언해두고 전체에서 참조

---

## 비동기 세이브/로드

동기 방식은 저장 중 프레임이 잠깐 멈출 수 있습니다. 대용량 데이터에는 비동기 사용 권장.

| 구분 | 함수 | 특징 |
|------|------|------|
| 동기 저장 | `SaveGameToSlot` | 즉시 완료, 간단하지만 프레임 히칭 가능 |
| 비동기 저장 | `AsyncSaveGameToSlot` | 워커 스레드에서 처리, 완료 시 델리게이트 호출 |
| 동기 로드 | `LoadGameFromSlot` | 즉시 반환 |
| 비동기 로드 | `AsyncLoadGameFromSlot` | 워커 스레드에서 처리, 완료 시 델리게이트 호출 |

---

## 세이브 파일 저장 위치

| 플랫폼 | 저장 경로 |
|--------|---------|
| Windows (패키지) | `%LOCALAPPDATA%\[ProjectName]\Saved\SaveGames\[SlotName].sav` |
| Windows (에디터 PIE) | `[ProjectRoot]\Saved\SaveGames\[SlotName].sav` |
| Mac | `~/Library/Application Support/[ProjectName]/Saved/SaveGames/` |
| iOS | 앱 샌드박스 Documents 폴더 내부 |
| Android | 앱 내부 저장소 |
| 콘솔 | 플랫폼 SDK의 공식 세이브 API로 추상화됨 |

`.sav` 파일은 바이너리 직렬화 포맷입니다. 에디터에서 내용 확인 불가.

---

## SaveGame Blueprint 에셋 만들기

1. Content Browser에서 우클릭 → **Blueprint Class** 선택
2. 부모 클래스 검색창에 `SaveGame` 입력 → `USaveGame` 선택
3. 에이름 규칙: `BP_MySaveGame`
4. 에디터에서 열어 **저장하고 싶은 변수를 추가**
   (int, float, bool, FString, Vector 등)
5. 변수의 **SaveGame 체크박스** 켜두기 (필터링 용도)

---

## GameInstance 활용

`UGameInstance`는 게임이 시작될 때 생성되어 **게임이 완전히 종료될 때까지 살아있는** 특수한 오브젝트입니다. 레벨이 바뀌어도, GameMode가 바뀌어도 살아남습니다.

**세이브 시스템과 함께 사용하는 이유:**
- 슬롯 이름 상수 보관 → 어디서든 참조 가능
- 현재 로드된 SaveGame 오브젝트를 캐싱 → 매 레벨마다 디스크에서 다시 읽을 필요 없음
- 레벨 전환 직전에 자동 저장 로직 연결 가능

Blueprint에서 GameInstance에 접근:
```
Get Game Instance → Cast To [내 GameInstance 클래스] → [변수/함수 접근]
```

---

## 아티스트 체크리스트

### 에셋 설정
- [ ] `BP_SaveGame` 에셋이 올바른 Content 폴더에 있는가?
- [ ] 저장할 변수들이 공개(BlueprintReadWrite)로 노출되어 있는가?
- [ ] Transient 변수(저장 불필요한 런타임 데이터)에 `Transient` 플래그가 켜져 있는가?

### Blueprint 연결
- [ ] `Create Save Game Object`에 올바른 SaveGame 클래스가 지정되어 있는가?
- [ ] `Save Game to Slot` / `Load Game from Slot`의 SlotName 문자열이 동일한가? (대소문자 구분)
- [ ] `Load Game from Slot` 이후 반드시 `Cast To BP_SaveGame`이 연결되어 있는가?
- [ ] Cast 실패(파일 없음)에 대한 처리가 있는가? (첫 실행 시 파일이 없음)

### 테스트
- [ ] PIE 실행 → 저장 → `Saved/SaveGames/` 폴더에 `.sav` 파일 생성 확인
- [ ] 다시 PIE 실행 → 로드 → 이전 데이터가 올바르게 복원되는가?
- [ ] 레벨 전환 후에도 데이터가 유지되는가?
- [ ] 저장 파일 삭제 후 첫 실행 시 크래시 없이 기본값으로 시작하는가?

### 주의사항
- 슬롯 이름 오타는 무음 버그(다른 파일 생성) → 상수로 관리
- 비동기 저장 중 게임 강제 종료 시 파일 손상 가능 → 저장 중 UI 표시 권장
