SWIFT_BUILD_FLAGS=--configuration debug

.PHONY: all
all: build

# ==================
# == Usual things ==
# ==================

.PHONY: build test clean

build:
	swift build $(SWIFT_BUILD_FLAGS)

run:
	swift run

clean:
	swift package clean

# =================
# == Lint/format ==
# =================

.PHONY: lint format spell

# If you are using any other reporter than 'emoji' then you are doing it wrong...
lint:
	SwiftLint lint --reporter emoji

format:
	SwiftFormat --config ./.swiftformat "./Sources"

# cSpell is our spell checker
# See: https://github.com/streetsidesoftware/cspell/tree/master/packages/cspell
spell:
	cspell --no-progress --relative --config "./.cspell.json" \
		"./Sources/**" \
		"./Tests/**" \
		"./Lib/**" \
		"./PyTests/**" \
		"./Scripts/**" \
		"./Code of Conduct.md" \
		"./LICENSE" \
		"./Makefile" \
		"./Package.swift" \
		"./README.md"

# ===========
# == Xcode ==
# ===========

.PHONY: xcode

xcode:
	swift package generate-xcodeproj
	@echo ''
	@echo 'Remember to add SwiftLint build phase!'
	@echo 'See: https://github.com/realm/SwiftLint#xcode'
