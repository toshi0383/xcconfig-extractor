#
# filter-build-settings.awk
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
/\t\t\tbuildSettings/ {
    B="filter"
    print $0
}
!/\t\t\tbuildSettings/ {
    if (B != "filter") {
        print $0
    } else {
        if ($1 == "\t\t\t};") {
            B=""
            print $0
        }
    }
}
