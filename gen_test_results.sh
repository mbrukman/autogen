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
# (Re-)generates the expected stdout and stderr outputs for tests.
#
################################################################################

function gen_test_data() {
  for input in testdata/*.in; do
    local expected_out="${input%.in}.out"
    local expected_err="${input%.in}.err"

    # Run tests in a hermetic environment such that they don't break every year.
    env YEAR=2014 \
      bash -c "./autogen.sh $(cat "${input}")" > "${expected_out}" 2> "${expected_err}"
  done
}

gen_test_data
