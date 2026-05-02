# 렌더링 & 셰이더 시스템

> 소스 경로: Runtime/Renderer/, Runtime/RenderCore/, Engine/Shaders/
> 아티스트를 위한 설명 — GPU가 화면을 만드는 과정

---

## 렌더링 파이프라인이란?

3D 데이터를 화면의 2D 픽셀로 변환하는 단계별 과정입니다.

```
메시 수집 (Mesh Collection)
    ↓
컬링 (Culling) — 카메라에 안 보이는 것 제거
    ↓
셰이더 바인딩 — GPU에 데이터 전달
    ↓
래스터화 (Rasterization) — 3D → 픽셀 변환
    ↓
픽셀 셰이더 — 각 픽셀 색상 계산
    ↓
포스트 프로세싱 — 블룸, DOF, 톤맵 등
    ↓
최종 화면 출력
```

---

## 셰이더 폴더 구조 (Engine/Shaders/)

```
Shaders/
├── Private/                   ← 엔진 내부용 (489개 파일)
│   ├── Common.ush              ← 모든 셰이더 공통 함수
│   ├── BRDF.ush                ← 표면 반사 모델 (금속/플라스틱/직물)
│   ├── BasePassPixelShader.usf ← 기본 색상 계산
│   ├── DeferredLightPixelShaders.usf ← 조명 계산
│   │
│   ├── PostProcess*/           ← 포스트 이펙트 (40개+)
│   │   ├── PostProcessBloom.usf       (밝은 부분 번짐)
│   │   ├── PostProcessDOF.usf         (카메라 초점)
│   │   ├── PostProcessTonemap.usf     (노출 조정)
│   │   └── PostProcessLensFlares.usf  (렌즈 플레어)
│   │
│   ├── Lumen/                  ← 실시간 전역 조명 (30개+)
│   ├── Nanite/                 ← 가상화 지오메트리 (26개)
│   └── RayTracing/             ← 레이 트레이싱
│
├── Public/                    ← 커스텀 셰이더용 공유 코드
└── Shared/                    ← C++과 셰이더가 공유하는 상수

확장자 의미:
  .usf = 완전한 셰이더 파일
  .ush = 헤더 (공유 함수 라이브러리)
```

---

## 머티리얼 시스템

### 머티리얼 도메인

| 도메인 | 용도 |
|--------|------|
| Surface (기본) | 일반 메시 표면 (철, 나무, 피부) |
| Deferred Decal | 표면 위 데칼 (탄흔, 페인트) |
| Light Function | 라이트 색상/강도 변조 |
| Post Process | 화면 전체 효과 |
| Virtual Texture | 대용량 텍스처 |

### 셰이딩 모델

| 셰이딩 모델 | 용도 | 특징 |
|------------|------|------|
| Default Lit | 일반 표면 | 금속, 플라스틱, 나무 |
| Unlit | 자체 발광 | UI, LED, 화면 |
| Subsurface | 빛이 스며드는 표면 | 피부, 왁스, 얇은 종이 |
| Clear Coat | 다층 코팅 | 자동차 페인트 |
| Cloth | 직물 | 옷, 카펫 |
| Eye | 눈 전용 | 눈동자 |

### 컴파일 흐름

```
머티리얼 그래프 편집 (에디터)
    ↓ (저장 시 자동 컴파일)
HLSL 셰이더 코드 생성
    ↓ (런타임)
GPU에서 Vertex/Pixel Shader 실행
    ↓
최종 픽셀 색상 결정
```

---

## 조명 & 그림자

### 라이트 종류

| 라이트 | 특징 | GPU 비용 |
|--------|------|---------|
| Directional Light | 태양, 무한 거리, 방향만 | 중간 |
| Point Light | 한 점에서 모든 방향 | 높음 |
| Spot Light | 원뿔형 | 높음 |
| Sky Light | 하늘 환경 조명 | 낮음 |
| Rect Light | 직사각형 라이트 | 매우 높음 |

### 그림자 기술

| 기술 | 품질 | 비용 |
|------|------|------|
| Shadow Maps | 보통 | 낮음 |
| Cascaded Shadow Maps (CSM) | 높음 | 중간 |
| Virtual Shadow Maps (VSM) | 높음 | 낮음 |
| Distance Field Shadows | 매우 높음 | 높음 |
| Ray Tracing Shadows | 최고 | 매우 높음 |

---

## 포스트 프로세싱

최종 이미지에 적용되는 화면 전체 효과

