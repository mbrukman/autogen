#!/bin/bash -eu
#
# Copyright 2009 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################
#
# Outputs a header file comment, with the appropriate comments based on the
# language, as deduced from the extension of the file.
#
# Sample usage:
#   autogen.sh file.js
#   autogen.sh file.py

# If we're runnig via Bazel, find the source files via $TEST_SRCDIR;
# otherwise, default to dir of current file and search relative to that.
if [ -n "${TEST_SRCDIR:-}" ]; then
  declare -r SRCDIR="${TEST_SRCDIR}/${TEST_WORKSPACE}"
else
  # If the file pointing to this script is a symlink, we need to resolve it.
  # However, it may be pointing to another symlink, so we have to resolve the
  # entire chain to find the root, and find the licenses relative to the
  # directory that holds the file.
  #
  # Unfortunately, different tools are available on different OSes, and even
  # when the same tool is available, it works differently on different systems.
  if which realpath > /dev/null 2>&1 ; then
    declare -r SRCDIR="$(dirname $(realpath $0))"
  elif which greadlink > /dev/null 2>&1 ; then
    # On OS X, Homebrew provides `greadlink` which is GNU readlink that works as
    # it does on Linux. To get it, run: `brew install coreutils`.
    declare -r SRCDIR="$(dirname $(greadlink -f $0))"
  elif which readlink > /dev/null 2>&1 ; then
    # On Linux, `readlink -f` can be used to resolve symlinks to the final
    # destination. However, on OS X, `readlink` does not have a `-f` flag.
    if [[ "$(uname -s)" == "Darwin" ]]; then
      symlink_target="${0}"
      while [ -h "${symlink_target}" ] || [ -L "${symlink_target}" ]; do
        next_symlink_target="$(readlink "${symlink_target}" || true)"
        if [ -z "${next_symlink_target}" ] || [[ "${symlink_target}" == "${next_symlink_target}" ]]; then
          break
        fi
        symlink_target="${next_symlink_target}"
      done
      declare -r SRCDIR="$(dirname "${symlink_target}")"
      # Cleanup the variable namespace.
      unset symlink_target
      unset next_symlink_target
    else
      declare -r SRCDIR="$(dirname $(readlink -f $0))"
    fi
  else
    declare -r SRCDIR="$(dirname $0)"
  fi
fi

# Path to license file will be computed from LICENSE_NAME below.
LICENSE_NAME="apache"
LICENSE_FILE=""
COPYRIGHT_HOLDER="Google Inc."
YEAR="${YEAR:-$(date +%Y)}"
MODIFY_FILE_INPLACE=0
SILENT=0

function printLicenseWithYear() {
  cat "${LICENSE_FILE}" \
    | sed "s/%YEAR%/${YEAR}/" \
    | sed "s/%COPYRIGHT_HOLDER%/${COPYRIGHT_HOLDER}/"
}

function printLicenseNonHashComment() {
  printLicenseWithYear | sed -E "s#^#$1 #;s/ +$//"
}

function printLicenseHashComment() {
  printLicenseWithYear | sed -E "s/^/# /;s/ +$//"
}

# Prepend piped-in text to a file in-place.
#
# Args:
#   $1: filename to modify
function prependToFileInPlace() {
  local -r file="${1}"

  # Prepend stdin to the beginning of the file using `ed`.
  cat | ed -s "${file}" << EOF
0a
$(cat -)
.
w
EOF
}

readonly TODO_COMMENT="TODO: High-level file comment."
function printFileCommentTemplate() {
  local comment=$1
  # Fit into 80 cols: repeat enough times, depending on our comment width.
  local repeat=$(echo 80 / $(echo -n "${comment}" | wc -c) | bc)
  echo $comment
  perl -e "print \"$comment\" x $repeat . \"\n\""
  echo $comment
  echo "$comment ${TODO_COMMENT}"
}

while getopts c:il:sy: opt ; do
  case "${opt}" in
    c)
      COPYRIGHT_HOLDER="${OPTARG}"
      ;;

    i)
      MODIFY_FILE_INPLACE=1
      ;;

    l)
      LICENSE_NAME="${OPTARG}"
      ;;

    s)
      SILENT=1
      ;;

    y)
      YEAR="${OPTARG}"
      ;;
  esac
done

shift $((OPTIND - 1))

# Compute license file path given the license name.
case "${LICENSE_NAME}" in
  apache)
    LICENSE_FILE="${SRCDIR}/licenses/apache-2.0.txt"
    ;;
  bsd2|bsd-2)
    LICENSE_FILE="${SRCDIR}/licenses/bsd-2-clause.txt"
    ;;
  bsd3|bsd-3)
    LICENSE_FILE="${SRCDIR}/licenses/bsd-3-clause.txt"
    ;;
  bsd4|bsd-4)
    LICENSE_FILE="${SRCDIR}/licenses/bsd-4-clause.txt"
    ;;
  gpl2|gpl-2)
    LICENSE_FILE="${SRCDIR}/licenses/gpl-2.txt"
    ;;
  gpl3|gpl-3)
    LICENSE_FILE="${SRCDIR}/licenses/gpl-3.txt"
    ;;
  lgpl|lgpl2|lgpl-2|lgpl2.1|lgpl-2.1)
    LICENSE_FILE="${SRCDIR}/licenses/lgpl-2.1.txt"
    ;;
  mit)
    LICENSE_FILE="${SRCDIR}/licenses/mit.txt"
    ;;
  *)
    echo "Invalid license selected: ${LICENSE_NAME}" >&2
    exit 1
esac

