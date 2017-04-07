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
PROJ=${1:?}
XCCONFIG_OUT_DIR=${2:-.}
$BASEDIR/extract-build-settings-to-xcconfigs.sh $PROJ $XCCONFIG_OUT_DIR
awk -F= -f $BASEDIR/filter-build-settings.awk $PROJ > a && mv a $PROJ

