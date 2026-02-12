# Talkk Flutter 미구현 항목 구현 가이드

> ainote BLoC/Cubit 패턴 참고 기반 구현 계획서
> 작성일: 2026-02-12

## 참조 프로젝트

- **ainote**: `/Users/seunghan/ainote/ainote_flutter_claude_bloc_poc/`
- **talkk**: `/Users/seunghan/talkk/flutter/`
- **공통 스택**: flutter_bloc 9.0.0, hydrated_bloc 10.1.1, Clean Architecture

---

## 아키텍처 개요

### talkk 현재 구조
```
lib/
├── core/              # 설정, 상수, 테마, 유틸
├── data/              # Repository 구현체, DataSource, Model
│   ├── datasources/   # API Client (Dio)
│   ├── models/        # DTO (JSON serializable)
│   └── repositories/  # Repository 구현
├── domain/            # 추상 인터페이스, Entity
│   ├── entities/
│   └── repositories/  # Abstract Repository
└── presentation/      # UI + BLoC
    ├── blocs/         # BLoC/Cubit (conversation, user, broadcast, auth, notification)
    ├── screens/       # 화면들
    └── widgets/       # 재사용 위젯
```

### ainote에서 차용할 패턴
1. **HydratedCubit**: 테마/언어 등 설정 영속화 (AppearanceCubit 참조)
2. **Optimistic Updates**: 즉시 UI 반영 후 API 호출 (TaskBloc 참조)
3. **BlocSelector**: 필요한 상태만 구독하여 리빌드 최소화
4. **에러 핸들링**: (message, isRetryable) 튜플 패턴
5. **Sealed Event**: `sealed class` 이벤트 계층

---

## Phase 1: 대화 화면 핵심 기능 (HIGH)

### 1.1 실제 메시지 연동
- **파일**: `conversation_screen.dart:136`
- **현재**: `itemCount: 10` 하드코딩
- **구현**:
  - `initState`에서 `ConversationMessagesRequested(conversationId)` 디스패치
  - `BlocBuilder<ConversationBloc, ConversationState>`로 messages 구독
  - `itemCount: state.messages[conversationId]?.length ?? 0`
- **참조**: ainote `TaskBloc` → `TasksLoadRequested` 이벤트 패턴

### 1.2 음성 메시지 재생
- **파일**: `conversation_screen.dart:145`
- **현재**: `onPlay` 콜백 비어있음
- **구현**:
  - `VoiceRecordingService.startPlayback(audioUrl)` 호출
  - 재생 상태 관리 (`_currentlyPlayingId` setState)
  - 완료 콜백으로 상태 리셋
- **기존 서비스**: `VoiceRecordingService` (이미 구현됨)
- **기존 위젯**: `VoiceMessagePlayer` (이미 존재)

### 1.3 + 1.4 음성 녹음 & 전송
- **파일**: `conversation_screen.dart:190, 194`
- **현재**: `_isRecording` 상태만 변경
- **구현**:
  - `onLongPressStart`: `VoiceRecordingService.startRecording()` 호출
  - `onLongPressEnd`: `stopRecording()` → 결과로 `ConversationSendMessage` 디스패치
  - 권한 체크 포함 (마이크 권한)
- **이벤트**: `ConversationSendMessage(conversationId, audioPath, duration)`
- **참조**: ainote 낙관적 업데이트 → 녹음 완료 즉시 UI에 메시지 추가

### 1.5 사용자 차단
- **파일**: `conversation_screen.dart:237`
- **현재**: 다이얼로그만 표시, 실제 차단 없음
- **구현**:
  - `context.read<UserBloc>().add(UserBlockRequested(userId))`
  - `BlocListener`로 성공/실패 처리
  - 성공 시 대화 목록으로 네비게이션
- **기존**: `UserBloc.UserBlockRequested` + `UserRepository.blockUser()` 구현됨

### 1.6 대화 삭제
- **파일**: `conversation_screen.dart:269`
- **현재**: `context.pop()` 네비게이션만
- **구현**:
  - 삭제 확인 후 `ConversationDelete(conversationId)` 디스패치
  - `BlocListener`로 성공 시 pop
- **기존**: `ConversationBloc.ConversationDelete` 이벤트 구현됨

---

## Phase 2: 프로필 & 이미지 업로드 (MEDIUM)

### 2.1 프로필 이미지 선택
- **파일**: `profile_edit_screen.dart:130`
- **현재**: SnackBar 메시지만
- **구현**:
  - `image_picker` 패키지 사용 (pubspec.yaml에 이미 있음)
  - 바텀시트: 카메라 / 갤러리 선택
  - 선택한 이미지 → `_selectedImage` 상태 저장
  - 저장 버튼 탭 시 `UserProfileUpdateRequested(profileImage: file)` 디스패치

### 2.2 멀티파트 이미지 업로드
- **파일**: `user_repository_impl.dart:42`
- **현재**: 이미지 파일 무시, 텍스트 필드만 업데이트
- **구현**:
  - `FormData`로 멀티파트 요청 구성
  - `MultipartFile.fromFile(path, filename:)` 사용
  - `user[profile_image]` 키로 업로드
- **참조**: `ConversationRepositoryImpl.sendMessage()`의 멀티파트 패턴 동일하게 적용

---

## Phase 3: 설정 화면 (MEDIUM)

### 3.1 + 3.2 다크 모드 (신규 Cubit 필요)
- **파일**: `settings_screen.dart:120, 122`
- **신규 생성**:
  ```
  lib/presentation/blocs/theme/
  ├── theme_cubit.dart       # HydratedCubit
  └── theme_state.dart       # ThemeMode 포함
  ```
