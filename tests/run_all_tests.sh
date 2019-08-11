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

source "$(dirname $0)/test_util.sh"

for file in *_test.sh; do
  echo "Running tests in ${file} ..."
  bash "${file}" "autogen.sh" \
      && test_record_and_print_passed "${file}" \
      || test_record_and_print_failed "${file}"
  echo
done

echo "Overall summary:"
test_print_status
test_exit
