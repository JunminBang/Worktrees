# Level Instance & Packed Level Actor

> 소스 경로: Runtime/Engine/Classes/Engine/LevelInstance/
> 아티스트를 위한 설명

---

## Level Instance란?

Level Instance는 **하나의 레벨(.umap)을 다른 레벨에 프리팹처럼 삽입**하는 시스템입니다. 동일한 구조물을 여러 곳에 배치하고, 원본 수정 시 모든 인스턴스에 자동 반영됩니다.

**비유:** 레고 블록 세트 — 한 번 조립한 세트를 찍어내어 여러 곳에 배치하고, 원본 설계를 바꾸면 모든 세트가 업데이트됩니다.

**기존 방식과 차이:**

| 방식 | 설명 | 한계 |
|------|------|------|
| 일반 레벨 배치 | 오브젝트를 직접 복사·붙여넣기 | 변경 시 일일이 수정 |
| Blueprint Actor | BP 안에 메시 배치 | 복잡한 씬 구성 어려움 |
| **Level Instance** | 레벨 자체를 재사용 단위로 활용 | 없음 (이 방식이 권장) |

---

## Level Instance 생성 방법

### 기존 오브젝트들을 Level Instance로 변환

1. 레벨 에디터에서 변환할 액터들 선택
2. 우클릭 → **Level** → **Create Level Instance**
3. 파일 이름 및 저장 위치 지정
4. 선택한 오브젝트가 새 Level Instance 안으로 이동

### 빈 Level Instance 생성 후 배치

1. Content Browser → 우클릭 → **Level** → 새 레벨 생성
2. 해당 레벨 파일을 레벨 에디터로 드래그
3. Level Instance로 자동 배치

---

## Level Instance 편집

### 인라인 편집 모드 (Edit In Place)

1. 레벨에 배치된 Level Instance를 **더블클릭**
2. 인라인 편집 모드 진입 — 다른 오브젝트는 반투명하게 표시
3. 내부 오브젝트 자유롭게 편집
4. **완료:** 레벨 에디터의 "Done" 버튼 클릭 → 변경 사항 저장 → 모든 인스턴스에 자동 반영

> **중요:** 한 인스턴스를 수정하면 같은 Level Instance를 사용하는 **모든 배치 지점**에 변경이 반영됩니다.

---

## Packed Level Actor — 정적 최적화 버전

`Packed Level Actor`는 Level Instance를 **Static Mesh로 베이크**한 고성능 버전입니다.

| 항목 | Level Instance | Packed Level Actor |
|------|--------------|-------------------|
| 편집 | 더블클릭 후 편집 가능 | 원본 Level Instance 열어 편집 후 재베이크 |
| 성능 | 일반 | 더 높음 (ISM 인스턴싱 활용) |
| 드로우콜 | 일반 | 감소 (정적 메시 병합) |
| 라이트맵 | 개별 | 통합 베이크 가능 |
| 사용 시기 | 편집이 자주 필요한 경우 | 완성된 모듈형 오브젝트 |

### Packed Level Actor 생성

1. Level Instance 액터 우클릭 → **Pack Level Instance**
2. 자동으로 내부 메시들을 병합해 정적 최적화
3. 원본 Level Instance는 그대로 유지됨

---

## World Partition과의 통합

Level Instance는 **World Partition 스트리밍**과 완벽히 통합됩니다:

- 레벨 인스턴스가 배치된 셀 기준으로 자동 스트리밍 IN/OUT
- 대형 오픈 월드에서 마을 단위, 건물 단위로 스트리밍 제어 가능
- `Streaming Policy`를 인스턴스별로 설정 가능

---

## 레벨 인스턴스 중첩 (Nested Level Instances)

Level Instance 안에 또 다른 Level Instance를 배치할 수 있습니다:

```
도시 레벨
  └─ 구역_A (Level Instance)
      ├─ 건물_01 (Level Instance)
      │    ├─ 방_01 (Level Instance)
      │    └─ 복도 (Level Instance)
      └─ 건물_02 (Level Instance)
```

---

## 실용 사례

### 모듈형 건물 조합

```
준비:
  LI_Room_Small.umap   ← 소형 방
  LI_Room_Large.umap   ← 대형 방
  LI_Corridor.umap     ← 복도
  LI_Stairs.umap       ← 계단

배치:
  → 각 LI를 드래그해 원하는 구조로 조합
  → 창문 위치 수정 필요 시: LI_Room_Small 더블클릭 → 수정 → Done
  → 모든 방에 자동 반영
```

### 팀 작업 분리

```
환경 아티스트 A: LI_Building_Residential.umap 담당
환경 아티스트 B: LI_Building_Commercial.umap 담당
레벨 디자이너: 메인 레벨에서 두 LI를 배치·조합만 담당
→ 충돌 없이 병렬 작업 가능
```

---

## 에디터 단축키 및 팁

| 작업 | 방법 |
|------|------|
| Level Instance 편집 진입 | 더블클릭 |
| 편집 종료 | Escape 또는 Outliner에서 Done |
| 인스턴스 독립 복사 | 우클릭 → Break Level Instance (LI 해제, 독립 오브젝트로 변환) |
| 새 LI 생성 | 선택 후 우클릭 → Create Level Instance |

---

## 아티스트 체크리스트

### Level Instance 설계 시
- [ ] Level Instance의 피벗(원점)이 의도한 위치에 있는가? (배치 기준점이 됨)
- [ ] 레벨 이름이 `LI_` 접두사를 사용해 식별하기 쉬운가?
- [ ] 내부 오브젝트들이 원점 기준으로 올바른 위치에 있는가?

### 편집 워크플로우
- [ ] 인라인 편집 후 반드시 "Done"을 눌러 저장했는가?
- [ ] 한 인스턴스 수정이 의도치 않은 다른 배치에 영향을 주지 않는가?
- [ ] 독립적으로 변경이 필요한 경우 `Break Level Instance`로 분리했는가?

### 성능 최적화
- [ ] 완성된 반복 모듈을 Packed Level Actor로 변환했는가?
- [ ] World Partition 스트리밍 설정이 적절한가?
- [ ] 중첩이 너무 깊어 편집이 복잡해지지 않았는가? (3단계 이하 권장)
