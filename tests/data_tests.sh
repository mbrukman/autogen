#!/bin/bash -u
#
# Copyright 2014 Google Inc.
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
# Runs all tests defined in the "testdata" dir.
#
################################################################################

# If we're runnig via Bazel, find the source files via $TEST_SRCDIR;
# otherwise, default to dir of current file and search relative to that.
if [ -n "${TEST_SRCDIR:-}" ]; then
  declare -r SRCDIR="${TEST_SRCDIR}/${TEST_WORKSPACE}"
else
  declare -r SRCDIR="$(dirname $0)/.."
fi

# Set temp directory from environment, if running under Bazel.
declare -r TMPDIR="${TEST_TMPDIR:-${TEMPDIR:-${TMPDIR:-/tmp}}}"

# Set verbosity level; 0=mostly silent, higher numbers for more output.
declare -r VERBOSE="${VERBOSE:-0}"

# Args:
#   $1: input file
#   $2: expected stdout
#   $3: expected stderr
function run_one_test() {
  local input="$1"
  local expected_out="$2"
  local expected_err="$3"

  local filebase="$(basename "${input%.in}")"
  local actual_out="$(mktemp "${TMPDIR}/${filebase}.out.XXXXXX")"
  local actual_err="$(mktemp "${TMPDIR}/${filebase}.err.XXXXXX")"

  # Run tests in a hermetic environment such that they don't break every year.
  bash -c "${SRCDIR}/autogen.sh -y 2014 $(cat "${input}")" > "${actual_out}" 2> "${actual_err}"

  local -i stdout=1
  local -i stderr=1

  if ! `diff "${expected_out}" "${actual_out}" > /dev/null 2>&1` ; then
    stdout=0
  fi

  if ! `diff "${expected_err}" "${actual_err}" > /dev/null 2>&1` ; then
    stderr=0
  fi

  local status_code=0
  if [ -t 1 ]; then
    local status="\033[0;32mPASSED\033[0m"
  else
    local status="PASSED"
  fi

  if [ ${stdout} -eq 0 ] || [ ${stderr} -eq 0 ]; then
    status_code=1
    if [ -t 1 ]; then
      status="\033[0;31mFAILED\033[0m"
    else
      status="FAILED"
    fi
  fi

  if [ "${VERBOSE}" -ge 1 ] || [ ${status_code} -ne 0 ]; then
    echo -e "${status} ${filebase}"
  fi

  if [ ${stdout} -eq 0 ]; then
    echo "  Differences in stdout; compare via: diff -u ${expected_out} ${actual_out}"
  else
    rm -f "${actual_out}"
  fi

  if [ ${stderr} -eq 0 ]; then
    echo "  Differences in stderr; compare via: diff -u ${expected_err} ${actual_err}"
  else
    rm -f "${actual_err}"
  fi

  return ${status_code}
}

function run_all_tests() {
  local num_passed_tests=0
  local num_failed_tests=0
  local num_total_tests=0
  local overall_status=0

  local -r num_files="$(ls -1 ${SRCDIR}/testdata/*.in | wc -l)"
  if [[ ${num_files} -eq 0 ]]; then
    echo "No files found in ${SRCDIR}/testdata; exiting." >&2
    exit 1
  fi

  for input in ${SRCDIR}/testdata/*.in; do
    local expected_out="${input%.in}.out"
    local expected_err="${input%.in}.err"
    run_one_test "${input}" "${expected_out}" "${expected_err}"
    local test_status=$?
    (( num_total_tests += 1 ))
    if [[ ${test_status} -eq 0 ]]; then
      (( num_passed_tests += 1 ))
    else
      (( num_failed_tests += 1 ))
      overall_status=${test_status}
    fi
  done

  if [ -t 1 ]; then
    local passed="\033[0;32mPASSED\033[0m"
    local failed="\033[0;31mFAILED\033[0m"
  else
    local passed="PASSED"
    local failed="FAILED"
  fi

  echo -e "${passed} ${num_passed_tests} / ${num_total_tests} tests"
  if [[ "${num_failed_tests}" -gt 0 ]]; then
    echo -e "${failed} ${num_failed_tests} / ${num_total_tests} tests"
  fi

  return ${overall_status}
}

run_all_tests
