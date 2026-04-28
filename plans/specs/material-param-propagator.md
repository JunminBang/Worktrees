# 기획서 — Material Param Propagator

> 작성일: 2026-04-27  
> 수정일: 2026-04-27 (어드바이저 검수 반영)  
> 카테고리: 렌더링 / 머티리얼  
> 우선순위: 중간

---

## 개요

선택한 UMaterial의 파라미터 값을 하위 Material Instance Constant(MIC) 전체에 일괄 반영하는 에디터 유틸리티.  
**드라이런 + 승인 게이트 포함 — 실제 변경은 확인 후 진행.**

> **material-instance-batcher와의 관계**:  
> material-instance-batcher가 MIC 구조 분석 인프라(수집/계층 순회/파라미터 해시)를 제공한다.  
> 이 도구는 그 인프라 위에 "쓰기 액션"을 추가하는 형태로, 2차 릴리스에서 통합 검토 권장.  
> 1차 릴리스는 독립 도구로 구현하되, 수집 로직은 material-instance-batcher와 동일 패턴을 따른다.

---

## 문제 정의

- 마스터 머티리얼 파라미터(기본값)를 바꿔도 이미 값을 오버라이드한 MIC들에는 반영되지 않는다.
- 수백 개 MIC를 수동으로 업데이트하는 데 시간이 많이 걸린다.
- Static Switch 변경 시 셰이더 재컴파일이 발생하는 걸 인지하지 못하는 경우가 많다.

---

## 목표

- 마스터 머티리얼의 특정 파라미터를 하위 MIC 전체에 일괄 반영
- 드라이런: 영향 MIC별 (현재값 → 변경 후 값) 미리보기
- Static Switch 변경 시 셰이더 재컴파일 경고 모달
- 반영 후 재저장

---

## 지원 파라미터 종류 (1차)

1차 릴리스는 **Scalar / Vector / Texture** 3종 지원. 나머지는 2차.

| 파라미터 종류 | 1차 | 2차 | API |
|---|---|---|---|
| Scalar | ✅ | | `SetScalarParameterValueEditorOnly` |
| Vector | ✅ | | `SetVectorParameterValueEditorOnly` |
| Texture | ✅ | | `SetTextureParameterValueEditorOnly` |
| Static Switch | 경고만 | ✅ | `SetStaticSwitchParameterValueEditorOnly` |
| DoubleVector | | ✅ | |
| RuntimeVirtualTexture | | ✅ | |
| Font | | ✅ | |

> **비교 단위**: `FMaterialParameterInfo`(Name + Association + Index) — 단순 Name 비교 금지.  
> **Static Switch 경고**: Static Switch 변경은 셰이더 퍼뮤테이션 재컴파일을 일으켜 수십~수백 셰이더 잡이 생성됨.  
> 1차 릴리스에서는 Static Switch 파라미터 선택 시 경고 모달 표시 + 진행 차단.

---

## MIC 수집 방식

`material-instance-batcher.md`의 수집 패턴을 따른다:

```cpp
// GetReferencers 단독 사용 금지 — Parent 검증 필수
IAssetRegistry::Get().EnumerateAssets(
    FARFilter{ClassPaths: /Script/Engine.MaterialInstanceConstant, bSearchSubClasses: false},
    [&](const FAssetData& AssetData) {
        // AssetRegistryTag "Parent" 비교로 1차 필터
        FString ParentPath;
        AssetData.GetTagValue("Parent", ParentPath);
        if (!ParentPath.Contains(TargetMaterialPath)) return true;
        
        // 정확한 검증: GetAsset() 후 Parent 직접 비교
        UMaterialInstanceConstant* MIC = Cast<UMaterialInstanceConstant>(AssetData.GetAsset());
        if (MIC && MIC->Parent == TargetMaterial) Candidates.Add(MIC);
        return true;
    }
);
```

> **계층 처리 정책**: 직접 자식(Parent == TargetMaterial)만 갱신 (1차).  
> 손자 이하의 중간 계층에서 동일 파라미터를 오버라이드하면 최종값이 달라지지 않음을 UI에 명시.

---

## 드라이런 미리보기

실제 변경 전 다음 4컬럼 미리보기를 보여준다:

| MIC 경로 | 파라미터 | 현재값 | 변경 후 값 | 적용 가능 여부 |
|---|---|---|---|---|
| /Game/MI_Rock_Wet | Roughness | 0.8 | 0.6 | ✅ |
| /Game/MI_Rock_Old | Roughness | (없음/상속) | 0.6 | ✅ (새로 추가) |
| /Game/Plugins/... | Roughness | 0.5 | 0.6 | ⚠ 읽기 전용 |

---

## 구현 방향

