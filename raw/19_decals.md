# Decal (데칼) 시스템

> 소스 경로: Runtime/Engine/Classes/Components/DecalComponent.h
> 아티스트를 위한 설명

---

## 데칼이란?

데칼은 3D 공간에 존재하는 "스티커"입니다. 메시 표면 위에 머티리얼을 투영해 그려주는 방식으로, 실제 메시 지오메트리를 수정하지 않습니다.

**대표적인 사용 사례:**
- 총탄 자국, 폭발 그을음, 충격 흔적
- 바닥의 핏자국, 타이어 스키드 마크
- 벽의 낙서, 포스터, 스텐실
- 웅덩이, 이끼, 녹슨 자국 같은 환경 디테일

---

## DecalComponent vs DecalActor

| 구분 | UDecalComponent | ADecalActor |
|------|----------------|-------------|
| 정체 | 컴포넌트 | 액터 |
| 용도 | C++/BP에서 직접 생성 | 레벨 에디터에서 배치 |
| 포함 관계 | 독립적으로 존재 | 내부에 UDecalComponent 소유 |
| 런타임 생성 | SpawnDecalAtLocation()이 반환 | 주로 에디터 배치용 |

---

## 데칼 블렌드 모드

### Deferred Decal 계열 (베이크드 라이팅 미지원)

| 모드 | 설명 | 사용 시기 |
|------|------|---------|
| **Translucent** | GBuffer 전체 갱신, 알파 블렌드 | 범용 데칼 (기본값) |
| **Stain** | BaseColor만 곱연산 | 얼룩, 오염, 녹 |
| **Normal** | 노멀만 블렌드 | 표면 디테일 추가 |
| **Emissive** | 발광만 가산 합성 | 네온, 빛나는 균열, 마법 문양 |

### DBuffer Decal 계열 (베이크드 라이팅 지원)

| 모드 | 갱신 채널 |
|------|---------|
| `DBuffer_ColorNormalRoughness` | Color + Normal + Roughness |
| `DBuffer_Color` | Color만 |
| `DBuffer_ColorNormal` | Color + Normal |
| `DBuffer_Normal` | Normal만 |
| `DBuffer_Roughness` | Roughness만 |

---

## DBuffer Decal vs Deferred Decal 차이

| 항목 | Deferred Decal | DBuffer Decal |
|------|---------------|---------------|
| 처리 시점 | 라이팅 패스 이후 GBuffer에 적용 | 라이팅 패스 이전에 별도 DBuffer에 기록 |
| 베이크드 라이팅 | 미지원 | 지원 |
| 성능 비용 | 낮음 | 약간 높음 |
| 사용 조건 | 기본 사용 가능 | `Project Settings > Rendering > DBuffer Decals` 활성화 필요 |

> **아티스트 주의:** 레벨이 라이트맵 베이크를 사용한다면 반드시 DBuffer 계열을 선택해야 합니다. Deferred 계열은 라이트맵 환경에서 데칼이 밝게 떠 보일 수 있습니다.

---

## 데칼 머티리얼 설정 방법

1. **Material Domain** → `Deferred Decal`로 변경
   - Details 패널 > Material > Material Domain
2. **Decal Blend Mode** 선택
3. 필요한 채널만 핀에 연결
   - Translucent 모드: BaseColor, Roughness, Normal, Opacity
   - Normal 모드: Normal, Opacity만
   - Emissive 모드: Emissive Color, Opacity만
4. **Opacity** 핀은 데칼 전체의 투명도 제어 (반드시 연결 권장)
5. **DecalLifetimeOpacity** 머티리얼 노드를 Opacity에 곱하면 페이드아웃 자동 적용

> **핵심 규칙:** Domain을 Deferred Decal로 설정하지 않으면 보이지 않습니다.

---

## Fade 관련 설정

