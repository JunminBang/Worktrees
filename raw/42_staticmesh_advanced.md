# 스태틱 메시 고급 — 소켓, Lightmap UV, LOD, Nanite

> 소스 경로: Runtime/Engine/Classes/Engine/StaticMesh.h
> 아티스트를 위한 설명

---

## 스태틱 메시 에디터 개요

스태틱 메시 에디터에서 LOD, UV, 소켓, 콜리전, Nanite 등 모든 메시 설정을 관리합니다.

**열기:** Content Browser에서 스태틱 메시 에셋 더블클릭

---

## Nanite 설정

Nanite는 폴리곤 수에 관계없이 고품질로 렌더링하는 가상화 메시 시스템입니다.

| 프로퍼티 | 설명 |
|---------|------|
| `Enable Nanite` | ON/OFF. 활성화 시 별도 LOD 불필요 |
| `Nanite Fallback Triangle Percent` | Nanite 미지원 환경에서 사용할 폴리곤 비율 |
| `Nanite Fallback Relative Error` | Nanite 폴백 오차 허용 범위 |
| `Displacement Maps` | 노멀 대신 실제 지오메트리 변위 적용 (UE5.3+) |

### Nanite 지원/미지원 항목

| 지원 | 미지원 |
|------|--------|
| 불투명 머티리얼 | 반투명/마스크 머티리얼 |
| 정적 메시 | 스켈레탈 메시 |
| 랜드스케이프 | 파티클/디캘 |
| 대부분의 PBR 머티리얼 | Pixel Depth Offset 사용 머티리얼 |

---

## LOD 설정

### 자동 LOD 생성

1. 스태틱 메시 에디터 → **LOD Settings** 탭
2. `Number of LODs` 설정
3. 각 LOD의 `Screen Size`와 `Percent Triangles` 조정
4. **Apply Changes** 클릭

### LOD별 주요 파라미터

| 파라미터 | 설명 |
|---------|------|
| `Screen Size` | 이 LOD가 적용되는 화면 점유 비율 (0~1) |
| `Percent Triangles` | 원본 대비 삼각형 유지 비율 |
| `Max Deviation` | 허용 오차 (cm) |
| `Welding Threshold` | 버텍스 병합 거리 임계값 |
| `Shadow LOD` | 그림자 전용 LOD |

### 수동 LOD 임포트

1. LOD 탭 → **LOD1** → `Import LOD Level1` → FBX 선택
2. 각 LOD는 동일한 UV 채널 수를 가져야 함

---

## Lightmap UV

### Lightmap UV란?

Lightmap UV는 **라이트맵(베이크드 조명)을 저장하기 위한 전용 UV 채널**입니다. 겹침 없이 UV 섬이 배치되어야 합니다.

| 요건 | 설명 |
|------|------|
| 겹침 없음 | UV 섬이 서로 겹치면 조명이 번짐 |
| 0~1 범위 | 모든 UV 섬이 0~1 UV 공간 안에 있어야 함 |
| 충분한 텍셀 | 작은 면도 최소 2×2 픽셀 이상 |

### 설정 방법

1. 스태틱 메시 에디터 → **Details** → `Light Map Coordinate Index`
   - 0 = UV 채널 0 (기본 텍스처 UV)
   - 1 = UV 채널 1 (Lightmap 전용)
2. `Light Map Resolution`: 라이트맵 텍스처 해상도 (64~2048)

### 자동 Lightmap UV 생성

1. FBX 임포트 시 `Generate Lightmap UVs` 체크
2. 또는 스태틱 메시 에디터 → **Build Settings** → `Generate Lightmap UVs` ON

### Lightmap 품질 확인

뷰포트 → **Optimization Viewmode** → `Lightmap Density` — 초록=적정, 파랑=너무 낮음, 빨강=너무 높음

---

## UV 채널 관리

| UV 채널 | 일반적 용도 |
|---------|-----------|
| UV 0 | 기본 텍스처 매핑 |
| UV 1 | Lightmap UV |
| UV 2 | 보조 텍스처 (디테일 맵, 데칼 등) |

---

## 소켓 (Socket)

소켓은 **메시의 특정 위치에 이름을 붙여 다른 오브젝트를 부착할 기준점**입니다.

### 소켓 생성

1. 스태틱 메시 에디터 → **Sockets** 패널
2. `+Socket` 클릭
3. 이름 지정 (예: `Socket_Muzzle`, `Socket_Handle`)
4. 위치/회전 조정 (뷰포트에서 직접 이동 가능)

### Blueprint에서 소켓 활용

```
→ SpawnActor at Location
    Location: GetSocketLocation (ComponentRef, "Socket_Muzzle")

→ AttachActorToActor
    Socket Name: "Socket_Handle"
```

---

## 콜리전 설정

### 콜리전 복잡도

| 타입 | 설명 | 성능 |
|------|------|------|
| `Simple` | 단순화된 볼록 도형 | 빠름 |
| `Complex` | 실제 폴리곤 기반 | 느림, 정확함 |
| `Use Complex as Simple` | 복잡한 메시도 폴리곤 콜리전 | 정적 오브젝트 전용 |

### 콜리전 자동 생성

스태틱 메시 에디터 → **Collision** 메뉴:
- `Auto Convex Collision`: 자동 볼록 분해
- `Add Box/Sphere/Capsule Simplified Collision`: 단순 도형 추가
- `Remove Collision`: 콜리전 제거

---

## 머티리얼 슬롯

| 설정 | 설명 |
|------|------|
| `Slot Name` | 머티리얼 슬롯 이름 (Blueprint에서 참조) |
| `Material` | 기본 머티리얼 |
| `Cast Shadow` | 이 슬롯이 그림자를 드리울지 |

---

## 아티스트 체크리스트

### 임포트 시
- [ ] FBX에 Lightmap UV(UV 채널 1)가 포함되어 있거나 자동 생성 옵션이 체크되어 있는가?
- [ ] 스케일이 언리얼 단위(cm)에 맞게 설정되어 있는가?
- [ ] 머티리얼 슬롯 이름이 의미 있는 이름인가?

### Nanite 사용 시
- [ ] 머티리얼이 Nanite 미지원 타입(반투명/마스크)이 아닌가?
- [ ] `Nanite Fallback`이 적절한 폴리곤 비율로 설정되어 있는가?

### LOD 설정 시
- [ ] Screen Size 임계값이 씬 스케일에 맞는가?
- [ ] LOD 전환 시 팝핑이 없는가?

### Lightmap
- [ ] Lightmap UV에 겹침이 없는가? (Lightmap Density 뷰로 확인)
- [ ] Light Map Resolution이 오브젝트 크기에 비례하는가?
