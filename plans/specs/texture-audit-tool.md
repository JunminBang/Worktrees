# 기획서 — Texture Audit Tool

> 작성일: 2026-04-26  
> 수정일: 2026-04-26 (어드바이저 검수 반영)  
> 카테고리: 에셋 파이프라인  
> 우선순위: 높음 (텍스처는 메모리 예산의 최대 점유원)

---

## 개요

프로젝트 내 텍스처를 일괄 분석해 해상도 규칙 위반(non-power-of-two), 과다 메모리 점유, 잘못된 압축 포맷을 탐지하고 리포트로 출력하는 에디터 유틸리티.  
**1차 릴리스는 탐지/리포트 전용 — 일괄 포맷 변경은 2차 릴리스.**

---

## 문제 정의

- 아티스트가 임포트 시 압축 설정을 기본값으로 두면 메모리를 과다 사용한다.
- non-pow2 텍스처는 스트리밍 효율이 떨어지고 일부 플랫폼에서 문제를 일으킨다.
- 프로젝트 규모가 커질수록 어느 텍스처가 메모리를 얼마나 쓰는지 파악하기 어렵다.
- 컬러맵에 노멀맵 압축 포맷이 적용되거나 그 반대 케이스가 종종 발생한다.

---

## 목표

- 전체 텍스처 해상도·압축 포맷·메모리 점유 일괄 분석
- 문제 항목을 카테고리별로 분류해 수정 우선순위 제공
- 메모리 절감 예측값 표시
- 1차: 탐지 + 리포트. 2차: 일괄 포맷 변경

---

## 탐지 항목

### 카테고리 A — 해상도

| 체크 | 기준 | 심각도 |
|---|---|---|
| Non-power-of-two | Width 또는 Height가 2의 거듭제곱이 아님 | 경고 |
| 비정상적 대형 텍스처 | 해상도 4096 초과 (설정 가능) | 경고 |
| 1×1 또는 2×2 텍스처 | 임포트 오류 의심 (`/Engine/`, 플러그인 경로 제외 후 판정) | 정보 |

### 카테고리 B — 압축 포맷

| 체크 | 기준 | 심각도 |
|---|---|---|
| 압축 없음 | `CompressionSettings == TC_Default` + (`LODGroup ∉ {UI, Lightmap, Shadowmap, Cinematic, EditorIcon}`) | 경고 |
| 노멀맵에 sRGB 오류 | `CompressionSettings == TC_Normalmap` AND `SRGB == true` | 오류 |
| 컬러맵에 노멀맵 포맷 | `CompressionSettings == TC_Normalmap` AND `LODGroup ∈ {World, Character}` AND `LODGroup ∉ {WorldNormalMap, CharacterNormalMap}` | 경고 |
| HDR 텍스처에 비HDR 압축 | `Source.Format == TSF_RGBA16F` AND `CompressionSettings ∉ {TC_HDR, TC_HDR_Compressed}` | 경고 |
| UI 텍스처에 밉맵 활성화 | `LODGroup == TEXTUREGROUP_UI` AND `MipGenSettings != NoMipmaps` | 정보 |
| UI 텍스처에 sRGB 미적용 | `LODGroup == TEXTUREGROUP_UI` AND `SRGB == false` | 정보 |

> **노멀맵 판정 근거**: LODGroup이 아닌 `CompressionSettings == TC_Normalmap`을 기준으로 삼는다.  
> LODGroup이 `World`인 노멀맵은 정상 설정이므로, LODGroup만으로 노멀 여부를 판단하면 오탐이 폭증한다.  
> `TEXTUREGROUP_WorldNormalMap`, `TEXTUREGROUP_CharacterNormalMap`은 별도 enum(`TextureDefines.h`)으로 존재하므로 컬러-노멀 룰에서 명시 제외.

### 카테고리 C — 메모리

