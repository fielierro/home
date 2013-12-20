;;; basis-utils.el --- miscellaneous utilities

;; Copyright (C) 1999-2001 Basis Technology, Corp.

;; Author: Tom Emerson <tree@basistech.com>
;; Created: Sometime in Fall '99
;; Keywords: basis utilities source code

;; Modified by Simon L. Nielsen to include my copyright stuff
;; $Id: simon-basis-utils.el,v 1.7 2004/08/22 22:53:04 simon Exp $

;;; Commentary:

;; This package contains a random collection of functions I've written
;; to automate some of the repetitive editing tasks when writing new
;; code. A side benefit is that they implicitly enforce our coding
;; conventions.

;;; Change Log (most recent first)
;;
;; 2001-04-05  tree  Fixed bogosity in bt-insert-local-vars and
;;                   basis-insert-include-file-guards-in-region (the
;;                   latter thanks to Mike Wilson <mike.wilson@tradeweb.com>
;; 2000-08-29  tree  Added bt_create_new_source_file functionality.
;; 2000-07-09  tree  Created.

;;; Code:

(defconst bt-include-directive-regexp
  "^[ \t]*#include[ \t]+[<\"]\\([a-zA-Z0-9_.]+\.h\\)[>\"][ \t]*$"
  "Regular expression used to detect #include directives")

(defconst bt-file-suffix-regexp
  "\\.\\([a-zA-Z0-9]+\\)$"
  "Regular expression used to detect and extract the suffix of a file name")

; FIXME: this should really get the comment character from the current
;        mode so that it can be used for other languages too.
(defun insert-std-copyright-c ()
  "Insert the standard Simon L. Nielsen copyright notice at the current point."
  (interactive "*")
  (insert
   (format
    (concat
     "/*\n"
     " * Copyright © %s SimpliVT Corporation\n"
     " * All rights reserved.\n"
     " */\n"
     "\n")
    (format-time-string "%Y")
    )
   ))

(provide 'simon-basis-utils)

;;; basis-utils.el ends here
