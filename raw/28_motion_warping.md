# Motion Warping — 애니메이션 위치 자동 보정

> 소스 경로: Engine/Plugins/Runtime/MotionWarping/Source/MotionWarping/Public/
> 아티스트를 위한 설명

---

## Motion Warping이란?

Motion Warping은 **루트 모션 애니메이션을 런타임에 목표 위치/회전에 맞춰 자동 보정**하는 시스템입니다.

**비유:** GPS 네비게이션 — 미리 녹화된 경로(애니메이션)가 있지만, 목적지(Warp Target)가 바뀌면 경로를 자동으로 재계산해 도착합니다. 손으로 하나하나 맞추지 않아도 됩니다.

**없을 때의 문제:**
- 캐릭터가 문 손잡이 앞에 서 있지만 손이 허공을 잡음
- 벽을 오르는 애니메이션이 실제 벽 높이와 맞지 않음
- 근접 처형 애니메이션이 적과 위치가 어긋남

**Motion Warping 사용 후:**
- 대상 위치에 따라 애니메이션이 자동으로 늘어나거나 줄어들어 정확히 맞음

---

## 사용 사례

| 사례 | 설명 |
|------|------|
| **오르기 (Climb)** | 다양한 높이의 선반/난간에 맞춰 팔 위치 자동 조정 |
| **뛰어넘기 (Vault)** | 장애물 높이에 따른 도약 궤적 보정 |
| **근접 처형 (Execution)** | 적 위치에 정확히 달라붙어 처형 모션 실행 |
| **문/스위치 상호작용** | 손잡이/버튼 위치에 손이 정확히 닿도록 보정 |
| **착지 (Landing)** | 지형 높이에 따른 착지 자세 보정 |

---

## 설정 방법

### 1. MotionWarpingComponent 추가

캐릭터 Blueprint에 `MotionWarpingComponent`를 추가합니다:

1. Character Blueprint 열기
2. Components 패널 → `+Add` → `Motion Warping` 검색 → 추가

### 2. 루트 모션 확인

Motion Warping은 **루트 모션(Root Motion)이 있는 애니메이션**에서만 동작합니다:
- 애니메이션 에셋 더블클릭 → Asset Details → `Enable Root Motion` 체크

### 3. Anim Notify 추가

애니메이션에서 워프가 적용될 구간을 지정합니다:

1. 애니메이션 에디터 열기
2. Notifies 트랙에 `AnimNotify_MotionWarping` 추가
   - `Notify Begin`: 워프 시작 프레임
   - `Notify End`: 워프 종료 프레임
3. **Warp Target Name** 입력 (예: `"ClimbTarget"`)
4. **Root Motion Modifier** 선택

---

## Root Motion Modifier 종류

| 수정자 | 설명 | 용도 |
|--------|------|------|
| **Skew Warp** | 이동 궤적을 목표를 향해 기울임 | 일반적인 위치 이동 보정 (기본 추천) |
| **Scale** | 전체 루트 모션을 비율로 늘리거나 줄임 | 간단한 거리 조정 |
| **Simple Warp** | 위치+회전 모두 단순 보정 | 간단한 상호작용 |

---

## Blueprint에서 Warp Target 설정

캐릭터가 특정 행동을 할 때 Target 위치를 등록합니다:

```
[오르기 시도 시]
→ Line Trace → HitResult (벽/선반 위치)
→ Add or Update Warp Target from Location
    Component: MotionWarpingComponent
    Warp Target Name: "ClimbTarget"
    Location: HitResult.Location
    Rotation: HitResult.Normal을 Rotator로 변환

→ Play Montage (오르기 애니메이션)
```

### 주요 노드

| 노드 | 설명 |
|------|------|
| `Add Or Update Warp Target From Location` | 위치 기반 타겟 등록/갱신 |
| `Add Or Update Warp Target From Transform` | 위치+회전 기반 타겟 등록/갱신 |
| `Add Or Update Warp Target From Component` | 컴포넌트 트랜스폼을 타겟으로 등록 |
| `Remove Warp Target` | 타겟 제거 |

---

## 워프 파라미터 상세

`AnimNotify_MotionWarping` 디테일에서 조정:

| 파라미터 | 설명 |
|---------|------|
| `Warp Target Name` | Blueprint에서 등록한 타겟 이름과 일치해야 함 |
| `Warp Point Anim Provider` | 타겟 기준점 (Default=루트, 또는 소켓 지정) |
| `Warp Translation` | 위치 워프 활성화 여부 |
| `Warp Rotation` | 회전 워프 활성화 여부 |
| `Rotation Type` | Facing/Default 등 회전 보정 방식 |
| `Warp Rotation Time Multiplier` | 회전 보정 속도 배율 |
| `Max Rotation Rate` | 최대 회전 속도 제한 (도/초) |

---

## IK Rig과의 병용

Motion Warping으로 전체 위치를 보정하고, IK Rig으로 손/발 위치를 세밀하게 맞출 수 있습니다:

```
Motion Warping: 몸 전체 위치를 벽 가까이 이동
  ↓
Control Rig / IK: 손이 정확히 손잡이/홈에 닿도록 미세 보정
```

---

## 주의사항

| 주의 | 설명 |
|------|------|
| 루트 모션 필수 | `Enable Root Motion`이 OFF이면 동작 안 함 |
| Warp 구간 제한 | 애니메이션 전체가 아닌 특정 구간에만 적용 |
| 과도한 워프 방지 | 목표가 너무 멀면 애니메이션이 부자연스럽게 늘어남 |
| 타겟 이름 일치 | Notify의 이름과 Blueprint 등록 이름이 정확히 동일해야 함 |
| 캐릭터 Mobility | 캐릭터 무브먼트 컴포넌트의 `Max Rotation Rate` 설정과 충돌 주의 |

---

## 아티스트 체크리스트

### 애니메이션 설정
- [ ] 대상 애니메이션에 `Enable Root Motion`이 켜져 있는가?
- [ ] `AnimNotify_MotionWarping`이 올바른 프레임 구간에 배치되었는가?
- [ ] Warp Target Name이 Blueprint 등록 이름과 정확히 일치하는가?
- [ ] 워프 구간의 시작/끝 프레임이 자연스러운 모션 구간인가?

### Blueprint 설정
- [ ] MotionWarpingComponent가 캐릭터에 추가되어 있는가?
- [ ] Warp Target 등록이 Montage 재생 이전에 호출되는가?
- [ ] 목표 위치/회전이 올바르게 계산되어 등록되는가?

### 결과 검증
- [ ] PIE에서 다양한 위치/각도에서 테스트했는가?
- [ ] 워프 범위를 초과하는 극단적 위치에서도 크래시/오류가 없는가?
- [ ] 워프 후 회전이 의도한 방향을 향하는가?
