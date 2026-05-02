# Control Rig — 절차적 애니메이션 리그

> 소스 경로: Engine/Plugins/Animation/ControlRig/Source/ControlRig/Public/
> 아티스트를 위한 설명

---

## Control Rig이란?

Control Rig은 UE5에 내장된 **절차적(Procedural) 애니메이션 리그 시스템**입니다.

Maya나 3ds Max 같은 DCC 툴의 리그를 언리얼 엔진 **안에서 직접** 만들고 실행할 수 있습니다. "절차적"이란 미리 구운(baked) 키프레임이 아니라 **매 프레임마다 수학적 규칙으로 포즈를 계산**한다는 뜻입니다.

**아티스트가 할 수 있는 것:**
- 팔꿈치 방향 컨트롤, 발 IK 컨트롤, 척추 FK 컨트롤 등을 엔진 안에서 직접 제작
- Sequencer에서 키프레임 애니메이션 제작
- 런타임에 발이 지형에 자동으로 맞는 절차적 발 배치
- 얼굴 표정 리그, 손가락 IK, 스파인 FK/IK 전환

---

## Rig Hierarchy 개념

### 요소 타입 (ERigElementType)

| 요소 | 역할 | 비유 |
|------|------|------|
| **Bone** | 실제 스켈레탈 메시의 뼈대 | Maya의 Joint |
| **Control** | 아티스트가 뷰포트에서 직접 잡고 움직이는 핸들 | Maya의 컨트롤 커브 |
| **Null (Space)** | 보이지 않는 좌표계 기준점 | Maya의 Group 노드 |
| **Curve** | 0~1 사이의 스칼라 값 채널. 모프 타겟 구동 등에 활용 | Set Driven Key 출력 |
| **Connector** | 모듈 간 연결점 (Modular Rig용) | - |

### 트랜스폼 타입

| 타입 | 설명 |
|------|------|
| **InitialLocal / InitialGlobal** | 기준 포즈 (바인드 포즈 = T/A 포즈) |
| **CurrentLocal / CurrentGlobal** | 현재 프레임에서 실제 계산된 포즈 |

---

## Forward / Backward Solve 개념

### Forward Solve (앞방향 계산)
- **컨트롤 → 뼈대** 방향으로 계산
- 아티스트가 컨트롤을 움직이면 뼈대 트랜스폼을 계산해 출력
- 런타임에 매 프레임 실행되는 **기본 실행 경로**
- 예: 팔 IK 컨트롤을 올리면 → IK 계산 → 팔꿈치·손목 포즈 결정

### Backward Solve (역방향 계산)
- **뼈대 → 컨트롤** 방향으로 계산
- 기존 애니메이션 클립의 뼈대 포즈를 역산하여 컨트롤 위치 계산
- **기존 FBX 애니메이션을 Control Rig으로 가져올 때(Baking)** 핵심

---

## IK 솔버 종류

### Two Bone IK
- 팔, 다리처럼 **정확히 2개 뼈대** 체인에 사용
- Root → Joint → End 구조 (예: 어깨 → 팔꿈치 → 손목)
- **Pole Vector** 지원: 팔꿈치나 무릎이 어느 방향을 향할지 제어
- Stretch 옵션: 타겟이 팔 길이보다 멀어지면 뼈를 늘릴지 여부

### FABRIK
- **N개 뼈대 체인** 모두 지원 (척추, 꼬리, 촉수 등)
- "Forward And Backward Reaching Inverse Kinematics" 알고리즘
- UE5에서 CCDIK 또는 Full Body IK 권장

### CCDIK
- 척추·꼬리·IK 체인에 활용
- FABRIK의 대안 (Cyclic Coordinate Descent 방식)

### Spring IK
- 물리 기반 스프링 동작으로 뼈대 체인을 흔들리게 함
- 옷자락, 머리카락, 꼬리 등에 활용

### Full Body IK (FBIK)
- UE5의 가장 강력한 IK 시스템
- **전신의 여러 이펙터를 동시에 제어** (양발 + 양손 + 머리 동시)
- 관절 제한(Angle Limit), 무게(Weight), 우선순위(Priority) 설정 가능
- Control Rig Blueprint에서 "Full Body IK" 노드로 사용

---

## 애니메이션 BP에서 Control Rig 연결

### 연결 방법

1. **애니메이션 블루프린트(ABP)** 열기
2. AnimGraph에서 **"Control Rig"** 노드 추가
3. 노드의 `ControlRigClass` 프로퍼티에 만들어둔 Control Rig 에셋 할당
4. 실행 순서: Evaluate → Control Rig Forward Solve → 최종 포즈 출력