| 체크 | 기준 | 심각도 |
|---|---|---|
| 단일 텍스처 메모리 상한 초과 | 런타임 메모리 > 64MB (설정 가능) | 경고 |
| 스트리밍 미설정 대형 텍스처 | 메모리 > 16MB AND `NeverStream == true` AND `LODGroup ∉ {UI, Lightmap, Shadowmap, Cinematic}` | 경고 |
| 밉맵 없는 대형 텍스처 | 512 초과 AND `MipGenSettings == NoMipmaps` AND `LODGroup != TEXTUREGROUP_UI` | 정보 |

> **VT(Virtual Texture) 예외**: `VirtualTextureStreaming == true`인 텍스처는 메모리 관리 방식이 다르므로  
> 카테고리 C 룰 전체에서 **별도 분류**하여 "VT 텍스처 (별도 분류)" 탭에 집계한다.  
> `CalcTextureMemorySizeEnum(TMC_AllMips)`은 VT 텍스처에서 의미 없는 값을 반환할 수 있어 신뢰 불가.

---

## 메모리 계산 방식

```
기본 경로 (정확): UTexture2D::CalcTextureMemorySizeEnum(TMC_AllMips)
  → 플랫폼별 실제 런타임 메모리. 로드 필요.

추정 fallback (CalcTextureMemorySizeEnum 실패 또는 미로드 시):
  런타임 압축 메모리 ≈ (Width × Height × BytesPerPixel) × 1.33

  포맷별 BytesPerPixel:
    BC1(DXT1):  0.5
    BC3(DXT5):  1.0
    BC4:        0.5
    BC5:        1.0  ← 노멀맵 권장
    BC7:        1.0
    ASTC 4x4:  1.0
    Uncompressed RGBA8: 4.0

  ⚠ 1.33배 계수: BC 포맷의 4×4 블록 정렬 패딩으로 실제는 1.35~1.40배 가능.
     경계선(64MB 부근) 텍스처에서 최대 ±10% 오차 발생.
     → 가능하면 반드시 CalcTextureMemorySizeEnum 우선 사용.
```

> ℹ️ `CalcTextureMemorySize(int32 MipCount)` (int 인자) ≠ `CalcTextureMemorySizeEnum(ETextureMipCount)` (enum 인자).  
> 기획서 전반에서 **`CalcTextureMemorySizeEnum(TMC_AllMips)`** 을 사용한다.  
> `FTexturePlatformData::GetMemorySize()`도 보조 수단으로 활용 가능.

---

## 메모리 절감 예측

1차 릴리스에서 절감 예측은 다음 고정 산식으로 계산한다:

```
절감 예측 = 현재 메모리 합계 - 권장 포맷 적용 시 예상 메모리 합계

권장 포맷 BPP:
  TC_Default (Uncompressed RGBA8, 4.0 BPP) → TC_BC7 (1.0 BPP) : 절감 비율 75%
  TC_Normalmap 부재 노멀 (BC3/DXT5, 1.0 BPP) → TC_Normalmap/BC5 (1.0 BPP) : 메모리 동일, 품질만 향상
  TC_HDR 부재 HDR (4.0 BPP) → TC_HDR/BC6H (1.0 BPP) : 절감 비율 75%
  그 외 이미 압축된 경우 → 절감 0 (포맷 오류 보정만)
```

> 이 예측은 **최대 절감 상한**이며 실제 툴 체인 결과와 다를 수 있음을 UI에 명시.

---

## 구현 방향

