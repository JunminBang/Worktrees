# Mass Entity — 대규모 군중 & AI 시뮬레이션

> 소스 경로: Engine/Plugins/Runtime/MassEntity/Source/MassEntity/Public/
> 아티스트를 위한 설명

---

## Mass Entity란?

Mass Entity는 **수천~수만 개의 캐릭터/오브젝트를 동시에 시뮬레이션**하기 위한 고성능 프레임워크입니다.

**비유:** 엑셀 스프레드시트처럼 — 개별 오브젝트(셀) 대신 데이터 열(Column)로 처리하고, 연산은 열 단위로 병렬 처리합니다. 수천 명의 군중이 도시를 걸어다니거나 전쟁 씬에서 수백 명의 병사가 동시에 움직이는 것을 가능하게 합니다.

**기존 방식 vs Mass Entity:**

| 항목 | 기존 Actor 방식 | Mass Entity |
|------|--------------|-------------|
| 오브젝트 1000개 | 1000개 Actor → 무거움 | 데이터 배열로 경량 처리 |
| 처리 방식 | 싱글스레드 Tick | 멀티스레드 Processor |
| 렌더링 | 개별 드로우콜 | ISM 인스턴싱 |
| 메모리 | 분산 | 연속 메모리 배열 |

---

## 핵심 개념 (ECS 구조)

Mass Entity는 **ECS (Entity-Component-System)** 아키텍처를 사용합니다.

| 개념 | 역할 | 비유 |
|------|------|------|
| **Entity** | 개별 존재 (군중 한 명) | 엑셀의 한 행(Row) |
| **Fragment** | Entity가 가진 데이터 조각 | 엑셀의 열(Column): 위치, 속도, 체력 |
| **Tag** | 상태 표시 (데이터 없음) | "선택됨", "사망" 플래그 |
| **Processor** | Fragment를 일괄 처리하는 로직 | 엑셀 수식: 모든 위치 += 속도 |
| **Archetype** | 같은 Fragment 조합을 가진 Entity 그룹 | 같은 열 구성을 가진 시트 |

---

## Mass 플러그인 활성화

1. **Edit → Plugins** 검색창에 `Mass` 입력
2. 다음 플러그인 활성화:
   - `Mass Entity`
   - `Mass Gameplay`
   - `Mass AI` (AI 기능 필요 시)
   - `Mass Crowd` (군중 시스템 필요 시)
   - `Zone Graph` (경로 시스템 필요 시)
3. 에디터 재시작

---

## Mass Spawner — 대규모 스폰

`MassSpawner` 액터로 대량의 Entity를 씬에 배치합니다.

### 설정 방법

1. Place Actors → **MassSpawner** 배치
2. `Mass Spawnable` 에셋 생성 (어떤 Entity를 스폰할지 정의)
3. 스폰 개수, 범위, 방식 설정
4. `Entity Config Asset`에 Fragment 조합 지정

### Entity Config Asset

MassSpawner가 사용하는 설정 에셋입니다:
- 어떤 Fragment를 가질지 선택
- AI 행동, 렌더링 방식, 이동 방식 등을 모듈로 조합

---

## Mass Crowd — 군중 시스템

군중 캐릭터는 **Instanced Static Mesh(ISM)** 또는 **Instanced Skeletal Mesh**로 렌더링됩니다. 수천 명을 하나의 드로우콜로 처리 가능합니다.

### 군중 LOD 시스템

카메라 거리에 따라 시뮬레이션 품질이 자동 조정됩니다:

| 거리 | 시뮬레이션 수준 |
|------|--------------|
| 근거리 (High Res) | 전체 물리 + 애니메이션 + AI 풀 시뮬레이션 |
| 중거리 (Medium) | 단순화된 이동 + 루프 애니메이션 |
| 원거리 (Off LOD) | 시각화만 — 위치만 업데이트, AI 없음 |

---

## ZoneGraph — 대규모 AI 경로

ZoneGraph는 Mass AI가 이동할 **경로 네트워크**를 정의합니다.

- 스플라인 기반 차선(Lane) 정의
- 인도, 차도, 공원 경로 등 구역 지정
- NavMesh보다 훨씬 대규모 처리 가능

**설정:**
1. `ZoneGraph` 플러그인 활성화
2. `Zone Shape Component`로 경로 영역 그리기
3. Lane Tag로 이동 타입 지정 (보행자/차량)

---

## Blueprint에서 Mass Entity 제어

Mass Entity는 기본적으로 C++ 중심이지만 일부 Blueprint 접근이 가능합니다:

| 가능한 것 | 불가능한 것 |
|---------|-----------|
| MassSpawner 스폰/스폰 중단 | 개별 Entity에 직접 접근 |
| Entity 개수 조회 | Tick에서 매 프레임 Entity 변경 |
| 스폰 위치 변경 | 일반 Actor와 동일한 방식 처리 |

> **아티스트 주의:** Mass Entity는 프로그래머 설정이 필요합니다. 아티스트는 주로 MassSpawner 배치, Entity Config 파라미터 조정, ZoneGraph 경로 그리기를 담당합니다.

---

## 성능 고려사항

| 팁 | 설명 |
|----|------|
| ISM 렌더링 | 같은 메시를 사용하는 Entity는 자동 인스턴싱 |
| LOD 거리 조정 | 멀리서는 시뮬레이션 끄기 |
| Fragment 최소화 | Entity당 Fragment 수가 적을수록 빠름 |
| 멀티스레드 | Processor는 자동으로 멀티스레드 실행 |
| 군중 상한 | 플랫폼별 최대 Entity 수 테스트 필요 |

---

## 아티스트 체크리스트

### 씬 설정
- [ ] 필요한 Mass 플러그인이 모두 활성화되어 있는가?
- [ ] MassSpawner의 스폰 범위가 씬 구조에 맞게 설정되어 있는가?
- [ ] Entity Config Asset이 올바른 Fragment 조합을 가지는가?

### ZoneGraph 설정
- [ ] Zone Shape로 이동 경로가 올바르게 정의되어 있는가?
- [ ] Lane Tag가 이동 타입별로 올바르게 분류되어 있는가?
- [ ] 경로가 끊기거나 막힌 곳은 없는가?

### 성능
- [ ] 원거리 LOD에서 시뮬레이션이 비활성화되는가?
- [ ] 같은 메시를 최대한 재사용해 ISM 인스턴싱을 활용하는가?
- [ ] 플랫폼 타겟에서 목표 Entity 수가 프레임 예산 안에 있는가?
