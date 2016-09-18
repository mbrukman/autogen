#!/bin/bash -eu
#
# Copyright 2016 Google Inc.
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
# Test to ensure that permissions are kept after using `autogen.sh -i`.
#
################################################################################

set -eu

# If we're runnig via Bazel, find the source files via $TEST_SRCDIR;
# otherwise, default to dir of current file and search relative to that.
#
# Also, if we're running via Bazel, it already defines $TEST_TMPDIR which we
# don't have to clean up; otherwise, create our own dir and schedule cleanup.
if [ -n "${TEST_SRCDIR:-}" ]; then
  declare -r SRCDIR="${TEST_SRCDIR}/${TEST_WORKSPACE}"
  declare -r TMPDIR="${TEST_TMPDIR}"
else
  declare -r SRCDIR="$(dirname $0)/.."
  declare -r TMPDIR="$(mktemp -d /tmp/$(basename $0).XXXXXX)"
  function cleanup() {
    rm -rf "${TMPDIR}"
  }
  trap cleanup EXIT INT TERM
fi

declare -i num_passed=0
declare -i num_failed=0

declare -r AUTOGEN="${SRCDIR}/autogen.sh"

# Pair-wise associated test cases of files and permissions.
declare -ar FILES=(file.sh file.py)
declare -ar PERM=(642 755)

# Get the file permissions in octal for the given file.
# Args:
#   $1: path to file
function getFilePermissions() {
  local -r file="$1"
  if [[ "$(uname -s)" == "Darwin" ]]; then
    stat -f '%A' "${file}"
  else
    stat -c '%a' "${file}"
  fi
}

function runTests() {
  for i in "${!FILES[@]}"; do
    local file="${FILES[i]}"
    local file_path="${TMPDIR}/${file}"
    local perm="${PERM[i]}"

    touch "${file_path}"
    chmod "${perm}" "${file_path}"
    "${AUTOGEN}" -i "${file_path}"

    # Verify whether new permissions match the original file permissions.
    local new_perm="$(getFilePermissions "${file_path}")"
    if [[ "${perm}" == "${new_perm}" ]]; then
      num_passed=$((num_passed+1))
    else
      echo "Permissions mismatch for: ${file}" >&2
      echo "  expected: ${perm}; actual: ${new_perm}" >&2
      num_failed=$((num_failed+1))
    fi
  done
}

runTests

declare -ir NUM_TOTAL=$((num_passed + num_failed))

if [[ ${num_passed} -gt 0 ]]; then
  if [ -t 1 ]; then
    declare -r PASSED="\033[0;32mPASSED\033[0m"
  else
    declare -r PASSED="PASSED"
  fi
  echo -e "${PASSED}: ${num_passed} / ${NUM_TOTAL}"
fi

if [[ ${num_failed} -gt 0 ]]; then
  if [ -t 1 ]; then
    declare -r FAILED="\033[0;31mFAILED\033[0m"
  else
    declare -r FAILED="FAILED"
  fi
  echo -e "${FAILED}: ${num_failed} / ${NUM_TOTAL}"
  declare -r STATUS_CODE=1
else
  declare -r STATUS_CODE=0
fi

exit ${STATUS_CODE}
