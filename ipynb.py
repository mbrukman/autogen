#!/usr/bin/python
#
# Copyright 2019 Google LLC
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

"""Outputs a Jupyter notebook stub with license header and metadata."""

import json
import sys


def main(argv):
    ipynb = {}
    cells = ipynb['cells'] = []

    # First cell has the license; read it from stdin.
    cell_license = {
        'cell_type': 'code',
        'execution_count': 0,
        'metadata': {
          'collapsed': False
        },
        'source': sys.stdin.readlines(),
        'outputs': [],
    }
    cells.append(cell_license)

    # Code starts on the next cell.
    cell_code = {
        'cell_type': 'code',
        'execution_count': 1,
        'metadata': {
          'collapsed': False
        },
        'source': [],
        'outputs': [],
    }
    cells.append(cell_code)

    # IPython/Jupyter configuration parameters.
    # TODO(mbrukman): how would a user configure these?
    ipynb['metadata'] = {
        'kernelspec': {
            'display_name': 'Python 3',
            'language': 'python',
            'name': 'python3'
        },
        'language_info': {
            'codemirror_mode': {
                'name': 'ipython',
                'version': 3
            },
            'file_extension': '.py',
            'mimetype': 'text/x-python',
            'name': 'python',
            'nbconvert_exporter': 'python',
            'pygments_lexer': 'ipython3',
            'version': '3.5.1'
        }
    }
    ipynb['nbformat'] = 4
    ipynb['nbformat_minor'] = 0

    print(json.dumps(ipynb, separators=(',', ': '), sort_keys=True, indent=2))


if __name__ == '__main__':
    main(sys.argv)
