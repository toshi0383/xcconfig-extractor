# xcconfig-extractor
Extract xcodeproj's buildSettings into separated xcconfig files

# Why
I was so tired of refactoring every target's buildSettings into xcconfig manually.

# Requirements
- Xcode8+ is officially supported, but should work against older ones too.

# Usage
```
cd your-app-directory/
/path-to/xcconfig-extractor/script/main.sh App.xcodeproj/project.pbxproj Configuration/
```
This will create xcconfig files under `Configuration` dir. Configurations are safely(awkly) removed from `buildSettings` section of pbxproj.

# TODOs
- Add `#include`ing Base configs.
- What else?🤔

# License
MIT
