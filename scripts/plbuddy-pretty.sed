#
# plbuddy-pretty.sed
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
s/Dict {//; s/}//
s/\(\ \)\([A-Z_]\{2,\} = \)/\
\2/g