```
렌더링 완료 (HDR)
    ↓ PostProcessBloom (밝은 부분 번짐)
    ↓ PostProcessDOF (초점 심도)
    ↓ PostProcessEyeAdaptation (노출 자동 조정)
    ↓ PostProcessTonemap (HDR → LDR 변환)
    ↓ 최종 화면
```

**에디터에서 조정**: `APostProcessVolume` 액터를 레벨에 배치

---

## Lumen (실시간 글로벌 일루미네이션)

**빛이 반사되어 다른 표면을 비추는 효과를 실시간으로 계산**

```
소스: Runtime/Renderer/Private/Lumen/ (26개 C++ 파일)
셰이더: Shaders/Private/Lumen/ (30개+ 파일)
```

### 작동 원리

```
① 메시를 작은 "카드"로 분할
② 각 카드에 빛 정보 저장
③ 카드 간 광선 추적 (간접광 계산)
④ 자주 쓰이는 조명 캐시
⑤ 최종 간접광 합성
```

### 아티스트가 조정하는 값

| 설정 | 설명 |
|------|------|
| Enable Lumen GI | 활성화/비활성화 |
| Lumen Quality | 0.5~2.0 (품질 vs 성능) |
| Max Trace Distance | 최대 추적 거리 |
| Final Gather Samples | 간접광 샘플 수 |

---

## Nanite (가상화 지오메트리)

**수억 개의 폴리곤도 실시간으로 렌더링하는 기술**

```
소스: Runtime/Renderer/Private/Nanite/ (26개 C++ 파일)
셰이더: Shaders/Private/Nanite/ (26개 파일)
```

### 작동 원리

```
① 메시 임포트 시 자동으로 계층 구조 생성
② 카메라에서 멀면 낮은 디테일, 가까우면 높은 디테일
③ 필요한 삼각형만 선택해서 렌더링
④ GPU에서 직접 컬링 및 래스터화
```

### 주의사항

| 지원 ✅ | 미지원 ❌ |
|---------|---------|
| 불투명 메시 | 반투명 메시 |
| 스태틱 메시 | 디플레이스먼트 맵 |
| 복잡한 실내 환경 | 스켈레탈 메시 |

---

## 렌더링 패스 종류

```cpp
// MeshPassProcessor.h
EMeshPass:
  DepthPass           — 깊이 버퍼만 생성
  BasePass            — 기본 색상/노말/거칠기
  SkyPass             — 하늘 렌더링
  CSMShadowDepth      — 캐스케이드 그림자
  VSMShadowDepth      — 가상 그림자
  Distortion          — 화면 왜곡 (유리, 열)
  Velocity            — 모션 블러용 벡터
  Translucency        — 반투명 처리
```

---

## 성능 최적화 요약

| 문제 | 해결책 |
|------|--------|
| 폴리곤 과다 | Nanite 활성화 |
| 조명 무거움 | Lumen 품질 낮추기 |
| 그림자 무거움 | Virtual Shadow Maps 사용 |
| 포스트 무거움 | 불필요한 효과 비활성화 |
| 텍스처 메모리 | 해상도 낮추기 + Virtual Texturing |

---

## 파일 규모

| 영역 | 파일 수 |
|------|--------|
| Shaders/Private | 489개 |
| Renderer/Private | 500개+ |
| Lumen (C++) | 26개 |
| Nanite (C++) | 26개 |
| MaterialExpression 클래스 | 200개+ |

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [20_ray_tracing.md](20_ray_tracing.md) | HW 레이 트레이싱 / Path Tracing / Lumen vs RT 비교 |
| [24_material_advanced.md](24_material_advanced.md) | Material Instance, Material Layer, MPC — 머티리얼 심화 |
| [25_lighting_system.md](25_lighting_system.md) | 광원 5종, Sky Atmosphere, 라이트 채널 상세 |
| [14_textures_advanced.md](14_textures_advanced.md) | Virtual Texture, RVT, 텍스처 압축 — VRAM 최적화 |
| [39_volumetric_clouds.md](39_volumetric_clouds.md) | 볼류메트릭 구름 / 안개 / 빛줄기 — Sky 렌더링 |
| [42_staticmesh_advanced.md](42_staticmesh_advanced.md) | Nanite 활성화, LOD, Lightmap UV 설정 |
| [53_profiling_optimization.md](53_profiling_optimization.md) | GPU 병목 분석, 드로우콜 최적화, stat 명령어 |
| [23_water_volumes.md](23_water_volumes.md) | PostProcessVolume 설정, 블룸/DOF 등 포스트 이펙트 |
