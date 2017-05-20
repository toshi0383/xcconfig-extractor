.PHONY = update bootstrap sourcery
SOURCERY ?= ./.build/debug/sourcery
PARAM = SWIFTPM_DEVELOPMENT=YES

update:
	$(PARAM) swift package update

bootstrap:
	$(PARAM) swift build
	$(PARAM) swift package generate-xcodeproj
	# todo: Add fixtures to xcodeproj
sourcery:
	$(SOURCERY) --templates Resources/SourceryTemplates/LinuxMain.stencil --sources Tests/ --output
