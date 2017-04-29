#!/bin/bash
set -eo pipefail
basedir=$(cd $(dirname $0); pwd)
cd $basedir/..
swift build
XCCONFIG_EXTRACTOR=${PWD}/.build/debug/xcconfig-extractor
if [ ! -x $XCCONFIG_EXTRACTOR ];then
    echo Executable not found!: $XCCONFIG_EXTRACTOR
    exit 1
fi

set +e
dir=${PWD}
for proj in $(find Fixtures -name "*xcodeproj")
do
    proj=${dir}/${proj}
    cd ${proj}/..
    before=$(xcodebuild -showBuildSettings)
    COMMAND="${XCCONFIG_EXTRACTOR} ${proj} ${dir}/xcconfig-extractor-configs"
    $COMMAND
    if [ $? -ne 0 ];then
        echo Execution Failed: $COMMAND
        FAILURES="$FAILURES $proj"
        STATUS=1
        continue
    fi
    after=$(xcodebuild -showBuildSettings)
    if [ "$before" != "$after" ];then
        echo xcodebuild -showBuildSettings result did not match!
        FAILURES="$FAILURES $proj"
        STATUS=1
    fi
done

if [ $STATUS ];then
    echo TEST FAILED
    echo $FAILURES
fi
exit $STATUS
