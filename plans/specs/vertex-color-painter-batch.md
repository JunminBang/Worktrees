# 기획서 — Vertex Color Painter Batch

> 작성일: 2026-04-27  
> 수정일: 2026-04-27 (어드바이저 검수 반영)  
> 카테고리: 렌더링 / 머티리얼  
> 우선순위: 낮음

---

## 개요

선택한 메시 그룹에 동일한 Vertex Color 값을 일괄 도포하는 에디터 유틸리티.  
**1차 릴리스: 인스턴스 레벨(레벨 배치 컴포넌트), Non-Nanite, LOD 전체 동기화.**

---

## 에셋 레벨 vs 인스턴스 레벨 설계 결정

| 구분 | 설명 | API 경로 | 위험도 |
|---|---|---|---|
| **인스턴스 레벨** (1차) | 레벨에 배치된 컴포넌트에만 색 덮어씌움. 원본 에셋 불변 | `UStaticMeshComponent::SetVertexColorOverride_LinearColor` | 낮음 |
| **에셋 레벨** (2차) | UStaticMesh 에셋 자체를 수정. 모든 인스턴스에 영구 반영 | `FMeshDescription` + `CommitMeshDescription` + `Build` | 높음 |

> 1차 릴리스는 **인스턴스 레벨**로 한정한다.  
> 에셋을 직접 수정하는 에셋 레벨은 협업 충돌·SCC 잠금·Nanite 재빌드 등 리스크가 크므로 2차에서 처리.

---

## 문제 정의

- 여러 메시에 동일한 Vertex Color(마스크, 오클루전, 파라미터) 값을 수작업으로 칠하기 어렵다.
- 머티리얼이 Vertex Color를 사용하는데 색이 초기화되지 않아 시각 결함이 생긴다.
- 채널별(R/G/B/A) 독립 도포 기능이 없어 파라미터 마스크 작업에 불편하다.

---

## 목표

- 레벨 선택 또는 지정 폴더 내 StaticMesh 컴포넌트에 RGBA 값 일괄 도포
- 기존 색 보존/덮어쓰기 옵션
- 채널별(R/G/B/A) 독립 적용
- 머티리얼이 Vertex Color를 사용하지 않을 때 사전 경고

---

## 적용 방식 (1차: 인스턴스 레벨)

```cpp
// UStaticMeshComponent::SetVertexColorOverride_LinearColor
// LOD별로 색 배열을 건네 인스턴스에 오버라이드

TArray<FColor> Colors;
int32 NumVerts = Comp->GetStaticMesh()->GetNumVertices(LODIndex);

// 검증: 버텍스 수 불일치 시 도포 불가
if (NumVerts == 0) { /* 오류 처리 */ }

Colors.Init(TargetColor, NumVerts);

// 채널 보존 옵션: 기존 인스턴스 색에서 지정 채널만 교체
if (bPreserveExistingChannels)
{
    TArray<FColor> ExistingColors = GetCurrentInstanceColors(Comp, LODIndex);
    for (int32 i = 0; i < Colors.Num(); ++i)
    {
        if (!bApplyR) Colors[i].R = ExistingColors[i].R;
        if (!bApplyG) Colors[i].G = ExistingColors[i].G;
        if (!bApplyB) Colors[i].B = ExistingColors[i].B;
        if (!bApplyA) Colors[i].A = ExistingColors[i].A;
    }
}

Comp->SetVertexColorOverride_LinearColor(LODIndex, ToLinearArray(Colors));
```

---

## 탐지 항목 (사전 검사)

| 체크 | 기준 | 처리 |
|---|---|---|
| Vertex Color 미사용 머티리얼 | 컴포넌트 머티리얼이 VertexColor 노드를 쓰지 않음 | 경고 모달 (진행 여부 사용자 선택) |
| Nanite 메시 | `NaniteSettings.bEnabled == true` | 1차 릴리스 스킵 + 목록 표시 |
| 버텍스 수 0 | `GetNumVertices(LOD) == 0` | 해당 LOD 스킵 |
| LOD 불일치 | 인스턴스 오버라이드 후 메시 재빌드 시 색 소실 가능 | 경고 표시 |

---

## LOD 동기화 정책

인스턴스 레벨에서도 **전체 LOD 동기화**를 기본으로 한다.  
LOD별로 버텍스 수가 다르므로 각 LOD에 독립적으로 도포:

```
for (int32 LOD = 0; LOD < Mesh->GetNumLODs(); ++LOD)
{
    SetVertexColorOverride_LinearColor(LOD, ...)
}
```

---

## 구현 방향

