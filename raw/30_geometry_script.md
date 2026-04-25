# Geometry Script — Blueprint 기반 절차적 메시 생성

> 소스 경로: Engine/Plugins/Runtime/GeometryScripting/Source/GeometryScriptingCore/Public/
> 아티스트를 위한 설명

---

## Geometry Script란?

Geometry Script는 **Blueprint 노드로 3D 메시를 절차적으로 생성하고 변형**하는 시스템입니다. C++ 코드 없이 노드를 연결해 메시를 만들거나 수정할 수 있습니다.

**비유:** 포토샵의 "비파괴 편집"처럼, 원본 메시를 직접 수정하지 않고 노드 그래프로 결과물을 만들어냅니다.

**사용 사례:**
- 절차적 건물/던전 생성
- 런타임에 지형 변형 (폭발 구덩이, 도로 파손)
- 에디터 도구 (자동 UV, 자동 LOD 생성 배치 도구)
- 메시 수리 자동화 (구멍 채우기, 노멀 수정)

---

## 핵심 클래스

| 클래스 | 역할 |
|--------|------|
| `UDynamicMesh` | Geometry Script가 조작하는 메시 데이터 컨테이너 |
| `UGeometryScriptLibrary` | 모든 메시 조작 함수 모음 (Blueprint Function Library) |
| `UDynamicMeshComponent` | 런타임에 DynamicMesh를 렌더링하는 컴포넌트 |
| `UEditorGeometryScriptLibrary` | 에디터 전용 기능 (배치 처리, 에셋 저장 등) |

---

## 기본 Primitive 생성

Blueprint에서 UDynamicMesh를 만들고 기본 도형을 생성합니다:

```
[BeginPlay 또는 Construction Script]
→ Create New Dynamic Mesh Asset
→ Append Box Mesh
    Box Size: (200, 200, 200)
    Target Mesh: (위 DynamicMesh)
→ Set Dynamic Mesh Component (렌더링에 적용)
```

### 지원 Primitive 목록

| 노드 | 생성 형태 |
|------|---------|
| `Append Box` | 직육면체 |
| `Append Sphere` | 구체 (UV Sphere / Icosphere) |
| `Append Cylinder` | 원통 |
| `Append Cone` | 원뿔 |
| `Append Torus` | 도넛 |
| `Append Disc` | 원판 |
| `Append Rounded Rectangle` | 모서리 둥근 직사각형 |
| `Append Line` | 선 (두께 지정 가능) |
| `Append Spline Mesh` | 스플라인을 따라 메시 생성 |

---

## Boolean 연산

두 메시를 조합하거나 빼는 연산입니다:

| 연산 | 설명 | 비유 |
|------|------|------|
| `Union` | 두 메시 합치기 | A + B |
| `Difference` | A에서 B를 빼기 | A - B (구멍 뚫기) |
| `Intersection` | 겹치는 부분만 남기기 | A ∩ B |

```
예시: 건물에 창문 구멍 뚫기
→ Append Box (건물 벽)
→ Append Box (창문 크기 박스)
→ Apply Mesh Boolean (Difference)
  → 결과: 창문이 뚫린 벽
```

---

## 메시 변형 노드

| 노드 | 설명 |
|------|------|
| `Subdivide Mesh` | 폴리곤 세분화 (부드럽게) |
| `Simplify Mesh` | 폴리곤 감소 |
| `Offset Mesh` | 표면을 법선 방향으로 밀어냄 (두껍게/얇게) |
| `Weld Mesh Edges` | 인접 버텍스 병합 (열린 모서리 닫기) |
| `Delete Triangles` | 특정 삼각형 삭제 |
| `Apply Noise` | 노이즈로 표면 울퉁불퉁하게 만들기 |
| `Apply Transform` | 이동/회전/스케일 적용 |
| `Mirror Mesh` | 특정 축으로 메시 미러링 |

---

## UV 조작

| 노드 | 설명 |
|------|------|
| `Auto Generate Patching UV` | 자동 UV 생성 (섬 단위 자동 분리) |
| `Apply Planar Projection` | 평면 투영 UV |
| `Apply Box Projection` | 박스 투영 UV (6방향) |
| `Apply Cylinder Projection` | 원통 투영 UV |
| `Repack UV Islands` | UV 섬을 0~1 공간에 재배치 |

---

## 에디터 유틸리티 위젯에서 활용

Geometry Script는 **에디터 자동화 도구 제작**에 특히 유용합니다:

**예시: 선택된 스태틱 메시에 자동 UV 생성 버튼**

```
[버튼 클릭 이벤트]
→ Get Selected Assets (선택된 에셋 가져오기)
→ For Each 루프
  → Cast to Static Mesh
  → Static Mesh To Dynamic Mesh (메시 변환)
  → Auto Generate UV
  → Bake Dynamic Mesh To Static Mesh (결과 저장)
```

---

## Dynamic Mesh Component — 런타임 메시 변형

런타임에 메시를 동적으로 변형하려면 `UDynamicMeshComponent`를 사용합니다:

1. Blueprint의 Components 패널 → `+Add` → `Dynamic Mesh Component`
2. `Get Dynamic Mesh` 노드로 메시 참조 획득
3. Geometry Script 노드로 변형
4. `Notify Mesh Updated` 호출 (변경 사항 렌더 반영)

**중요:** 런타임 변형은 비용이 큽니다. 복잡한 연산은 BeginPlay나 이벤트 트리거 시점에만 실행하세요.

---

## 성능 주의사항

| 주의 | 설명 |
|------|------|
| Tick에서 사용 금지 | 메시 생성/변형은 매 프레임 실행하면 매우 느림 |
| Boolean 연산 비용 | 복잡한 메시에서는 수 ms 소요 가능 |
| 폴리곤 수 관리 | Subdivide 남발 시 메모리·렌더링 부하 급증 |
| 에디터 vs 런타임 | 에디터 도구 제작에 최적, 런타임은 단순한 작업만 권장 |

---

## 아티스트 체크리스트

### 에디터 도구 제작 시
- [ ] Editor Utility Widget에서 실행하는가? (에디터 전용 노드 사용 시)
- [ ] 배치 처리 전 에셋을 백업했는가?
- [ ] UV 자동 생성 결과를 확인하고 오류 메시에 대한 예외 처리가 있는가?

### 런타임 메시 생성 시
- [ ] 메시 생성이 BeginPlay 또는 명시적 이벤트 시점에만 실행되는가?
- [ ] `Notify Mesh Updated` 호출을 빠뜨리지 않았는가?
- [ ] Dynamic Mesh Component가 씬에 추가되어 있는가?

### Boolean 연산 시
- [ ] 두 메시의 노멀 방향이 올바른가? (뒤집힌 노멀은 Boolean 오류 유발)
- [ ] 연산 후 `Weld Mesh Edges`로 경계를 정리했는가?
- [ ] 결과 폴리곤 수가 예상 범위 안에 있는가?
