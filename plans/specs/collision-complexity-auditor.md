# 기획서 — Collision Complexity Auditor

> 작성일: 2026-04-25  
> 카테고리: 퍼포먼스 프로파일링  
> 우선순위: 높음

---

## 개요

레벨 내 Static Mesh의 콜리전 복잡도를 분석해, 불필요하게 Per-Poly(Complex) 콜리전을 사용하는 메시를 탐지하고 Simple 콜리전 대체 후보를 제안하는 에디터 유틸리티.

---

## 문제 정의

- Per-Poly 콜리전은 비주얼 정확도는 높지만 물리 연산 비용이 크다.
- 배경 오브젝트(바위, 가구, 소품 등)에 Per-Poly가 걸려 있어도 게임플레이에 영향이 없는 경우가 많다.
- 레벨 규모가 커지면 수작업으로 모든 메시의 콜리전 설정을 확인하기 어렵다.

---

## 목표

- 레벨 전체 메시 콜리전 복잡도 일괄 스캔
- Per-Poly 사용 메시 중 Simple 대체 가능한 후보 자동 탐지
- 대체 시 절감 효과 예측값 제공

---

## 주요 기능

| 기능 | 설명 |
|---|---|
| 콜리전 타입 스캔 | 레벨 내 모든 Static Mesh의 콜리전 복잡도(Simple / Complex / Per-Poly) 수집 |
| Per-Poly 탐지 | `CollisionComplexity == ECollisionTraceFlag::CTF_UseComplexAsSimple` 인 메시 목록 추출 |
| Simple 대체 후보 판정 | 폴리곤 수 기준(임계값: 500tri 이하) + 게임플레이 콜리전 채널 미사용 조건으로 후보 필터링 |
| 비용 절감 예측 | 폴리곤 수 대비 Simple 프리미티브(Box / Capsule / Convex)로 교체 시 트라이 감소량 추정 |
| 일괄 변경 | 후보 목록에서 선택 → Simple 콜리전으로 일괄 적용 |

---

## 구현 방향

- `UStaticMesh::GetBodySetup()` → `CollisionTraceFlag` 확인
- 레벨 내 `AStaticMeshActor` 순회 후 소스 `UStaticMesh`로 역참조
- 폴리곤 수: `UStaticMesh::GetNumTriangles(LODIndex)` 활용
- 게임플레이 채널 사용 여부: `UBodySetup::CollisionReponses` 확인 (Block/Overlap 채널 체크)
- 일괄 변경 시 에셋 수정 → `MarkPackageDirty()` + 저장 프롬프트

---

## 입출력

**입력**
- 대상 레벨 (또는 선택 액터 범위)
- 폴리곤 수 임계값 (기본값: 500tri)
- 게임플레이 채널 필터 (Block/Overlap 사용 중인 메시 제외 옵션)

**출력**
- 에디터 내 결과 패널 (메시명 / 현재 콜리전 타입 / 폴리곤 수 / 절감 예측)
- `Saved/CollisionAudit_레벨명_YYYYMMDD.csv`

---

## 판정 기준 (초기값)

| 조건 | 판정 |
|---|---|
| Per-Poly + 500tri 이하 + 게임플레이 채널 미사용 | Simple 대체 권장 |
| Per-Poly + 500tri 초과 | 수동 검토 필요 |
| Per-Poly + 게임플레이 채널 사용 중 | 변경 제외 (자동 처리 금지) |

---

## 제약 / 리스크

- 게임플레이 콜리전 채널 사용 여부 자동 판별이 완벽하지 않을 수 있음 → 게임플레이 채널 사용 메시는 자동 변경에서 항상 제외
- 에셋 수정은 되돌리기 어려우므로 일괄 변경 전 반드시 사용자 확인 프롬프트 표시

---

## 완료 기준

- [ ] 레벨 내 Per-Poly 콜리전 메시 전체 탐지
- [ ] Simple 대체 후보 자동 분류
- [ ] CSV 리포트 저장
- [ ] 일괄 변경 기능 (확인 프롬프트 포함)
- [ ] wiki에 결과 패턴 ingest
