PROJECT_NAME := Abacaxi
XCODEPROJ := $(PROJECT_NAME).xcodeproj
REQUIRED_XCODEGEN_VERSION := 2.45.3

.PHONY: start bootstrap generate-localizations generate open clean lint lint-strict

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
