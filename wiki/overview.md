# 레벨 개요

**마지막 스캔:** 2026-04-09  
**총 액터 수:** 51개

---

## 씬 구성 요약

이 레벨은 **테스트/트레이닝 맵**으로 보임. 중앙 플로어를 중심으로 사방에 장애물(Cube, Ramp, Cylinder)이 배치된 아레나 구조.

### 레이아웃

```
         N (+Y)
         |
  Cylinder5/4   (10, 1900)
         |
W --  Cylinder6/7  --  Cylinder8/9  -- E
(-1900,-10)           (1900,-10)
         |
  Cylinder2/3   (10, -1900)
         |
         S (-Y)
```

- **중앙**: Floor (스케일 4x4x1), PlayerStart @ Z=302
- **4방향 경계**: Cylinder 쌍이 각 방향 끝에 배치
- **코너**: QuarterCylinder (1500,1500), (-1500,1500), (1500,-1500), (-1500,-1500)
- **외벽**: 스케일 Y=40인 Cube들 (SM_Cube3 등) — 긴 벽면으로 추정
- **고지대**: SM_Cube17/18/19/20 — Z=200 위치의 플랫폼들

---

## 액터 목록

### StaticMesh — Cube (20개)
| 이름 | 위치 | 스케일 | 비고 |
|------|------|--------|------|
| Floor | (0,0,0) | (4,4,1) | 메인 바닥 |
| SM_Cube | (1200,1500,0) | - | |
| SM_Cube2 | (1800,-2000,0) | - | |
| SM_Cube3 | (-2000,-2000,0) | (2,40,2) | 긴 벽면 |
| SM_Cube4 | (-1800,-1800,0) | - | |
| SM_Cube5 | (-1800,2000,0) | - | |
| SM_Cube6 | (1500,1200,0) | - | |
| SM_Cube7 | (1200,-1500,0) | - | |
| SM_Cube8 | (1500,-1200,0) | (6,3,2) | Y=-90° 회전 |
| SM_Cube9 | (-1500,-1200,0) | - | |
| SM_Cube10 | (-1200,-1500,0) | - | |
| SM_Cube11 | (-1200,1500,0) | - | |
| SM_Cube12 | (-1500,1200,0) | - | |
| SM_Cube17 | (1900,-2000,200) | - | 고지대 |
| SM_Cube18 | (-1900,-1900,200) | - | 고지대 |
| SM_Cube19 | (-1900,2000,200) | - | 고지대 |
| SM_Cube20 | (-2000,-2000,200) | (1,40,2) | 고지대 벽 |

### StaticMesh — Cylinder (9개)
| 이름 | 위치 | 비고 |
|------|------|------|
| SM_Cylinder2 | (10,-1900,0) | **⚠ SM_Cylinder3과 겹침** |
| SM_Cylinder3 | (10,-1900,0) | **⚠ SM_Cylinder2와 겹침** |
| SM_Cylinder4 | (10,1900,0) | **⚠ SM_Cylinder5와 겹침** |
| SM_Cylinder5 | (10,1900,0) | **⚠ SM_Cylinder4와 겹침** |
| SM_Cylinder6 | (-1900,-10,0) | **⚠ SM_Cylinder7과 겹침** |
| SM_Cylinder7 | (-1900,-10,0) | **⚠ SM_Cylinder6과 겹침** |
| SM_Cylinder8 | (1900,-10,0) | **⚠ SM_Cylinder9와 겹침** |
| SM_Cylinder9 | (1900,-10,0) | **⚠ SM_Cylinder8과 겹침** |

### StaticMesh — Ramp (8개)
SM_Ramp ~ SM_Ramp8 — 코너/경계 근처에 분산 배치

### StaticMesh — QuarterCylinder (6개)
SM_QuarterCylinder ~ SM_QuarterCylinder12 — 코너 장식/구조물

### 환경
| 이름 | 위치 |
|------|------|
| DirectionalLight | (0,0,920) |
| SkyLight | (0,0,690) |
| VolumetricCloud | (0,0,820) |
| SkyAtmosphere | (0,0,1020) |
| ExponentialHeightFog | (-5600,-50,-6850) |
| PostProcessVolume | (100,100,500) |

---

## 이슈 요약

- **⚠ BUG-001**: Cylinder 쌍 4곳 동일 위치 겹침 (SM_Cylinder2/3, 4/5, 6/7, 8/9)
- PlayerStart가 Z=302에 있음 — 바닥(Z=0)에서 302 유닛 위. 의도적 배치인지 확인 필요.
- ExponentialHeightFog가 Z=-6850에 있음 — 정상 범위 외, 의도적 배치일 수 있음.

---

## 관련 페이지
- [index](index.md)
- [StaticMesh 시스템](systems/static_mesh.md)
- [라이팅 & PostProcess](systems/lighting.md)
- [렌더링 파이프라인 & 기법](systems/rendering.md)
- [UE5 전체 개요](systems/ue5_overview.md)
