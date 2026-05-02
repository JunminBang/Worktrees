# 데이터 관리 — Gameplay Tags, DataAsset, DataTable, CurveTable

> 소스 경로: Runtime/GameplayTags/, Runtime/Engine/Classes/Engine/
> 아티스트를 위한 설명

---

## Gameplay Tags

### Gameplay Tags란?

Gameplay Tags는 게임 오브젝트에 "이름표(라벨)"를 붙이는 시스템입니다.

단순한 bool 변수(`bIsStunned`) 대신, **점(.)으로 구분된 계층 구조 텍스트**를 사용해 상태·능력·카테고리를 표현합니다.

**핵심 특징:**
- **계층형**: `Character.State.Stunned`는 자동으로 `Character.State`와 `Character`의 자식
- **매칭 규칙**: `"Character.State.Stunned".MatchesTag("Character.State")` → True
- **네트워크 최적화**: 내부적으로 uint16 숫자 인덱스로 압축

### 태그 네임스페이스 예시

```
Character.State.Stunned          ← 캐릭터 기절 상태
Character.State.Burning          ← 불타는 상태
Character.State.Invincible       ← 무적 상태

Ability.Fire                     ← 불 계열 스킬
Ability.Fire.Projectile          ← 불 계열 투사체 스킬
Ability.Ice.Slow                 ← 얼음 계열 감속 스킬

Item.Weapon.Sword                ← 검 아이템
Item.Consumable.Potion           ← 포션 소비 아이템

Damage.Type.Physical             ← 물리 피해
Damage.Type.Magical.Fire         ← 마법 화염 피해

GameplayCue.Hit.Fire             ← 불 공격 피격 이펙트 큐
GameEvent.BossSpawned            ← 보스 등장 이벤트
```

### 에디터에서 태그 생성/관리

1. 언리얼 에디터 상단 메뉴 → **Edit → Project Settings**
2. **Gameplay Tags** 검색
3. **Gameplay Tag List**에서 `+` 버튼으로 새 태그 추가
4. 태그 이름 입력: `Character.State.Stunned` 형식
5. **Dev Comment** 란에 태그 용도 설명 작성 권장
6. 저장 → `Config/DefaultGameplayTags.ini`에 자동 기록

Blueprint에서는 변수 타입을 `Gameplay Tag` 또는 `Gameplay Tag Container`로 설정하면 드롭다운으로 태그 선택 가능.

---

## DataAsset — 게임 데이터를 에셋으로 관리

### DataAsset이란?

`UDataAsset`은 게임 설정값·수치·참조 데이터를 **콘텐츠 브라우저 에셋 파일(.uasset)로 저장**하는 가장 단순한 방법입니다.

**사용 예시:**
- 캐릭터 스탯 DataAsset: 최대 체력, 이동 속도, 점프 높이
- 무기 DataAsset: 기본 데미지, 공격 속도, 메시 참조, 이펙트 참조

### DataAsset 작성 방법

1. 콘텐츠 브라우저 → 우클릭 → **Miscellaneous → Data Asset**
2. 상속할 클래스 선택 (프로그래머가 만든 C++ 클래스)
3. 에셋 이름은 `DA_` 접두사 사용 (예: `DA_SwordWeapon`)
4. 디테일 패널에서 값 직접 편집

### PrimaryDataAsset vs DataAsset

| 구분 | UDataAsset | UPrimaryDataAsset |
|------|-----------|-------------------|
| Asset Manager 등록 | 불가 | 가능 |
| 로드/언로드 제어 | 항상 메모리에 로드 | 수동으로 로드/언로드 가능 |
| 사용 시점 | 소규모, 단순 데이터 | 대규모, DLC, 메모리 최적화 필요 시 |

**선택 기준:**
- 항상 필요한 캐릭터 스탯 → `UDataAsset`
- 스킬·아이템·스테이지처럼 필요할 때만 로드 → `UPrimaryDataAsset`

---

## DataTable — CSV 기반 대량 데이터

### DataTable이란?

`UDataTable`은 **스프레드시트(CSV/JSON)를 언리얼 에셋으로 임포트**한 테이블입니다. 동일한 구조의 데이터가 여러 행(Row)으로 반복될 때 사용합니다.

**사용 예시: 아이템 목록**

| Name | DisplayName | Damage | Weight |
|------|------------|--------|--------|
| Sword_01 | 철검 | 50 | 5.0 |
| Sword_02 | 강철검 | 80 | 7.5 |
| Bow_01 | 단궁 | 30 | 2.0 |

### DataTable 작성 방법

1. 엑셀/구글 시트로 데이터 작성 → CSV로 내보내기
2. 콘텐츠 브라우저 → **Import** → CSV 파일 선택
3. 행 구조체(Row Struct) 선택 (프로그래머가 미리 만든 것)
4. 에셋 이름은 `DT_` 접두사 사용 (예: `DT_ItemList`)
5. 데이터 수정 시: 에셋 더블클릭 → DataTable 에디터에서 편집 or CSV 재임포트