```
모듈 의존성 (Build.cs PrivateDependencyModuleNames):
  "AssetRegistry", "UnrealEd", "RenderCore",
  "Slate", "SlateCore", "ToolMenus", "PropertyEditor"

  ※ "EditorScriptingUtilities"는 불필요 (AssetRegistry + UnrealEd로 충분)

[패스 1 — AssetRegistry 태그 스캔 (로드 없음)]
1. IAssetRegistry::Get().GetAssets(Filter)
   FARFilter:
     ClassPaths: /Script/Engine.Texture2D, /Script/Engine.TextureCube,
                 /Script/Engine.VolumeTexture, /Script/Engine.Texture2DArray
     ※ bRecursiveClasses=true로 Texture2D 상속 탐색. TextureCube/VolumeTexture는
        Texture2D의 자식이 아니므로 반드시 명시 나열 필요.
     PackagePaths: /Game
     제외: /Game/Developers/, /Engine/, 플러그인 경로 (기본)
   AssetData.GetTagValue()로 다음 정보 추출 (로드 없이):
     SizeX, SizeY, Format(PF_*), LODGroup, CompressionSettings, SRGB

2. 태그 기반 1차 룰 적용:
   → 이슈 후보 목록 생성 (경고/오류 가능성 있는 것만)

[패스 2 — 의심 후보만 로드]
3. 후보 텍스처만 AssetData.GetAsset() 호출 (동기 로드)
   UTexture2D* Tex = Cast<UTexture2D>(AssetData.GetAsset())
   수집:
   - Tex->VirtualTextureStreaming (VT 여부 — 메모리 룰 분기)
   - Tex->NeverStream
   - Tex->MipGenSettings
   - Tex->CalcTextureMemorySizeEnum(TMC_AllMips) ← 정확 메모리
   - Tex->Source.GetSizeX(), GetSizeY() (import-time 원본 크기)

4. VT 텍스처 별도 분류 후 나머지에 카테고리 A~C 룰 적용
   → FTextureIssue 레코드 생성

[패스 3 — 결과 집계]
5. 카테고리별 이슈 수
6. 메모리 절감 예측 (고정 산식 적용)
7. 상위 메모리 점유 텍스처 Top 20 (VT 포함, 별도 표시)
8. 취소 시 수집된 부분 결과 보존하여 패널에 노출

[패스 4 — 출력]
9. 에디터 패널 표시
10. Content Browser에서 선택:
    FContentBrowserModule& CB = FModuleManager::LoadModuleChecked<FContentBrowserModule>("ContentBrowser")
    CB.Get().SyncBrowserToAssets(SelectedAssets)
11. CSV 저장: Saved/TextureAudit_YYYYMMDD_HHmmss_N.csv
    (동시 다중 스캔 대비 카운터 N 접미사)
```

---

## 에디터 패널 구성

```
[전체 스캔] 버튼  |  [선택 폴더만] 버튼  |  [취소] 버튼 (슬로우태스크)

요약: 총 텍스처 482개 | VT 23개 (별도) | 오류 3개 | 경고 27개 | 정보 41개
현재 텍스처 메모리 총합: 1.8 GB | 절감 예측(최대): ~340 MB

[탭: 해상도 문제] [탭: 압축 문제] [탭: 메모리 Top 20] [탭: VT 별도] [탭: 전체]

────────────────────────────────────────────────────────────
텍스처명           | 해상도     | 포맷    | 메모리  | 이슈
────────────────────────────────────────────────────────────
T_Terrain_Diff    | 4096×4096 | DXT1   | 22 MB  | 대형 경고
T_Wall_N          | 2048×2048 | DXT5   | 11 MB  | TC_Normalmap 미설정 + SRGB=true (오류)
T_UI_Button       | 512×512   | DXT1   | 0.3 MB | UI에 밉맵 활성화
────────────────────────────────────────────────────────────

⚠ 절감 예측은 최대 상한치입니다. 실제 쿠킹 결과와 차이가 있을 수 있습니다.

클릭 → Content Browser에서 선택
```

---

## Wiki Auto-Ingest Hook 연동

`tools/auto-ingest/config.json` watchTargets에 추가:

```json
{
  "id": "texture-audit",
  "pattern": "Saved/TextureAudit_*.csv",
  "parser": "profiling-csv",
  "rawPath": "raw/auto/profiling/",
  "wikiCategory": "pattern",
  "wikiTags": ["texture", "memory", "compression"],
  "minSizeKB": 1,
  "debounceSeconds": 0
}
```

---

