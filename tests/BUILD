# Copyright 2016 Google LLC
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

load(":autogen_test.bzl", "autogen_test")

sh_library(
    name = "test_util",
    srcs = [
        "test_util.sh",
    ],
    testonly = 1,
)

autogen_test(
    name = "data",
    data = [
        "//licenses",
        ":testdata",
    ],
)

autogen_test(
    name = "inplace",
)

autogen_test(
    name = "inplace_perm",
)

autogen_test(
    name = "longflags",
    data = [
        ":testdata",
    ],
)

autogen_test(
    name = "symlink",
)
