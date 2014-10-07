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

LICENSE="$(dirname $0)/apache-2.0-header.txt"

function printLicenseWithYear() {
  cat ${LICENSE} | sed "s/YEAR/$(date +%Y)/"
}

function printLicenseNonHashComment() {
  printLicenseWithYear | sed "s#^#$1 #;s/ \+$//"
}

function printLicenseHashComment() {
  printLicenseWithYear | sed "s/^/# /;s/ \+$//"
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

if [[ $# -eq 0 ]]; then
  echo "Syntax: $0 [filename]"
  exit
fi

case $1 in

  *.c | *.h)
    echo "/*"
    printLicenseNonHashComment " *"
    echo " */"
    echo "/* ${TODO_COMMENT} */"
    ;;

  *.cpp | *.hpp | *.java | *.js | *.proto | *.scala)
    printLicenseNonHashComment "//"
    printFileCommentTemplate "//"
    ;;

  *.hs)
    printLicenseNonHashComment "--"
    printFileCommentTemplate "--"
    ;;

  *.lisp)
    printLicenseNonHashComment ";;"
    printFileCommentTemplate ";;"
    ;;

  *.ml | *.sml)
    echo "(*"
    printLicenseNonHashComment " *"
    echo " *)"
    echo "(* ${TODO_COMMENT} *)"
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

  *.py)
    echo "#!/usr/bin/python"
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

  Makefile | Makefile.*)
    printLicenseHashComment
    printFileCommentTemplate "#"
    ;;

  *)
    echo "File extension not recognized."
    ;;

esac
