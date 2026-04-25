---
name: UE5 월드 & 네트워크 & 에셋 관리
type: System
tags: unreal-engine, world-partition, level-streaming, landscape, foliage, networking, replication, asset-manager
source: raw-ingest
scene_verified: false
last_updated: 2026-04-19
---

# UE5 월드 & 네트워크 & 에셋 관리

> 소스 경로: Runtime/Engine/Classes/Engine/, Runtime/Landscape/, Runtime/Foliage/, Runtime/Net/, Runtime/AssetRegistry/
> 🔗 Engine Reference (UE5.7 API 변경): [modules/networking.md](../../docs/engine-reference/unreal/modules/networking.md)

---

## 월드 & 레벨

| 개념 | 역할 |
|------|------|
| World | 게임이 실행되는 전체 3D 공간 컨테이너 (항상 1개) |
| Level | 저장/로드 가능한 개별 맵 단위 (World 안에 여러 개 동시 로드 가능) |

---

## 레벨 스트리밍 & World Partition

**레벨 스트리밍**: 맵을 조각으로 나눠 필요할 때만 로드/언로드.
- `ULevelStreamingAlwaysLoaded` / `ULevelStreamingDynamic` / `ULevelStreamingVolume`

**World Partition** (오픈 월드): 대형 맵을 셀(Cell) 단위로 자동 분할, 카메라 주변만 스트리밍.
- 데이터 레이어(Data Layers): 낮/밤, 스토리 분기 등 조건부 레이어
- **권장**: 대형 오픈 월드 프로젝트에 필수

---

## Landscape & Foliage

| 항목 | Foliage | Landscape Grass |
|------|---------|----------------|
| 주체 | 독립 액터 시스템 | Landscape에 내장 |
| 용도 | 나무, 덤불, 바위 | 풀, 잔디 |
| 충돌 | 선택적 | 보통 없음 |

**성능**: Instancing으로 같은 메시를 GPU 1번 호출로 수천 개 렌더링.

---

## 네트워크 복제

```
서버에서 속성 변경
  → 변경된 속성만 클라이언트에 전송
  → 클라이언트 Actor 업데이트
  → OnRep_PropertyName() 콜백 실행 (선택)
```

| 키워드 | 의미 |
|--------|------|
| Replicated | 이 변수는 모든 클라이언트에 동기화 |
| Server | 이 함수는 서버에서만 실행 |
| Client | 이 함수는 클라이언트에서만 실행 |
| NetMulticast | 서버 + 모든 클라이언트 동시 실행 |

**Relevancy**: 멀리 있는 액터는 복제 안 함 → `NetCullDistanceSquared`로 거리 조정.

---

## 에셋 참조 종류

| 종류 | 설명 | 로드 시점 |
|------|------|---------|
| Hard Reference (UPROPERTY()) | 강한 참조 | 오너 로드 시 함께 자동 로드 |
| Soft Reference (TSoftObjectPtr) | 약한 참조 | 명시적으로 요청할 때만 로드 |

**원칙**: 항상 필요한 에셋 → Hard / 선택적 에셋 → Soft

---

## 텍스처 스트리밍

카메라 거리에 따라 텍스처 Mip Level 자동 교체.
- LOD Bias: 전체 해상도 강제로 낮춤
- Virtual Texture: 수 GB 대용량 텍스처 지원

---

## 아티스트 체크리스트

```
월드 설계:
✓ 대형 맵은 World Partition으로 셀 분할
✓ Foliage 밀도 성능에 영향 없는 수준인가?

멀티플레이:
✓ 복제 필요 변수에 Replicated 표시됨?
✓ 서버 전용 로직에 Server 표시됨?

에셋 관리:
✓ 항상 필요한 에셋만 Hard Reference
✓ 선택적 에셋은 Soft Reference로 지연 로드
```

---

## 관련 페이지
- [UE5 전체 개요](ue5_overview.md)
- [게임플레이 프레임워크](ue5_gameplay_framework.md)
- [StaticMesh 시스템](static_mesh.md)
- [UE5 렌더링 & 셰이더 시스템](ue5_rendering_shader.md)
