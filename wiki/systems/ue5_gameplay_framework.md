---
name: UE5 게임플레이 프레임워크 & 입력 시스템
type: System
tags: unreal-engine, gameplay, actor, character, gamemode, controller, input, enhanced-input
source: raw-ingest
scene_verified: false
last_updated: 2026-04-19
---

# UE5 게임플레이 프레임워크 & 입력 시스템

> 소스 경로: Runtime/Engine/Classes/GameFramework/, Runtime/InputCore/

---

## 계층 구조

| 계층 | 역할 | 비유 |
|------|------|------|
| World | 게임이 펼쳐지는 전체 공간 | 극장 건물 전체 |
| GameMode | 게임의 규칙 (서버 전용) | 연출 감독 |
| GameState | 게임의 현재 상태 (모든 클라이언트 동기화) | 스코어보드 |
| PlayerController | 플레이어 입력 → 캐릭터 조종 | 조종자 |
| Pawn / Character | 조종되는 물리적 존재 | 배우 |
| PlayerState | 플레이어 정보 (이름, 점수, 팀) | 프로그램 책자 |
| GameInstance | 맵 전환 후에도 유지 | 극장 운영 시스템 |

---

## 클래스 계층

```
AActor                        ← 레벨에 배치 가능한 모든 것의 기초
  └─ APawn                    ← 조종 가능한 액터
       └─ ACharacter          ← 스켈레탈 메시 + 이동 내장

AController
  ├─ APlayerController        ← 플레이어 입력 처리
  └─ AAIController            ← AI 로직 처리

AInfo
  └─ AGameModeBase            ← 게임 규칙 (서버에만 존재)
  └─ AGameStateBase           ← 모든 클라이언트에 동기화
```

---

## ACharacter 구성

- `UCapsuleComponent` — 충돌 캡슐 (루트)
- `USkeletalMeshComponent` — 3D 모델
- `UCharacterMovementComponent` — 걷기·점프·수영·낙하

**CharacterMovement 주요 수치**

| 속성 | 설명 | 예시 값 |
|------|------|---------|
| MaxWalkSpeed | 걷기 속도 (cm/s) | 느림=300, 보통=600, 빠름=1200 |
| JumpZVelocity | 점프 높이 | 낮음=300, 보통=600, 높음=1000 |
| GravityScale | 중력 배수 | 1.0=기본, 0.5=달처럼 둥실 |
| MaxStepHeight | 올라갈 수 있는 계단 높이 | 기본=45 |
| WalkableFloorAngle | 올라갈 수 있는 경사도 | 기본=44도 |

---

## 컴포넌트 시스템

| 컴포넌트 | 역할 |
|---------|------|
| SkeletalMeshComponent | 뼈대 3D 모델 (캐릭터 몸통) |
| StaticMeshComponent | 정적 3D 모델 (박스, 건물) |
| CapsuleComponent | 캡슐 충돌체 |
| CharacterMovementComponent | 이동·점프·중력 처리 |
| SpringArmComponent | 카메라 붐대 |
| CameraComponent | 실제 카메라 |

---

## 입력 시스템 (Enhanced Input)

```
플레이어 키 누름
  → PlayerController 감지
  → InputMappingContext 확인
  → InputAction 발동 (예: IA_Jump)
  → 바인딩된 함수 실행 → 캐릭터 점프
```

| 용어 | 역할 |
|------|------|
| InputMappingContext | 입력 설정 묶음 (게임 중/메뉴 중 각각 다른 설정) |
| InputAction | 게임 기능 단위 (IA_Jump, IA_Move, IA_Attack) |
| InputModifier | 입력값 변환 (감도, 데드존, 반전) |
| InputTrigger | 발동 조건 (눌렀을 때, 떼었을 때, 누르는 동안) |

---

## 멀티플레이 존재 위치

| 객체 | 서버 | 내 클라이언트 | 다른 클라이언트 |
|------|------|-------------|----------------|
| GameMode | ✅ | ❌ | ❌ |
| GameState | ✅ | ✅ | ✅ |
| 내 PlayerController | ✅ | ✅ | ❌ |
| 내 Character | ✅ | ✅ | ✅ (복제) |

---

## 아티스트 체크리스트

```
새 캐릭터 만들 때:
✓ ACharacter 기반 Blueprint 생성
✓ SkeletalMesh 할당
✓ AnimBlueprint 연결
✓ CapsuleComponent 크기 조정
✓ MaxWalkSpeed, JumpZVelocity 수치 조정
✓ InputMappingContext 할당
✓ 레벨에 PlayerStart 배치
```

---

## 관련 페이지
- [애니메이션 & 물리 시스템](ue5_animation_physics.md)
- [UE5 전체 개요](ue5_overview.md)
- [AI & 내비게이션](ue5_ai_navigation.md)
- [월드 & 네트워크 & 에셋](ue5_world_network.md)
