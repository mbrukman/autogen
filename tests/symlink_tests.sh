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

declare -r AUTOGEN="${SRCDIR}/autogen.sh"

# We need to get the absolute path to $AUTOGEN because otherwise, relative paths
# from absolute paths in $TMPDIR will not work.

declare -r AUTOGEN_DIR="$(cd $(dirname "${AUTOGEN}"); pwd -P)"
declare -r AUTOGEN_FULL_PATH="${AUTOGEN_DIR}/$(basename "${AUTOGEN}")"

declare -ar AUTOGEN_SYMLINKS=(
    "${TMPDIR}/autogen0.sh"
    "${TMPDIR}/autogen1.sh"
    "${TMPDIR}/autogen2.sh"
)

ln -s "${AUTOGEN_FULL_PATH}"   "${AUTOGEN_SYMLINKS[0]}"
ln -s "${AUTOGEN_SYMLINKS[0]}" "${AUTOGEN_SYMLINKS[1]}"
ln -s "${AUTOGEN_SYMLINKS[1]}" "${AUTOGEN_SYMLINKS[2]}"

declare -i status_code=0

for ext in hs ml pl rb py sh; do
  expected_file="${TMPDIR}/expected.${ext}"
  touch "${expected_file}"
  "${AUTOGEN}" -i "${expected_file}"

  for autogen in ${AUTOGEN_SYMLINKS[@]}; do
    actual_file="${TMPDIR}/$(basename $autogen).actual.${ext}"
    touch "${actual_file}"
    "${autogen}" -i "${actual_file}"
    if ! diff -u "${expected_file}" "${actual_file}" ; then
      status_code=1
    fi
  done
done

if [[ ${status_code} -eq 0 ]]; then
  if [ -t 1 ]; then
    declare -r PASSED="\033[0;32mPASSED\033[0m"
  else
    declare -r PASSED="PASSED"
  fi
  echo -e "${PASSED}"
else
  if [ -t 1 ]; then
    declare -r FAILED="\033[0;31mFAILED\033[0m"
  else
    declare -r FAILED="FAILED"
  fi
  echo -e "${FAILED}"
fi

exit ${status_code}
