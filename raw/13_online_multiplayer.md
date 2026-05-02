# 온라인 서브시스템 & 멀티플레이어

> 소스 경로: Engine/Plugins/Online/OnlineSubsystem/
> 아티스트를 위한 설명

---

## 온라인 서브시스템이란?

온라인 서브시스템(Online Subsystem, OSS)은 Steam, Epic Online Services(EOS), PlayStation Network, Xbox Live 등 **다양한 온라인 플랫폼을 하나의 공통 인터페이스로 연결해주는 중간 레이어**입니다.

**비유:** "전기 콘센트 멀티탭"과 같습니다. 게임 코드는 콘센트(공통 인터페이스)에 꽂기만 하면 되고, 뒤쪽 배선(Steam인지 EOS인지)은 신경 쓸 필요가 없습니다.

---

## 주요 인터페이스 목록

| 인터페이스 | 하는 일 | 아티스트 관련도 |
|-----------|--------|--------------|
| `IOnlineSession` | 게임 방 생성/검색/참가/종료 | 매우 높음 |
| `IOnlinePartySystem` | 로비/파티(그룹) 관리 | 높음 |
| `IOnlineFriends` | 친구 목록, 초대, 팔로우 | 높음 |
| `IOnlinePresence` | 친구 온라인 상태 표시 | 중간 |
| `IOnlineIdentity` | 로그인/로그아웃, 유저 ID | 높음 |
| `IOnlineAchievements` | 업적(도전과제) 관리 | 높음 |
| `IOnlineLeaderboards` | 리더보드(랭킹) | 높음 |
| `IOnlineExternalUI` | 플랫폼 기본 UI 열기 (Steam 오버레이 등) | 높음 |
| `IOnlineVoice` | 음성 채팅 | 중간 |
| `IOnlineChat` | 텍스트 채팅 | 중간 |
| `IOnlineStoreV2` | 인앱 구매 상점 목록 | 중간 |

---

## 게임 세션 생성/검색/참가 흐름

### 호스트(방장) 흐름
```
1. CreateSession()  → 세션 생성 요청 (비동기)
        ↓ OnCreateSessionComplete 발동
2. StartSession()   → 세션을 "게임 중" 상태로 전환
        ↓ 게임 플레이 중...
3. EndSession()     → 세션 종료 상태로 전환
4. DestroySession() → 세션 완전 삭제
```

### 클라이언트(참가자) 흐름
```
1. FindSessions()   → 서버 목록 검색 (비동기)
        ↓ OnFindSessionsComplete 발동 → 결과 목록 수신
2. JoinSession()    → 원하는 방에 참가 요청
        ↓ OnJoinSessionComplete 발동
           - Success: 접속 성공
           - SessionIsFull: 방이 꽉 참
           - SessionDoesNotExist: 방이 사라짐
           - AlreadyInSession: 이미 참가 중
```

### 친구 초대 흐름
```
친구가 초대 보냄
    ↓ OnSessionInviteReceived 발동
수락 클릭
    ↓ OnSessionUserInviteAccepted 발동
    → JoinSession() 자동 호출
```

---

## 멀티플레이 로비 구조

### Party 시스템
파티는 "게임 시작 전 대기 공간"입니다.

| 동작 | 설명 |
|------|------|
| `CreateParty()` | 파티 생성 |
| `JoinParty()` | 파티 참가 |
| `LeaveParty()` | 파티 나가기 |
| `KickMember()` | 멤버 강퇴 |
| `PromoteMember()` | 방장 위임 |
| `SendInvitation()` | 파티 초대장 발송 |

### 로비 UI 연결 구조
```
[로비 UI 위젯 (UMG)]
    ↓ Blueprint 이벤트 바인딩
[GameSession C++ 클래스]
    ↓ IOnlineSession / IOnlinePartySystem 호출
[플랫폼 백엔드 (Steam/EOS/Null)]
```

---

## Steam vs EOS 플러그인 차이

