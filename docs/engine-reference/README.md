# 엔진 레퍼런스 문서

이 디렉토리에는 프로젝트에서 사용하는 게임 엔진의 버전 고정 문서 스냅샷이 들어 있다.
**LLM의 학습 데이터에는 컷오프 날짜가 있고** 게임 엔진은 자주 업데이트되기 때문에 이 파일들이 필요하다.

## 존재 이유

Claude의 학습 데이터 컷오프(현재 2025년 5월) 이후에도 Unreal 같은 게임 엔진은
브레이킹 API 변경, 신규 기능, 지원 중단 패턴을 포함한 업데이트를 계속 출시한다.
이 레퍼런스 파일 없이는 에이전트가 구식 코드를 제안하게 된다.

## 구조

각 엔진은 자체 디렉토리를 가진다:

```
<engine>/
├── VERSION.md                 # 고정 버전, 검증 날짜, 학습 공백 기간
├── breaking-changes.md        # 버전 간 API 변경 사항 (위험 수준별 정리)
├── deprecated-apis.md         # "X 대신 Y 사용" 대조표
├── current-best-practices.md  # 모델 학습 데이터에 없는 최신 관행
└── modules/                   # 서브시스템별 빠른 레퍼런스 (최대 ~150줄)
    ├── rendering.md
    ├── physics.md
    └── ...
```

## 사용 방법

엔진 API 관련 작업 시:

1. `VERSION.md`를 읽어 현재 엔진 버전 확인
2. 엔진 API 제안 전 `deprecated-apis.md` 확인
3. 버전별 이슈는 `breaking-changes.md` 참조
4. 서브시스템 작업 시 관련 `modules/*.md` 읽기

## 유지 관리

### 갱신 시점

- 엔진 버전 업그레이드 후
- LLM 모델 업데이트 시 (새 학습 컷오프)
- 모델이 틀리게 알고 있는 API 발견 시

### 갱신 방법

1. `VERSION.md`에 새 엔진 버전과 날짜 업데이트
2. `breaking-changes.md`에 버전 전환 항목 추가
3. 새로 지원 중단된 API를 `deprecated-apis.md`로 이동
4. `current-best-practices.md`에 새 패턴 추가
5. 관련 `modules/*.md`에 API 변경 사항 반영
6. 수정된 모든 파일에 "Last verified" 날짜 설정

### 품질 규칙

- 모든 파일에 "Last verified: YYYY-MM-DD" 날짜 필수
- 모듈 파일은 150줄 이하 유지 (컨텍스트 예산)
- 올바른/잘못된 패턴을 보여주는 코드 예시 포함
- 검증을 위한 공식 문서 URL 링크
- 모델의 학습 데이터와 다른 내용만 문서화
