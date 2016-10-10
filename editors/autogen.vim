" Copyright 2016 Google Inc.
"
" Licensed under the Apache License, Version 2.0 (the "License");
" you may not use this file except in compliance with the License.
" You may obtain a copy of the License at
"
"      http://www.apache.org/licenses/LICENSE-2.0
"
" Unless required by applicable law or agreed to in writing, software
" distributed under the License is distributed on an "AS IS" BASIS,
" WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
" See the License for the specific language governing permissions and
" limitations under the License.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Generate boilerplate comments for new files.
function! GenerateBoilerplate(filename)
  " Modify this line as needed for your installation:
  " * specify the full path to autogen
  " * add flags as needed to set license, copyright holder, etc.
  let gen = system("../autogen -s " . a:filename)
  call append(0, split(gen, '\v\n'))
endfunction

" To use Autogen for all files (unknown file types silently ignored), use:
autocmd! BufNewFile * call GenerateBoilerplate(expand('%'))

" To use Autogen for specific file types, use this pattern instead:
" autocmd! BufNewFile *.py,*.sh call GenerateBoilerplate(expand('%'))

" Insert boilerplate comments at the top of current buffer.
function! InsertBoilerplate()
  call GenerateBoilerplate(bufname('%'))
endfunction

" Create a command "Autogen" for inserting text at top of current buffer:
command! Autogen call InsertBoilerplate()

" Alternatively, bind Ctrl-Shift-A to insert text at the top of the buffer:
nnoremap <C-A> :call InsertBoilerplate()<CR>