```
모듈 의존성 (Build.cs PrivateDependencyModuleNames):
  "Engine", "UnrealEd", "MaterialEditor",
  "AssetRegistry", "AssetTools",
  "Slate", "SlateCore", "ToolMenus"
  (에디터 전용 — Type: Editor, WITH_EDITOR 가드)

[패스 1 — MIC 수집]
1. EnumerateAssets + Parent 태그 1차 필터
2. GetAsset() 로드 + Parent 직접 검증
3. Source Control 사전 체크아웃 시도
   → 실패(읽기 전용) MIC → "적용 불가" 표시

[패스 2 — 드라이런]
4. 사용자가 파라미터 + 변경값 입력
5. Static Switch 선택 시 경고 모달 + 1차 릴리스 진행 차단
6. 각 MIC에 대해 현재값 조회 → (현재값, 변경 후 값, 적용 가능) 테이블 구성
7. 드라이런 CSV 출력 + 패널 표시

[패스 3 — 배치 적용 (승인 후)]
8. 100개 초과 시 확인 모달 ("N개 MIC에 적용합니다")
9. FScopedTransaction으로 묶기
10. 각 MIC에 대해:
    - Set*ParameterValueEditorOnly 호출
    - UMaterialEditingLibrary::UpdateMaterialInstance(MIC)
    - MIC->PostEditChange()
    - MIC->MarkPackageDirty()
11. USourceControlHelpers::CheckInFiles 또는 SaveAsset
12. FShaderCompilingManager::Get().FinishAllCompilation() 대기 (진행 표시)
13. 결과 리포트 CSV
```

---

## 에디터 패널 구성

```
① 마스터 머티리얼 선택
② 파라미터 목록 표시 (Scalar/Vector/Texture 필터)
③ 변경값 입력
④ [드라이런] 버튼 → 미리보기 표시
⑤ [배치 적용] 버튼 (드라이런 확인 후 활성화)

드라이런 결과: 영향 MIC 47개 | 적용 가능 44개 | 읽기 전용 3개

─────────────────────────────────────────────────────────────────────
MIC 경로                  | 파라미터  | 현재값 | 변경 후   | 상태
─────────────────────────────────────────────────────────────────────
/Game/Mat/MI_Rock_Wet     | Roughness | 0.8   | 0.6      | ✅
/Game/Mat/MI_Rock_Old     | Roughness | 상속   | 0.6      | ✅
/Game/Plugins/MI_Rock_P   | Roughness | 0.5   | 0.6      | ⚠ 읽기 전용
─────────────────────────────────────────────────────────────────────

⚠ 손자 계층 이하 MIC는 중간 계층이 같은 파라미터를 오버라이드하면 최종값이 다를 수 있습니다.
```

---

## 입출력

**입력**
- 마스터 UMaterial 선택
- 변경할 파라미터 + 새 값 (Scalar/Vector/Texture)

**출력**
- 드라이런 미리보기 패널 + CSV
- 배치 적용 결과 CSV
- `{ProjectSaved}/MaterialPropReports/ParamPropagate_YYYYMMDD_HHmmss_N.csv`
  - 컬럼: MICPath / Parameter / OldValue / NewValue / Status / Notes

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| Static Switch | 1차 릴리스 진행 차단. 2차에서 지원 + 셰이더 재컴파일 경고 |
| 손자 계층 MIC | 직접 자식만 갱신. 오버라이드 충돌 가능성 UI 명시 |
| 소스 컨트롤 | 체크아웃 실패 MIC는 스킵 + 별도 표시 |
| 셰이더 컴파일 | Scalar/Vector/Texture도 변경 시 셰이더 재컴파일 발생 — FShaderCompilingManager 대기 |
| 100개 초과 | 확인 모달. 하드 제한은 없으나 FScopedSlowTask 필수 |
| MID(런타임) | `bSearchSubClasses=false`로 자동 제외 |

---

## 완료 기준

### 1차 릴리스
- [ ] `EnumerateAssets` + Parent 태그 1차 필터 + `GetAsset()` 검증
- [ ] Source Control 체크아웃 + 읽기 전용 MIC 분리
- [ ] 파라미터 3종 (Scalar/Vector/Texture) 지원
- [ ] Static Switch 선택 시 경고 모달 + 진행 차단
- [ ] 드라이런: (현재값, 변경후값, 적용가능) 4컬럼 미리보기
- [ ] `Set*ParameterValueEditorOnly` → `UpdateMaterialInstance` → `PostEditChange` → `MarkPackageDirty` 순서
- [ ] `FScopedTransaction` + 100개 초과 확인 모달
- [ ] `FShaderCompilingManager::FinishAllCompilation` 대기 + 진행 표시
- [ ] 에디터 패널 + 드라이런 CSV + 결과 CSV

### 2차 릴리스
- [ ] Static Switch 지원 + 셰이더 재컴파일 진행 표시
- [ ] DoubleVector / RVT / Font 파라미터 추가
- [ ] 손자 계층 MIC 재귀 갱신 옵션
- [ ] material-instance-batcher 통합 검토
