PROJECT_NAME := Abacaxi
XCODEPROJ := $(PROJECT_NAME).xcodeproj
REQUIRED_XCODEGEN_VERSION := 2.45.3

.PHONY: start bootstrap generate open clean lint lint-strict

start: bootstrap generate open

bootstrap:
	@if ! command -v xcodegen >/dev/null 2>&1; then \
		echo "XcodeGen not found — installing via Homebrew..."; \
		brew install xcodegen; \
	fi
	@installed_version=$$(xcodegen --version | awk '{print $$2}'); \
	if [ "$$installed_version" != "$(REQUIRED_XCODEGEN_VERSION)" ]; then \
		echo "error: XcodeGen $(REQUIRED_XCODEGEN_VERSION) required, found $$installed_version"; \
		echo "Run: brew upgrade xcodegen (or brew install xcodegen@$(REQUIRED_XCODEGEN_VERSION))"; \
		exit 1; \
	fi

generate:
	xcodegen generate

open:
	open $(XCODEPROJ)

clean:
	rm -rf $(XCODEPROJ)
	rm -rf ~/Library/Developer/Xcode/DerivedData/$(PROJECT_NAME)-*

lint:
	@Scripts/swiftlint.sh

lint-strict:
	@Scripts/swiftlint.sh --strict
