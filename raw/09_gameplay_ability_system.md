# GAS (Gameplay Ability System)

> 소스 경로: Engine/Plugins/Runtime/GameplayAbilities/Source/GameplayAbilities/
> 아티스트를 위한 설명

---

## GAS 개요

GAS는 언리얼 엔진의 **게임플레이 능력 시스템**으로, 캐릭터의 스킬·버프/디버프·체력·마나 같은 수치·쿨다운·비용 소모 등 전투와 관련된 거의 모든 것을 체계적으로 관리하는 플러그인입니다.

RPG의 마법 시스템, FPS의 궁극기, 액션 게임의 콤보 스킬처럼 "캐릭터가 무언가를 할 수 있다"는 개념을 일관된 방식으로 구현합니다.

```
조건 체크 → 비용 소모 → 쿨다운 시작 → 이펙트 재생 → 수치 변경
```

---

## 핵심 구성요소 5가지

```
캐릭터 (Actor)
  └── AbilitySystemComponent ←── 모든 GAS 기능의 본부
        ├── AttributeSet ←──────── 수치 창고 (HP, MP, ATK...)
        ├── GameplayAbility ←───── 스킬 카드 (공격, 점프, 힐...)
        │     ├── Cost GE ─────── 비용 처방전
        │     └── Cooldown GE ─── 쿨다운 처방전
        ├── GameplayEffect ←────── 효과 처방전 (버프, 피해, 회복)
        │     └── GameplayCue ─── 비주얼/사운드 신호
        └── GameplayTag ←───────── 상태 메모지 (기절, 화상, 버프 중...)
```

---

### 1. AbilitySystemComponent (ASC)

**비유:** 캐릭터의 **스킬북 + 상태 관리자 + 네트워크 통신사**를 합쳐놓은 것입니다.

- GAS를 쓰는 모든 캐릭터/액터에 반드시 부착
- 어빌리티 부여(Give) 및 실행(Activate) 창구
- 현재 활성 GameplayEffect 목록 보관
- AttributeSet 할당 및 관리
- 네트워크 복제(Replication) 처리

**Replication Mode 설정:**

| 모드 | 적합한 상황 |
|------|-----------|
| `Full` | 싱글플레이 |
| `Mixed` | 멀티플레이 플레이어 캐릭터 |
| `Minimal` | 멀티플레이 AI 캐릭터 |

---

### 2. GameplayAbility (GA)

**비유:** 캐릭터가 사용할 수 있는 **기술 카드** 한 장입니다.

파이어볼, 점프, 구르기, 도발, 궁극기 등이 각각의 GA입니다.

**에디터 주요 설정:**

| 항목 | 설명 |
|------|------|
| `CostGameplayEffectClass` | 스킬 사용 비용 (마나/스태미나를 깎는 GE 연결) |
| `CooldownGameplayEffectClass` | 쿨다운 (재사용 대기 시간 GE 연결) |
| `AbilityTags` | 이 스킬을 식별하는 태그 |
| `ActivationRequiredTags` | 이 태그가 있어야만 발동 가능 |
| `ActivationBlockedTags` | 이 태그가 있으면 발동 불가 |
| `CancelAbilitiesWithTag` | 이 스킬이 실행되면 해당 태그의 스킬 강제 취소 |
| `ActivationOwnedTags` | 스킬 활성화 중 캐릭터에 자동으로 붙는 태그 |
| `InstancingPolicy` | NonInstanced / PerActor / PerExecution |
| `NetExecutionPolicy` | 클라이언트/서버 실행 위치 |

---

### 3. GameplayEffect (GE)

**비유:** 어트리뷰트(수치)를 바꾸거나 태그를 붙이는 **처방전**입니다.

**지속 시간 유형:**

| 유형 | 설명 | 사용 예 |
|------|------|---------|
| `Instant` | 즉시 적용 후 사라짐 | 피해, 즉시 회복 |
| `HasDuration` | 설정한 시간 동안 유지 | 방어력 버프 3초 |
| `Infinite` | 수동으로 제거할 때까지 영구 | 패시브 능력, 장착 효과 |

