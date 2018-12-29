#!/bin/bash
set -eo pipefail

basedir=$(cd $(dirname $0); pwd)
cd $basedir/..
make build
XCCONFIG_EXTRACTOR=${PWD}/.build/x86_64-apple-macosx10.10/debug/xcconfig-extractor
if [ ! -x $XCCONFIG_EXTRACTOR ];then
    echo Executable not found!: $XCCONFIG_EXTRACTOR
    exit 1
fi

set +e
dir=${PWD}
for proj in $(find Fixtures -name "*xcodeproj")
do
    echo "=============================="
    echo $proj
    proj=${dir}/${proj}
    cd ${proj}/..
    tmpdir="${PWD}/tmp/xcconfig-extractor-configs"
    # testScheme=$(xcodebuild -list | grep -A1 Schemes | tail -1 | tr -d ' ') # TODO: Test against all scheme, creating shared ones on demand..
    xcodebuild -showBuildSettings > before
    COMMAND="${XCCONFIG_EXTRACTOR} ${proj} ${tmpdir}"
    echo $COMMAND
    $COMMAND && ls -l ${tmpdir}
    if [ $? -ne 0 ];then
        echo Execution Failed: $COMMAND
        FAILURES="$FAILURES $proj"
        STATUS=1
        continue
    fi
    xcodebuild -showBuildSettings > after
    diff before after
    if [ $? -ne 0 ];then
        echo "xcodebuild -showBuildSettings between before and after execution differ."
        FAILURES="$FAILURES $proj"
        STATUS=1
        continue
    fi
done

if [ $STATUS ];then
    echo TEST FAILED
    echo Failing Tests: $FAILURES
fi
exit $STATUS
