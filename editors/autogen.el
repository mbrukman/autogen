;; Copyright 2016 Google LLC
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;      http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

(defun autogen-text-for-buffer ()
  "Return the output of autogen on the current buffer name."
  (interactive)
  (let ((filename (buffer-file-name)))
    (with-output-to-string
      ; Note: modify path according to your installation of Autogen.
      (call-process (concat default-directory "../autogen")  ; program
                    nil                                      ; infile
                    (list standard-output nil)               ; buffer
                    nil                                      ; display
                    ; Add any other optional arguments here, e.g., to modify
                    ; license, copyright holder, etc.
                    "-s"                                     ; silent
                    filename))))

(defun autogen ()
  "Automatically generate boilerplate text."
  (interactive)
    (let ((boilerplate (autogen-text-for-buffer)))
      (save-excursion
        (goto-char (point-min))
        (insert boilerplate))))

(defun autogen-file-not-found-hook ()
  "Automatically generate boilerplate text.
Restore the modified state of buffer (typically to unmodified) so that
new files aren't considered modified until the user types into them."
  (interactive)
  (let ((modified (buffer-modified-p)))
    (autogen)
    (set-buffer-modified-p modified))
  t)    ; don't run other find-file-not-found-functions

; Automatically generate boilerplate for new files.
(add-hook 'find-file-not-found-functions #'autogen-file-not-found-hook)

; Bind "Ctrl-c + a" to run Autogen in the current buffer.
(global-set-key "\C-ca" #'autogen)   ; bind autogen to Control-c + a
