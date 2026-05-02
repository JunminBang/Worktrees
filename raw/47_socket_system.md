# 소켓 시스템 — 무기 부착 & 오브젝트 연결

> 소스 경로: Runtime/Engine/Classes/Engine/SkeletalMeshSocket.h
> 아티스트를 위한 설명

---

## 소켓이란?

소켓(Socket)은 **메시의 특정 위치에 이름을 붙인 부착 기준점**입니다. 스켈레탈 메시의 뼈대(Bone)에 붙이거나, 스태틱 메시의 임의 위치에 추가할 수 있습니다.

**비유:** LEGO의 연결 핀 — 정해진 위치에만 다른 블록을 꽂을 수 있는 규격화된 연결 지점입니다.

**대표 사용 사례:**
- 손에 무기/아이템 부착 (`Socket_RightHand`)
- 총구 위치에서 총알/이펙트 스폰 (`Socket_Muzzle`)
- 등에 활/검 장착 (`Socket_BackWeapon`)
- 머리 위 UI/마크 위치 (`Socket_HeadTop`)
- 발밑 먼지 이펙트 (`Socket_LeftFoot`, `Socket_RightFoot`)

---

## 스켈레탈 메시 소켓 생성

1. **스켈레탈 메시 에디터** 열기 (캐릭터 메시 더블클릭)
2. **Skeleton Tree** 패널에서 소켓을 붙일 뼈대 우클릭
3. **Add Socket** 선택
4. 소켓 이름 입력 (예: `hand_r_weapon`)
5. 뷰포트에서 위치/회전 직접 조정

### 소켓 미리보기

스켈레탈 메시 에디터 → Skeleton Tree → 소켓 우클릭 → **Add Preview Asset** → 무기 메시 선택
→ 실제 게임처럼 위치 미리보기 가능

---

## 스태틱 메시 소켓 생성

1. **스태틱 메시 에디터** 열기
2. **Sockets** 패널 → `+Socket` 클릭
3. 이름 및 위치/회전 설정

---

## 네이밍 컨벤션

일관된 소켓 이름 규칙을 팀 전체에서 통일하는 것이 중요합니다.

| 소켓 이름 | 용도 |
|---------|------|
| `Socket_RightHand` / `hand_r` | 오른손 부착 |
| `Socket_LeftHand` / `hand_l` | 왼손 부착 |
| `Socket_Muzzle` | 총구 이펙트/발사 위치 |
| `Socket_Spine` | 등 무기 |
| `Socket_Head` | 머리 부착 (헬멧, 마커) |
| `Socket_Root` | 루트 기준점 |
| `Socket_FootL` / `Socket_FootR` | 발 이펙트 |

---

## Blueprint에서 소켓 활용

### 소켓 위치/회전 가져오기

```
→ Get Socket Location
    Target: Mesh Component
    Socket Name: "Socket_Muzzle"
→ 반환: 월드 위치 (Vector)

→ Get Socket Transform
    → 위치+회전+스케일 모두 반환
```

### 총구에서 이펙트 스폰

```
[발사 시]
→ Get Socket Location ("Socket_Muzzle")
→ Get Socket Rotation ("Socket_Muzzle")
→ Spawn Emitter at Location
    Location: Socket 위치
    Rotation: Socket 회전
```

### 무기 액터 부착 (Attach)

```
[무기 장착]
→ Spawn Actor (BP_Sword)
→ Attach Actor to Component
    Parent: Character Mesh
    Socket Name: "Socket_RightHand"
    Attachment Rule: Keep Relative / Snap to Target

[무기 해제]
→ Detach From Actor
    Rules: Keep World
```

### 소켓에 파티클 붙이기

```
→ Spawn Emitter Attached
    Template: NS_FootDust
    Attach to Component: Character Mesh
    Socket Name: "Socket_FootL"
    Location Type: Snap to Target
```

---

## AttachmentTransformRules — 부착 옵션

| 규칙 | 설명 |
|------|------|
| `KeepRelativeTransform` | 부착 후 상대 위치 유지 |
| `KeepWorldTransform` | 부착 후 월드 위치 유지 (소켓 위치로 이동 안 함) |
| `SnapToTargetNotIncludingScale` | 소켓에 딱 맞춰 붙음 (스케일 제외) |
| `SnapToTargetIncludingScale` | 소켓에 딱 맞춰 붙음 (스케일 포함) |

> **무기 장착에는 `SnapToTargetNotIncludingScale`** 이 가장 일반적입니다.

---

## 소켓 오프셋 조정

소켓 위치가 맞지 않을 때 Blueprint에서 오프셋 적용:

```
→ Attach Actor to Component (소켓에 부착)
→ Set Relative Location (오프셋 미세 조정)
→ Set Relative Rotation (회전 미세 조정)
```

또는 소켓 에디터에서 위치/회전을 직접 수정하는 것이 더 깔끔합니다.

---

## Anim Notify와 소켓 연동

애니메이션 특정 프레임에서 소켓 기반 이벤트 실행:

```
애니메이션 에디터 → Notify 트랙 → Add Notify → AnimNotify_PlayParticleEffect
  → Socket Name: "Socket_FootL"
  → Particle System: NS_FootStep
→ 발이 땅에 닿는 순간 정확히 먼지 이펙트 재생
```

---

## 아티스트 체크리스트

### 소켓 배치
- [ ] 소켓 이름이 팀 컨벤션을 따르는가?
- [ ] Preview Asset으로 무기/오브젝트가 올바른 위치/회전에 있는지 확인했는가?
- [ ] 발 소켓이 발바닥 중앙에 위치하는가?
- [ ] 총구 소켓이 총신 끝, 올바른 발사 방향을 향하는가?

### Blueprint 연결
- [ ] `GetSocketLocation` 호출 시 컴포넌트가 유효한지(`IsValid`) 확인하는가?
- [ ] `AttachActorToComponent`에서 Socket Name 오타가 없는가?
- [ ] 부착 규칙(`SnapToTarget`)이 올바르게 선택되어 있는가?

### Anim Notify 연동
- [ ] 발 착지 프레임에 소켓 이펙트 Notify가 배치되어 있는가?
- [ ] 총 발사 애니메이션의 발사 프레임에 이펙트 Notify가 있는가?

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [03_animation_physics.md](03_animation_physics.md) | AnimNotify — 발/총구 소켓 이펙트 발동 타이밍 설정 |
| [15_control_rig.md](15_control_rig.md) | Control Rig — 소켓이 부착되는 뼈대(Bone) 구조 |
| [48_collision_trace.md](48_collision_trace.md) | Line Trace 시작점으로 Socket_Muzzle 위치 사용 |
| [42_staticmesh_advanced.md](42_staticmesh_advanced.md) | 스태틱 메시 소켓 생성 방법 |
| [32_niagara_advanced.md](32_niagara_advanced.md) | 소켓 위치에 Niagara 이펙트 Spawn Attached |
| [04_audio_effects.md](04_audio_effects.md) | 소켓 위치에서 3D 사운드 재생 (발소리, 총구음) |
