# 월드 & 네트워크 & 에셋 관리

> 소스 경로: Runtime/Engine/Classes/Engine/, Runtime/Landscape/, Runtime/Foliage/, Runtime/Net/, Runtime/AssetRegistry/
> 아티스트를 위한 설명

---

## 월드(World)와 레벨(Level)의 차이

```
소스:
  Runtime/Engine/Classes/Engine/World.h
  Runtime/Engine/Classes/Engine/Level.h
```

| 개념 | 역할 | 비유 |
|------|------|------|
| **World** | 게임이 실행되는 전체 3D 공간 컨테이너 | 스튜디오 전체 |
| **Level** | 저장/로드 가능한 개별 맵 단위 | 스튜디오 안의 세트장 |

- World는 항상 1개
- World 안에 여러 Level이 동시에 로드될 수 있음
- Level에는 배치된 액터들 + 빌드 데이터(라이트맵 등) 포함

### ALevelScriptActor

레벨 전용 블루프린트 이벤트 핸들러.
레벨 블루프린트에서 작성하는 이벤트가 이 클래스로 처리됨.

---

## 레벨 스트리밍 & World Partition

### 레벨 스트리밍 (LevelStreaming)

```
소스: Runtime/Engine/Classes/Engine/LevelStreaming.h
```

맵을 여러 조각으로 나눠 필요할 때만 로드/언로드.

```
메인 레벨 (항상 로드)
├── 존 A 레벨 (플레이어 근처 → 로드)
├── 존 B 레벨 (멀어지면 → 언로드)
└── 존 C 레벨 (필요 시 → 로드)
```

**스트리밍 방식**

| 클래스 | 방식 |
|--------|------|
| `ULevelStreamingAlwaysLoaded` | 항상 로드 |
| `ULevelStreamingDynamic` | 런타임 동적 로드/언로드 |
| `ULevelStreamingVolume` | 볼륨 기반 자동 트리거 |

### World Partition (오픈 월드)

대형 맵을 **셀(Cell)** 단위로 자동 분할하고 카메라 주변만 스트리밍.

- 무한에 가까운 오픈 월드 가능
- 에디터에서 셀 크기 조정
- **데이터 레이어(Data Layers)**: 낮/밤, 스토리 분기 등 조건부 레이어

**권장**: 대형 오픈 월드 프로젝트는 World Partition 필수

---

## Landscape (지형 시스템)

```
소스: Runtime/Landscape/Classes/
  Landscape.h              ← 지형 액터
  LandscapeComponent.h     ← 지형 섹션 (렌더링 + 충돌)
  LandscapeInfo.h          ← 메타데이터
  LandscapeLayerInfoObject.h ← 페인트 레이어
  LandscapeGrassType.h     ← 내장 그래스
```

### 구조

```
ALandscape
├── ULandscapeComponent × N  (섹션 분할 렌더링)
│   ├── 높이맵 데이터
│   ├── 웨이트맵 (레이어 블렌드)
│   └── 렌더링 메시
├── ULandscapeHeightfieldCollisionComponent (물리)
└── ULandscapeInfo (편집 메타데이터)
```

### 충돌 방식

| 방식 | 특징 |
|------|------|
| Heightfield Collision | 빠름, 높이맵 기반 |
| Mesh Collision | 정확함, 복잡한 지형용 |

### 아티스트가 알아야 할 것

- 지형 그래스는 Foliage가 아닌 Landscape에 내장 (`ULandscapeGrassType`)
- 각 컴포넌트는 독립적으로 LOD 처리 → 성능 최적화
- 텍스처 레이어 페인팅은 에디터 Landscape 모드에서 직접 수행

---

## Foliage (식생 시스템)

```
소스: Runtime/Foliage/Public/
  InstancedFoliage.h          ← 핵심 클래스
  FoliageType.h               ← 식생 타입 기본 클래스
  FoliageType_InstancedStaticMesh.h ← ISM 기반 식생
  ProceduralFoliageComponent.h ← 절차적 자동 배치
```

### Foliage vs Landscape Grass 차이

| 항목 | Foliage | Landscape Grass |
|------|---------|----------------|
| 주체 | 독립 액터 시스템 | Landscape에 내장 |
| 용도 | 나무, 덤불, 바위 | 풀, 잔디 |
| 배치 | 수동 또는 절차적 | Landscape 페인팅 연동 |
| 충돌 | 선택적 | 보통 없음 |