**Modifier 연산 방식:**

| 연산 | 설명 | 예시 |
|------|------|------|
| `Add` | 수치에 더하기/빼기 | 체력 -30 |
| `Multiply` | 수치에 곱하기 | 이동속도 × 0.5 |
| `Override` | 수치를 완전히 덮어쓰기 | 체력 강제 100 |

**에디터 주요 설정:**

| 항목 | 설명 |
|------|------|
| `DurationPolicy` | 지속 시간 유형 |
| `DurationMagnitude` | 효과 지속 시간 (초) |
| `Period` | 주기적 적용 간격 (독 데미지 등) |
| `Modifiers` | 어트리뷰트를 얼마나, 어떻게 바꿀지 |
| `GameplayCues` | 효과 적용 시 재생할 이펙트 태그 |
| `GrantedTags` | 효과 적용 중 부여하는 상태 태그 |
| `Stacking` | 중첩(스택) 허용 여부와 최대 스택 수 |

---

### 4. GameplayTag

**비유:** 캐릭터에 붙이는 **포스트잇 메모지**입니다.

```
Ability.Attack.Melee        ← 근접 공격 스킬
Ability.Attack.Ranged       ← 원거리 공격 스킬
Status.Stun                 ← 기절 상태
Status.Burn                 ← 화상 상태
GameplayCue.Hit.Fire        ← 불 공격 피격 이펙트 큐
GameplayCue.Buff.Haste      ← 속도 버프 이펙트 큐
```

**활용 흐름:**
```
캐릭터가 "Status.Stun" 태그를 가지고 있음
→ GA의 ActivationBlockedTags에 "Status.Stun" 등록
→ 기절 중엔 모든 스킬 자동 차단
→ 기절 GE 만료 → 태그 자동 제거 → 스킬 재사용 가능
```

---

### 5. AttributeSet

**비유:** 캐릭터의 **스탯 시트(능력치 표)**입니다.

```
FGameplayAttributeData
  ├── BaseValue    ← 영구적 기본 수치 (레벨업, 장비 등이 바꿈)
  └── CurrentValue ← 실시간 수치 (버프/디버프 포함, 표시값)
```

**일반적으로 포함되는 어트리뷰트:**
- `Health` / `MaxHealth` — 현재 체력 / 최대 체력
- `Mana` / `MaxMana` — 현재 마나 / 최대 마나
- `AttackPower` — 공격력
- `Defense` — 방어력
- `MoveSpeed` — 이동 속도

> **아티스트 주의:** AttributeSet은 C++ 프로그래머가 정의합니다. 아티스트는 GameplayEffect를 통해 이 수치들을 참조·수정합니다.

---

## GameplayCue — 비주얼/사운드 연결

GAS 이벤트 발생 시 재생할 VFX·SFX·카메라 이펙트를 연결하는 채널.

| 종류 | 설명 | 사용 예 |
|------|------|---------|
| `GameplayCueNotify_Static` | 순간 이벤트 | 총 피격 파티클 |
| `GameplayCueNotify_Actor` | 지속 이펙트 (액터 스폰) | 화염 버프 지속 이펙트 |
| `GameplayCueNotify_Burst` | 즉발형 | 폭발 이펙트 |
| `GameplayCueNotify_Looping` | 반복 재생형 | 독 상태 파티클 루프 |

**이벤트 타이밍:**
- `OnExecute` — 즉발 GE 적용 순간
- `OnActive` — 지속 GE 처음 적용될 때
- `WhileActive` — 지속 GE 유지되는 동안
- `OnRemove` — 지속 GE 제거될 때

> GameplayCue 태그는 반드시 `GameplayCue.`으로 시작해야 합니다.

---

## 흔한 사용 패턴

