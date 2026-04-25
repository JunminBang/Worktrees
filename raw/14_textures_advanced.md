# 텍스처 고급 기능 — Virtual Texturing & 렌더 타겟

> 소스 경로: Runtime/Engine/Classes/Engine/, Runtime/Renderer/Private/VT/
> 아티스트를 위한 설명

---

## Virtual Texture (VT) vs 일반 텍스처

### 일반 텍스처 (Standard Texture)
- 게임 시작 또는 스트리밍 구역 진입 시 **전체 밉체인을 메모리에 올림**
- 해상도가 올라갈수록 VRAM 사용량 선형 증가
- 4096×4096 텍스처(BC7 압축) 기준 약 22MB 차지

### Virtual Texture (VT)
- 텍스처를 **타일(Page) 단위로 쪼개** 현재 화면에 보이는 타일만 요청
- 이론상 **수십 GB 해상도** 텍스처도 VRAM 예산 내에서 운용 가능
- 활성화: 텍스처 에셋 → `Virtual Texture Streaming` 체크
- 머티리얼에서 `Texture Sample` 대신 **`Virtual Texture Sample`** 노드 사용 필요

---

## Runtime Virtual Texture (RVT)

일반 VT가 **미리 만들어진** 텍스처를 스트리밍하는 것이라면, RVT는 **씬 렌더러가 실행 중에 직접 텍스처 페이지를 그려 넣는** 방식입니다.

**RVT 레이아웃:**
```
월드 공간
  └─ RuntimeVirtualTextureComponent (씬에 배치된 박스 볼륨)
        └─ URuntimeVirtualTexture 에셋
              └─ VirtualTextureBuilder (원거리용 베이크 결과물)
```

**지원하는 레이어 타입:**
- `BaseColor` — RGBA
- `Normal` — RG+A 채널 패킹
- `Roughness` — G 채널
- `Specular` — R 채널
- `Mask` — B 채널
- `BaseColor_Normal_Specular` — 3개 렌더타겟 동시 출력

**RuntimeVirtualTextureComponent 주요 속성:**

| 속성 | 설명 |
|------|------|
| `BoundsAlignActor` | 경계를 맞출 액터 (보통 Landscape) |
| `bSnapBoundsToLandscape` | 랜드스케이프 버텍스와 텍셀 정렬 (반드시 켜기) |
| `StreamingTexture` | 원거리용 베이크된 저밉 텍스처 |
| `bHidePrimitives` | RVT 기여 메시를 메인 패스에서 숨김 (이중 렌더링 방지) |

---

## RVT 주요 사용 사례

### 1. Landscape 머티리얼 블렌딩 (가장 대표적)
랜드스케이프 위에 바위·풀·흙 레이어가 각각 머티리얼로 블렌딩될 때:
- 매 프레임 픽셀마다 레이어 계산을 반복 → 비용 높음
- RVT를 쓰면 **카메라가 처음 볼 때 한 번만 렌더링 후 캐시**
- `bSnapBoundsToLandscape = true` 필수

### 2. 메시 ↔ 랜드스케이프 블렌딩
- 바위, 나무 뿌리 등이 지면과 자연스럽게 섞이도록
- 메시 머티리얼에 `Write to Runtime Virtual Texture` 체크
- 랜드스케이프 머티리얼은 `Runtime Virtual Texture Sample` 노드로 읽음

### 3. 스트리밍 저밉 베이크
- `StreamingTexture` 슬롯에 베이크 결과물을 넣으면
- 원거리에서는 렌더링 없이 베이크된 텍스처 사용 → 성능 향상

---

## Texture2D 주요 설정

### Compression Settings (압축 방식)

| 설정값 | 용도 | 비고 |
|--------|------|------|
| `TC_Default` (DXT1/BC1) | 일반 컬러, 알파 없음 | 가장 작은 용량 |
| `TC_BC7` | 고품질 컬러, 알파 있음 | DXT5보다 품질 우수 |
| `TC_Normalmap` | 노멀맵 전용 | RG 채널만 저장, B 재구성 |
| `TC_Masks` | 마스크/채널 패킹 | sRGB 강제 비활성화 |
| `TC_HDR` | HDR 환경맵 | 16bit float |
| `TC_SingleFloat` | 단일 채널 float | 높이맵 등 |

> **아티스트 주의:** 노멀맵에 `TC_Default` 쓰면 B 채널을 그냥 압축해 품질이 떨어집니다. 반드시 `TC_Normalmap` 사용.

### sRGB 설정

| 텍스처 종류 | sRGB 설정 |
|-----------|---------|
| 컬러 텍스처 (BaseColor, Emissive) | **ON** |
| 데이터 텍스처 (노멀맵, Roughness, Metallic, Mask, 높이맵) | **OFF** |

