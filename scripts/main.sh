#
# main.sh
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

BASEDIR=$(cd $(dirname $0);pwd)
if [ $# -eq 0 ];then
    echo "Usage:"
    echo "    $(basename $0) [path to pbxproj] [output dir (defaults to '.')]"
    exit 1
elif [ "$1" == "--version" ];then
    echo "xcconfig-extractor 0.1.3"
    exit
fi
PBXPROJ=${1:?}
XCCONFIG_OUT_DIR=${2:-.}
$BASEDIR/extract-build-settings-to-xcconfigs.sh $PBXPROJ $XCCONFIG_OUT_DIR
awk -F= -f $BASEDIR/filter-build-settings.awk $PBXPROJ > a && mv a $PBXPROJ