### 패턴 1: 공격 (즉발 피해)
```
[플레이어 입력]
→ GA_MeleeAttack 발동
  → CommitAbility() — 마나 30 소모
  → 몽타주 재생
  → GE_MeleeDamage 적용 (Health -50, Instant)
    → GameplayCue.Hit.Melee → 타격 파티클 + 사운드
```

### 패턴 2: 버프 (시간 제한)
```
[버프 아이템 사용]
→ GE_SpeedBuff 적용 (MoveSpeed × 1.5, HasDuration 5초)
  → 태그 "Status.Hasted" 부여
  → GameplayCue.Buff.Speed → 속도 파티클 루프 시작
→ 5초 후 GE 만료
  → 태그 "Status.Hasted" 제거
  → GameplayCue OnRemove → 파티클 종료
```

### 패턴 3: 상태이상 (기절)
```
[피격]
→ GE_Stun 적용 (HasDuration 2초)
  → 태그 "Status.Stunned" 부여
  → 모든 스킬 ActivationBlockedTags에 "Status.Stunned" 등록 → 차단
→ 2초 후 GE 만료 → 태그 제거 → 스킬 재사용
```

### 패턴 4: 도트(DoT) 피해
```
GE_PoisonDamage 설정:
  DurationPolicy: HasDuration (10초)
  Period: 1.0 (매 1초마다 적용)
  Modifier: Health Add -5
  → 10초 동안 1초마다 체력 5 감소
```

---

## 아티스트 체크리스트

### GameplayAbility 제작 시
- [ ] Blueprint 부모 클래스가 `UGameplayAbility`인가?
- [ ] `AbilityTags`에 고유 식별 태그가 있는가?
- [ ] 비용 GE가 `CostGameplayEffectClass`에 연결되어 있는가?
- [ ] 쿨다운 GE가 `CooldownGameplayEffectClass`에 연결되어 있는가?
- [ ] 발동 조건/차단 태그가 올바르게 설정되어 있는가?

### GameplayEffect 제작 시
- [ ] `DurationPolicy`가 의도한 유형인가?
- [ ] `Modifiers`에서 올바른 Attribute와 연산이 설정되어 있는가?
- [ ] 비주얼 피드백이 `GameplayCues`에 연결되어 있는가?
- [ ] GameplayCue 태그가 `GameplayCue.`으로 시작하는가?

### GameplayCueNotify 제작 시
- [ ] `OnRemove`에서 지속 이펙트가 반드시 종료되는가?
- [ ] 에셋이 올바른 GameplayCue 경로에 있는가?
- [ ] 저장 후 GameplayCue Manager를 리스캔했는가?

### 전체 세팅
- [ ] 캐릭터에 `AbilitySystemComponent`가 부착되어 있는가?
- [ ] `Replication Mode`가 환경(싱글/멀티)에 맞게 설정되어 있는가?
- [ ] AttributeSet이 ASC에 등록되어 있는가?
- [ ] 사용하는 GameplayTag가 프로젝트 세팅에 등록되어 있는가?

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [01_gameplay_framework.md](01_gameplay_framework.md) | Actor/Character — ASC를 부착하는 기반 클래스 |
| [16_data_management.md](16_data_management.md) | GameplayTag 등록 및 관리, DataAsset으로 어빌리티 설정 관리 |
| [21_blueprint_advanced.md](21_blueprint_advanced.md) | Blueprint Interface — GA 발동 입력 처리 패턴 |
| [48_collision_trace.md](48_collision_trace.md) | Line Trace — 근접/원거리 공격 히트 감지 후 GE 적용 |
| [04_audio_effects.md](04_audio_effects.md) | GameplayCue에서 Niagara VFX / SoundCue 연결 |
| [44_character_movement.md](44_character_movement.md) | GE로 이동속도(MoveSpeed) 어트리뷰트 조정 |
| [26_skeletal_mesh_lod.md](26_skeletal_mesh_lod.md) | Morph Target — GE 적용 시 표정/상태 변화 비주얼 |
