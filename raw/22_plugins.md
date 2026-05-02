# 플러그인 시스템 — UE5 플러그인 구조와 주요 플러그인

> 소스 경로: Runtime/Projects/Public/Interfaces/IPluginManager.h
> 아티스트를 위한 설명

---

## 플러그인이란?

플러그인은 **언리얼 엔진의 기능을 확장하는 추가 모듈 패키지**입니다. 엔진 코어를 수정하지 않고도 새 기능(에디터 도구, 렌더링 기법, 게임플레이 시스템 등)을 켜고 끌 수 있습니다.

**비유:** 스마트폰 앱 — 기본 OS는 그대로이고 필요한 앱만 설치해서 기능을 추가하는 것과 동일합니다.

---

## 플러그인 활성화/비활성화 방법

1. 언리얼 에디터 상단 메뉴 → **Edit → Plugins**
2. 검색창에 플러그인 이름 입력
3. 체크박스로 활성화/비활성화
4. **에디터 재시작** 필요

플러그인 설정은 `[프로젝트폴더]/[프로젝트이름].uproject` 파일에 JSON으로 저장됩니다.

---

## .uplugin 파일 구조

플러그인 배포 시 포함되는 `.uplugin` 파일의 주요 필드:

```json
{
    "FileVersion": 3,
    "Version": 1,
    "VersionName": "1.0",
    "FriendlyName": "My Plugin",
    "Description": "플러그인 설명",
    "Category": "Rendering",
    "CreatedBy": "Studio Name",
    "Modules": [
        {
            "Name": "MyPlugin",
            "Type": "Runtime",
            "LoadingPhase": "Default"
        },
        {
            "Name": "MyPluginEditor",
            "Type": "Editor",
            "LoadingPhase": "PostEngineInit"
        }
    ],
    "Plugins": [
        {
            "Name": "DependencyPlugin",
            "Enabled": true
        }
    ]
}
```

---

## 모듈 타입 (Module Type)

| 타입 | 설명 | 포함 대상 |
|------|------|---------|
| `Runtime` | 게임 실행 중에도 동작 | 게임플레이 로직, 컴포넌트 |
| `Editor` | 에디터에서만 동작 | 에디터 도구, 커스텀 패널 |
| `Developer` | 개발·빌드 시에만 동작 | 빌드 도구, 코드 생성기 |
| `RuntimeNoCommandlet` | Runtime과 동일하나 Commandlet 제외 | - |
| `UncookedOnly` | 쿠킹 전 에디터 전용 | 소스 전용 에셋 처리 |

---

## 역할별 주요 플러그인 목록

### 렌더링 & 비주얼
| 플러그인 | 기능 |
|---------|------|
| `Lumen` | 동적 글로벌 일루미네이션 (기본 활성화) |
| `Nanite` | 마이크로폴리곤 가상화 메시 (기본 활성화) |
| `VirtualShadowMaps` | 고해상도 가상 그림자 맵 |
| `VirtualTextureSupport` | 가상 텍스처 스트리밍 |
| `Water` | WaterBody, 물 표면, 부력 시스템 |
| `Volumetrics` | 볼류메트릭 구름, 안개 |

### 헤어 & 그루밍
| 플러그인 | 기능 |
|---------|------|
| `HairStrands` | Groom/HairStrands 렌더링 시스템 |
| `Alembic Importer` | `.abc` Groom·캐시 임포트 |

### 애니메이션
| 플러그인 | 기능 |
|---------|------|
| `ControlRig` | 절차적 리깅 시스템 (기본 활성화) |
| `MotionWarping` | 동작 왜핑(애니메이션 위치 보정) |
| `IKRig` | IK Retargeting 시스템 |
| `FullBodyIK` | FBIK 솔버 |
| `PoseSearch` | 모션 매칭 시스템 |
| `AnimToTexture` | 애니메이션을 버텍스 텍스처로 베이크 |

### AI & 내비게이션
| 플러그인 | 기능 |
|---------|------|
| `NavigationSystem` | NavMesh 내비게이션 (기본 활성화) |
| `AIModule` | AI Controller, Behavior Tree (기본 활성화) |
| `MassEntity` | 대규모 군중 시뮬레이션 |
| `SmartObjects` | AI 상호작용 스마트 오브젝트 |
| `StateTree` | 계층형 상태 머신 |

