# xcconfig-extractor
Extract xcodeproj's buildSettings into separated xcconfig files

# Why
I was so tired of refactoring every target's buildSettings into xcconfig manually.

# Requirements
- Xcode8+ is officially supported, but should work against older ones too.

# Usage

1. Make sure you star this repo
2. `cd your-app-directory/`
3. `/path-to/xcconfig-extractor/script/main.sh App.xcodeproj/project.pbxproj Configuration/`

This will create xcconfig files under `Configuration` dir. Configurations are safely(awkly) removed from `buildSettings` section of pbxproj.

# TODOs
- Filter Duplicated Lines
- What else?🤔

# License
MIT
