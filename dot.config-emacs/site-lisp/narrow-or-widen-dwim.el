;;; narrow-or-widen-dwim.el --- 
;;
;; Copyright (C) 2016 Lluís Vilanova
;;
;; Author: Lluís Vilanova <lluis@fimbulvetr.bsc.es>
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see http://www.gnu.org/licenses/.

;;; Commentary:
;;
;; Adapted from http://endlessparentheses.com/emacs-narrow-or-widen-dwim.html to
;; support `fancy-narrow'.

;;; Code:

(require 'fancy-narrow)


(defun narrow-or-widen-dwim (p)
  "Widen if buffer is narrowed, narrow-dwim otherwise.
Dwim means: region, org-src-block, org-subtree, or
defun, whichever applies first. Narrowing to
org-src-block actually calls `org-edit-src-code'.

With prefix P, don't widen, just narrow even if buffer
is already narrowed."
  (interactive "P")
  (declare (interactive-only))
  (cond ((and (buffer-narrowed-p) (not p)) (widen))
        ((and fancy-narrow--overlay-left (overlay-buffer fancy-narrow--overlay-left) (not p))
         (fancy-widen))
        ((region-active-p)
         (fancy-narrow-to-region (region-beginning)
                                 (region-end)))
        ((derived-mode-p 'org-mode)
         ;; `org-edit-src-code' is not a real narrowing
         ;; command. Remove this first conditional if
         ;; you don't want it.
         (cond ((ignore-errors (org-edit-src-code) t)
                (delete-other-windows))
               ((ignore-errors (org-narrow-to-block) t))
               (t (org-narrow-to-subtree))))
        ((derived-mode-p 'latex-mode)
         (LaTeX-narrow-to-environment))
        (t (fancy-narrow-to-defun))))

(provide 'narrow-or-widen-dwim)

;;; narrow-or-widen-dwim.el ends here
