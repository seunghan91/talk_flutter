.PHONY: build-ipa testflight clean

EXPORT_OPTIONS  = ios/ExportOptions.plist
API_KEY         = BS4SD32G2U
API_ISSUER      = 213dd70a-f512-449a-b36f-86655445cec4
IPA_DIR         = build/ios/ipa
IPA_FILE        = $(IPA_DIR)/Voiceting.ipa

build-ipa:
	flutter build ipa --release --export-options-plist=$(EXPORT_OPTIONS)

testflight: build-ipa
	@echo "📦 TestFlight 업로드 중..."
	xcrun altool --upload-app \
		--type ios \
		--file "$(IPA_FILE)" \
		--apiKey $(API_KEY) \
		--apiIssuer $(API_ISSUER) \
		--verbose
	@echo "✅ TestFlight 업로드 완료!"

clean:
	flutter clean && flutter pub get