### 주요 옵션

| 옵션 | 설명 |
|------|------|
| `bStripFromClientBuilds` | 클라이언트 빌드에서 제외 (서버 전용 민감 데이터) |
| `bIgnoreExtraFields` | CSV에 추가 열이 있어도 경고 무시 |
| `bPreserveExistingValues` | 누락된 필드에 기존 값 유지 |

---

## CurveTable — 레벨별 스탯 커브

### CurveTable이란?

`UCurveTable`은 **X축(입력값) → Y축(출력값) 커브를 여러 행으로 묶어 관리**하는 테이블입니다. 레벨에 따른 스탯 증가, 거리에 따른 데미지 감쇠 등에 사용합니다.

**커브 타입:**

| 타입 | 설명 |
|------|------|
| `SimpleCurves` | 선형 보간만 지원, 가볍고 빠름 |
| `RichCurves` | 베지어 곡선, 커스텀 접선 지원, 에디터에서 자유롭게 조형 |

**사용 예시: 레벨별 캐릭터 스탯**

| Level (X) | MaxHP | AttackPower | Defense |
|-----------|-------|-------------|---------|
| 1 | 100 | 10 | 5 |
| 10 | 500 | 45 | 22 |
| 30 | 1500 | 120 | 65 |
| 50 | 3000 | 250 | 130 |

### CurveTable 작성 방법

1. CSV로 커브 데이터 작성 (첫 열 = 행 이름, 첫 행 = X축 값)
2. 콘텐츠 브라우저 → Import → CSV 선택 → CurveTable로 임포트
3. 에셋 이름은 `CT_` 접두사 (예: `CT_CharacterLevelStats`)
4. 에셋 더블클릭 → 커브 에디터에서 각 포인트를 그래프로 조작 가능

---

## 요약 비교표

| 시스템 | 용도 | 파일 접두사 | 편집 도구 |
|--------|------|-----------|----------|
| **Gameplay Tags** | 상태/이벤트 라벨링 | 없음 | Project Settings 패널 |
| **DataAsset** | 단일 오브젝트 설정값 | `DA_` | 디테일 패널 |
| **PrimaryDataAsset** | 메모리 관리 필요한 설정값 | `DA_` | 디테일 패널 |
| **DataTable** | 동일 구조 대량 데이터 | `DT_` | DataTable 에디터 / CSV |
| **CurveTable** | X→Y 수치 커브 데이터 | `CT_` | 커브 에디터 / CSV |

---

## 아티스트 체크리스트

### DataAsset 작업 시
- [ ] 에셋 이름에 `DA_` 접두사를 붙였는가?
- [ ] 올바른 C++ 클래스를 선택했는가?
- [ ] 수치 단위가 기획서와 일치하는가? (cm vs m, 초 vs 밀리초 등)

### DataTable 작업 시
- [ ] 에셋 이름에 `DT_` 접두사를 붙였는가?
- [ ] CSV 첫 열이 `Name`인가? (행의 고유 키)
- [ ] 행 이름(Name)에 공백이나 특수문자가 없는가?
- [ ] 재임포트 후 기존 데이터가 의도대로 유지되는가?

### CurveTable 작업 시
- [ ] 에셋 이름에 `CT_` 접두사를 붙였는가?
- [ ] X축 값이 기획 범위를 전부 커버하는가?
- [ ] 커브 에디터에서 그래프에 이상값(스파이크)이 없는가?

### Gameplay Tags 작업 시
- [ ] 태그 이름이 `대분류.중분류.소분류` 계층 구조를 따르는가?
- [ ] Project Settings → Gameplay Tags에 등록했는가?
- [ ] 용도를 `Dev Comment`란에 기록했는가?
- [ ] Blueprint에서 드롭다운으로 정상 선택되는지 확인했는가?

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [09_gameplay_ability_system.md](09_gameplay_ability_system.md) | GameplayTag — GAS AbilityTag, StatusTag, CooldownTag 등 사용 |
| [18_save_load.md](18_save_load.md) | SaveGame — DataTable 참조 ID를 저장하는 패턴 |
| [21_blueprint_advanced.md](21_blueprint_advanced.md) | Blueprint에서 DataTable Row 읽기/쓰기 패턴 |
| [05_ai_navigation.md](05_ai_navigation.md) | Blackboard — AI 상태를 GameplayTag로 표현하는 패턴 |
| [06_ui_cinematics.md](06_ui_cinematics.md) | UI — DataTable에서 아이템명/텍스트 데이터 읽어 표시 |
| [22_plugins.md](22_plugins.md) | 플러그인으로 제공되는 DataAsset 확장 시스템 |
