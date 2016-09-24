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

source "$(dirname $0)/test_util.sh"

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

declare -r RANDOM_DATA="$(date)"

for ext in sh py rb hs; do
  actual_file="${TMPDIR}/actual.${ext}"
  expected_file="${TMPDIR}/expected.${ext}"

  # Generate the actual file and update it in-place.
  echo "${RANDOM_DATA}" > "${actual_file}"
  "${SRCDIR}/autogen.sh" -i "${actual_file}"

  # Generate the expected file using the usual means.
  "${SRCDIR}/autogen.sh" "${expected_file}" > "${expected_file}"
  echo "${RANDOM_DATA}" >> "${expected_file}"

  # Compare the two files.
  diff -u "${expected_file}" "${actual_file}" \
      && test_record_passed \
      || test_record_failed
done

test_print_status
test_exit
