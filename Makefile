# Talkk Flutter 빌드 자동화 시스템
# 사용법: make [target] [VAR=value ...]
# 예제: make build-ios, make clean, make help

.PHONY: help clean setup build-ios build-ipa build-testflight build-android build-aab test analyze format run run-sim run-device devices info

# 기본 변수
SHELL := /bin/bash
PROJECT_ROOT := $(shell pwd)
FLUTTER := flutter
SCRIPT_DIR := $(PROJECT_ROOT)/scripts
BUILD_TYPE ?= release
VERBOSE ?= false
API_BASE_URL ?= https://talkk-api.onrender.com/api/v1

# 빌드 결과 저장
RELEASES_DIR := $(PROJECT_ROOT)/build
RELEASES_IOS := $(RELEASES_DIR)/ios/v$(VERSION)
RELEASES_ANDROID := $(RELEASES_DIR)/android/v$(VERSION)

# 색상 정의
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

# 로깅 함수
define log_header
	@echo -e "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo -e "$(BLUE)$(1)$(NC)"
	@echo -e "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
endef

define log_step
	@echo -e "$(YELLOW)▶ $(1)$(NC)"
endef

define log_success
	@echo -e "$(GREEN)✅ $(1)$(NC)"
endef

define log_error
	@echo -e "$(RED)❌ $(1)$(NC)"
endef

# 버전 추출
VERSION := $(shell grep "version:" pubspec.yaml | awk '{print $$2}')
COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
TIMESTAMP := $(shell date '+%Y-%m-%d %H:%M:%S')

# ===== 도움말 =====

help:
	$(call log_header,Talkk Flutter 빌드 명령어)
	@echo ""
	@echo "📱 빠른 명령어:"
	@echo "  make b                 - iOS 빌드 (build-ios)"
	@echo "  make rs                - 시뮬레이터 실행 (run-sim)"
	@echo "  make t                 - 테스트 실행"
	@echo "  make a                 - 코드 분석"
	@echo ""
	@echo "설정:"
	@echo "  make setup             - 개발 환경 초기화 (의존성 + 코드 생성)"
	@echo "  make clean             - 빌드 캐시 삭제"
	@echo "  make info              - 빌드 정보 출력"
	@echo ""
	@echo "빌드:"
	@echo "  make build-ios         - iOS 앱 빌드 (release)"
	@echo "  make build-ipa         - IPA 파일 생성"
	@echo "  make build-testflight  - TestFlight용 빌드 (빌드번호 자동증가)"
	@echo "  make build-android     - Android APK 빌드"
	@echo "  make build-aab         - Android AAB 빌드"
	@echo ""
	@echo "실행:"
	@echo "  make run               - 기본 디바이스에서 실행"
	@echo "  make run-sim           - iOS 시뮬레이터에서 실행"
	@echo "  make run-sim-dev       - 시뮬레이터 (개발 모드, localhost)"
	@echo "  make run-device        - 실제 디바이스에서 실행"
	@echo "  make devices           - 디바이스 목록"
	@echo ""
	@echo "품질:"
	@echo "  make test              - 유닛 테스트"
	@echo "  make analyze           - 정적 분석"
	@echo "  make format            - 코드 포맷팅"
	@echo "  make codegen           - 코드 생성 (freezed, retrofit, json)"
	@echo ""
	@echo "배포:"
	@echo "  make testflight        - 빌드 + TestFlight 업로드"
	@echo ""
	@echo "변수:"
	@echo "  BUILD_TYPE=release|debug  (기본: release)"
	@echo "  VERBOSE=true              (상세 로그)"
	@echo ""

# ===== 정보 =====

info:
	$(call log_header,빌드 정보)
	@echo "프로젝트: Talkk Flutter"
	@echo "버전: $(VERSION)"
	@echo "커밋: $(COMMIT)"
	@echo "시간: $(TIMESTAMP)"
	@echo "API: $(API_BASE_URL)"

# ===== 정리 =====

clean: clean-flutter clean-ios
	$(call log_success,전체 정리 완료)

clean-flutter:
	$(call log_step,Flutter 캐시 정리 중...)
	@$(FLUTTER) clean
	@rm -rf .dart_tool
	$(call log_success,Flutter 정리 완료)

clean-ios:
	$(call log_step,iOS 빌드 캐시 정리 중...)
	@rm -rf ios/Pods ios/Podfile.lock
	@rm -rf ios/.symlinks
	@cd ios && xcodebuild clean 2>/dev/null || true
	@rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-* 2>/dev/null || true
	$(call log_success,iOS 정리 완료)

