# xcconfig-extractor
Refactor target's buildSettings into xcconfigs with one shot🚀

# Requirements
- Xcode8+ is officially supported, but should work against older ones too.

# Usage

```
$ xcconfig-extractor /path/to/Your.xcodeproj Configurations
```

This will create xcconfig files under `Configuration` dir. Configurations are removed from `buildSettings` section of pbxproj.

# Available Options
```
Options:
    --trim-duplicates [default: true] - Extract duplicated lines to common xcconfig files.
```

# TODOs
- Add Tests

# License
MIT
