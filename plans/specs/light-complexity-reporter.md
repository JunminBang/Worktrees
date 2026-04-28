# 기획서 — Light Complexity Reporter

> 작성일: 2026-04-26  
> 수정일: 2026-04-26 (어드바이저 검수 반영)  
> 카테고리: 씬 / 레벨 관리  
> 우선순위: 중간

---

## 개요

레벨 내 Light 컴포넌트를 순회해 Dynamic Light 수·유형·영향 구간 중복을 분석하고 리포트로 출력하는 에디터 유틸리티.

---

## 문제 정의

- Dynamic Light가 너무 많으면 드로우콜과 셰이더 비용이 폭증한다.
- 여러 Light의 영향 반경이 같은 구간에 중복되어도 눈으로 파악이 어렵다.
- Stationary 라이트 5개 초과 시 자동 Dynamic 강등이 발생해도 어떤 라이트가 강등됐는지 파악하기 어렵다.

---

## 목표

- 레벨 내 Light 컴포넌트 목록 + Mobility·유형별 집계
- 영향 반경 중복 페어 탐지 (가중 임팩트 스코어 기반)
- 상위 영향 라이트 Top 20 리포트
- Stationary 라이트 자동 강등 여부 식별

---

## 탐지 항목

| 체크 | 기준 | 심각도 |
|---|---|---|
| 과다 Dynamic(Movable) 라이트 | Movable 라이트 수 > N (Megalights 비활성 기본: 50, 설정 가능) | 경고 |
| Stationary 라이트 5개 초과 | 같은 공간에 Stationary > 4 → 자동 Movable 강등 우려 | 경고 |
| 반경 중복 고임팩트 페어 | 임팩트 스코어(아래 정의) ≥ 임계값 | 경고 |
| 과도한 AttenuationRadius | Movable 라이트 중 AttenuationRadius > 2000 UU AND Intensity > 0 | 정보 |
| 그림자 미설정 Movable 라이트 | `bCastShadows == false` AND `Mobility == Movable` | 정보 |

> **Megalights 활성 시**: `r.Megalights.Enable == 1` 이면 "Dynamic 라이트 > N" 경고는 자동 억제.  
> `r.DynamicGlobalIlluminationMethod` 값도 함께 확인해 Lumen 환경 여부를 메타데이터에 기록.

---

## 영향 반경 중복 탐지 방식

단순 "거리 < R1+R2" 페어 카운트 대신 **임팩트 가중 스코어** 사용:

```
OverlapScore(A, B) = (Intensity_A × Intensity_B) / (Distance_AB² + 1)

OverlapScore ≥ 임계값(설정 가능, 기본: 1.0) 페어 → 경고 대상
```

- 반경이 크더라도 강도가 낮으면 실제 비용이 낮음
- 거리가 멀수록 스코어 감쇠 → 끝자락만 겹치는 페어 오탐 방지
- SpotLight는 OuterConeAngle 기반 방향 보정 계수 적용 (기본: 0.5)

> ⚠ 정밀 보셀 기반 탐지(체적 계산)는 2차 릴리스. 1차는 스코어 페어 비교.

---

## Light 컴포넌트 수집

```
// ALight 액터 이터레이터만으로는 BP/컴포넌트 형태 라이트 누락
// → ULightComponentBase 파생 컴포넌트 전체 순회

for (TActorIterator<AActor> ActorIt(World); ActorIt; ++ActorIt)
{
    TArray<ULightComponent*> LightComps;
    ActorIt->GetComponents<ULightComponent>(LightComps);
    for (ULightComponent* LC : LightComps)
    {
        if (!LC->IsRegistered()) continue;
        if (!LC->GetOwner()->GetWorld() == World) continue;
        if (LC->bHiddenInGame) continue;           // HiddenInGame 라이트 제외
        if (LC->Intensity <= 0.f) continue;        // 강도 0 제외
        if (!LC->bAffectsWorld) continue;          // World 영향 없는 라이트 제외
        // FLightSample 생성
    }
}
```

### 수집 대상 정보

| 필드 | 소스 |
|---|---|
| LightType | `UPointLightComponent` / `USpotLightComponent` / `URectLightComponent` / `UDirectionalLightComponent` / `USkyLightComponent` |
| Mobility | `USceneComponent::Mobility` |
| AttenuationRadius | `ULightComponent::AttenuationRadius` |
| Intensity | `ULightComponent::Intensity` |
| bCastShadows | `ULightComponent::CastShadows` |
| bUseInverseSquaredFalloff | `ULightComponent::bUseInverseSquaredFalloff` |
| LightFunctionMaterial 유무 | `ULightComponent::LightFunctionMaterial != nullptr` |
| IES Profile 유무 | `UPointLightComponent::IESTexture != nullptr` |
| OwnerActor | `GetOwner()->GetActorLabel()` |
| OwnerLevel | `GetOwner()->GetLevel()->GetOutermost()->GetName()` |
| Location | `GetOwner()->GetActorLocation()` |

### 제외 대상

