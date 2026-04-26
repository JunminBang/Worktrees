# 기획서 — Collision Complexity Auditor

> 작성일: 2026-04-25  
> 수정일: 2026-04-26 (아키텍트 검수 반영)  
> 카테고리: 퍼포먼스 프로파일링  
> 우선순위: 높음

---

## 개요

레벨 내 Static Mesh의 콜리전 복잡도를 분석해, 불필요하게 Complex 콜리전을 사용하는 메시를 탐지하고 Simple 콜리전 대체 후보를 제안하는 에디터 유틸리티.  
**1차 릴리스는 진단/리포트 전용 — 일괄 변경 기능은 2차 릴리스.**

---

## 문제 정의

- Per-Poly(Complex) 콜리전은 물리 연산 비용이 크다.
- 배경 오브젝트에 Complex 콜리전이 걸려 있어도 게임플레이에 영향 없는 경우가 많다.
- 레벨 규모가 커지면 수작업으로 모든 메시의 콜리전 설정을 확인하기 어렵다.

---

## 목표

- 레벨 전체 메시 콜리전 복잡도 일괄 스캔
- Simple 대체 가능한 후보 자동 탐지 (오탐 필터링 포함)
- 대체 시 절감 효과 예측값 제공
- 1차: 진단 + 리포트 출력. 2차: 일괄 변경 (안전망 확보 후)

---

## 핵심 설계 원칙: 2계층 모델

> UE5 콜리전은 **에셋(BodySetup)** + **인스턴스(BodyInstance)** 2계층.  
> 게임플레이 의미는 인스턴스 측에 있으므로 **에셋만 보고 판정하면 오탐**.

| 계층 | 저장 위치 | 포함 정보 |
|---|---|---|
| 에셋 | `UBodySetup` | 콜리전 도형(AggGeom), TraceFlag, PhysMaterial |
| 인스턴스 | `FBodyInstance` (컴포넌트별) | 응답 채널(Block/Overlap/Ignore), Custom Trace Channel |

---

## 수집 범위

> ⚠️ `AStaticMeshActor`만 순회하면 누락이 발생한다.

| 소스 | 비고 |
|---|---|
| `AStaticMeshActor` | 기본 |
| `UStaticMeshComponent` (BP 내부) | Blueprint 컴포넌트 포함 |
| `UInstancedStaticMeshComponent` | ISM |
| `UHierarchicalInstancedStaticMeshComponent` | HISM |
| `UFoliageType_InstancedStaticMesh` | 폴리지 인스턴스 |
| `GeometryCollection` | **1차 릴리스 제외** |

---

## 주요 기능

### 1. 콜리전 타입 스캔

탐지 대상 TraceFlag (`UBodySetup->CollisionTraceFlag`):
- `CTF_UseComplexAsSimple` — Complex를 Simple로 사용 (주 탐지 대상)
- `CTF_UseSimpleAndComplex` — 일부 트레이스에 Complex 사용 (보조 탐지 대상)

### 2. Simple 대체 후보 판정 (AND 조건)

| 조건 | 기준 |
|---|---|
| TraceFlag | `UseComplexAsSimple` 또는 `UseSimpleAndComplex` |
| AggGeom 존재 | `BodySetup->AggGeom.GetElementCount() > 0` — 비어있으면 "프리미티브 생성 후보"로 별도 분류 |
| 폴리곤 수 | LOD0 기준 500tri 이하 (`RenderData->LODResources[0].GetNumTriangles()`) |
| 인스턴스 응답 채널 | 레벨 내 모든 인스턴스의 `BodyInstance` 순회 — Block/Overlap/Custom Trace Channel 사용 여부 확인 |
| NavMesh 의존 | `bCanEverAffectNavigation == true` 인 컴포넌트 포함 시 **자동 후보 제외 + 경고** |
| PhysMat 다중성 | 페이스별 Physical Material Mask 사용 시 자동 후보 제외 |

### 3. 후보 분류

| 분류 | 조건 |
|---|---|
| **Simple 즉시 전환 권장** | AggGeom 존재 + 게임플레이 채널 미사용 + 500tri 이하 |
| **프리미티브 생성 후 전환** | AggGeom 없음 + 게임플레이 채널 미사용 |
| **수동 검토 필요** | 500tri 초과 또는 NavMesh 의존 또는 PhysMat 다중 |
| **변경 제외** | 게임플레이 채널(Block/Overlap/Custom) 사용 중 |

