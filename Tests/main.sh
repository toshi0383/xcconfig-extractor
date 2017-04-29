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
    tmpdir="${PWD}/tmp/xcconfig-extractor-configs"
    COMMAND="${XCCONFIG_EXTRACTOR} ${proj} ${tmpdir}"
    $COMMAND && ls -l ${tmpdir}
    if [ $? -ne 0 ];then
        echo Execution Failed: $COMMAND
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
