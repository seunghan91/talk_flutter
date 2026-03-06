# Talkk — 미구현 항목 TODO

> 마지막 점검: 2026-03-06

---

## ✅ 완료 (2026-03-06 작업)

- [x] `conversations#close` — 대화 종료 API
- [x] `conversations#unread_count` — 안 읽은 메시지 수 API
- [x] `wallets#transfer` — 사용자 간 코인 이체 (트랜잭션 보장)
- [x] `payments_controller.rb` — IAP 영수증 검증 + 코인 지급 (iOS 구현, Android stub)
- [x] FCM UNREGISTERED 토큰 자동 DB 삭제
- [x] Flutter IAP 연동 — `IapService`, `WalletBloc` 연결, `CoinChargeSheet` 실결제 플로우

---

## 🔴 CRITICAL (배포 전 필수)

### 백엔드

- [ ] **Admin 인증 보완**
  - 파일: `app/controllers/admin/base_controller.rb`
  - 현재: dev/test 환경에서 하드코딩된 mock admin으로 bypass
  - 해결: Admin 유저 모델 또는 환경변수 기반 인증 구현
  - 프로덕션에서 admin 패널이 인증 없이 접근 가능한 보안 이슈

### Flutter + 스토어

- [ ] **App Store Connect에 IAP 상품 등록**
  - `com.talkapp.talkk2025.cash_100` (100코인, ₩1,100)
  - `com.talkapp.talkk2025.cash_1000` (1000+50코인, ₩11,000)
  - `com.talkapp.talkk2025.cash_5000` (5000+750코인, ₩55,000)
  - Bundle ID: `com.talkk.talkFlutter`
  - 상품 타입: Consumable

- [ ] **`APPLE_SHARED_SECRET` 환경변수 설정**
  - Render 서버 환경변수에 추가 필요
  - App Store Connect → 앱 → 인앱 결제 → 공유 암호

- [ ] **Android IAP 구현** (현재 dev/test 환경만 허용)
  - 파일: `payments_controller.rb#verify_android_receipt`
  - Google Play Developer API 연동 필요
  - `GOOGLE_SERVICE_ACCOUNT_JSON` 환경변수 필요

---

## 🟠 HIGH (출시 후 빠르게)

- [ ] **WebSocket 실시간 (ActionCable)**
  - 파일: `app/channels/application_cable/connection.rb`, `channel.rb`
  - 현재: 빈 클래스 (구현 없음)
  - 영향: 실시간 메시지 수신 없음 (폴링으로 대체 중)
  - Solid Cable 이미 설정됨 — Channel만 구현하면 됨

- [ ] **프리미엄 구독 기능**
  - 파일: `app/models/user.rb` — `premium?` 항상 `false` 반환
  - 구독 상품 추가 및 구독 상태 확인 로직 필요

---

## 🟡 MEDIUM (여유 있을 때)

- [ ] **푸시 알림 수신 처리 고도화**
  - 현재: 95% 완성 (발송, 수신, 딥링크 모두 동작)
  - 개선: 알림 권한 거부 시 UI 안내, 토큰 등록 실패 재시도 로직

- [ ] **프로필 나이/지역 필드**
  - 백엔드 DB에 `age`, `region` 컬럼 없음
  - 마이그레이션 + API + Flutter 프로필 편집 화면 연동

- [ ] **테스트 커버리지**
  - 백엔드: payments, conversations#close, wallets#transfer 스펙 작성
  - Flutter: WalletBloc IAP 플로우 bloc_test 추가

---

## 📦 스토어 배포 체크리스트

```bash
# TestFlight 빌드
cd /Users/seunghan/talkk
make build-testflight

# Render 환경변수 추가 (talkk-api)
APPLE_SHARED_SECRET=<App Store Connect 공유 암호>
```

- [ ] App Store Connect 앱 정보 입력 (스크린샷, 설명, 키워드)
- [ ] 개인정보처리방침 URL 연결
- [ ] 연령 등급 설정
- [ ] TestFlight 내부 테스트 → 외부 테스트 → 심사 제출
