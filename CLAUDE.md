# Claude Guidelines for Talk Flutter App

## 프로젝트 개요
- **프로젝트명**: Talkk Flutter (talk_flutter)
- **목적**: React Native Talk 앱을 Flutter로 재개발
- **아키텍처**: ainote Flutter 프로젝트의 Clean Architecture + BLoC 패턴 적용
- **API 서버**: https://talkk-api.onrender.com/api/v1 (Rails 8.1.2)

## 기술 스택

### State Management
- **flutter_bloc** ^9.0.0 - BLoC 패턴 구현
- **hydrated_bloc** ^10.1.1 - 상태 영속화
- **equatable** ^2.0.5 - 값 비교

### Networking
- **dio** ^5.9.0 - HTTP 클라이언트
- **retrofit** 4.7.2 - 타입 안전 API 클라이언트

### Backend (Talkk API)
- **Rails 8.1.2** & **Ruby 3.4.1**
- **Solid Suite** (Queue, Cache, Cable) - DB 기반 인프라 통합

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

## ⚠️ UI/Design System Rules (MANDATORY)

UI 코드를 작성하거나 수정할 때 반드시 아래 규칙을 따를 것.

### 절대 하지 말 것 (NEVER)

```dart
// ❌ 하드코딩 금지 - 다크모드 깨짐
Container(color: Colors.white)
Text('...', style: TextStyle(color: Color(0xFF2D1B1B)))
Text('...', style: TextStyle(color: AppColors.textPrimaryLight))
Divider(color: AppColors.neutral200)
BoxDecoration(color: AppColors.muted)
BoxDecoration(border: Border.all(color: AppColors.border))
```

### 반드시 할 것 (ALWAYS)

```dart
// ✅ context 확장 메서드 사용 - 라이트/다크 자동 대응
Container(color: context.cardColor)           // 카드 배경
Container(color: context.mutedColor)          // muted 배경
Text('...', style: TextStyle(color: context.textPrimary))      // 주요 텍스트
Text('...', style: TextStyle(color: context.textSecondary))    // 보조 텍스트
Text('...', style: TextStyle(color: context.textTertiary))     // 힌트 텍스트
Text('...', style: TextStyle(color: context.mutedForegroundColor)) // muted 텍스트
Divider(color: Theme.of(context).dividerColor)  // 구분선
BoxDecoration(border: Border.all(color: context.borderColor))  // 테두리
BoxDecoration(color: context.accentColor)      // accent 배경
BoxShadow(color: context.shadowColor)          // 그림자
```

### 컨텍스트 확장 메서드 전체 목록 (`lib/core/theme/app_colors.dart`)

| 메서드 | 라이트 | 다크 | 용도 |
|--------|--------|------|------|
| `context.textPrimary` | #2D1B1B | #FAFAFA | 주요 텍스트, 헤더 |
| `context.textSecondary` | #8B6B6B | #D4D4D4 | 보조 텍스트 |
| `context.textTertiary` | #A89A9A | #A3A3A3 | 힌트, 아이콘 |
| `context.mutedForegroundColor` | #8B6B6B | #B3B3B3 | placeholder |
| `context.cardColor` | #FFFFFF | #252525 | 카드 배경 |
| `context.surfaceColor` | #FFFFFF | #252525 | 화면 배경 |
| `context.mutedColor` | #FFF0F0 | #404040 | 연한 배경 |
| `context.accentColor` | #FFD4D8 | #404040 | 강조 배경 |
| `context.secondaryColor` | #FFB3BA | #404040 | 보조 색상 |
| `context.borderColor` | rgba(E63946,15%) | #404040 | 테두리 |
| `context.inputBgColor` | #FFF5F5 | #404040 | 입력창 배경 |
| `context.shadowColor` | rgba(0,0,0,6%) | rgba(0,0,0,24%) | 그림자 |
| `context.primaryColor` | #E63946 | #FAFAFA | 브랜드 색상 |

### WCAG 2.1 AA 대비율 기준

| 텍스트 종류 | 최소 대비율 | 실패 사례 |
|------------|------------|----------|
| 일반 텍스트 (14px 이하) | **4.5:1** | mutedForeground on white = 3.9:1 ❌ |
| 큰 텍스트 (18px+ 또는 14px bold+) | 3:1 | |
| UI 컴포넌트, 아이콘 | 3:1 | secondary on white = 1.6:1 ❌ |

- 섹션 헤더, 라벨, 버튼 텍스트 → 반드시 `context.textPrimary` 사용
- hint/placeholder성 보조 텍스트만 `context.mutedForegroundColor` 허용

### 다크모드를 고려한 카드 데코레이션 패턴

```dart
// ✅ 올바른 카드 데코레이션
BoxDecoration(
  color: context.cardColor,
  borderRadius: BorderRadius.circular(AppRadius.xl),
  border: Border.all(color: context.borderColor),
  boxShadow: [
    BoxShadow(
      color: context.shadowColor,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ],
)
```

### 브랜드 색상 (하드코딩 허용)

아래 색상은 다크/라이트 공통으로 하드코딩 허용:
- `AppColors.primary` (#E63946) - 버튼, CTA, 강조 액션
- `AppColors.success`, `AppColors.error`, `AppColors.info`, `AppColors.warning` - 상태 색상
- `Colors.white` - primary 버튼 위의 텍스트/아이콘 (on-primary)

---

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

## 개발 체크리스트 (2026.02 업데이트)

### ✅ 완료
- [x] Rails 8.1.2 백엔드 업그레이드 완료 (Solid Suite 도입)
- [x] Auth BLoC 완성 (로그인/회원가입/로그아웃/SMS인증)
- [x] Broadcast BLoC 구현 (목록조회/생성/답장)
- [x] Conversation BLoC 구현 (목록/즐겨찾기/삭제)
- [x] User BLoC 구현
- [x] Notification BLoC 구현 (FCM 연동 로직 기초)
- [x] Wallet BLoC 구현
- [x] 음성 녹음 위젯 (VoiceMessageRecorder + VoiceRecordingService)
- [x] 음성 재생 위젯 (VoiceMessagePlayer + 파형 시각화)
- [x] GoRouter 라우팅 설정 완료
- [x] 모든 화면 UI 구현 완료 (HomeScreen 등 20여 개)
- [x] 공통 위젯 및 DI 설정 완료
- [x] Firebase 초기화 및 테마 시스템 적용

### 🚧 진행 필요
- [ ] 푸시 알림 최종 연동 및 수신 처리 고도화
- [ ] 오프라인 모드 데이터 동기화 강화 (Drift 캐싱)
- [ ] 통합 테스트 및 위젯 테스트 커버리지 확대
- [ ] iOS/Android 최종 빌드 및 스토어 배포 준비