잘못 설정하면 머티리얼 계산이 감마 공간에서 뒤틀려 렌더링 결과가 달라집니다.

### Texture Group

| 그룹 | 설명 |
|------|------|
| `TEXTUREGROUP_World` | 일반 월드 텍스처 |
| `TEXTUREGROUP_WorldNormalMap` | 월드 노멀맵 |
| `TEXTUREGROUP_Character` | 캐릭터 텍스처 |
| `TEXTUREGROUP_UI` | UI 텍스처 (밉 불필요, 압축 주의) |
| `TEXTUREGROUP_Terrain_Heightmap` | 랜드스케이프 높이맵 |
| `TEXTUREGROUP_Terrain_Weightmap` | 랜드스케이프 레이어 웨이트 |
| `TEXTUREGROUP_Effects` | 파티클/VFX |
| `TEXTUREGROUP_ColorLookupTable` | LUT (압축/밉 없음) |

---

## Render Target 활용

### TextureRenderTarget2D 포맷 선택

| 포맷 | 용도 | 메모리 |
|------|------|--------|
| `RTF_RGBA8` | 미니맵, UI 스냅샷 | 4 bytes/px |
| `RTF_RGBA8_SRGB` | sRGB 출력 필요 UI | 4 bytes/px |
| `RTF_RGBA16f` | HDR 씬 캡처, 반사 | 8 bytes/px |
| `RTF_RGBA32f` | 정밀 계산 | 16 bytes/px |
| `RTF_R32f` | 단일 채널 깊이/높이 | 4 bytes/px |

**핵심 설정:**
- `bAutoGenerateMips` — 렌더 후 자동 밉맵 생성
- `bSupportsUAV` — Compute Shader에서 쓰기 가능
- `bForceLinearGamma` — 선형 공간 강제

### 주요 사용 사례

| 용도 | 권장 포맷 | 참고 |
|------|---------|------|
| 미니맵 | `RTF_RGBA8` | 매 프레임 업데이트 불필요 |
| 보안 카메라/백미러 | `RTF_RGBA16f` | HDR 씬 정확히 캡처 |
| 포스트프로세스 입력 | `RTF_RGBA16f` | `bForceLinearGamma = true` |
| Mirror/반사 표면 | `RTF_RGBA16f` | Planar Reflection 대안 |

---

## Texture Array / Texture Cube

### Texture2DArray
- 최대 **512 슬라이스** 지원
- 모든 슬라이스가 동일한 해상도와 포맷이어야 함
- **사용 사례:** 지형 레이어 팩, 캐릭터 스킨 변형, 구름 볼륨 슬라이스

### TextureCube
- 내부적으로 **6면 = 6 슬라이스**
- **사용 사례:** IBL(Image Based Lighting), 스카이박스, 반사 큐브맵

### TextureCubeArray
- 큐브맵 여러 개를 하나의 에셋으로 묶음
- **사용 사례:** 영역별 다른 IBL, 포인트 라이트 섀도우 큐브맵 배열

---

## 아티스트 체크리스트

### 텍스처 임포트 시
- [ ] **sRGB 확인**: 컬러 텍스처만 ON, 노멀/러프/메탈/마스크는 OFF
- [ ] **Compression 설정**: 노멀맵은 반드시 `TC_Normalmap`
- [ ] **Texture Group 설정**: 월드→`World`, 캐릭터→`Character`, UI→`UI`
- [ ] **해상도 2의 제곱**: NPOT 텍스처는 밉맵 생성 불가, VT 비호환

### VT 사용 시
- [ ] 머티리얼 노드를 `Virtual Texture Sample`로 교체
- [ ] `VT Streaming` 체크박스를 텍스처 에셋에서 켬
- [ ] 텍스처 해상도가 2048 이상인 경우에만 VT 의미 있음

### RVT 설정 시
- [ ] `RuntimeVirtualTextureComponent`를 씬에 배치하고 볼륨 경계를 랜드스케이프에 맞춤
- [ ] `bSnapBoundsToLandscape = true` 필수
- [ ] 랜드스케이프 머티리얼에 `Runtime Virtual Texture Sample` 노드 추가
- [ ] 기여 메시 머티리얼에 `Write to Runtime Virtual Texture` 활성화
- [ ] 에디터에서 `Build` 버튼으로 스트리밍 저밉 베이크

### Render Target 사용 시
- [ ] **포맷 최소화**: 일반 컬러는 RTF_RGBA8, HDR 필요 시만 RTF_RGBA16f
- [ ] 미니맵처럼 자주 업데이트 불필요한 경우 캡처 빈도 낮추기
- [ ] 사용하지 않는 렌더타겟은 해제 (VRAM 상시 점유)
