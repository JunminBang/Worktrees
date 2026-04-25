---
name: Nanite 셰이더 상세
type: System
tags: unreal-engine, nanite, geometry, culling, rasterizer, micropolygon, shader
source: engine-source
scene_verified: false
last_updated: 2026-04-25
---

# Nanite 셰이더 상세

> 소스 경로: `Engine/Shaders/Private/Nanite/` (48개 파일)  
> C++ 소스: `Runtime/Renderer/Private/Nanite/`  
> 공유 정의: `/Engine/Public/NaniteDefinitions.h`

---

## 아키텍처 개요

Nanite = GPU-Driven 마이크로폴리곤 래스터라이저 + 클러스터 DAG LOD

```
CPU: 드로우콜 1개
  → GPU: 클러스터 계층(DAG) 탐색
  → 화면 크기에 따라 LOD 클러스터 선택
  → 소프트웨어 래스터라이저(작은 트라이앵글)
    또는 하드웨어 래스터라이저(큰 트라이앵글)
  → Visibility Buffer(uint64) 기록
  → Shading (머티리얼 분류 후 Compute)
```

---

## 1. 컬링 시스템

| 파일 | 역할 |
|------|------|
| `NaniteCullingCommon.ush` | 컬링 공통 함수, `CULLING_PASS` 매크로 |
| `NaniteClusterCulling.usf` | 클러스터 단위 Frustum/Occlusion 컬링 |
| `NaniteCulling.ush` | 컬링 유틸리티 |
| `NaniteHZBCull.ush` | Hierarchical Z-Buffer 오클루전 |
| `NaniteHierarchyTraversal.ush` | 클러스터 DAG 탐색 |
| `NaniteHierarchyTraversalCommon.ush` | DAG 탐색 공통 |
| `NaniteInstanceCulling.usf` | 인스턴스 레벨 컬링 |
| `NaniteInstanceHierarchyCulling.usf` | 인스턴스 계층 컬링 |
| `NanitePrimitiveFilter.usf` | 프리미티브 필터링 |

**컬링 패스 종류**:
```
CULLING_PASS_NO_OCCLUSION  — 첫 번째 패스 (오클루전 무시)
CULLING_PASS_OCCLUSION_MAIN  — 메인 오클루전 쿼리
CULLING_PASS_OCCLUSION_POST  — 후처리 오클루전
```

---

## 2. 래스터라이저

| 파일 | 역할 |
|------|------|
| `NaniteRasterizer.usf` | 소프트웨어 래스터라이저 메인 |
| `NaniteRasterizer.ush` | 래스터화 공통 함수 |
| `NaniteRasterizationCommon.ush` | 픽셀 쓰기 공통 — VSM 연동 포함 |
| `NaniteRasterBinning.usf` | 트라이앵글 → 래스터 빈 분류 |
| `NaniteRasterClear.usf` | 래스터 버퍼 초기화 |
| `NaniteSplit.usf` | 대형 트라이앵글 분할 |
| `NaniteDice.ush` | 테셀레이션 보조 |

---

## 3. 데이터 구조 & 스트리밍

| 파일 | 역할 |
|------|------|
| `NaniteAttributeDecode.ush` | 압축 버텍스 어트리뷰트 디코딩 |
| `NaniteDataDecode.ush` | 클러스터 데이터 디코딩 |
| `NaniteStreaming.usf` | 클러스터 스트리밍 업데이트 |
| `NaniteStreaming.ush` | 스트리밍 공통 |
| `NaniteScatterUpdates.usf` | 스캐터 방식 데이터 업데이트 |
| `NaniteStreamOut.usf` | 스트림 아웃 |
| `NaniteSceneCommon.ush` | 씬 데이터 접근 |
| `NanitePackedNaniteView.ush` | 뷰 데이터 패킹 |
| `NaniteImposter.ush` | 원거리 Imposter LOD |

---

## 4. 셰이딩

| 파일 | 역할 |
|------|------|
| `NaniteShadeBinning.usf` | 머티리얼별 셰이딩 빈 분류 |
| `NaniteShadeCommon.ush` | 셰이딩 공통 |
| `NaniteShadeDebug.usf` | 셰이딩 디버그 뷰 |
| `NaniteExportGBuffer.usf` | Visibility Buffer → GBuffer 변환 |
| `NaniteDepthDecode.usf` | 깊이 버퍼 디코딩 |
| `NaniteDepthExport.usf` | 깊이 버퍼 익스포트 |
| `NaniteFastClear.usf` | 버퍼 빠른 초기화 |

---

## 5. 레이 트레이싱 연동

| 파일 | 역할 |
|------|------|
| `NaniteRayTrace.ush` | Nanite + HW RT 연동 공통 |
| `NaniteRayTracing.usf` | HW RT 히트 셰이더 |
| `NaniteSVO.ush` | Sparse Voxel Octree 보조 |

---

## 6. 디버그 & 유틸

| 파일 | 역할 |
|------|------|
| `NaniteDebugViews.usf` | VisualizeNanite 뷰포트 오버레이 |
| `NaniteEditorCommon.ush` | 에디터 전용 공통 |
| `NanitePrintStats.usf` | 클러스터/폴리곤 통계 출력 |
| `NaniteEmitShadow.usf` | 그림자 패스 방출 |
| `NaniteSkinningUpdateViewData.usf` | 스키닝 뷰 데이터 업데이트 |

---

## Nanite 지원/미지원 정리

| 지원 ✅ | 미지원 ❌ |
|---------|---------|
| 불투명 스태틱 메시 | 반투명 머티리얼 |
| 복잡한 고폴리 메시 | 스켈레탈 메시 (기본) |
| 인스턴싱 | Displacement Map |
| VSM 연동 | World Position Offset (제한적) |
| HW RT 연동 | Masked 머티리얼 (제한적) |

> **주의**: 반투명/마스크 머티리얼 → Nanite 자동 비활성화. 투명 오브젝트는 Nanite 미사용 패스로 폴백.

---

## Virtual Shadow Maps 연동

`NaniteRasterizationCommon.ush`는 VSM 페이지 접근을 직접 포함:
```
#include "../VirtualShadowMaps/VirtualShadowMapPageOverlap.ush"
#include "../VirtualShadowMaps/VirtualShadowMapPageAccessCommon.ush"
```
→ Nanite 클러스터가 VSM 페이지에 직접 그림자를 기록

---

## 관련 페이지
- [셰이더 전체 개요](overview.md)
- [Virtual Shadow Maps & 조명 셰이더](shadow_lighting.md)
- [UE5 렌더링 & 셰이더 시스템](../systems/ue5_rendering_shader.md)
- [LOD & Neural Geometry 논문](../papers/lod_and_geometry.md)
- [UE5 실시간 렌더링 기술 지도](../query_ue5_rendering_map.md)
