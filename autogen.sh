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

declare -r AUTOGEN="$(dirname $0)"

LICENSE="${AUTOGEN}/licenses/apache-2.0.txt"
COPYRIGHT_HOLDER="Google Inc."
YEAR="${YEAR:-$(date +%Y)}"

function printLicenseWithYear() {
  cat "${LICENSE}" \
    | sed "s/%YEAR%/${YEAR}/" \
    | sed "s/%COPYRIGHT_HOLDER%/${COPYRIGHT_HOLDER}/"
}

function printLicenseNonHashComment() {
  printLicenseWithYear | sed -E "s#^#$1 #;s/ +$//"
}

function printLicenseHashComment() {
  printLicenseWithYear | sed -E "s/^/# /;s/ +$//"
}

readonly TODO_COMMENT="TODO: High-level file comment."
function printFileCommentTemplate() {
  local comment=$1
  # Fit into 80 cols: repeat enough times, depending on our comment width.
  local repeat=$(echo 80 / $(echo -n ${comment} | wc -c) | bc)
  echo $comment
  perl -e "print \"$comment\" x $repeat . \"\n\""
  echo $comment
  echo "$comment ${TODO_COMMENT}"
}

while getopts c:l:y: opt ; do
  case "${opt}" in
    c)
      COPYRIGHT_HOLDER="${OPTARG}"
      ;;

    l)
      case "${OPTARG}" in
        apache)
          LICENSE="${AUTOGEN}/licenses/apache-2.0.txt"
          ;;
        bsd2|bsd-2)
          LICENSE="${AUTOGEN}/licenses/bsd-2-clause.txt"
          ;;
        bsd3|bsd-3)
          LICENSE="${AUTOGEN}/licenses/bsd-3-clause.txt"
          ;;
        bsd4|bsd-4)
          LICENSE="${AUTOGEN}/licenses/bsd-4-clause.txt"
          ;;
        gpl2|gpl-2)
          LICENSE="${AUTOGEN}/licenses/gpl-2.txt"
          ;;
        lgpl|lgpl2|lgpl-2|lgpl2.1|lgpl-2.1)
          LICENSE="${AUTOGEN}/licenses/lgpl-2.1.txt"
          ;;
        mit)
          LICENSE="${AUTOGEN}/licenses/mit.txt"
          ;;
        *)
          echo "Invalid license selected: ${OPTARG}" >&2
          exit 1
      esac
      ;;
    y)
      YEAR="${OPTARG}"
      ;;
  esac
done

shift $((OPTIND - 1))

if [[ $# -eq 0 ]]; then
  echo "\
Syntax: $0 [options] <filename>

Options:
  -c [copyright holder]
  -l [license]
  -y [year]

Licenses:
  apache:       Apache 2.0
  bsd2:         BSD, 2-clause, aka Simplified/FreeBSD
  bsd3:         BSD, 3-clause, aka Revised/New/Modified
  bsd4:         BSD, 4-clause, aka Original
  gpl2:         GPL 2
  lgpl2.1:      LGPL 2.1 (aliases: lgpl, lgpl2)
  mit:          MIT" >&2
  exit 1
fi

case "$1" in

  *.c | *.h)
    echo "/*"
    printLicenseNonHashComment " *"
    echo " */"
    echo "/* ${TODO_COMMENT} */"
    ;;

  *.cc | *.cpp | *.go | *.hpp | *.java | *.js | *.proto | *.scala | *.rs)
    printLicenseNonHashComment "//"
    printFileCommentTemplate "//"
    ;;

  *.el)
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

  *.lisp)
    printLicenseNonHashComment ";;"
    printFileCommentTemplate ";;"
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

  *_test.py)
    # Get the common python header without the test additions.
    readonly BASE_PY=$(echo $1 | sed 's/_test//')
    $0 ${BASE_PY}
    echo
    echo "import unittest"
    # Maybe import the package that this is intended to test.
    if [ -e ${BASE_PY} ]; then
      echo "import $(echo ${BASE_PY} | sed 's/\.py$//')"
    fi
    ;;

  *.py)
    echo "#!/usr/bin/python"
    echo "#"
    printLicenseHashComment
    printFileCommentTemplate "#"
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

  Dockerfile | Makefile | Makefile.* | Rakefile | Vagrantfile)
    printLicenseHashComment
    printFileCommentTemplate "#"
    ;;

  *)
    echo "File type not recognized: $1" >&2
    exit 1
    ;;

esac
