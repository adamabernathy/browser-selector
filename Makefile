.PHONY: build test run release open install clean bump-patch bump-minor bump-major

build:
	swift build

test:
	DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test

run: build
	./scripts/setup-dev-router.sh
	swift run BrowserSwitchMenuBarApp

release:
	./scripts/build-app.sh --release

open:
	./scripts/build-app.sh --release --run

install:
	./scripts/install.sh

clean:
	rm -rf .build dist

bump-patch:
	./scripts/bump-version.sh patch

bump-minor:
	./scripts/bump-version.sh minor

bump-major:
	./scripts/bump-version.sh major