### 4. 절감 효과 예측

- 현재 Complex tri 수 vs Simple 프리미티브(Box/Capsule/Convex) 교체 시 tri 감소량 추정
- Chaos Physics GJK/EPA 컨벡스 비용 고려 (컨벡스 32개 이상이면 Simple이 더 비쌀 수 있음 → 경고)

---

## 구현 방향

```
1. 컴포넌트 순회 (AStaticMeshActor + BP + ISM + HISM + Foliage)
2. 에셋 레코드 수집:
   - UBodySetup->CollisionTraceFlag
   - UBodySetup->AggGeom.GetElementCount()
   - RenderData->LODResources[0].GetNumTriangles()
   - UBodySetup->PhysMaterial / Physical Material Mask 유무
3. 인스턴스 레코드 수집:
   - UPrimitiveComponent->BodyInstance.GetResponseToChannels()
   - Custom Trace Channel 포함 전체 채널 순회
   - bCanEverAffectNavigation 확인
4. 에셋의 모든 인스턴스를 합산해 후보 판정
5. CSV / JSON 리포트 출력
```

---

## 입출력

**입력**
- 대상 레벨 (또는 선택 액터 범위)
- 폴리곤 수 임계값 (기본값: 500tri)
- 컨벡스 수 경고 임계값 (기본값: 32개)

**출력**
- 에디터 내 결과 패널 (메시명 / TraceFlag / tri 수 / AggGeom 유무 / 분류 / 절감 예측)
- `Saved/CollisionAudit_레벨명_YYYYMMDD.csv`
- `Saved/CollisionAudit_레벨명_YYYYMMDD.json` (2차 일괄 변경용 매니페스트)

---

## 2차 릴리스 — 일괄 변경 안전망 (구현 전 필수)

| 안전망 | 내용 |
|---|---|
| Git clean 강제 | 변경 전 워킹 트리 클린 상태 확인 — 커밋되지 않은 변경이 있으면 중단 |
| 변경 매니페스트 JSON | `Saved/CollisionAudit/` 에 저장 — 동일 매니페스트로 롤백 명령 제공 |
| 다른 레벨 참조 경고 | 변경 대상 에셋이 다른 레벨에서도 참조되면 경고 표시 |
| AggGeom 자동 생성 | Simple 전환 전 프리미티브(Box/Capsule/Convex) 자동 생성 필수 — 없이 플래그만 바꾸면 콜리전 사라짐 |
| 재쿠킹 권고 | 변경 후 패키징 회귀 방지를 위해 쿠킹 재실행 안내 |

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| 2계층 판정 | 에셋만 보면 오탐. 인스턴스 `BodyInstance` 순회 필수 |
| AggGeom 비어있는 메시 | 플래그만 바꾸면 콜리전 전체 사라짐 → "프리미티브 생성 후보"로 분리 |
| 다중 레벨 참조 | 한 레벨 스캔 결과로 에셋 변경 시 다른 레벨에 영향 — 2차 릴리스 안전망 필수 |
| NavMesh 의존 | Per-Poly → Simple 전환 시 NavMesh 재빌드 결과 달라짐 |
| Chaos Physics | 컨벡스 32개 이상은 Simple이 오히려 더 비쌀 수 있음 — 절감 예측에 반영 |

---

## 완료 기준

### 1차 릴리스 (진단/리포트)
- [ ] 전체 컴포넌트 소스(AStaticMeshActor + BP + ISM + HISM + Foliage) 순회
- [ ] 에셋 레코드 + 인스턴스 레코드 2계층 수집
- [ ] 후보 4분류 (즉시 전환 / 프리미티브 생성 후 전환 / 수동 검토 / 제외) 출력
- [ ] NavMesh / PhysMat 다중 / 컨벡스 과다 경고
- [ ] CSV / JSON 매니페스트 저장
- [ ] wiki에 결과 패턴 ingest

### 2차 릴리스 (일괄 변경)
- [ ] Git clean 강제 확인
- [ ] AggGeom 자동 생성 후 플래그 변경
- [ ] 매니페스트 기반 롤백 명령
- [ ] 다른 레벨 참조 경고
