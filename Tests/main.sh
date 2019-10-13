#!/bin/bash
set -eo pipefail

basedir=$(cd $(dirname $0); pwd)
SRCROOT="$basedir/.."
cd $SRCROOT
swift build
XCCONFIG_EXTRACTOR=${PWD}/.build/x86_64-apple-macosx/debug/xcconfig-extractor
if [ ! -x $XCCONFIG_EXTRACTOR ];then
    echo Executable not found!: $XCCONFIG_EXTRACTOR
    exit 1
fi

set +e
for proj in $(find Fixtures -name "*xcodeproj" | grep -v archive)
do
    echo "=============================="
    echo $proj
    proj=${SRCROOT}/${proj}
    cd ${proj}/..
    tmpdir="${PWD}/tmp/xcconfig-extractor-configs"
    # testScheme=$(xcodebuild -list | grep -A1 Schemes | tail -1 | tr -d ' ') # TODO: Test against all scheme, creating shared ones on demand..
    xcodebuild -showBuildSettings 2> /dev/null > before
    COMMAND="${XCCONFIG_EXTRACTOR} ${proj} ${tmpdir}"
    echo $COMMAND
    $COMMAND && ls -l ${tmpdir}
    if [ $? -ne 0 ];then
        echo Execution Failed: $COMMAND
        FAILURES="$FAILURES $proj"
        STATUS=1
        continue
    fi
    xcodebuild -showBuildSettings 2> /dev/null > after
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
else
    cd $SRCROOT/Fixtures
    git reset --hard @
    git clean -df
fi
exit $STATUS