```
모듈 의존성 (Build.cs PrivateDependencyModuleNames):
  "Engine", "UnrealEd",
  "Slate", "SlateCore", "ToolMenus"
  (에디터 전용 — Type: Editor, WITH_EDITOR 가드)
  ※ "MeshPaint" 모듈 불필요 (인터랙티브 브러시 전용)

[패스 1 — 대상 수집]
1. 레벨 선택 액터의 UStaticMeshComponent 수집
   또는 지정 폴더 AssetRegistry에서 StaticMesh 수집 후 레벨 인스턴스 역추적
2. Nanite 메시 분리 → 스킵 목록
3. 머티리얼 VertexColor 노드 사용 여부 검사 → 미사용 시 경고 모달

[패스 2 — 드라이런 미리보기]
4. 영향 컴포넌트 수 / LOD별 버텍스 수 표시
5. 색 미리보기 (RGBA 값 + 채널 마스크)

[패스 3 — 도포 (승인 후)]
6. FScopedTransaction 시작
7. 각 컴포넌트 × 각 LOD에 대해:
   - Modify() 호출
   - 버텍스 수 검증
   - 채널별 보존 옵션 적용
   - SetVertexColorOverride_LinearColor(LODIndex, Colors)
8. 결과 리포트 + 패널 갱신

[되돌리기 지원]
9. 도포 전 기존 색 백업 → "원본 복원" 버튼 (트랜잭션 Undo 외 추가 안전망)
```

---

## 에디터 패널 구성

```
대상 선택: [현재 선택 액터] 버튼  |  [폴더 지정] 버튼

색 설정:
  R: [0~255] [✅ 적용]   G: [0~255] [✅ 적용]
  B: [0~255] [✅ 적용]   A: [255  ] [✅ 적용]
  
  [✅ 기존 채널 보존 (선택 해제 채널만 유지)]

[드라이런] 버튼  →  [적용] 버튼  |  [원본 복원] 버튼

드라이런 결과: 컴포넌트 42개 (Nanite 스킵 8개) | 경고: VertexColor 미사용 5개

─────────────────────────────────────────────────────────────────────
컴포넌트명              | 메시              | LOD 수 | 버텍스 수 | 상태
─────────────────────────────────────────────────────────────────────
SM_Rock_01_Inst         | SM_Rock_01       | 3      | 2,451    | ✅
SM_Nanite_Building      | SM_Building      | -      | -        | ⚠ Nanite 스킵
SM_BrokenWall_01        | SM_BrokenWall    | 2      | 1,203    | ⚠ VC 미사용 경고
─────────────────────────────────────────────────────────────────────
```

---

## 입출력

**입력**
- 대상 컴포넌트 (레벨 선택 or 폴더 기반)
- RGBA 값 (0–255)
- 채널별 적용 마스크 (R/G/B/A 독립 ON/OFF)
- 기존 채널 보존 여부

**출력**
- 에디터 패널 (드라이런 → 도포 흐름)
- 레벨 저장 (인스턴스 오버라이드 데이터는 레벨 패키지에 저장됨)
- `{ProjectSaved}/VertexColorReports/VCPainterReport_YYYYMMDD_HHmmss_N.csv`
  - 컬럼: ActorLabel / ComponentName / MeshPath / LODIndex / NumVertices / AppliedColor / Status

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| 인스턴스 레벨 한계 | 메시 재빌드 시 인스턴스 오버라이드 색 소실 가능. UI 경고 표시 |
| Nanite 메시 | 1차 스킵. 2차에서 fallback mesh 동기화 포함 처리 |
| LOD별 버텍스 수 차이 | 각 LOD에 독립 도포. 버텍스 수 0인 LOD 스킵 |
| VertexColor 미사용 머티리얼 | 경고 모달. 사용자가 계속 진행 가능 |
| Undo | `FScopedTransaction` + `Modify()`. 백업 색으로 원본 복원 버튼 추가 제공 |
| 에셋 레벨 도포 | 2차 릴리스. FMeshDescription + CommitMeshDescription + Build 필요 |

---

## 완료 기준

### 1차 릴리스 (인스턴스 레벨)
- [ ] 레벨 선택 컴포넌트 / 폴더 기반 수집
- [ ] Nanite 메시 자동 분리 + 스킵 목록
- [ ] 머티리얼 VertexColor 노드 사용 여부 검사 → 경고 모달
- [ ] 버텍스 수 검증 (`GetNumVertices`)
- [ ] 전체 LOD 동기화 도포 (`SetVertexColorOverride_LinearColor`)
- [ ] 채널별 독립 마스크 (R/G/B/A ON/OFF)
- [ ] 기존 채널 보존 옵션
- [ ] `FScopedTransaction` + `Modify()` (Undo 지원)
- [ ] 도포 전 색 백업 → 원본 복원 버튼
- [ ] 에디터 패널 (드라이런 → 승인 → 도포)
- [ ] CSV 리포트

### 2차 릴리스 (에셋 레벨)
- [ ] `FMeshDescription` + `CommitMeshDescription` + `Build` 에셋 레벨 도포
- [ ] Nanite 메시 지원 (fallback mesh + 재빌드 트리거)
- [ ] Source Control 체크아웃 통합
- [ ] 그라디언트 / 프리셋 색상 지원