if [[ $# -eq 0 ]]; then
  cat >&2 << EOF
Syntax: $0 [options] <filename>

Options:
  -c [copyright holder]    set copyright holder (default: "${COPYRIGHT_HOLDER}")
  -i                       modify the given file in-place
  -l [license]             choose the license (default: "${LICENSE_NAME}")
  -s                       silent: no error output for unknown file types
  -y [year]                choose the year (default: ${YEAR})

Licenses:
  apache:       Apache 2.0
  bsd2:         BSD, 2-clause, aka Simplified/FreeBSD
  bsd3:         BSD, 3-clause, aka Revised/New/Modified
  bsd4:         BSD, 4-clause, aka Original
  gpl2:         GPL 2
  gpl3:         GPL 3
  lgpl2.1:      LGPL 2.1 (aliases: lgpl, lgpl2)
  mit:          MIT
EOF
  exit 1
fi

declare -r FILE="$1"

# Re-run this script with all the same flags, minus the in-place flag.
if [[ "${MODIFY_FILE_INPLACE}" -eq 1 ]]; then
  $0 \
    -c "${COPYRIGHT_HOLDER}" \
    -l "${LICENSE_NAME}" \
    -y "${YEAR}" \
    "${FILE}" \
    | prependToFileInPlace "${FILE}"
  exit $?
fi

case "${FILE}" in

  # TODO(mbrukman): in some projects, *.h are actually C++ files where users
  # want to use C++ style "//" comments. How can we handle this flexibility?
  *.c | *.h | *.css)
    echo "/*"
    printLicenseNonHashComment " *"
    echo " */"
    echo "/* ${TODO_COMMENT} */"
    ;;

  *.cc | *.cpp | *.cs | *.go | *.hh | *.hpp | *.java | *.js | *.m | *.mm | *.proto | *.rs | *.scala | *.swift)
    printLicenseNonHashComment "//"
    printFileCommentTemplate "//"
    ;;

  *.el | *.lisp)
    printLicenseNonHashComment ";;"
    printFileCommentTemplate ";;"
    ;;

  *.erl)
    printLicenseNonHashComment "%"
    printFileCommentTemplate "%"
    ;;

  *.hs)
    printLicenseNonHashComment "--"
    printFileCommentTemplate "--"
    ;;

  *.html | *.xml)
    echo "<!--"
    printLicenseNonHashComment " "
    echo "-->"
    ;;

  *.jsonnet)
    printLicenseHashComment
    printFileCommentTemplate "#"
    ;;

  *.md | *.markdown)
    printLicenseWithYear
    ;;

  *.ml | *.sml)
    echo "(*"
    printLicenseNonHashComment " *"
    echo " *)"
    echo "(* ${TODO_COMMENT} *)"
    ;;

  *.php)
    # We can't make PHP scripts locally executable with the #!/usr/bin/php line
    # because PHP comments only have meaning inside the <?php ... ?> which
    # means the first line cannot be simply #!/usr/bin/php to let the shell
    # know how to run these scripts.  Instead, we'll have to run them via
    # "php script.php" .
    #
    # Note: PHP accepts C, C++, and shell-style comments.
    echo "<?php"
    printLicenseNonHashComment "//"
    printFileCommentTemplate "//"
    echo
    # E_STRICT was added in PHP 5.0 and became included in E_ALL in PHP 6.0 .
    echo "error_reporting(E_ALL | E_STRICT);"
    echo "?>"
    ;;

  *.pl)
    echo "#!/usr/bin/perl"
    echo "#"
    printLicenseHashComment
    printFileCommentTemplate "#"
    echo
    echo "use strict;"
    ;;

  test_*.py | *_test.py)
    echo "#!/usr/bin/python"
    echo "#"
    printLicenseHashComment
    cat <<EOF

"""${TODO_COMMENT}"""
EOF
    BASE_PY="${1/#test_/}"
    BASE_PY="${BASE_PY/_test/}"
    echo
    echo "import unittest"
    # Maybe import the package that this is intended to test.
    if [ -e "${BASE_PY}" ]; then
      echo "import ${BASE_PY/%.py/}"
    fi
    # Add basic bootstrap code.
    cat <<EOF


class FooTest(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def testBar(self):
        pass


if __name__ == '__main__':
    unittest.main()
EOF
    ;;

  *.py)
    echo "#!/usr/bin/python"
    echo "#"
    printLicenseHashComment
    cat <<EOF

"""${TODO_COMMENT}"""

import sys


def main(argv):
    pass


if __name__ == '__main__':
    main(sys.argv)
EOF
    ;;

  *.rb)
    echo "#!/usr/bin/ruby"
    echo "#"
    printLicenseHashComment
    printFileCommentTemplate "#"
    ;;

  *.sh)
    echo "#!/bin/bash -eu"
    echo "#"
    printLicenseHashComment
    printFileCommentTemplate "#"
    ;;

  *.txt | README)
    printLicenseWithYear
    ;;

  *.vim)
    printLicenseNonHashComment \"
    # Handle the file header locally; hard to pass a double-quote to function
    # which wants to double-quote its arguments.
    echo "\""
    perl -e "print '\"' x 80 . \"\n\""
    echo "\""
    echo "\" ${TODO_COMMENT}"
    ;;

  *.yaml | *.yml)
    printLicenseHashComment
    printFileCommentTemplate "#"
    ;;

  BUILD | Dockerfile | Makefile | Makefile.* | Rakefile | Vagrantfile)
    printLicenseHashComment
    printFileCommentTemplate "#"
    ;;

  *)
    if [ ${SILENT} -eq 0 ] ; then
      echo "File type not recognized: ${FILE}" >&2
      exit 1
    fi
    ;;

esac