# ===== 설정 =====

setup:
	$(call log_header,개발 환경 초기화)
	$(call log_step,Flutter 의존성 설치 중...)
	@$(FLUTTER) pub get
	$(call log_step,코드 생성 중 (freezed, retrofit, json)...)
	@dart run build_runner build --delete-conflicting-outputs
	$(call log_success,설정 완료!)

codegen:
	$(call log_step,코드 생성 중...)
	@dart run build_runner build --delete-conflicting-outputs
	$(call log_success,코드 생성 완료)

pod-install:
	$(call log_step,CocoaPods 설치 중...)
	@cd ios && pod install --repo-update
	$(call log_success,CocoaPods 설치 완료)

# ===== 빌드 번호 =====

increment-build-number:
	$(call log_step,빌드 번호 자동 증가 중...)
	@bash $(SCRIPT_DIR)/increment-build-number.sh

# ===== iOS 빌드 =====

build-ios:
	$(call log_header,iOS 빌드 시작 ($(BUILD_TYPE)))
	@echo "버전: $(VERSION)"
	@echo ""
	@if [ "$(BUILD_TYPE)" = "release" ]; then \
		$(FLUTTER) build ios --release --no-codesign \
			--dart-define=API_BASE_URL=$(API_BASE_URL) $(if $(filter true,$(VERBOSE)),-v); \
	else \
		$(FLUTTER) build ios --debug \
			--dart-define=API_BASE_URL=$(API_BASE_URL) $(if $(filter true,$(VERBOSE)),-v); \
	fi
	$(call log_success,iOS 빌드 완료)
	@echo "위치: build/ios/iphoneos/Runner.app"

build-ipa: increment-build-number
	$(call log_header,IPA 파일 생성 중)
	@echo "버전: $(VERSION)"
	@echo ""
	@$(FLUTTER) pub get
	@$(FLUTTER) build ipa --release \
		--dart-define=API_BASE_URL=$(API_BASE_URL) \
		$(if $(filter true,$(VERBOSE)),-v)
	$(call log_success,IPA 생성 완료)

