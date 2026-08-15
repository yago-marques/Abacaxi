PROJECT_NAME := Abacaxi
XCODEPROJ := $(PROJECT_NAME).xcodeproj
REQUIRED_XCODEGEN_VERSION := 2.45.3
TEST_DESTINATION ?= platform=iOS Simulator,name=iPhone 16
TEST_SCHEME ?= AllTests
BASE_REF ?= origin/main
RESULTS_DIR ?= build/test-results

.PHONY: start bootstrap generate-localizations generate open clean lint lint-strict test test-impacted

start: bootstrap generate-localizations generate open

bootstrap:
	@if ! command -v xcodegen >/dev/null 2>&1; then \
		echo "XcodeGen not found — installing via Homebrew..."; \
		brew install xcodegen; \
	fi
	@if ! command -v swiftgen >/dev/null 2>&1; then \
		echo "SwiftGen not found — installing via Homebrew..."; \
		brew install swiftgen; \
	fi
	@if [ ! -f Configs/Secrets.xcconfig ]; then \
		cp Configs/Secrets.example.xcconfig Configs/Secrets.xcconfig; \
		echo "warning: Configs/Secrets.xcconfig created from example — set API_KEY before running the app."; \
	fi
	@installed_version=$$(xcodegen --version | awk '{print $$2}'); \
	lowest=$$(printf '%s\n%s\n' "$(REQUIRED_XCODEGEN_VERSION)" "$$installed_version" | sort -V | head -n1); \
	if [ "$$lowest" != "$(REQUIRED_XCODEGEN_VERSION)" ]; then \
		echo "error: XcodeGen $(REQUIRED_XCODEGEN_VERSION) or newer required, found $$installed_version"; \
		echo "Run: brew upgrade xcodegen"; \
		exit 1; \
	fi

generate:
	xcodegen generate

generate-localizations:
	@find Modules -path '*/Sources/*/swiftgen.yml' -print | while read config; do \
		echo "Generating localized sources from $$config..."; \
		mkdir -p "$$(dirname "$$config")/Resources/Generated"; \
		swiftgen config run --config "$$config"; \
	done

open:
	open $(XCODEPROJ)

clean:
	rm -rf $(XCODEPROJ)
	rm -rf ~/Library/Developer/Xcode/DerivedData/$(PROJECT_NAME)-*

lint:
	@Scripts/swiftlint.sh

lint-strict:
	@Scripts/swiftlint.sh --strict

test:
	xcodebuild test \
		-project $(XCODEPROJ) \
		-scheme $(TEST_SCHEME) \
		-destination '$(TEST_DESTINATION)' \
		$(if $(TEST_RESULT_BUNDLE),-resultBundlePath "$(TEST_RESULT_BUNDLE)")

test-impacted:
	@set -e; \
	schemes="$$(bash Scripts/impacted-test-schemes.sh $(BASE_REF) HEAD)"; \
	if [ -z "$$schemes" ]; then \
		echo "error: impacted-test-schemes.sh produced no schemes" >&2; \
		exit 1; \
	fi; \
	rm -rf "$(RESULTS_DIR)"; \
	mkdir -p "$(RESULTS_DIR)"; \
	echo "Impacted test schemes: $$schemes"; \
	for scheme in $$schemes; do \
		module="$${scheme%Tests}"; \
		if [ "$$scheme" != "AllTests" ] && grep -q '\.macOS(' "Modules/$$module/Package.swift" 2>/dev/null; then \
			echo "==> $$module: swift test (macOS-native, sem simulador)"; \
			swift test --package-path "Modules/$$module" --xunit-output "$(CURDIR)/$(RESULTS_DIR)/$$module.xml"; \
		else \
			$(MAKE) test TEST_SCHEME=$$scheme TEST_RESULT_BUNDLE="$(CURDIR)/$(RESULTS_DIR)/$$scheme.xcresult"; \
		fi; \
	done; \
	echo "Result files in $(RESULTS_DIR):"; \
	ls -l "$(RESULTS_DIR)" || true
