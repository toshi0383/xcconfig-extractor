.PHONY = update build bootstrap sourcery
SOURCERY ?= ./.build/debug/sourcery
PARAM = SWIFTPM_DEVELOPMENT=YES

test:
	$(PARAM) swift test

update:
	$(PARAM) swift package update

build:
	$(PARAM) swift build

bootstrap: build
	$(PARAM) swift package generate-xcodeproj
	# todo: Add fixtures to xcodeproj
sourcery:
	$(SOURCERY) --templates Resources/SourceryTemplates/LinuxMain.stencil --sources Tests/ --output

# Needs toshi0383/scripts to be added to cmdshelf's remote
install:
	cmdshelf run "swiftpm/install.sh toshi0383/xcconfig-extractor"

release:
	rm -rf .build/release
	swift build -c release -Xswiftc -static-stdlib
	cmdshelf run "swiftpm/release.sh xcconfig-extractor"
