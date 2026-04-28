# 기획서 — UV Density Checker

> 작성일: 2026-04-27  
> 수정일: 2026-04-27 (어드바이저 검수 반영)  
> 카테고리: 렌더링 / 머티리얼  
> 우선순위: 중간

---

## 개요

StaticMesh / SkeletalMesh의 Texel Density를 분석해 기준치를 벗어난 메시를 탐지하는 에디터 유틸리티.

---

## 문제 정의

- 텍스처 예산을 낭비하는 과밀 UV, 시각 품질이 떨어지는 과소 UV가 혼재한다.
- 아티스트마다 기준이 달라 일관된 텍스처 해상도 관리가 어렵다.
- UV 채널 누락(UV0 없음, Lightmap UV1 없음)이 런타임 문제를 일으킨다.

---

## 목표

- 레벨 내 StaticMesh / ISM / HISM 컴포넌트의 Texel Density 분석
- 기준치 대비 과소/과대 밀도 메시 탐지
- UV 채널 수 이상 탐지

---

## Texel Density 계산 방식

자체 공식 계산 대신 **UE 텍스처 스트리밍 시스템이 이미 캐시한 값을 우선 사용**한다.

```
기본 경로 (정확):
  UStaticMesh::UpdateUVChannelData(false)  // false = 재계산 안 함, 캐시 사용
  UStaticMesh::GetUVChannelData(MaterialIndex)
    → FMeshUVChannelInfo::LocalUVDensities[UVChannel]  // 채널별 texel density

  단위: texels per world unit(cm). 표시 시 100 곱해 texels/m으로 변환.

Fallback (캐시 없을 시):
  FMeshDescription + FStaticMeshAttributes::GetVertexInstanceUVs()로
  UV island 면적 vs world-space 삼각형 면적 비율 계산 (에디터 전용)
```

> **텍스처 해상도 기준**: `GetUVChannelData(MaterialIndex)` — 머티리얼 슬롯별로 연결된 텍스처 해상도도 함께 반영됨.  
> 단순 UV0 범위/AABB 기반 추정은 비주기적 UV, 회전 island에서 큰 오차를 일으키므로 사용하지 않는다.

---

## 탐지 항목

| 체크 | 기준 | 심각도 |
|---|---|---|
| Texel Density 과소 | `LocalUVDensities[0]` × 100 < 하한 (기본: 512 texels/m) | 경고 |
| Texel Density 과대 | `LocalUVDensities[0]` × 100 > 상한 (기본: 2048 texels/m) | 정보 |
| UV0 채널 없음 | `GetNumTexCoords(LOD0)` == 0 | 오류 |
| Lightmap UV 없음 | UV1 없음 + Static 라이팅 환경 (Lumen 비활성 시만) | 정보 |

> **Lumen 활성 시**: `r.DynamicGlobalIlluminationMethod == 1` 이면 라이트맵 불필요 → "Lightmap UV 없음" 룰 자동 비활성.  
> **임계값 정책**: 단일 px/m 기준은 장르/카메라 거리에 따라 다르므로 에셋 카테고리 태그 기반 분기를 2차 릴리스에서 지원.

---

## 컴포넌트 수집 범위

`TActorIterator<AStaticMeshActor>` 단독으로는 ISM/HISM/Foliage/PCG 인스턴스를 놓친다.

```cpp
// 정확한 수집 — 컴포넌트 기반
for (TActorIterator<AActor> ActorIt(World); ActorIt; ++ActorIt)
{
    TArray<UStaticMeshComponent*> Comps;
    ActorIt->GetComponents<UStaticMeshComponent>(Comps);
    for (UStaticMeshComponent* Comp : Comps)
    {
        if (!Comp->IsRegistered()) continue;
        if (!Comp->GetStaticMesh()) continue;
        // FUVDensitySample 생성
    }
}
```

| 컴포넌트 타입 | 포함 여부 | 비고 |
|---|---|---|
| `UStaticMeshComponent` | ✅ | |
| `UInstancedStaticMeshComponent` (ISM) | ✅ | `GetStaticMesh()` 동일 경로 |
| `UHierarchicalInstancedStaticMeshComponent` (HISM) | ✅ | Foliage 포함 |
| `USkeletalMeshComponent` | ❌ | 1차 제외 (MeshDescription 구조 다름) |
| Nanite 메시 | ✅ (분석) | `NaniteSettings.bEnabled` 표시 |
| World Partition 미로드 | ❌ | 배너 표시 |

---

## 구현 방향

