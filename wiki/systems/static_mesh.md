---
name: StaticMesh 시스템
type: system
tags: rendering, collision, actor
last_updated: 2026-04-09
---

# StaticMesh 시스템

## 개요

언리얼에서 StaticMesh 관련 클래스는 두 가지로 구분됨:

- **`UStaticMesh`** — 메시 에셋 자체 (geometry, LOD, 콜리전 데이터 보관)
- **`AStaticMeshActor`** — 레벨에 배치되는 액터 (UStaticMeshComponent를 가진 껍데기)

```
AStaticMeshActor
  └── UStaticMeshComponent   ← 실제 렌더링/충돌 담당
        └── UStaticMesh*     ← 에셋 참조 (공유됨)
```

## 핵심 동작

### 렌더링
- 런타임에 transform이 고정 → GPU 인스턴싱/배칭 최적화 가능
- Mobility가 Static이면 라이트맵 베이크 대상 → 이동 시 라이팅 재빌드 필요
- 같은 UStaticMesh를 참조하는 다수의 AStaticMeshActor는 자동으로 인스턴싱 처리됨

### 충돌
- `CollisionProfile`에 따라 `BlockAll`, `Overlap`, `NoCollision` 결정
- 콜리전이 없으면 플레이어가 통과함 — 눈에 보이지만 막히지 않는 버그의 주요 원인

### Mobility
| 값 | 의미 | 주의 |
|----|------|------|
| Static | 라이트맵 베이크 대상 | 런타임 이동 불가 |
| Stationary | 제한적 동적 라이팅 | |
| Movable | 완전 동적 | 성능 비용 높음 |

## 현재 씬에서 관찰된 패턴

- **스케일로 변형된 벽**: `SM_Cube3` 스케일 (2, 40, 2) — 1x1x1 큐브 메시를 Y축 40배로 늘려 긴 벽으로 사용
- **겹친 인스턴스**: `SM_Cylinder8/9` 동일 위치 — 같은 에셋의 인스턴스 2개 → [BUG-001](../bugs/BUG-001.md)
- **바닥 아래 배치**: `SM_QuarterCylinder9~12` Z=-100 — 의도적 숨김 또는 잘못된 배치

## 자주 묻는 디버그 질문

**Q. 오브젝트가 보이는데 충돌이 안 돼요**
→ UStaticMeshComponent의 CollisionProfile 확인. `NoCollision` 또는 `OverlapAll`로 설정돼 있을 가능성.

**Q. 오브젝트가 안 보여요**
→ 1) Visibility 체크 2) 스케일이 0인지 확인 3) Z값이 바닥 아래인지 확인 4) 다른 액터에 완전히 가려졌는지 확인

**Q. 같은 메시인데 하나만 라이팅이 이상해요**
→ Mobility 값이 다를 수 있음. Static vs Movable 혼용 시 발생.

## 관련 페이지
- [레벨 개요](../overview.md)
- [렌더링 파이프라인 & 기법](rendering.md)
- [UE5 렌더링 & 셰이더 시스템](ue5_rendering_shader.md)
- [UE5 월드 & 네트워크 & 에셋](ue5_world_network.md)
