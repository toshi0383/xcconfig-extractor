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
PBXPROJ=${1:?}
XCCONFIG_OUT_DIR=${2:?}
SED_FILE=$(cd $(dirname $0);pwd)/plbuddy-pretty.sed
HEADER_MESSAGE="// Generated using xcconfig-extractor by Toshihiro Suzuki - https://github.com/toshi0383/xcconfig-extractor"

print() {
    $plbuddy -c "Print ${1}" $PBXPROJ
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
        buildSettings=$(print objects:$configuration:buildSettings)
        configurationName=$(print objects:$configuration:name)
        FILEPREFIX=${targetName}-${configurationName}
        FILENAME="${XCCONFIG_OUT_DIR}/${FILEPREFIX}.xcconfig"
        echo "${HEADER_MESSAGE}" > "${FILENAME}"
        echo $buildSettings | sed -f $SED_FILE | sed '/^ *$/d' | sort >> "${FILENAME}"
    done
}

if [ ! -d "${XCCONFIG_OUT_DIR}" ];then
    mkdir "${XCCONFIG_OUT_DIR}"
fi

ROOTOBJ=`$plbuddy -c 'Print rootObject' ${PBXPROJ}`

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
    printBuildSettings $(print objects:$target:buildConfigurationList) $targetName
done
