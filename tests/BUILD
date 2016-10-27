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

sh_library(
    name = "test_util",
    srcs = [
        "test_util.sh",
    ],
    testonly = 1,
)

sh_test(
    name = "data_test",
    srcs = ["data_test.sh"],
    data = [
        "//:autogen_tool",
        "//licenses",
        "//testdata",
        ":test_util",
    ],
    size = "small",
    timeout = "short",
)

sh_test(
    name = "inplace_test",
    srcs = ["inplace_test.sh"],
    data = [
        "//:autogen_tool",
        ":test_util",
    ],
    size = "small",
    timeout = "short",
)

sh_test(
    name = "inplace_perm_test",
    srcs = ["inplace_perm_test.sh"],
    data = [
        "//:autogen_tool",
        ":test_util",
    ],
    size = "small",
    timeout = "short",
)

sh_test(
    name = "symlink_test",
    srcs = ["symlink_test.sh"],
    data = [
        "//:autogen_tool",
        ":test_util",
    ],
    size = "small",
    timeout = "short",
)
