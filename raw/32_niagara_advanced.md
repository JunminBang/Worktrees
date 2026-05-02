# Niagara 고급 — GPU 시뮬레이션, Data Interface, Ribbon/Beam/Mesh

> 소스 경로: Engine/Plugins/FX/Niagara/Source/Niagara/Public/
> 아티스트를 위한 설명

---

## Niagara 시스템 계층 구조

```
NiagaraSystem (시스템)
  └─ NiagaraEmitter (이미터 1, 2, 3...)
        └─ 파티클 (Particle 1, 2, 3...)
              └─ Module (스폰/업데이트/이벤트 로직)
```

| 레벨 | 역할 |
|------|------|
| **System** | 여러 Emitter를 하나로 묶는 최상위 컨테이너 |
| **Emitter** | 파티클 풀 하나. CPU 또는 GPU 선택 |
| **Particle** | 개별 파티클 인스턴스 |
| **Module** | 파티클에 적용되는 개별 기능 블록 |

---

## CPU vs GPU 시뮬레이션

| 항목 | CPU 시뮬레이션 | GPU 시뮬레이션 |
|------|--------------|--------------|
| 파티클 수 | 수백~수천 | 수만~수십만 |
| 충돌 | 씬 콜리전 정확 사용 가능 | 깊이 버퍼 기반 근사 |
| Data Interface | 모두 지원 | 일부만 지원 |
| Blueprint 이벤트 | 사용 가능 | 제한적 |
| 성능 | CPU 부하 | GPU 부하 (병렬 처리) |
| 추천 시기 | 적은 수의 복잡한 파티클 | 대량의 단순한 파티클 |

**GPU 활성화:** Emitter 설정 → `Sim Target` → `GPU Compute Sim`

---

## Data Interface — 외부 데이터 연결

Data Interface는 **파티클 시스템이 외부 데이터(메시, 텍스처, 오디오 등)를 읽는 연결 고리**입니다.

### Skeletal Mesh DI

스켈레탈 메시 표면이나 뼈대에서 파티클을 스폰합니다:

| 기능 | 설명 |
|------|------|
| 표면 위 스폰 | 피부/옷에서 불꽃, 연기 파티클 방출 |
| 소켓 위치 | 특정 본/소켓에서 파티클 생성 |
| 버텍스 컬러 | 버텍스 컬러를 마스크로 사용 |

**사용 예시:** 불타는 캐릭터 — 피부 표면 전체에서 불꽃 파티클 방출

### Static Mesh DI

정적 메시 표면에서 파티클 스폰:
- 면 위에서 랜덤 스폰 (잎 흩날림, 먼지 방출)
- 버텍스 위치 샘플링

### Texture Sample DI

텍스처에서 색상이나 데이터를 읽어 파티클에 적용:
- 텍스처 색상 → 파티클 색상 매핑
- 노이즈 텍스처 → 파티클 이동 패턴 제어

### Collision DI

씬 콜리전과 파티클이 상호작용:
- 파티클이 바닥·벽에 튕기거나 붙음
- `GPU Collision Depth Buffer`: 깊이 버퍼 기반 GPU 콜리전 (저비용)
- `Scene Depth`: 화면에 보이는 표면에만 콜리전

### Audio DI

오디오 스펙트럼 데이터로 파티클 제어:
- 음악 비트에 맞춰 파티클 폭발
- 주파수별 진폭 → 파티클 크기/색상

---

## Niagara Event — 파티클 간 통신

Event는 **파티클이 다른 파티클 또는 외부 시스템에 신호를 보내는 메커니즘**입니다.

| 이벤트 타입 | 설명 |
|-----------|------|
| `Collision Event` | 파티클이 충돌할 때 이벤트 발생 |
| `Death Event` | 파티클이 수명을 다할 때 이벤트 발생 |
| `Location Event` | 파티클 위치를 다른 이미터로 전달 |

**예시:** 불꽃 파티클이 바닥에 닿으면 → 충돌 이벤트 발생 → 연기 이미터가 해당 위치에서 연기 스폰

---

## Blueprint에서 Niagara 파라미터 변경

### 컴포넌트 파라미터 변경

```
[폭발 색상 변경]
→ Get Niagara Component
→ Set Variable Color
    In Variable Name: "User.ExplosionColor"
    In Value: 빨간색

[강도 조절]
→ Set Variable Float
    In Variable Name: "User.Intensity"
    In Value: 2.5
```

### 파라미터 이름 규칙

