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

# Args:
#   $1: input file
#   $2: expected stdout
#   $3: expected stderr
function run_one_test() {
  local input="$1"
  local expected_out="$2"
  local expected_err="$3"

  local filebase="$(basename "${input%.in}")"
  local actual_out="$(mktemp "/tmp/${filebase}.out.XXXXXX")"
  local actual_err="$(mktemp "/tmp/${filebase}.err.XXXXXX")"

  # Run tests in a hermetic environment such that they don't break every year.
  bash -c "./autogen.sh -y 2014 $(cat "${input}")" > "${actual_out}" 2> "${actual_err}"

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

  echo -e "${status} ${filebase}"

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
  for input in testdata/*.in; do
    local expected_out="${input%.in}.out"
    local expected_err="${input%.in}.err"
    run_one_test "${input}" "${expected_out}" "${expected_err}"
  done
}

run_all_tests