| 항목 | Steam | EOS (Epic Online Services) |
|------|-------|---------------------------|
| 플러그인 폴더 | `OnlineSubsystemSteam/` | `OnlineSubsystemEOS/` |
| 필요 계정 | Steam Steamworks 등록 | Epic 개발자 계정 |
| 크로스 플랫폼 | Steam 유저끼리만 | PC + Console + Mobile 크로스 가능 |
| 오버레이 UI | Steam 오버레이 자동 제공 | EOS 오버레이 별도 플러그인 |
| 로컬 테스트 | `OnlineSubsystemNull` | `OnlineServicesNull` |
| ini 설정 키 | `DefaultPlatformService=Steam` | `DefaultPlatformService=EOS` |

---

## 아티스트 관련 사항

### 로비 UI (UMG 위젯)
- 방 목록, 플레이어 슬롯, 준비 버튼, 팀 구성 등을 위젯으로 배치
- 실제 데이터(방 목록, 플레이어 이름)는 C++ 코드가 인터페이스에서 받아 위젯에 전달
- **아티스트가 직접 건드리는 것:** 레이아웃, 색상, 애니메이션, 아이콘

### 친구 목록 / 초대 UI
- 온라인 상태 아이콘 4종 준비:
  - Online (초록)
  - Away (노랑)
  - Offline (회색)
  - DoNotDisturb (빨강)

### 업적 UI
`FOnlineAchievementDesc`에서 제공하는 정보:
- `Title` — 업적 제목 (다국어 지원 FText)
- `LockedDesc` — 잠긴 상태 설명
- `UnlockedDesc` — 달성 후 설명
- `bIsHidden` — 숨김 업적 여부
- `UnlockTime` — 달성 일시

---

## 아티스트 체크리스트

### UI 제작 전
- [ ] 어떤 온라인 서브시스템을 사용하는지 확인 (Steam / EOS / Null)
- [ ] 로그인 화면이 필요한지, 자동 로그인인지 확인
- [ ] 로비 UI가 Session 기반인지 Party 기반인지 확인
- [ ] 지원 플랫폼 해상도/언어 확인

### 로비/매칭 화면
- [ ] 방 목록 스크롤 UI에 로딩 상태(빈 목록) 처리가 있는가?
- [ ] 방이 꽉 찼을 때(SessionIsFull) 오류 메시지 UI가 있는가?
- [ ] 매칭 취소 버튼 반응이 즉각적인가? (비동기 중 버튼 비활성화 필요)
- [ ] 방 인원 슬롯 UI가 최대 인원 수에 맞게 동적으로 변하는가?

### 친구/초대 UI
- [ ] 온라인 상태 아이콘 4가지 (Online/Away/Offline/DoNotDisturb) 준비됐는가?
- [ ] 초대 수락/거절 버튼에 자동 소멸 타이머가 있는가?

### 업적 UI
- [ ] 숨김 업적(`bIsHidden=true`)을 잠긴 상태에서 "???"로 표시하는가?
- [ ] 달성 퍼센트(0~100%) 프로그레스 바가 있는가?
- [ ] 업적 달성 시 화면 팝업 알림(Toast) 위치와 애니메이션이 준비됐는가?

### 로컬 테스트
- [ ] Steam/EOS 없이 테스트할 때 `DefaultPlatformService=Null` 설정 확인
- [ ] PIE에서 멀티 플레이어 테스트: Net Mode를 `Play As Listen Server`로 설정

---

## 관련 문서

| 문서 | 연관 이유 |
|------|---------|
| [01_gameplay_framework.md](01_gameplay_framework.md) | GameMode/GameState — 멀티플레이어 서버 권한 흐름 기반 |
| [06_ui_cinematics.md](06_ui_cinematics.md) | UMG — 로비·매칭·친구 UI 위젯 제작 |
| [09_gameplay_ability_system.md](09_gameplay_ability_system.md) | GAS — 서버 권한 Ability 실행 및 Attribute 복제 |
| [18_save_load.md](18_save_load.md) | Save/Load — 멀티플레이어 세션 정보 저장 및 복원 |
| [07_world_network_assets.md](07_world_network_assets.md) | 네트워크 3계층 구조 — Replicated/RPC 기초 개념 |
| [16_data_management.md](16_data_management.md) | DataTable — 매칭·업적 데이터 관리 |