### 공간(Space) 종류

| 공간 | 설명 |
|------|------|
| WorldSpace | 월드 절대 좌표 |
| ActorSpace | 액터 루트 기준 |
| ComponentSpace | 스켈레탈 메시 컴포넌트 기준 |
| LocalSpace | 각 요소의 부모 기준 로컬 공간 |

---

## Modular Rig (UE5.5+)

Control Rig을 **모듈 단위로 조립**하는 시스템:
- "팔 모듈", "다리 모듈", "척추 모듈"을 각각 만들어 캐릭터에 조립
- `Connector` 타입 요소를 통해 모듈 간 연결
- 인간형 외 사족보행, 다관절 캐릭터에 재사용성 극대화

---

## 아티스트 워크플로우 예시

### 얼굴 리그
```
1. 눈썹·눈꺼풀·입 코너 등에 Control 요소 배치
2. Curve 채널로 모프 타겟(표정 블렌드셰이프) 값 연결
3. Control 움직임 → Curve 값 변화 → 모프 타겟 구동
4. Sequencer에서 Control을 직접 키프레임
```

### 손 IK
```
1. 손목에 IK Control, 팔꿈치 방향에 Pole Vector Control 배치
2. Two Bone IK 노드 연결 (어깨 → 팔꿈치 → 손목)
3. 손가락에 FK Control 추가
4. 런타임에 무기를 잡거나 벽을 짚을 때 절차적 보정
```

### 발 IK (Foot Placement)
```
1. 각 발에 IK Control 배치 (월드 스페이스 고정)
2. 라인 트레이스로 지형 높이 감지 → Control 위치 업데이트
3. Two Bone IK로 다리 포즈 재계산
4. 발목 회전을 지형 법선 벡터에 맞춰 적용
```

---

## 아티스트 체크리스트

### Control Rig 제작 시
- [ ] Rig Hierarchy의 Bone 이름이 스켈레탈 메시와 정확히 일치하는가?
- [ ] Control 요소의 Shape와 Color를 용도별로 구분했는가?
  - (FK=원형 파란색, IK=큐브 빨간색 등)
- [ ] Null/Space 요소를 Control의 부모로 사용했는가?
- [ ] Initial Transform(바인드 포즈)을 기준 포즈에서 정확히 설정했는가?
- [ ] Forward Solve가 정상 동작하는지 컨트롤 조작으로 확인했는가?

### IK 설정 시
- [ ] Two Bone IK: Pole Vector 방향이 자연스러운 관절 굽힘 방향인가?
- [ ] FABRIK/CCDIK: MaxIterations(10~20)와 Precision 값이 설정되어 있는가?
- [ ] Stretch 기능 사용 시 StretchStartRatio(보통 0.75) 조정이 됐는가?
- [ ] IK Weight 값으로 FK와 IK 간 블렌딩이 설정됐는가?

### 애니메이션 BP 연결 시
- [ ] AnimGraph에서 ControlRigClass가 올바르게 할당되어 있는가?
- [ ] `LODThreshold` 설정으로 원거리에서 Control Rig이 비활성화되는가?
- [ ] Backward Solve로 기존 애니메이션을 올바르게 베이킹했는가?

### 런타임 퍼포먼스
- [ ] Control Rig은 매 프레임 CPU에서 실행됨 → 불필요한 노드 제거
- [ ] 원거리 LOD에서 Control Rig 솔버가 비활성화되는가?
- [ ] Full Body IK는 이펙터 수를 최소화했는가?

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [03_animation_physics.md](03_animation_physics.md) | AnimBlueprint — Control Rig 노드를 AnimGraph에 연결 |
| [26_skeletal_mesh_lod.md](26_skeletal_mesh_lod.md) | Skeleton 계층 구조 — Control Rig의 Bone 요소 기반 |
| [47_socket_system.md](47_socket_system.md) | 소켓 — Control Rig과 함께 사용하는 뼈대 연결 지점 |
| [28_motion_warping.md](28_motion_warping.md) | Motion Warping — Control Rig IK와 결합한 위치 보정 |
| [36_sequencer_advanced.md](36_sequencer_advanced.md) | Sequencer에서 Control Rig 컨트롤로 키프레임 애니메이션 제작 |
| [48_collision_trace.md](48_collision_trace.md) | Line Trace — 발 IK 배치에서 지형 높이 감지에 활용 |
