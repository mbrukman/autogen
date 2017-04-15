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
# Ensure that long-form args are equivalent to short-form args.

# Ensure that the stdout and stderr files are equivalent for the base file
# (which uses short-form args only) to the set of files which use a mix of
# short- and long-form args or long-form args exclusively.
#
# That `autogen` actually produces the same output is checked by another test
# which ensures this for all files in `testdata/*`.

# If we're runnig via Bazel, find the source files via $TEST_SRCDIR;
# otherwise, default to dir of current file and search relative to that.
if [ -n "${TEST_SRCDIR:-}" ]; then
  declare -r SRCDIR="${TEST_SRCDIR}/${TEST_WORKSPACE}"
else
  declare -r SRCDIR="$(dirname $0)/.."
fi

declare -r TESTDATA="${SRCDIR}/tests/testdata"

declare -r BASE="${TESTDATA}/mit-acme-erl"
for mode in 1 2 1_2 ; do
  for ext in out err ; do
    diff "${BASE}.${ext}" "${BASE}-longflag_${mode}.${ext}"
  done
done