- **패턴**: ainote `AppearanceCubit` (HydratedCubit) 참조
  ```dart
  class ThemeCubit extends HydratedCubit<ThemeState> {
    ThemeCubit() : super(const ThemeState());

    void toggleDarkMode() {
      emit(state.copyWith(
        themeMode: state.themeMode == ThemeMode.light
          ? ThemeMode.dark : ThemeMode.light,
      ));
    }

    @override
    ThemeState? fromJson(Map<String, dynamic> json) => ThemeState.fromJson(json);

    @override
    Map<String, dynamic>? toJson(ThemeState state) => state.toJson();
  }
  ```
- **main.dart**: `BlocProvider<ThemeCubit>` 추가 + `BlocBuilder`로 `MaterialApp` 감싸기

### 3.3 언어 선택 (신규 Cubit 필요)
- **파일**: `settings_screen.dart:131`
- **신규 생성**:
  ```
  lib/presentation/blocs/locale/
  ├── locale_cubit.dart      # HydratedCubit
  └── locale_state.dart      # Locale 포함
  ```
- **패턴**: ainote `LocaleCubit` 참조
- **구현**: 바텀시트에서 언어 선택 → `setLocale(Locale)` → `MaterialApp.locale` 반영

### 3.4 + 3.5 + 3.6 도움말/약관 페이지
- **파일**: `settings_screen.dart:147, 154, 161`
- **구현**: 간단한 `StatelessWidget` + WebView 또는 Markdown 렌더링
- **신규 생성**:
  ```
  lib/presentation/screens/settings/
  ├── help_screen.dart
  ├── privacy_policy_screen.dart
  └── terms_of_service_screen.dart
  ```
- **라우팅**: GoRouter에 `/help`, `/privacy-policy`, `/terms-of-service` 추가

---

## Phase 4: 피드백 & 방송 차단 (MEDIUM-LOW)

### 4.1 피드백 전송 (신규 BLoC 필요)
- **파일**: `feedback_screen.dart:38`
- **현재**: `Future.delayed` 목업
- **신규 생성**:
  ```
  lib/presentation/blocs/feedback/
  ├── feedback_bloc.dart
  ├── feedback_event.dart
  └── feedback_state.dart

  lib/domain/repositories/feedback_repository.dart
  lib/data/repositories/feedback_repository_impl.dart
  ```
- **API**: `POST /api/v1/feedback` → `{ category, content }`
- **패턴**: ainote `DdayBloc` (간단한 CRUD BLoC) 참조

### 4.2 방송 상세 차단
- **파일**: `broadcast_detail_screen.dart:273`
- **현재**: 다이얼로그만
- **구현**: 1.5와 동일 패턴 → `UserBloc.add(UserBlockRequested(userId))`

---

## 신규 생성 파일 목록

### BLoC/Cubit (ainote 패턴 참조)
| 파일 | 타입 | ainote 참조 |
|------|------|------------|
| `blocs/theme/theme_cubit.dart` | HydratedCubit | `appearance_cubit.dart` |
| `blocs/theme/theme_state.dart` | State | `appearance_state.dart` |
| `blocs/locale/locale_cubit.dart` | HydratedCubit | `locale_cubit.dart` |
| `blocs/locale/locale_state.dart` | State | `locale_state.dart` |
| `blocs/feedback/feedback_bloc.dart` | Bloc | `dday_bloc.dart` |
| `blocs/feedback/feedback_event.dart` | Event | `dday_event.dart` |
| `blocs/feedback/feedback_state.dart` | State | `dday_state.dart` |

### Repository
| 파일 | 역할 |
|------|------|
| `domain/repositories/feedback_repository.dart` | 피드백 인터페이스 |
| `data/repositories/feedback_repository_impl.dart` | 피드백 구현체 |

### Screen
| 파일 | 역할 |
|------|------|
| `screens/settings/help_screen.dart` | 도움말 |
| `screens/settings/privacy_policy_screen.dart` | 개인정보 처리방침 |
| `screens/settings/terms_of_service_screen.dart` | 이용약관 |

---

## 구현 순서 & 의존성

```
Phase 1 (기존 인프라 활용, 병렬 가능)
├── 1.1 메시지 연동 ──┐
├── 1.2 음성 재생 ────┤── 모두 ConversationBloc 기존 인프라
├── 1.3+1.4 녹음 전송 ┤
├── 1.5 사용자 차단 ──┤── UserBloc 기존 인프라
└── 1.6 대화 삭제 ────┘

Phase 2 (이미지 처리)
├── 2.1 이미지 선택 ← image_picker
└── 2.2 멀티파트 업로드 ← Dio FormData

Phase 3 (신규 Cubit 생성 필요)
├── 3.1+3.2 ThemeCubit 생성 → SettingsScreen 연동 → main.dart 연동
├── 3.3 LocaleCubit 생성 → SettingsScreen 연동 → main.dart 연동
└── 3.4-3.6 정적 페이지 3개 + GoRouter 라우트

Phase 4 (신규 BLoC 생성 필요)
├── 4.1 FeedbackBloc + Repository 생성 → FeedbackScreen 연동
└── 4.2 방송 차단 (UserBloc 기존 활용)
```

---

## 품질 기준

- **에러 핸들링**: 모든 API 호출에 try-catch + 사용자 친화적 메시지
- **로딩 상태**: API 호출 시 로딩 인디케이터 표시
- **낙관적 업데이트**: 차단, 삭제 등은 즉시 UI 반영 후 API 호출
- **BlocListener**: 성공/실패 시 SnackBar 또는 네비게이션
- **HydratedCubit**: 테마/언어는 앱 재시작 후에도 유지
- **기존 패턴 준수**: talkk의 기존 BLoC 패턴과 일관성 유지
