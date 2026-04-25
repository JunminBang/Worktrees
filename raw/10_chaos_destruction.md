# Chaos Destruction (파괴 물리 시스템)

> 소스 경로: Runtime/Experimental/GeometryCollectionEngine/, Runtime/Experimental/Chaos/
> 아티스트를 위한 설명

---

## Chaos Destruction이란?

Chaos Destruction은 UE5에 내장된 **실시간 파괴 물리 시스템**입니다. 기존 Apex Destruction을 완전히 대체하며, Chaos Physics 솔버 위에서 동작합니다.

**작동 흐름:**
```
StaticMesh
→ Fracture Mode에서 조각냄
→ GeometryCollection 에셋 생성
→ 레벨에 배치
→ 런타임에 충격/힘 적용
→ 조각 분리 (Break)
→ 물리 시뮬레이션
```

---

## GeometryCollection 에셋 구조

GeometryCollection은 단순한 메시가 아닌 **계층형 파괴 데이터 묶음**입니다.

| 데이터 그룹 | 저장 내용 |
|------------|---------|
| Vertices Group | 버텍스 위치, 노멀, UV, 버텍스 컬러 |
| Faces Group | 삼각형 인덱스, MaterialID |
| Geometry Group | 조각별 바운딩박스, InnerRadius/OuterRadius |
| Transform Group | 조각별 트랜스폼, 시뮬레이션 타입, 계층 구조 |
| Material Group | 렌더링 섹션 (머티리얼별 묶음) |
| Breaking Group | 파괴 이벤트 데이터 |

**시뮬레이션 타입:**

| 타입 | 의미 |
|------|------|
| `FST_None` | 시뮬레이션 안 함 |
| `FST_Rigid` | 독립 강체 — 실제로 날아가는 파편 |
| `FST_Clustered` | 여러 조각을 묶는 중간 그룹 노드 |

---

## Fracture 파괴 레벨 구조

파괴 결과는 **트리 구조**로 저장됩니다:

```
Level 0 : Root  (클러스터 노드)
    ├─ Level 1: A  B  C  D  (큰 덩어리)
    │           |
    └─ Level 2: A1 A2  (더 잘게 쪼갠 조각)
```

- Level이 낮을수록 큰 덩어리, 높을수록 작은 파편
- `MaxClusterLevel`로 최대 파괴 단계 제어

### 파괴 방식 종류

| 방식 | 설명 | 사용 시기 |
|------|------|---------|
| Voronoi | 랜덤 씨앗점 기반 분쇄 | 범용 파괴 (암석, 콘크리트) |
| Voronoi Clustered | 큰 덩어리 → 작은 덩어리 단계별 | 건물 붕괴 |
| Plane Cut | 평면으로 슬라이스 | 칼/폭발 방향성 파괴 |
| Brick | 벽돌 패턴 | 벽 파괴 |
| Mesh Fracture | 다른 메시 형태로 조각 | 커스텀 파편 모양 |

---

## 에디터 설정 항목

### Clustering 탭

| 프로퍼티 | 역할 | 권장값 |
|----------|------|--------|
| `EnableClustering` | 클러스터 파괴 활성화 | 건물: 켜기 / 단순 소품: 끄기 |
| `MaxClusterLevel` | 파괴 최대 깊이 | 2~3 권장 |
| `ClusterGroupIndex` | 같은 인덱스끼리 하나의 클러스터로 묶임 | 연결된 구조물 같은 번호 |

### Damage 탭

| 프로퍼티 | 역할 |
|----------|------|
| `DamageThreshold` | 레벨별 파괴 임계값 배열. 숫자 클수록 강함 |
| `DamagePropagationData.bEnabled` | 파괴가 주변으로 전파되는지 |
| `BreakDamagePropagationFactor` | 부서진 조각이 주변에 전달하는 데미지 비율 |

### Collision 탭

| 프로퍼티 | 역할 |
|----------|------|
| `ImplicitType` | Box / Sphere / Capsule / LevelSet / Convex 선택 |
| `CollisionType` | Implicit-Implicit(정확) vs Particle-Implicit(빠름) |
| `SizeSpecificData` | 조각 크기별 충돌 설정 배열 |

### Removal 탭 (성능 중요!)