### PCG & 환경
| 플러그인 | 기능 |
|---------|------|
| `PCG` | Procedural Content Generation 프레임워크 |
| `Landmass` | 랜드스케이프 레이어 절차 생성 |
| `Landscape` | 랜드스케이프 시스템 (기본 활성화) |
| `Foliage` | 폴리지 시스템 (기본 활성화) |

### 게임플레이
| 플러그인 | 기능 |
|---------|------|
| `GameplayAbilities` | GAS (Gameplay Ability System) |
| `EnhancedInput` | 고급 입력 매핑 시스템 |
| `GameplayTags` | 태그 기반 레이블링 시스템 (기본 활성화) |
| `Chaos` | 물리 파괴 시스템 (기본 활성화) |
| `ChaosVehicles` | 물리 기반 차량 시스템 |

### 물리 & 시뮬레이션
| 플러그인 | 기능 |
|---------|------|
| `ChaosCloth` | 물리 기반 헝겊 시뮬레이션 |
| `NiagaraFluids` | GPU 유체 시뮬레이션 |
| `PhysicsFieldPlugin` | 물리 필드 (폭발·바람 영향 영역) |

### 임포트 & 내보내기
| 플러그인 | 기능 |
|---------|------|
| `FBX Importer` | FBX 임포트 (기본 활성화) |
| `Alembic Importer` | Alembic(`.abc`) 임포트 |
| `USD Importer` | Pixar USD 포맷 임포트 |
| `glTF Importer` | glTF/GLB 임포트 |
| `DatasmithContent` | CAD, 건축 소프트웨어 임포트 |

### 온라인 & 멀티플레이어
| 플러그인 | 기능 |
|---------|------|
| `OnlineSubsystem` | 플랫폼 공통 온라인 추상 레이어 |
| `OnlineSubsystemSteam` | Steam 연동 |
| `OnlineSubsystemEOS` | Epic Online Services 연동 |

### 에디터 도구
| 플러그인 | 기능 |
|---------|------|
| `EditorScriptingUtilities` | 에디터 스크립팅 Blueprint 노드 모음 |
| `BlueprintHeaderView` | BP에서 C++ 헤더 프리뷰 |
| `AssetManagerEditor` | Asset Manager 시각화 |

---

## 역할별 권장 활성화 플러그인

### 환경 아티스트
- PCG
- Water
- Volumetrics
- HairStrands (식물·풀 라인 표현 시)
- Landmass

### 캐릭터 아티스트
- HairStrands
- ControlRig
- IKRig
- ChaosCloth
- Alembic Importer

### FX 아티스트
- Niagara (기본 활성화)
- NiagaraFluids
- PhysicsFieldPlugin
- Chaos

### 게임플레이 디자이너
- GameplayAbilities (GAS)
- EnhancedInput
- MassEntity (대규모 AI)
- StateTree

---

## 아티스트 체크리스트

### 플러그인 관리
- [ ] 필요 없는 플러그인은 비활성화했는가? (빌드 시간 및 메모리 절약)
- [ ] 플러그인 활성화 후 에디터를 재시작했는가?
- [ ] 팀원과 동일한 플러그인 세트를 유지하는가? (.uproject 파일 공유)

### 빌드 및 배포
- [ ] 패키징 전에 불필요한 `Editor` 전용 플러그인은 런타임에 포함되지 않는지 확인했는가?
- [ ] 타겟 플랫폼(콘솔, 모바일)에서 지원되지 않는 플러그인을 활성화하지 않았는가?
- [ ] 외부 마켓플레이스 플러그인의 UE5.7 호환성을 확인했는가?

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [08_editor_systems.md](08_editor_systems.md) | 에디터 모듈 — Editor 타입 플러그인과 에디터 확장 구조 |
| [21_blueprint_advanced.md](21_blueprint_advanced.md) | Blueprint Function Library — 플러그인으로 배포하는 패턴 |
| [11_pcg_procedural.md](11_pcg_procedural.md) | PCG 플러그인 — 활성화 및 의존 플러그인 설정 |
| [12_groom_hair.md](12_groom_hair.md) | HairStrands / Alembic Importer 플러그인 활성화 |
| [09_gameplay_ability_system.md](09_gameplay_ability_system.md) | GameplayAbilities 플러그인 — GAS 활성화 및 런타임 모듈 |
| [32_niagara_advanced.md](32_niagara_advanced.md) | Niagara / NiagaraFluids 플러그인 — VFX 시스템 확장 |