```
모듈 의존성 (Build.cs PrivateDependencyModuleNames):
  "Engine", "UnrealEd",
  "MeshDescription", "StaticMeshDescription",
  "Slate", "SlateCore", "ToolMenus"
  (에디터 전용 — Type: Editor, WITH_EDITOR 가드)

[패스 1 — 컴포넌트 수집]
1. GEditor->GetEditorWorldContext().World()
2. WP 활성 여부 감지 → 배너
3. Lumen 활성 여부: r.DynamicGlobalIlluminationMethod CVar 조회
4. 컴포넌트 기반 UStaticMesh 수집 (중복 제거 TSet)

[패스 2 — Texel Density 수집]
5. 각 UStaticMesh에 대해:
   a. GetNumTexCoords(0) 체크 — UV0 없으면 오류 기록 후 스킵
   b. UpdateUVChannelData(false) 호출
   c. GetUVChannelData(MaterialIndex) → LocalUVDensities[0] 읽기
   d. 단위 변환: × 100 → texels/m
   e. Nanite 여부 태깅

[패스 3 — 탐지 룰 + 집계]
6. 탐지 룰 4종 적용
7. 밀도 분포 통계: 중앙값 / 상위 25% / 하위 25%

[패스 4 — 출력]
8. 에디터 패널 + Content Browser 선택
9. CSV: {ProjectSaved}/UVReports/UVDensityReport_YYYYMMDD_HHmmss_N.csv
```

---

## 에디터 패널 구성

```
[스캔] 버튼

환경: Lumen ON (Lightmap 룰 비활성) | World Partition 활성 (로드된 셀만)

요약: 메시 327개 | 오류 2개 | 경고 18개 | 정보 31개
밀도 분포: 중앙값 784 px/m | 하위 25% 312 px/m | 상위 25% 1,891 px/m

[탭: 과소 밀도] [탭: 과대 밀도] [탭: UV 채널 오류] [탭: 전체]

─────────────────────────────────────────────────────────────────────────
메시명              | Texel Density | UV 채널 | Nanite | 이슈
─────────────────────────────────────────────────────────────────────────
SM_DistantMountain  | 187 px/m     | UV0 있음 | OFF    | 과소 밀도 경고
SM_HeroProp_Watch   | 3,102 px/m   | UV0 있음 | OFF    | 과대 밀도 정보
SM_BrokenRock       | N/A          | UV0 없음 | OFF    | 오류
─────────────────────────────────────────────────────────────────────────

클릭 → Content Browser 포커스
```

---

## 입출력

**입력 (설정 가능)**
- Texel Density 하한 (기본: 512 texels/m)
- Texel Density 상한 (기본: 2048 texels/m)

**출력**
- 에디터 패널 (탭별, 클릭 → Content Browser)
- `{ProjectSaved}/UVReports/UVDensityReport_YYYYMMDD_HHmmss_N.csv`
  - 컬럼: PackagePath / MeshName / TexelDensityPxM / NumUVChannels / IsNanite / IsLightmapUVPresent / Issues

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| `UVChannelData` 캐시 없음 | 에셋을 한 번도 빌드 안 하면 캐시 없음 → Fallback MeshDescription 계산 |
| 에디터 전용 | `WITH_EDITOR` 가드 + 에디터 모듈 한정 |
| Nanite 메시 | 분석은 가능. Nanite 자체 LOD가 있으므로 수치 해석 주의 |
| 머티리얼 UV 스케일 | TextureCoordinate 노드의 Tiling 미반영 → 2차 릴리스에서 보완 |
| World Partition 미로드 | 로드된 셀만. 배너 표시 |
| 단일 임계값 오탐 | 장르별 카테고리 태그 기반 분기는 2차 릴리스 |

---

## 완료 기준

### 1차 릴리스
- [ ] 컴포넌트 기반 수집 (SM / ISM / HISM 포함)
- [ ] `UpdateUVChannelData` + `GetUVChannelData` 기반 Texel Density 수집
- [ ] UV0 없음 오류 탐지 (`GetNumTexCoords`)
- [ ] Lumen 활성 시 Lightmap UV 룰 자동 비활성
- [ ] Nanite 메시 태깅
- [ ] 밀도 분포 통계 (중앙값/상위하위 25%)
- [ ] 에디터 패널 (탭별, 클릭 → Content Browser)
- [ ] FScopedSlowTask + 취소 버튼
- [ ] CSV 출력 (ProjectSaved 절대화)

### 2차 릴리스
- [ ] SkeletalMesh 지원
- [ ] 에셋 카테고리 태그별 임계값 분기
- [ ] 머티리얼 TextureCoordinate Tiling 반영
- [ ] MeshDescription 직접 적분 (정밀 모드)