| 프로퍼티 | 역할 |
|----------|------|
| `bRemoveOnMaxSleep` | 멈춘 파편 자동 제거 |
| `MaximumSleepTime` | 멈춰있으면 제거할 시간 (1.0~3.0초 권장) |
| `RemovalDuration` | 제거 애니메이션 길이 |
| `bScaleOnRemoval` | 제거 시 크기 줄어들며 사라지기 |

### Rendering 탭

| 프로퍼티 | 역할 |
|----------|------|
| `EnableNanite` | Nanite 활성화 (고폴리 파편에 유리) |
| `RootProxyData` | 파괴 전 표시할 대리 스태틱 메시 (성능 최적화) |

---

## 파괴 이펙트 연동 방법

### 블루프린트 이벤트 바인딩

컴포넌트에서 제공하는 파괴 이벤트:

| 이벤트 | 발동 시점 |
|--------|---------|
| `OnChaosBreakEvent` | 조각이 파괴(Break)될 때 |
| `OnChaosRemovalEvent` | 조각이 제거(Remove)될 때 |
| `OnChaosCrumblingEvent` | 클러스터가 산산조각날 때 |
| `OnGeometryCollectionFullyDecayedEvent` | 전부 사라졌을 때 |

**이벤트에서 얻을 수 있는 정보 (FChaosBreakingEventData):**
- `Location` — 파괴 위치 (월드 좌표)
- `Velocity` — 파괴 시 속도
- `Mass` — 조각의 질량

### 필드 시스템으로 파괴 유발

Blueprint 호출 가능 함수:

| 함수 | 역할 |
|------|------|
| `ApplyExternalStrain(...)` | 특정 조각에 외부 충격 적용 |
| `CrumbleCluster(ItemIndex)` | 특정 클러스터 즉시 산산조각 |
| `CrumbleActiveClusters()` | 활성화된 모든 클러스터 즉시 산산조각 |
| `ApplyBreakingLinearVelocity(...)` | 파괴된 조각에 방향 속도 부여 |
| `SetAnchoredByBox(Box, bAnchored)` | 특정 영역 고정/해제 |
| `RemoveAllAnchors()` | 모든 앵커 해제 → 건물 전체 붕괴 연출 |

---

## 성능 최적화 팁

| 팁 | 설명 |
|----|------|
| 조각 수 50개 이하 | 파편 수가 늘어날수록 연산 비용 선형 증가 |
| `bRemoveOnMaxSleep = true` | 바닥에 쌓인 파편 빠르게 제거 (필수) |
| `MaximumSleepTime` 짧게 | 1.0~3.0초 권장 |
| 크기별 충돌 타입 분리 | 큰 조각: Convex, 작은 조각: Box/Sphere |
| `RootProxyData` 설정 | 파괴 전에는 간소화된 메시 렌더링 |
| `EnableNanite` | 고폴리 파편에 Nanite LOD 자동 처리 |

---

## 아티스트 체크리스트

### 에셋 제작 단계
- [ ] 원본 Static Mesh를 GeometryCollection으로 변환했는가?
- [ ] 파괴 방식(Voronoi 등)으로 조각을 냈는가?
- [ ] 조각 수가 목표치(50개 이하) 이내인가?
- [ ] `EnableClustering`과 `MaxClusterLevel`(2~3단계) 설정을 했는가?
- [ ] `DamageThreshold` 배열을 레벨별로 설정했는가?
- [ ] 내부면(Internal Face)에 별도 머티리얼을 지정했는가?
- [ ] `bRemoveOnMaxSleep = true`로 자동 제거를 활성화했는가?
- [ ] `RootProxyData`에 간소화 프록시 메시를 연결했는가?

### 레벨 배치 단계
- [ ] 파괴 이벤트에 파티클/사운드 이펙트를 바인딩했는가?
- [ ] 고정되어야 할 부분에 앵커(`SetAnchoredByBox`)가 설정되어 있는가?

### 최종 확인
- [ ] PIE에서 파괴 시 프레임 드랍이 없는가?
- [ ] 파편이 바닥에 무한히 쌓이지 않고 제거되는가?
- [ ] 파괴 사운드/이펙트가 `BreakEvent.Location`에서 재생되는가?
