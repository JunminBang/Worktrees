# 기획서 — Blueprint Compile Watchdog

> 작성일: 2026-04-26  
> 수정일: 2026-04-26 (어드바이저 검수 반영)  
> 카테고리: 빌드 / 퀄리티 게이트  
> 우선순위: 높음 (빌드 안정성 + Wiki Auto-Ingest Hook 연동)

---

## 개요

프로젝트 내 전체 Blueprint를 일괄 컴파일하고, 에러·경고·Deprecated 노드를 CSV로 출력하는 에디터 유틸리티.  
Wiki Auto-Ingest Hook과 연동해 반복 발생하는 BP 오류 패턴을 wiki에 자동 누적한다.

---

## 문제 정의

- BP 에러가 다른 레벨을 열기 전까지 발각되지 않아 늦게 발견된다.
- 경고/Deprecated 노드가 방치되다 업그레이드 시 한꺼번에 터진다.
- 어떤 BP에서 얼마나 많은 문제가 발생하는지 전체 그림이 없다.
- BP 오류 패턴이 wiki에 남지 않아 같은 실수가 반복된다.

---

## 목표

- 프로젝트 전체 BP 일괄 컴파일 → 에러/경고 수집
- BP별 / 오류 유형별 집계 리포트
- CSV 출력으로 Wiki Auto-Ingest Hook 자동 연동
- CI/CD 파이프라인에서 Commandlet으로도 실행 가능

---

## 실행 모드

### Mode A — 에디터 내 실행 (1차 릴리스 주력)

Editor Utility Widget에서 버튼 클릭 → 에디터 안에서 전체 BP 컴파일 실행.

```cpp
FKismetEditorUtilities::CompileBlueprint(
    Blueprint,
    EBlueprintCompileOptions::BatchCompile
        | EBlueprintCompileOptions::SkipGarbageCollection
        | EBlueprintCompileOptions::SkipSave,
    &ResultsLog
);
```

- `BatchCompile` : 일괄 처리 최적화
- `SkipGarbageCollection` : 매 BP마다 GC 방지 (N개마다 수동 GC)
- `SkipSave` : 자동 저장 스킵 (SCC 잠금 충돌 방지)

### Mode B — Commandlet 실행 (2차 릴리스)

엔진 내장 `UCompileAllBlueprintsCommandlet`을 **서브클래스로 상속**해 CSV 출력만 추가.  
자체 재구현 없이 엔진 로직 재활용 → 엔진 업그레이드 자동 호환.

```
UnrealEditor-Cmd.exe MyProject.uproject -run=CompileAllBlueprints
    -IgnoreFolder=/Game/Developers
    -unattended
```

> ⚠️ UE5.7은 `UnrealEditor-Cmd.exe` 사용 (`UE5Editor.exe` 아님).

---

## 수집 범위

| 대상 | 포함 여부 | 비고 |
|---|---|---|
| `UBlueprint` (일반 BP) | ✅ | |
| `UAnimBlueprint` | ✅ | bRecursiveClasses=true 로 자동 포함 |
| `UWidgetBlueprint` | ✅ | bRecursiveClasses=true 로 자동 포함 |
| `UBlueprintFunctionLibrary` | ✅ | AssetRegistry로 직접 분류 불가 → 로드 후 `BlueprintType == BPTYPE_FunctionLibrary` 분기 |
| `UBlueprintMacroLibrary` | ✅ | 동일하게 로드 후 분기 |
| `/Game/Developers/` 경로 | ❌ | 개발자 개인 폴더 제외 |
| `/Engine/` 경로 | ❌ | 엔진 기본 BP 제외 |
| 플러그인 BP | ❌ 기본 | 설정으로 포함 가능 |

---

## 수집 항목

각 컴파일 메시지에 대해:

| 필드 | 내용 |
|---|---|
| BlueprintPath | `/Game/Characters/BP_Hero` |
| BlueprintClass | `UBlueprint` / `UAnimBlueprint` 등 |
| Severity | `Error` / `Warning` / `Note` |
| Message | `FTokenizedMessage::ToText().ToString()` |
| NodeType | Deprecated 패스에서 별도 수집 (아래 참조) |
| IsDeprecated | Deprecated 노드 여부 |

### 집계 리포트

- BP별 에러 수 / 경고 수 상위 N개
- 노드 유형별 오류 빈도
- 전체 컴파일 성공/실패 BP 수

---

## 구현 방향