## 입출력

**입력**
- 스캔 경로 (기본: `/Game/`)
- 대형 텍스처 상한 해상도 (기본: 4096)
- 단일 텍스처 메모리 경고 임계값 (기본: 64MB)
- 스트리밍 경고 임계값 (기본: 16MB)

**출력**
- 에디터 결과 패널 (탭별 분류, 취소 시 부분 결과 보존, 클릭 → Content Browser 선택)
- `Saved/TextureAudit_YYYYMMDD_HHmmss_N.csv`
  - 컬럼: PackagePath / TextureName / SizeX / SizeY / CompressionSettings / SRGB / LODGroup / MemoryMB / IsVT / Issues

---

## 2차 릴리스 — 일괄 포맷 변경

| 안전망 | 내용 |
|---|---|
| dry-run + 미리보기 | 변경 목록 확인 후 승인 |
| 변경 매니페스트 | 롤백을 위한 (oldSettings → newSettings) 기록 |
| 재쿠킹 권고 | 포맷 변경 후 쿠킹 재실행 안내 |
| 플랫폼별 오버라이드 보존 | `PlatformData` 오버라이드 설정 덮어쓰기 방지 |
| 100개 상한 | 1회 일괄 변경 최대 100개 |

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| 플랫폼별 차이 | `CalcTextureMemorySizeEnum()`는 현재 타깃 플랫폼 기준. 콘솔/모바일 메모리는 다를 수 있음 |
| TextureCube / VolumeTexture | ClassPaths에 명시 나열하여 수집. 메모리 계산식이 2D와 다름 — 별도 표시 |
| 가상 텍스처 (Virtual Texture) | `VirtualTextureStreaming == true` 시 메모리 룰 분기, 별도 탭으로 집계 |
| 스트리밍 완료 전 조회 | `TMC_AllMips` 기준으로 통일 |
| 로드 비용 | 2-pass 구조로 이슈 후보만 로드. FScopedSlowTask + 취소 버튼 + 부분 결과 보존 필수 |
| API 혼동 주의 | `CalcTextureMemorySize(int32)` ≠ `CalcTextureMemorySizeEnum(ETextureMipCount)`. 반드시 후자 사용 |
| 메모리 추정 오차 | BC 블록 패딩으로 1.33배 계수에 최대 ±10% 오차. `CalcTextureMemorySizeEnum` 사용 시 무관 |

---

## 완료 기준

### 1차 릴리스 (탐지/리포트)
- [ ] IAssetRegistry 기반 텍스처 목록 수집 (Texture2D + TextureCube + VolumeTexture + Texture2DArray 명시 나열)
- [ ] 2-pass 스캔: 패스1 AssetRegistry 태그만 → 패스2 의심 후보만 로드
- [ ] VirtualTextureStreaming 플래그 체크 → 별도 탭 분류
- [ ] 카테고리 A~C 전체 탐지 룰 구현 (검수 반영 버전)
- [ ] `CalcTextureMemorySizeEnum(TMC_AllMips)` 기반 메모리 측정 (추정식은 fallback)
- [ ] 메모리 절감 예측값 (고정 산식 + "최대 상한" UI 안내)
- [ ] Top 20 메모리 점유 텍스처 집계 (VT 포함, 별도 표시)
- [ ] 에디터 패널 (탭별 분류, 취소 시 부분 결과 보존, 클릭 → FContentBrowserModule::SyncBrowserToAssets)
- [ ] FScopedSlowTask 진행률 + 취소 버튼
- [ ] CSV 리포트 저장 (파일명 카운터 N 접미사)
- [ ] Wiki Auto-Ingest Hook config.json watchTarget 추가

### 2차 릴리스 (일괄 포맷 변경)
- [ ] dry-run + 미리보기 + 승인 단계
- [ ] 변경 매니페스트 + 롤백
- [ ] 플랫폼별 오버라이드 보존
- [ ] VT / TextureCube / VolumeTexture 별도 처리
