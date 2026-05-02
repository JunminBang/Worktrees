# World Partition 심화 — HLOD, Data Layer, 오픈 월드 구성

> 소스 경로: Runtime/Engine/Classes/WorldPartition/
> 아티스트를 위한 설명

---

## World Partition이란?

World Partition은 **대형 오픈 월드를 자동으로 관리하는 스트리밍 시스템**입니다. 기존에는 레벨 디자이너가 서브 레벨을 수동으로 만들어 스트리밍을 설정했지만, World Partition은 이를 완전히 자동화합니다.

**비유:** 도시 지도를 구역별로 자동으로 나눠서, 플레이어가 있는 구역만 로드하고 나머지는 언로드합니다.

### 활성화 방법
1. **World Settings** → `World Partition` → `Enable World Partition` 체크
2. 또는 새 레벨 생성 시 **Open World** 템플릿 선택

---

## 스트리밍 그리드

World Partition은 레벨을 **셀(Cell) 격자**로 자동 분할합니다.

| 프로퍼티 | 설명 |
|---------|------|
| `Cell Size` | 스트리밍 셀 한 칸의 크기 (기본 12800cm = 128m) |
| `Loading Range` | 플레이어 주변 몇 칸을 로드할지 (기본 25600cm) |
| `Enable Streaming` | 스트리밍 ON/OFF (에디터에서 OFF하면 전체 로드) |

### 에디터에서 스트리밍 시각화
- 상단 툴바 → **World Partition Editor** 창 열기
- 그리드 셀별 로드 상태 확인
- 특정 셀을 수동으로 로드/언로드 가능

---

## Data Layer — 콘텐츠 레이어 분리

Data Layer는 **오브젝트를 논리적 그룹으로 분리**해 런타임에 선택적으로 로드/언로드하는 기능입니다.

**사용 예시:**
- `DL_NightVariant`: 야간 전용 오브젝트 (가로등, 달빛 반사)
- `DL_WeatherRain`: 비 올 때만 등장하는 물웅덩이, 우산 쓴 NPC
- `DL_QuestPhase2`: 특정 퀘스트 단계에서만 나타나는 구조물

### Data Layer 생성 및 설정

1. **World Partition Editor** → **Data Layers** 탭
2. `+` 버튼으로 새 Data Layer 생성
3. 이름 지정 (예: `DL_Night`)
4. 오브젝트 선택 → Details → `Data Layer` → 해당 레이어 할당

### Data Layer 타입

| 타입 | 설명 |
|------|------|
| `Editor` | 에디터에서만 사용 (제작 편의용) |
| `Runtime` | 런타임에 Blueprint로 활성화/비활성화 가능 |

### Blueprint에서 Data Layer 제어

```
→ Get World Partition Subsystem
→ Activate Data Layer (DataLayerAsset: DL_Night)
→ Deactivate Data Layer (DataLayerAsset: DL_Day)
```

---

## HLOD — Hierarchical Level of Detail

HLOD는 **멀리 있는 오브젝트들을 단순화된 하나의 메시로 통합**해 성능을 최적화합니다.

**비유:** 멀리서 보이는 도시 전경 — 실제 건물 수백 채가 아니라 하나로 합쳐진 단순화 메시를 렌더링합니다.

### HLOD 레이어 설정

1. **World Settings** → `HLOD` → `Enable HLOD` 체크
2. HLOD 레이어 추가:
   - `HLOD Layer 0`: 가장 가까운 단순화 (폴리곤 50% 감소)
   - `HLOD Layer 1`: 중거리 (폴리곤 80% 감소)
   - `HLOD Layer 2`: 원거리 (폴리곤 95% 감소, 임포스터 등)

### HLOD 타입

| 타입 | 설명 |
|------|------|
| `Merged Mesh` | 여러 메시를 하나로 합침 |
| `Simplified Mesh` | 전체를 단순화된 하나의 메시로 |
| `Instanced` | Instanced Static Mesh로 통합 |
| `Imposter` | 빌보드 텍스처로 대체 (최원거리) |

### HLOD 빌드

1. **Build → Build HLOD** 메뉴 실행
2. 백그라운드에서 자동 처리
3. 결과물은 `HLOD` 폴더에 저장

---

## 액터 스트리밍 설정

개별 액터의 스트리밍 동작을 제어할 수 있습니다:

| 프로퍼티 | 설명 |
|---------|------|
| `Is Spatially Loaded` | OFF이면 항상 로드 (스트리밍 제외) |
| `Grid Placement` | 어느 그리드/셀에 배치될지 |
| `HLOD Layer` | 이 액터가 사용할 HLOD 레이어 |

> **팁:** 항상 보여야 하는 중요 오브젝트(게임 매니저, 전역 사운드 등)는 `Is Spatially Loaded` = OFF로 설정하세요.

---

## World Partition 워크플로우 팁

| 팁 | 설명 |
|----|------|
| 에디터에서 전체 로드 | `Enable Streaming` OFF → 전체 맵 편집 가능 |
| 특정 구역만 작업 | World Partition Editor에서 해당 셀만 로드 |
| 팀 협업 | 각자 다른 셀/구역을 담당해 충돌 없이 작업 |
| One File Per Actor | 액터마다 별도 파일 → 소스 관리 충돌 최소화 |

---

## 아티스트 체크리스트

### 스트리밍 설정
- [ ] Cell Size가 씬 규모에 적합한가? (도시: 큰 셀, 실내: 작은 셀)
- [ ] Loading Range가 플레이어 시야 거리보다 크게 설정되어 있는가?
- [ ] 항상 필요한 오브젝트에 `Is Spatially Loaded = OFF`가 설정되어 있는가?

### Data Layer
- [ ] Data Layer 이름이 용도를 명확히 나타내는가? (`DL_` 접두사 권장)
- [ ] Runtime 타입 레이어가 Blueprint에서 올바르게 제어되는가?
- [ ] 에디터 전용 레이어가 빌드에 포함되지 않는가?

### HLOD
- [ ] HLOD 빌드가 최신 상태인가? (오브젝트 수정 후 재빌드)
- [ ] 원거리에서 HLOD 팝핑(급격한 전환)이 없는가?
- [ ] Impostor HLOD의 텍스처가 충분한 해상도인가?

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [07_world_network_assets.md](07_world_network_assets.md) | 레벨 스트리밍 기초 — LevelStreaming vs World Partition 비교 |
| [31_level_instance.md](31_level_instance.md) | Level Instance — World Partition 셀 단위 스트리밍 통합 |
| [35_landscape_advanced.md](35_landscape_advanced.md) | 랜드스케이프 — 대형 지형과 World Partition 셀 연동 |
| [43_foliage_system.md](43_foliage_system.md) | Foliage — Data Layer 기반 식생 조건부 로드/언로드 |
| [27_mass_entity.md](27_mass_entity.md) | Mass Entity — 스트리밍 셀 단위 Entity 활성화/비활성화 |
| [53_profiling_optimization.md](53_profiling_optimization.md) | HLOD 비용 — 원거리 통합 메시 렌더링 성능 측정 |