build-testflight: clean
	$(call log_header,TestFlight용 프로덕션 빌드)
	@echo "버전: $(VERSION)"
	@echo ""
	$(call log_step,1. 빌드 번호 증가...)
	@bash $(SCRIPT_DIR)/increment-build-number.sh
	$(call log_step,2. 의존성 설치...)
	@$(FLUTTER) pub get
	$(call log_step,3. 코드 생성...)
	@dart run build_runner build --delete-conflicting-outputs
	$(call log_step,4. 정적 분석...)
	@$(FLUTTER) analyze || (echo "⚠️  경고 무시하고 계속..."; true)
	$(call log_step,5. IPA 빌드...)
	@$(FLUTTER) build ipa --release \
		--obfuscate \
		--split-debug-info=build/app/outputs/symbols \
		--dart-define=API_BASE_URL=$(API_BASE_URL) \
		$(if $(filter true,$(VERBOSE)),-v)
	$(call log_success,TestFlight용 IPA 생성 완료!)
	@echo ""
	@echo "📦 IPA 파일:"
	@ls -lh build/ios/ipa/*.ipa 2>/dev/null || echo "  ExportOptions.plist 없이 빌드됨 → Xcode에서 Archive 필요"
	@echo ""
	@echo "다음 단계:"
	@echo "  make upload-testflight  (Transporter로 업로드)"

upload-testflight:
	$(call log_header,TestFlight 업로드 안내)
	@echo ""
	@echo "🎯 Transporter 앱 사용 (추천):"
	@echo "  1. Mac App Store에서 'Transporter' 설치"
	@echo "  2. IPA 파일 드래그 & 드롭"
	@echo "  3. Apple ID 로그인 후 '배송'"
	@echo ""
	@IPA_FILE=$$(ls build/ios/ipa/*.ipa 2>/dev/null | head -1); \
	if [ -n "$$IPA_FILE" ]; then \
		echo "📦 IPA: $$IPA_FILE"; \
		echo ""; \
		read -p "Transporter 앱을 열까요? (Y/n): " open_app; \
		if [ "$$open_app" != "n" ] && [ "$$open_app" != "N" ]; then \
			open -a Transporter 2>/dev/null || open "https://apps.apple.com/app/transporter/id1450874784"; \
		fi; \
	else \
		echo "❌ IPA 파일을 찾을 수 없습니다. 먼저 make build-testflight을 실행하세요."; \
	fi

testflight: build-testflight
	@echo ""
	@read -p "🚀 TestFlight에 업로드하시겠습니까? (Y/n): " confirm; \
	if [ "$$confirm" != "n" ] && [ "$$confirm" != "N" ]; then \
		$(MAKE) upload-testflight; \
	else \
		echo "나중에 'make upload-testflight'로 업로드하세요."; \
	fi

# ===== Android 빌드 =====

build-android:
	$(call log_header,Android APK 빌드 ($(BUILD_TYPE)))
	@echo "버전: $(VERSION)"
	@echo ""
	@$(FLUTTER) build apk --$(BUILD_TYPE) \
		--dart-define=API_BASE_URL=$(API_BASE_URL) $(if $(filter true,$(VERBOSE)),-v)
	$(call log_success,Android APK 완료)
	@echo "위치: build/app/outputs/flutter-apk/"

build-aab: increment-build-number
	$(call log_header,Android AAB 빌드)
	@echo "버전: $(VERSION)"
	@echo ""
	@$(FLUTTER) pub get
	@$(FLUTTER) build appbundle --release \
		--dart-define=API_BASE_URL=$(API_BASE_URL) \
		$(if $(filter true,$(VERBOSE)),-v)
	$(call log_success,Android AAB 완료)
	@echo "위치: build/app/outputs/bundle/release/"

# ===== 테스트 & 품질 =====

test:
	$(call log_step,유닛 테스트 실행 중...)
	@$(FLUTTER) test
	$(call log_success,테스트 완료)

test-coverage:
	$(call log_step,커버리지 테스트 실행 중...)
	@$(FLUTTER) test --coverage
	$(call log_success,커버리지 테스트 완료)

analyze:
	$(call log_step,코드 분석 중...)
	@$(FLUTTER) analyze
	$(call log_success,분석 완료)

format:
	$(call log_step,코드 포맷팅 중...)
	@dart format lib/ test/
	$(call log_success,포맷팅 완료)

# ===== 실행 =====

run:
	$(call log_step,앱 실행 중...)
	@$(FLUTTER) run \
		--dart-define=API_BASE_URL=$(API_BASE_URL) $(if $(filter true,$(VERBOSE)),-v)

run-sim:
	$(call log_step,시뮬레이터에서 실행 중...)
	@DEVICE_ID=$$(flutter devices | grep "iPhone.*Simulator" | head -1 | awk '{print $$NF}' | tr -d '()'); \
	if [ -z "$$DEVICE_ID" ]; then \
		echo "❌ 실행 중인 시뮬레이터를 찾을 수 없습니다"; \
		exit 1; \
	fi; \
	echo "디바이스: $$DEVICE_ID"; \
	$(FLUTTER) run -d $$DEVICE_ID \
		--dart-define=API_BASE_URL=$(API_BASE_URL) $(if $(filter true,$(VERBOSE)),-v)

run-sim-dev:
	$(call log_step,시뮬레이터 (개발모드 - localhost)...)
	@DEVICE_ID=$$(flutter devices | grep "iPhone.*Simulator" | head -1 | awk '{print $$NF}' | tr -d '()'); \
	if [ -z "$$DEVICE_ID" ]; then \
		echo "❌ 실행 중인 시뮬레이터를 찾을 수 없습니다"; \
		exit 1; \
	fi; \
	echo "디바이스: $$DEVICE_ID (개발모드)"; \
	$(FLUTTER) run -d $$DEVICE_ID \
		--dart-define=API_BASE_URL=http://localhost:3000/api/v1 $(if $(filter true,$(VERBOSE)),-v)

run-device:
	$(call log_step,실제 디바이스에서 실행 중...)
	@DEVICE_ID=$$(flutter devices | grep "iOS" | grep -v "Simulator" | head -1 | awk '{print $$NF}' | tr -d '()'); \
	if [ -z "$$DEVICE_ID" ]; then \
		echo "❌ 연결된 디바이스를 찾을 수 없습니다"; \
		exit 1; \
	fi; \
	echo "디바이스: $$DEVICE_ID"; \
	$(FLUTTER) run -d $$DEVICE_ID \
		--dart-define=API_BASE_URL=$(API_BASE_URL) $(if $(filter true,$(VERBOSE)),-v)

devices:
	$(call log_header,디바이스 목록)
	@$(FLUTTER) devices

# ===== 단축 명령어 =====

.PHONY: b bi ba bt tf t a f rs rsd rd

b: build-ios
bi: build-ipa
ba: build-android
bt: build-testflight
tf: testflight
t: test
a: analyze
f: format
rs: run-sim
rsd: run-sim-dev
rd: run-device

# 기본 타겟
.DEFAULT_GOAL := help
