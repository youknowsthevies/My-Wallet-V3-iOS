#  scripts/format-code.sh
#
# Automatically formats the codebase by using swiftlint and swiftformat rules.
# 

set -ue
swiftlint --fix
swiftformat .