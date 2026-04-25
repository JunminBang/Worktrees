# 레이 트레이싱 & 렌더링 고급 기능

> 소스 경로: Runtime/Renderer/Private/RayTracing/, Runtime/Engine/Classes/Engine/RendererSettings.h
> 아티스트를 위한 설명

---

## 레이 트레이싱이란?

레이 트레이싱(Ray Tracing)은 빛이 실제로 반사·굴절·산란하는 방식을 물리적으로 시뮬레이션하는 렌더링 기법입니다. 게임 엔진의 기본 래스터라이제이션 방식보다 훨씬 사실적이지만, GPU 성능 요구가 높습니다.

**UE5에서 레이 트레이싱 활성화:**
- `Project Settings > Rendering > Ray Tracing` 체크
- DirectX 12 모드 필요 (Windows)
- RTX 2060 이상 GPU 권장

---

## 레이 트레이싱 기능 목록

| 기능 | 설명 | 성능 비용 |
|------|------|---------|
| **RT Shadows** | 소프트 섀도우, 영역광 정확한 그림자 | 중간 |
| **RT Reflections** | 거울/금속 표면의 정확한 반사 | 높음 |
| **RT Ambient Occlusion** | 구석·틈새의 정확한 접촉 그림자 | 낮음-중간 |
| **RT Global Illumination** | 간접광의 실시간 시뮬레이션 | 매우 높음 |
| **RT Translucency** | 유리·물·반투명 표면 정확한 투과 | 높음 |
| **Path Tracing** | 영화급 완전 물리 기반 렌더링 | 극도로 높음 (실시간 불가) |

---

## Lumen vs 하드웨어 레이 트레이싱

| 항목 | Lumen (소프트웨어) | 하드웨어 RT |
|------|-----------------|-----------|
| GPU 요구 | 낮음 (모든 GPU) | RTX 2060 이상 |
| 정확도 | 근사치 (매우 자연스러움) | 물리적으로 정확 |
| 반사 디테일 | 보통 | 매우 정밀 |
| 성능 비용 | 낮음~중간 | 중간~매우 높음 |
| 추천 용도 | 게임 (기본값) | 시네마틱, 건축 시각화 |
| 설정 위치 | Project Settings > Lumen | Project Settings > Ray Tracing |

> **아티스트 가이드:** 일반 게임 프로젝트에서는 Lumen이 기본값이자 권장 선택입니다. 하드웨어 RT는 시네마틱 렌더링이나 최고급 PC 타겟 시에만 활성화하세요.

---

## TSR — Temporal Super Resolution

TSR(Temporal Super Resolution)은 UE5의 내장 업스케일링 기술입니다.

| 항목 | 설명 |
|------|------|
| **개념** | 낮은 해상도로 렌더링 후 AI 기반으로 고해상도로 업스케일 |
| **장점** | 성능을 유지하면서 화질 향상 가능 |
| **설정** | `Project Settings > Rendering > Anti-Aliasing Method > TSR` |
| **Screen Percentage** | 50~100% 범위 조정 (낮을수록 빠름, 높을수록 선명) |
| **비교 대상** | NVIDIA DLSS, AMD FSR과 유사 개념 |

---

## 액터별 RT 설정

각 메시 액터의 디테일 패널에서 레이 트레이싱 동작을 개별 제어할 수 있습니다:

| 프로퍼티 | 설명 |
|---------|------|
| `Visible in Ray Tracing` | 이 액터가 RT에서 보이는지 여부 |
| `Cast Ray Traced Shadow` | RT 그림자 캐스팅 여부 |
| `Affects Dynamic Indirect Lighting` | Lumen/RT GI에 영향을 미치는지 |
| `Ray Tracing Group Id` | 같은 ID끼리 투명도 처리 최적화 |

---

## PostProcessVolume 레이 트레이싱 파라미터

PostProcessVolume에서 레이 트레이싱 품질을 세밀하게 제어할 수 있습니다:

| 카테고리 | 주요 파라미터 | 설명 |
|---------|------------|------|
| **RT Reflections** | `Max Roughness` | 어느 거칠기까지 RT 반사 적용 (높을수록 비용 증가) |
| **RT Reflections** | `Max Bounces` | 반사 반복 횟수 (1~8, 기본 1) |
| **RT Shadows** | `Shadow Samples Per Pixel` | 부드러운 그림자 샘플 수 |
| **RT AO** | `Samples Per Pixel` | AO 샘플 수 |
| **RT GI** | `Samples Per Pixel` | GI 샘플 수 |
| **Path Tracing** | `Max Bounces` | 경로 추적 반사 횟수 |
| **Path Tracing** | `Samples Per Pixel` | 노이즈 감소를 위한 샘플 수 (높을수록 느림) |

---

## 성능 트레이드오프

| 사용 시나리오 | 권장 설정 |
|-------------|---------|
| **고사양 게임 (AAA)** | Lumen + TSR + RT Shadows만 선택적 활성화 |
| **중간 사양 게임** | Lumen만, RT 비활성화 |
| **시네마틱 시퀀서** | Path Tracing + Movie Render Queue |
| **건축 시각화** | HW RT Reflections + RT GI |
| **콘솔 (PS5/XSX)** | 콘솔 전용 RT 파이프라인 (하드웨어 내장) |

---

## Path Tracing 사용 방법

Path Tracing은 실시간이 아닌 **오프라인 렌더링**에 사용합니다:

1. `Project Settings > Rendering > Path Tracing` 활성화
2. PostProcessVolume에서 Rendering Features → Path Tracing 선택
3. **Movie Render Queue**에서 Path Tracing 패스 선택
4. `Samples Per Pixel` 높게 설정 (512~2048)
5. 렌더링 — 프레임당 수십 초~수 분 소요 가능

---

## 아티스트 체크리스트

### 레이 트레이싱 활성화 시
- [ ] DirectX 12가 활성화되어 있는가? (`Project Settings > Platforms > Windows`)
- [ ] GPU가 RTX 2060 이상인가?
- [ ] 프로젝트 타겟 플랫폼이 RT를 지원하는가?

### 씬 최적화
- [ ] 원거리 오브젝트에 `Visible in Ray Tracing` OFF 처리를 고려했는가?
- [ ] 불필요한 오브젝트에 `Cast Ray Traced Shadow` OFF 설정을 했는가?
- [ ] PostProcessVolume에서 `Max Roughness`를 0.6 이하로 제한해 반사 비용을 줄였는가?
- [ ] TSR이 활성화되어 있는가? (성능 대비 품질 최적화)

### 반사 표현
- [ ] 높은 반사율의 머티리얼(금속, 거울)에는 `Max Roughness` 조정이 필요한가?
- [ ] 유리/물 표면에 `RT Translucency`가 필요한지 검토했는가?

### 시네마틱 렌더링
- [ ] Movie Render Queue를 사용하는가?
- [ ] Path Tracing 사용 시 `Samples Per Pixel`을 512 이상 설정했는가?
- [ ] Path Tracing과 일반 게임플레이 렌더링이 분리된 레벨/카메라 셋업인가?
