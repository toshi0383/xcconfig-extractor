.PHONY = start-daemons
SOURCERY ?= ./.build/debug/sourcery

bootstrap:
	SWIFTPM_DEVELOPMENT_Pbxproj=YES swift build
	swift package generate-xcodeproj
	# todo: Add fixtures to xcodeproj
start-daemons:
	$(SOURCERY) --templates Resources/SourceryTemplates/LinuxMain.stencil --sources Tests/ --output Tests/LinuxMain.swift --watch
