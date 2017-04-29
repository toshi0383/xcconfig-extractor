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
    --no-trim-duplicates [default: false] - Don't extract duplicated lines to common xcconfig files, simply map each buildSettings to one file.
    --no-edit-pbxproj [default: false] - Do not modify pbxproj.
```

# TODOs
- Add Tests

# License
MIT
