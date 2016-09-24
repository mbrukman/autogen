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
# Utilities for writing tests.
#
################################################################################

# Create variables which can be used to get colorful output on terminals, and
# readable output when writing to a non-terminal, such as a file or pipe.
#
# Usage:
#   echo -e "${PASSED}: ... message ..."
if [ -t 1 ]; then
  declare -r PASSED="\033[0;32mPASSED\033[0m"
  declare -r FAILED="\033[0;31mFAILED\033[0m"
else
  declare -r PASSED="PASSED"
  declare -r FAILED="FAILED"
fi

declare -i num_passed_tests=0
declare -i num_failed_tests=0
declare -i num_total_tests=0
declare -i status_code=0

# Reset all counters to their initial values.
function test_reset() {
  num_passed_tests=0
  num_failed_tests=0
  num_total_tests=0
  status_code=0
}

# Record test as having passed.
function test_record_passed() {
  (( num_passed_tests += 1 ))
  (( num_total_tests += 1 ))
}

# Print a status message for a passed test.
#
# Args:
#   $1: (optional) additional status to print out
function test_print_passed() {
  local status_msg="${1:-}"
  if [ -n "${status_msg}" ]; then
    status_msg=": ${status_msg}"
  fi
  echo -e "${PASSED}${status_msg}"
}

# Record a test having passed and print a status message.
#
# Args:
#   $1: (optional) additional status to print out
function test_record_and_print_passed() {
  test_record_passed
  test_print_passed "${1:-}"
}

# Record test as having failed.
function test_record_failed() {
  (( num_failed_tests += 1 ))
  (( num_total_tests += 1 ))
  (( status_code = 1 ))
}

# Print a status message for a failed test.
#
# Args:
#   $1: (optional) additional status to print out
function test_print_failed() {
  local status_msg="${1:-}"
  if [ -n "${status_msg}" ]; then
    status_msg=": ${status_msg}"
  fi
  echo -e "${FAILED}${status_msg}"
}

# Record a test having failed and print a status message.
#
# Args:
#   $1: (optional) additional status to print out
function test_record_and_print_failed() {
  test_record_failed
  test_print_failed "${1:-}"
}

# Print overall status, including the counters.
function test_print_status() {
  echo -e "${PASSED}: ${num_passed_tests} / ${num_total_tests} tests"
  if [[ "${num_failed_tests}" -gt 0 ]]; then
    echo -e "${FAILED}: ${num_failed_tests} / ${num_total_tests} tests"
  fi
}

# Return current status code, to be used from a function.
function test_return() {
  return ${status_code}
}

# Exit script with current status code.
function test_exit() {
  exit ${status_code}
}