| 프로퍼티 | 설명 |
|---------|------|
| `FadeScreenSize` | 화면 크기 기준 페이드아웃 임계값. 작아지면 자동 페이드 |
| `FadeInStartDelay` | 스폰 후 페이드인 시작까지 대기 시간 (초) |
| `FadeInDuration` | 페이드인 완료까지 걸리는 시간 (초) |
| `FadeStartDelay` | 페이드아웃 시작까지 대기 시간 (초) |
| `FadeDuration` | 페이드아웃 완료까지 걸리는 시간 (초). 0이면 영구 유지 |
| `bDestroyOwnerAfterFade` | 페이드아웃 완료 후 소유 액터 자동 삭제 |

**예시:** `StartDelay=3.0, Duration=1.0, DestroyOwnerAfterFade=true` → 3초 유지 후 1초 동안 서서히 사라지고 액터 삭제

---

## 런타임에 데칼 스폰하는 방법

### SpawnDecalAtLocation (Blueprint)
```
Target: GameplayStatics
DecalMaterial: [데칼 머티리얼]
DecalSize: (X=20, Y=20, Z=20)   ← 박스 크기로 투영 범위 결정
Location: HitResult.ImpactPoint
Rotation: (-90, 0, 0)           ← 아래를 향함
LifeSpan: 5.0                   ← 5초 후 자동 삭제 (0=영구)
```

### SpawnDecalAttached (특정 컴포넌트에 붙여서 따라다니는 데칼)
```
AttachToComponent: HitResult.Component
Location: HitResult.ImpactPoint
LocationType: KeepWorldPosition
```

### 총탄 자국 스폰 패턴
1. LineTrace 실행
2. HitResult에서 ImpactPoint와 ImpactNormal 추출
3. ImpactNormal을 Rotator로 변환
4. SpawnDecalAtLocation 호출
5. 반환된 UDecalComponent에 SetFadeOut 호출

---

## 성능 최적화

| 팁 | 설명 |
|----|------|
| 화면에 동시 데칼 50개 이하 | 그 이상은 오버드로우 증가 |
| `LifeSpan` 설정 | 오래된 데칼 자동 삭제 |
| `FadeScreenSize` 설정 | 멀리서 자동 소멸 (권장값: 0.01~0.05) |
| `DecalSize` 최소화 | 너무 크면 픽셀 오버드로우 증가 |
| 총탄/파티클 연동 데칼 | 최대 개수 제한 로직 구현 권장 |
| 오브젝트 풀 사용 | 자주 스폰/삭제되는 데칼에 풀 패턴 적용 |

---

## 아티스트 체크리스트

### 머티리얼 설정
- [ ] Material Domain이 `Deferred Decal`로 설정되어 있는가?
- [ ] 목적에 맞는 Decal Blend Mode를 선택했는가?
- [ ] 베이크드 라이팅 레벨이면 DBuffer 계열 모드를 선택했는가?
- [ ] Opacity 핀이 연결되어 있는가?
- [ ] 페이드 효과가 필요하면 `DecalLifetimeOpacity` 노드를 Opacity에 곱했는가?

### 배치 및 크기
- [ ] DecalSize(투영 박스)가 표면을 완전히 덮는가?
- [ ] 투영 박스가 불필요하게 크지 않은가? (오버드로우 주의)
- [ ] 데칼이 의도한 표면에만 투영되는가? (박스가 벽을 뚫고 뒤에 투영되지 않는가?)

### 페이드 및 수명
- [ ] 동적으로 생성되는 데칼에 LifeSpan 또는 FadeDuration이 설정되어 있는가?
- [ ] `FadeScreenSize`를 설정해 멀리서 자동 소멸되도록 했는가?
- [ ] `bDestroyOwnerAfterFade`를 켜서 메모리 누수를 방지했는가?

### 성능
- [ ] 화면에 동시에 보이는 데칼이 50개를 넘지 않는가?
- [ ] 총탄/파티클 연동 데칼에 최대 개수 제한 로직이 있는가?
