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
# Run tests to verify that in-place file modification works as intended.
# TODO(mbrukman): run over the entire test suite's set of file types / licenses.
#
################################################################################

set -eu

declare -r TEST_SRCDIR="$(dirname $0)/.."
declare -r TEST_TMPDIR="$(mktemp -d "/tmp/$(basename $0).XXXXXX")"

function cleanup() {
  rm -rf "${TEST_TMPDIR}"
}

trap cleanup EXIT INT TERM

declare -r RANDOM_DATA="$(date | md5)"

declare -i num_passed=0
declare -i num_failed=0

for ext in sh py rb hs; do
  actual_file="${TEST_TMPDIR}/actual.${ext}"
  expected_file="${TEST_TMPDIR}/expected.${ext}"

  # Generate the actual file and update it in-place.
  echo "${RANDOM_DATA}" > "${actual_file}"
  "${TEST_SRCDIR}/autogen.sh" -i "${actual_file}"

  # Generate the expected file using the usual means.
  "${TEST_SRCDIR}/autogen.sh" "${expected_file}" > "${expected_file}"
  echo "${RANDOM_DATA}" >> "${expected_file}"

  # Compare the two files.
  diff -u "${expected_file}" "${actual_file}"
  if [[ $? -eq 0 ]]; then
    num_passed=$((num_passed+1))
  else
    num_failed=$((num_failed+1))
  fi
done

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