| 네임스페이스 | 설명 |
|------------|------|
| `User.` | 외부에서 주입하는 사용자 정의 파라미터 |
| `System.` | 시스템 레벨 내장 변수 |
| `Emitter.` | 이미터 레벨 내장 변수 |
| `Particles.` | 파티클 레벨 내장 변수 |

---

## Ribbon 파티클 — 꼬리/선 표현

Ribbon은 **연속된 파티클을 선으로 연결**해 꼬리, 궤적, 번개 등을 표현합니다.

| 설정 | 설명 |
|------|------|
| `Ribbon Width` | 리본 너비 |
| `Ribbon Width Mode` | Fixed/FromCurve/FromParticleAttribute |
| `UV Scale` | 텍스처 UV 반복 배율 |
| `Tessellation` | 곡선 부드럽게 처리 (세그먼트 수) |

**사용 예시:** 칼 궤적, 마법 지팡이 trail, 연기 꼬리, 바람에 날리는 천

---

## Beam 이미터 — 두 점 사이 빔

두 지점(Source → Target)을 연결하는 에너지 빔:

| 설정 | 설명 |
|------|------|
| `Beam Source` | 빔 시작점 (소켓, 위치) |
| `Beam End` | 빔 끝점 |
| `Tangent` | 빔 곡선 방향 제어 |
| `Segments` | 빔 분할 수 |

**사용 예시:** 번개, 레이저, 전기 방전, 에너지 연결선

---

## Mesh 파티클 — Static Mesh를 파티클로

Static Mesh를 파티클로 사용해 오브젝트 파편, 잎사귀, 잔해 등을 표현합니다:

1. Emitter → Render 섹션 → `Add Render` → `Mesh Renderer`
2. `Meshes` 배열에 Static Mesh 에셋 추가
3. `Override Materials`로 파티클 색상/머티리얼 제어

---

## 성능 최적화

| 팁 | 설명 |
|----|------|
| `Max Count` 설정 | Emitter별 최대 파티클 수 제한 |
| `Fixed Bounds` | 동적 바운드 계산 비용 제거 (수동으로 크기 지정) |
| `Cull Distance` | 멀리서 Emitter 자동 비활성화 |
| `Warm Up` | 시작 시 n초치 시뮬레이션 미리 실행 |
| `Sleep Threshold` | 파티클 없을 때 자동 슬립 |
| GPU 우선 사용 | 대량 파티클은 GPU Sim 필수 |
| LOD | 거리별 파티클 수·품질 감소 설정 |

---

## 아티스트 체크리스트

### 이미터 설정
- [ ] CPU/GPU 중 파티클 수에 맞는 방식을 선택했는가?
- [ ] `Max Count`로 최대 파티클 수를 제한했는가?
- [ ] `Fixed Bounds`를 설정해 런타임 바운드 계산을 피했는가?

### Data Interface 사용 시
- [ ] Skeletal Mesh DI에 올바른 메시 컴포넌트가 연결되어 있는가?
- [ ] GPU 시뮬레이션에서 지원하지 않는 DI를 사용하지 않았는가?
- [ ] Texture Sample DI의 텍스처 포맷이 읽기 가능한가?

### Blueprint 연동
- [ ] User 파라미터 이름이 `User.` 접두사를 포함하는가?
- [ ] Set Variable 노드의 이름이 Niagara 내부 파라미터 이름과 정확히 일치하는가?

### 성능
- [ ] Cull Distance가 씬 규모에 맞게 설정되어 있는가?
- [ ] 화면에 동시 재생되는 Niagara System 수가 예산 안에 있는가?
- [ ] Ribbon/Beam에 Tessellation이 불필요하게 높지 않은가?

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [04_audio_effects.md](04_audio_effects.md) | 파티클 + 사운드 조합 — 충격 이펙트 세트 구성 |
| [47_socket_system.md](47_socket_system.md) | 소켓 — 무기/캐릭터 소켓에서 Niagara 시스템 스폰 |
| [19_decals.md](19_decals.md) | 파티클 + 데칼 조합 — 총탄 충격 이펙트 세트 구성 |
| [50_physical_material.md](50_physical_material.md) | Surface Type — 표면별 파티클 이펙트 분기 (콘크리트/금속/나무) |
| [10_chaos_destruction.md](10_chaos_destruction.md) | 파괴 이벤트 — 파편 발생 시 Niagara 먼지/불꽃 이펙트 연동 |
| [53_profiling_optimization.md](53_profiling_optimization.md) | GPU 파티클 비용 측정 — Niagara Debugger & GPU 프로파일링 |
