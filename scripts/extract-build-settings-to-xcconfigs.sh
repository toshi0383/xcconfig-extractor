#
# extract-build-settings-to-xcconfigs.sh
# xcconfig-extractor
#
# author:
#     Toshihiro Suzuki
#
# since:
#     4/7/2017
#
# copyright:
#     Copyright © 2017 Toshihiro Suzuki. All rights reserved.
#
#!/bin/bash
set -eo pipefail

plbuddy='/usr/libexec/PlistBuddy'
XCODEPROJ=${1:?}
XCCONFIG_OUT_DIR=${2:?}
SED_FILE=$(cd $(dirname $0);pwd)/plbuddy-pretty.sed

print() {
    $plbuddy -c "Print ${1}" $XCODEPROJ
}

printBuildSettings() {
    addr=${1:?}
    targetName=${2:?}
    ConfigurationObjects=$(print objects:$addr:buildConfigurations)
    for configuration in $ConfigurationObjects
    do
        if [ "${configuration}" == "Array" ];then
            continue
        fi
        if [ "${configuration}" == "{" ];then
            continue
        fi
        if [ "${configuration}" == "}" ];then
            continue
        fi
        configurationName=$(print objects:$configuration:name)
        buildSettings=$(print objects:$configuration:buildSettings)
        echo
        FILEPREFIX=${targetName}-${configurationName}
        echo "=== ${FILEPREFIX} ==="
        echo $buildSettings | sed -f $SED_FILE > $XCCONFIG_OUT_DIR/$FILEPREFIX.xcconfig
    done
}

if [ ! -f "${XCCONFIG_OUT_DIR}" ];then
    mkdir "${XCCONFIG_OUT_DIR}"
fi

ROOTOBJ=`$plbuddy -c 'Print rootObject' ${XCODEPROJ}/project.pbxproj`

echo "Base"
printBuildSettings $(print objects:$ROOTOBJ:buildConfigurationList) Base
targets=$(print objects:$ROOTOBJ:targets)
for target in $targets
do
    if [ "${target}" == "Array" ];then
        continue
    fi
    if [ "${target}" == "{" ];then
        continue
    fi
    if [ "${target}" == "}" ];then
        continue
    fi
    targetName=$(print objects:$target:name)
    echo "${targetName} (Native Target)"
    printBuildSettings $(print objects:$target:buildConfigurationList) $targetName
done