### 성능 최적화 방식

- **인스턴싱(Instancing)**: 같은 메시를 GPU 1번 호출로 수천 개 렌더링
- **Procedural Foliage**: 특정 영역에 자동으로 채우기
- `ProceduralFoliageBlockingVolume`: 특정 구역 식생 제외

---

## 네트워크 & 멀티플레이어

```
소스: Runtime/Engine/Classes/Engine/
  NetDriver.h      ← 네트워크 드라이버
  NetConnection.h  ← 클라이언트 연결
  ActorChannel.h   ← 액터 복제 채널
```

### 네트워크 3계층 구조

```
UNetDriver (게임 / 데모 / 비콘)
    ↓
UNetConnection (플레이어별 연결)
    ↓
Channel (데이터 종류별 채널)
  ├─ Control Channel  (연결 상태)
  ├─ Voice Channel    (음성)
  └─ Actor Channel    (액터 복제)
        ↓
FObjectReplicator (속성/RPC 복제)
```

### 액터 복제 흐름

```
서버에서 속성 변경 (예: 체력 감소)
    ↓
변경된 속성만 클라이언트에 전송
    ↓
클라이언트 Actor 업데이트
    ↓ (선택)
OnRep_PropertyName() 콜백 실행
```

### 아티스트가 알아야 할 것 (C++ 관점)

| 키워드 | 의미 |
|--------|------|
| `Replicated` | 이 변수는 모든 클라이언트에 동기화 |
| `Server` | 이 함수는 서버에서만 실행 |
| `Client` | 이 함수는 클라이언트에서만 실행 |
| `NetMulticast` | 서버 + 모든 클라이언트 동시 실행 |

### Relevancy (관련성)

성능을 위해 멀리 있는 액터는 복제 안 함.
- 플레이어와 가까운 액터만 네트워크 전송
- `NetCullDistanceSquared`로 거리 조정 가능

---

## 에셋 관리 시스템

```
소스:
  Runtime/Engine/Classes/Engine/AssetManager.h
  Runtime/Engine/Classes/Engine/StreamableManager.h
  Runtime/AssetRegistry/Public/AssetRegistry.h
```

### 에셋 참조 종류

| 종류 | 설명 | 로드 시점 |
|------|------|---------|
| Hard Reference (`UPROPERTY()`) | 강한 참조 | 오너 로드 시 함께 자동 로드 |
| Soft Reference (`TSoftObjectPtr`) | 약한 참조 | 명시적으로 요청할 때만 로드 |

**원칙**: 항상 필요한 에셋 → Hard, 선택적 에셋 → Soft

### AssetManager

- PrimaryAsset (직접 관리하는 에셋: 캐릭터, 스킨, 아이템) 등록 및 관리
- 비동기 로드 (`FStreamableDelegate` 콜백)
- 번들(Bundle) 단위로 에셋 그룹화 가능

### AssetRegistry

- 프로젝트 내 모든 에셋의 메타데이터 인덱스
- 에셋 검색, 의존성 조회, 태그 기반 필터링

---

## 텍스처 스트리밍

카메라 거리에 따라 텍스처 해상도를 자동으로 교체.

```
멀리 있을 때: Mip Level 4 (저해상도) 로드
가까워지면:   Mip Level 1 (고해상도) 로드
```

**아티스트가 설정하는 항목**

| 설정 | 위치 | 설명 |
|------|------|------|
| LOD Bias | Texture 속성 | 전체 해상도를 강제로 낮춤 |
| Streaming 활성화 | Texture 속성 | 스트리밍 켜기/끄기 |
| Virtual Texture | 고급 설정 | 매우 큰 텍스처 (수 GB) 지원 |

---

## 아티스트 체크리스트

```
월드 설계:
✓ 대형 맵은 World Partition으로 셀 분할
✓ 로딩 시간 단축을 위해 Level Streaming 활용
✓ Landscape 텍스처 해상도 과하지 않은가?
✓ Foliage 밀도 성능에 영향 없는 수준인가?

멀티플레이:
✓ 복제 필요 변수에 Replicated 표시됨?
✓ 서버 전용 로직에 Server 표시됨?
✓ NetCullDistanceSquared 거리 적절한가?

에셋 관리:
✓ 항상 필요한 에셋만 Hard Reference
✓ 선택적 에셋은 Soft Reference로 지연 로드
✓ 텍스처 스트리밍 Streaming Pool 크기 충분한가?
```
