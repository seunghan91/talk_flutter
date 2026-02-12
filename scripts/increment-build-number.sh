#!/bin/bash
# Talkk Flutter 빌드 번호 자동 증가
# pubspec.yaml의 version: x.x.x+BUILD_NUMBER 에서 BUILD_NUMBER를 +1
#
# 원리:
#   pubspec.yaml (version: 1.0.0+42)
#        ↓ flutter pub get
#   ios/Flutter/Generated.xcconfig (FLUTTER_BUILD_NUMBER=42)
#        ↓
#   ios/Runner/Info.plist (CFBundleVersion=$(FLUTTER_BUILD_NUMBER))

set -e

PUBSPEC="pubspec.yaml"

if [ ! -f "$PUBSPEC" ]; then
  echo "❌ pubspec.yaml을 찾을 수 없습니다"
  exit 1
fi

# 현재 빌드 번호 추출
CURRENT_BUILD=$(grep "^version:" "$PUBSPEC" | sed 's/version: [0-9.]*+\([0-9]*\)/\1/')
NEW_BUILD=$((CURRENT_BUILD + 1))

# pubspec.yaml 업데이트
sed -i '' "s/version: \([0-9.]*\)+[0-9]*/version: \1+$NEW_BUILD/" "$PUBSPEC"

echo "✅ 빌드 번호: $CURRENT_BUILD → $NEW_BUILD"