```
모듈 의존성 (Build.cs PrivateDependencyModuleNames):
  "AssetRegistry", "Kismet", "KismetCompiler",
  "UnrealEd", "EditorSubsystem", "AssetEditorSubsystem"

[패스 1 — BP 목록 수집]
1. AssetRegistry 초기 스캔 완료 대기 (WaitForCompletion)
2. IAssetRegistry::Get().GetAssets(Filter)
   FARFilter:
     ClassPaths: /Script/Engine.Blueprint
     bRecursiveClasses = true   (AnimBP, WidgetBP 자동 포함)
     PackagePaths: /Game
     제외 경로 필터링 (/Game/Developers 등)
3. 로드 후 BlueprintType으로 FunctionLibrary / MacroLibrary 분기

[패스 2 — 컴파일 + 메시지 수집]
4. PIE 실행 중 차단: GEditor->PlayWorld != nullptr 이면 중단 + 안내
5. 각 BP에 대해:
   FCompilerResultsLog ResultsLog;
   ResultsLog.SetSilentMode(true);
   FKismetEditorUtilities::CompileBlueprint(BP,
       BatchCompile | SkipGarbageCollection | SkipSave, &ResultsLog)
6. ResultsLog.Messages 순회:
   - FTokenizedMessage::ToText().ToString()으로 메시지 직렬화
   - EMessageSeverity::Error / Warning / Note 분류
   - FBPCompileIssue 레코드 생성
7. N개(기본: 50)마다 CollectGarbage(RF_NoFlags) 수동 호출
8. 에러 발생 BP → 2차 패스에서 재시도 1회 (토폴로지 정렬 대신)

[패스 3 — Deprecated 노드 탐지]
9. 각 BP의 모든 EdGraph 순회:
   for (UEdGraph* Graph : BP->UbergraphPages + BP->FunctionGraphs)
     for (UEdGraphNode* Node : Graph->Nodes)
       if (UK2Node* K2Node = Cast<UK2Node>(Node))
         K2Node->HasDeprecatedReference() → IsDeprecated = true
         DeprecationMessage 메타데이터 수집

[결과 출력]
10. 심각도별 정렬 + BP별 그룹핑
11. 에디터 패널 표시
12. 클릭 시 BP 에디터 열기:
    GEditor->GetEditorSubsystem<UAssetEditorSubsystem>()->OpenEditorForAsset(AssetPath)
13. CSV 저장: Saved/BlueprintCompile_YYYYMMDD_HHmmss.csv (UTF-8 BOM 포함)
```

---

## 에디터 패널 구성

```
[전체 컴파일] 버튼  |  [선택 폴더만] 버튼  |  [취소] 버튼

요약: 총 BP 235개 | 오류 12개 | 경고 47개 | Deprecated 8개

[오류만 보기] [경고만 보기] [전체 보기]

─────────────────────────────────────────────────────────
BP 이름          | 심각도  | 메시지               | Deprecated
─────────────────────────────────────────────────────────
BP_EnemyAI      | Error   | Pin type mismatch    | -
ABP_Character   | Warning | Unused variable 'X'  | -
BP_Door         | Note    | DeprecationMessage   | ✅
─────────────────────────────────────────────────────────

클릭 → UAssetEditorSubsystem::OpenEditorForAsset
```

---

## Wiki Auto-Ingest Hook 연동

`tools/auto-ingest/config.json` watchTargets에 추가:

```json
{
  "id": "bp-compile",
  "pattern": "Saved/BlueprintCompile_*.csv",
  "parser": "profiling-csv",
  "rawPath": "raw/auto/logs/",
  "wikiCategory": "debugging",
  "wikiTags": ["blueprint", "compile-error"],
  "minSizeKB": 1,
  "debounceSeconds": 0
}
```

---

## 입출력

**입력**
- 스캔 경로 (기본: `/Game/`, 지정 하위 폴더도 가능)
- 제외 경로 설정 (기본: `/Game/Developers/`, `/Engine/`)
- 플러그인 BP 포함 여부 (기본: OFF)
- GC 주기 (기본: 50개마다)

**출력**
- 에디터 결과 패널 (클릭 → BP 에디터 열기)
- `Saved/BlueprintCompile_YYYYMMDD_HHmmss.csv` (UTF-8 BOM)
  - 컬럼: BlueprintPath / BlueprintClass / Severity / Message / NodeType / IsDeprecated

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| PIE 중 실행 | `GEditor->PlayWorld != nullptr` 체크 → 실행 차단 + 안내 |
| GC 압박 | SkipGarbageCollection + N개마다 수동 GC로 처리 |
| 컴파일 순서 의존성 | `FBlueprintCompilationManager` 내부에서 자동 처리 — 토폴로지 정렬 불필요. 에러 BP만 2차 패스 재시도 |
| SCC 잠금 | `SkipSave` 플래그로 방지 |
| Deprecated 탐지 | `FCompilerResultsLog` 단독으론 부족 — EdGraph 별도 순회 필요 |
| FunctionLibrary/MacroLibrary | AssetRegistry bRecursiveClasses로 분류 불가 → 로드 후 BlueprintType 분기 |
| CSV 한글 깨짐 | UTF-8 BOM 포함 저장 |
| Mode B Commandlet | UCompileAllBlueprintsCommandlet 서브클래스로 구현 — 자체 재발명 불필요 |

---

## 완료 기준

### 1차 릴리스 (에디터 내 실행)
- [ ] IAssetRegistry 기반 BP 목록 수집 (bRecursiveClasses, 제외 경로, FunctionLibrary/MacroLibrary 분기)
- [ ] PIE 실행 중 차단 가드
- [ ] FKismetEditorUtilities::CompileBlueprint (BatchCompile | SkipGarbageCollection | SkipSave)
- [ ] FTokenizedMessage::ToText() 메시지 직렬화
- [ ] N개마다 수동 GC
- [ ] 에러 BP 2차 패스 재시도
- [ ] Deprecated 노드 탐지 (EdGraph 순회 + UK2Node::HasDeprecatedReference)
- [ ] BP별 / 노드 유형별 집계
- [ ] 에디터 패널 (클릭 → UAssetEditorSubsystem::OpenEditorForAsset)
- [ ] FScopedSlowTask 진행률 + 취소 버튼
- [ ] CSV 리포트 저장 (UTF-8 BOM)
- [ ] Wiki Auto-Ingest Hook config.json watchTarget 추가

### 2차 릴리스 (Commandlet 지원)
- [ ] UCompileAllBlueprintsCommandlet 서브클래스로 CSV 출력 확장
- [ ] CI/CD 파이프라인 연동 가이드
- [ ] `-IgnoreFolder` 파라미터 연동
