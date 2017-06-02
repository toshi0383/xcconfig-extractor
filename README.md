# xcconfig-extractor
Refactor target's buildSettings into xcconfigs with one shot🚀

[![Build Status](https://www.bitrise.io/app/9823e204182ddb41.svg?token=hychUqBHuvhZfzLLl2Ehiw&branch=master)](https://www.bitrise.io/app/9823e204182ddb41)

# Requirements
- Xcode8+ is officially supported, but should work against older ones too.

# Usage

```bash
$ xcconfig-extractor /path/to/Your.xcodeproj Configurations
```

This will create xcconfig files under `Configuration` dir. Configurations are removed from `buildSettings` section of pbxproj.

Generated xcconfigs are added to your project automatically. ✏️

![xcode's general tab](images/xcode-configuration-sample.png)

# Available Options
```bash
Options:
    --no-trim-duplicates [default: false] - Don't extract duplicated lines to common xcconfig files, simply map each buildSettings to one file.
    --no-edit-pbxproj [default: false] - Do not modify pbxproj at all.
    --include-existing [default: true] - `#include` already configured xcconfigs.
    --no-set-configurations [default: false] - Do not set xcconfig(baseConfigurationReference) in pbxproj. Ignored if `--no-edit-pbxproj` is true.
```

# Build Setting Validation
⚠️ ***Waring*** ⚠️

You should check app's Build Settings hasn't been affected by applying this tool.
xcconfig does not allow any `$(inherited)` from `#include`ing xcconfigs. (See: https://github.com/toshi0383/xcconfig-extractor/pull/8#issuecomment-298234943) So if you have any existing xcconfig configured on your project, it might cause problems.

Recommended way to check Build Settings is to run command like below. Make sure outputs does not change between before and after.
```bash
$ xcodebuild -showBuildSettings -configuration Release > before
$ # apply xcconfig-extractor
$ xcodebuild -showBuildSettings -configuration Release > after
$ diff before after # should prints nothing!
```

If output changed, you should manually fix it. (e.g. by adding missing variable to target's(top level) xcconfig.)  
[This article](https://pewpewthespells.com/blog/xcconfig_guide.html#BuildSettingInheritance) is helpful to understand how inheritance works.

# Install
## Build from source
- Clone this repo and run `swift build -c release`.  
- Executable will be created at `.build/release/xcconfig-extractor`.

# TODOs
- Add More Tests

# License
MIT