- `bHiddenInGame == true`
- `Intensity <= 0`
- `bAffectsWorld == false`
- `DirectionalLight` / `SkyLight`: AttenuationRadius 개념 없음 → Top 20에서 별도 표시(방향성 라이트 탭)

---

## 구현 방향

```
모듈 의존성 (Build.cs PrivateDependencyModuleNames):
  "Engine", "UnrealEd", "Slate", "SlateCore", "ToolMenus"

[패스 1 — 데이터 수집]
1. World 결정: GEditor->GetEditorWorldContext().World()
   → EditorWorld 기준. PIE/SIE 중이면 "PIE 종료 후 실행" 안내 + 차단.
2. World Partition 활성 여부: World->GetWorldPartition() != nullptr
   → 활성 시 "로드된 셀만 스캔됨" 배너 표시
3. 컴포넌트 순회 (위 코드 기준) → TArray<FLightSample> 수집

[패스 2 — 집계]
4. Mobility별 / LightType별 카운트
5. Megalights 활성 여부 확인: r.Megalights.Enable CVar 조회
6. 탐지 룰 적용 (위 표)
7. Stationary 강등 식별: Stationary 라이트 중 `bPrecomputedLightingIsValid == false` 표시

[패스 3 — 반경 중복 스코어링]
8. Movable / Stationary 라이트 페어 O(N²) 스코어 계산
   N > 200 시 경고 + 성능 옵션 안내 (공간 파티션 적용은 2차)

[패스 4 — 출력]
9. 에디터 패널 (EditorUtilityWidget 기반) + Content Browser 선택
10. CSV 저장: Saved/LightReports/LightReport_YYYYMMDD_HHmmss_N.csv
```

---

## 에디터 패널 구성

```
[스캔] 버튼

환경: Lumen ON | Megalights OFF | World Partition 활성 (로드된 셀만)

요약: 라이트 총 84개 | Movable 31개 | Stationary 12개 | Static 41개
      경고 5개 | 정보 11개

[탭: 요약] [탭: 반경 중복] [탭: Top 20] [탭: 방향성 라이트] [탭: 전체]

─────────────────────────────────────────────────────────
라이트명            | 유형    | Mobility   | 반경    | 이슈
─────────────────────────────────────────────────────────
PointLight_Torch_01 | Point  | Movable    | 800 UU | 중복 페어 3
SpotLight_Lamp_02   | Spot   | Stationary | 1200UU | -
DirectionalLight    | Dir    | Stationary | -      | (별도 탭)
─────────────────────────────────────────────────────────

클릭 → 액터 선택 (GEditor->SelectActor + 카메라 이동)
```

---

## 입출력

**입력 (설정 가능)**
- Dynamic(Movable) 라이트 경고 임계값 (기본: 50)
- 반경 중복 OverlapScore 임계값 (기본: 1.0)
- AttenuationRadius 정보 임계값 (기본: 2000 UU)

**출력**
- 에디터 결과 패널 (탭별, 클릭 → 액터 선택)
- `Saved/LightReports/LightReport_YYYYMMDD_HHmmss_N.csv`
  - 컬럼: LightName / LightType / Mobility / AttenuationRadius / Intensity / bCastShadows / bUseInverseSquaredFalloff / HasLightFunction / HasIESProfile / OverlapScore / OwnerActor / OwnerLevel / Location / Issues

---

## 제약 / 리스크

| 항목 | 내용 |
|---|---|
| Megalights 환경 | `r.Megalights.Enable == 1` 시 Movable 라이트 수 경고 자동 억제 |
| World Partition 미로드 셀 | 로드된 셀만 스캔. 배너로 명시 |
| DirectionalLight / SkyLight | AttenuationRadius 개념 없음 → 별도 탭으로 표시 |
| 반경 중복 O(N²) | N > 200 시 성능 경고. 공간 분할은 2차 릴리스 |
| PIE 차단 | PIE/SIE 중 실행 차단 |

---

## 완료 기준

### 1차 릴리스
- [ ] `ULightComponent` 파생 컴포넌트 전체 순회 (Actor 이터레이터 + GetComponents)
- [ ] Intensity/bAffectsWorld/bHiddenInGame 기반 필터링
- [ ] Megalights/Lumen CVar 조회 → 임계값 분기
- [ ] 탐지 룰 5종 구현
- [ ] Stationary 강등 식별 (`bPrecomputedLightingIsValid`)
- [ ] 임팩트 가중 OverlapScore 페어 계산
- [ ] World Partition 활성 배너
- [ ] 에디터 패널 (EditorUtilityWidget, 탭별, 클릭 → GEditor->SelectActor)
- [ ] FScopedSlowTask + 취소 버튼
- [ ] CSV 저장 (Saved/LightReports/ 서브폴더)

### 2차 릴리스
- [ ] 보셀 그리드 기반 정밀 cover count
- [ ] 공간 분할(Octree) 적용으로 대형 레벨 O(N²) 개선
- [ ] World Partition 전체 셀 순차 로드 스캔
