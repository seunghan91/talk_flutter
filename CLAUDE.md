# Claude Guidelines for Talk Flutter App

## 프로젝트 개요
- **프로젝트명**: Talkk Flutter (talk_flutter)
- **목적**: React Native Talk 앱을 Flutter로 재개발
- **아키텍처**: ainote Flutter 프로젝트의 Clean Architecture + BLoC 패턴 적용
- **API 서버**: https://talkk-api.onrender.com/api/v1 (Rails 7.1)

## 기술 스택

### State Management
- **flutter_bloc** ^9.0.0 - BLoC 패턴 구현
- **hydrated_bloc** ^10.1.1 - 상태 영속화
- **equatable** ^2.0.5 - 값 비교

### Networking
- **dio** ^5.9.0 - HTTP 클라이언트
- **retrofit** 4.7.2 - 타입 안전 API 클라이언트

### Database
- **drift** ^2.29.0 - SQLite ORM
- **flutter_secure_storage** ^9.0.0 - 보안 저장소

### Navigation
- **go_router** ^16.0.0 - 타입 안전 라우팅

### Code Generation
- **freezed** ^3.0.0 - 불변 데이터 클래스
- **json_serializable** ^6.8.0 - JSON 직렬화

## 프로젝트 구조

```
lib/
├── core/                    # 핵심 유틸리티
│   ├── config/             # 환경 설정
│   ├── constants/          # 상수 정의
│   ├── enums/              # 열거형
│   ├── errors/             # 에러 처리
│   ├── extensions/         # 확장 메서드
│   ├── services/           # 핵심 서비스
│   ├── theme/              # 테마 설정
│   └── utils/              # 유틸리티
│
├── data/                   # 데이터 레이어
│   ├── database/           # Drift 데이터베이스
│   ├── datasources/        # 데이터 소스
│   │   ├── remote/         # API 클라이언트
│   │   └── local/          # 로컬 저장소
│   ├── models/             # DTO 모델
│   ├── repositories/       # Repository 구현
│   └── services/           # 비즈니스 로직 서비스
│
├── domain/                 # 도메인 레이어
│   ├── entities/           # 비즈니스 엔티티
│   ├── enums/              # 도메인 열거형
│   └── repositories/       # Repository 인터페이스
│
├── presentation/           # 프레젠테이션 레이어
│   ├── blocs/              # BLoC/Cubit
│   │   ├── auth/           # 인증 BLoC
│   │   ├── broadcast/      # 방송 BLoC
│   │   ├── conversation/   # 대화 BLoC
│   │   ├── message/        # 메시지 BLoC
│   │   └── user/           # 사용자 BLoC
│   ├── router/             # GoRouter 설정
│   ├── screens/            # 화면
│   └── widgets/            # 재사용 위젯
│
└── main.dart               # 앱 진입점
```

## 주요 기능

### 1. 음성 브로드캐스팅
- 음성 메시지 녹음 및 다수에게 전송
- 6일 자동 만료
- 지능형 수신자 선택 알고리즘

### 2. 1:1 음성 메시징
- 브로드캐스트 답장으로 대화 시작
- 음성 메시지 기반 커뮤니케이션

### 3. 사용자 인증
- 전화번호 SMS 인증
- JWT 토큰 기반 인증

### 4. 푸시 알림
- Firebase Cloud Messaging 연동

## Build Commands

```bash
# 의존성 설치
flutter pub get

# 코드 생성 (freezed, retrofit, drift)
dart run build_runner build --delete-conflicting-outputs

# 앱 실행
flutter run

# iOS 빌드
flutter build ios

# Android 빌드
flutter build apk

# 테스트
flutter test
```

## API Contract

### 인증 API
- `POST /auth/phone-verifications` - SMS 코드 요청
- `POST /auth/phone-verifications/verify` - 코드 확인
- `POST /auth/sessions` - 로그인
- `POST /auth/registrations` - 회원가입

### 방송 API
- `GET /broadcasts` - 방송 목록
- `POST /broadcasts` - 방송 생성 (multipart)
- `POST /broadcasts/:id/reply` - 방송 답장

### 대화 API
- `GET /conversations` - 대화 목록
- `POST /conversations/:id/send_message` - 메시지 전송

### 사용자 API
- `GET /users/me` - 내 정보
- `PATCH /users/me` - 프로필 수정

## 테스트 계정

| 이름 | 전화번호 | 비밀번호 |
|-----|---------|---------|
| 김채현 | 01011111111 | password |
| 이지원 | 01022222222 | password |
| 박지민 | 01033333333 | password |

## Code Style

### BLoC 패턴
- Event: 불변 객체, Equatable 상속
- State: copyWith 패턴, Equatable 상속
- BLoC: 이벤트 핸들러 메서드 분리

### Repository 패턴
- 인터페이스는 domain 레이어에 정의
- 구현체는 data 레이어에 위치
- 의존성 역전 원칙 적용

### 에러 처리
- Failure 클래스로 도메인 에러 표현
- ApiException으로 API 에러 래핑
- 사용자 친화적 메시지 변환

## 개발 체크리스트

- [ ] Auth BLoC 완성 (로그인/회원가입/로그아웃)
- [ ] Broadcast BLoC 구현
- [ ] Conversation BLoC 구현
- [ ] 음성 녹음/재생 위젯
- [ ] 푸시 알림 연동
- [ ] 오프라인 모드 지원
- [ ] 테스트 작성
