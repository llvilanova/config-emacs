;;; move-text.el --- 
;;
;; Copyright (C) 2014 Lluís Vilanova
;;
;; Author: Lluís Vilanova <vilanova@ac.upc.edu>
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
;; Simple functions to move text/lines around.

;;; Code:

(defun move-text--internal (arg)
  (cond
   ((and mark-active transient-mark-mode)
    (if (> (point) (mark))
        (exchange-point-and-mark))
    (let ((column (current-column))
          (text (delete-and-extract-region (point) (mark))))
      (forward-line arg)
      (move-to-column column t)
      (set-mark (point))
      (insert text)
      (exchange-point-and-mark)
      (setq deactivate-mark nil)))
   (t
    (let ((column (current-column)))
      (beginning-of-line)
      (when (or (> arg 0) (not (bobp)))
        (forward-line)
        (when (or (< arg 0) (not (eobp)))
          (transpose-lines arg))
        (forward-line -1))
      (when (< arg 0)
        (forward-line -1))
      (move-to-column column t)))))

(defun move-text-down (arg)
  "Move region or current line ARG lines down."
  (interactive "*p")
  (move-text--internal arg))

(defun move-text-up (arg)
  "Move region or current line ARG lines up."
  (interactive "*p")
  (move-text--internal (- arg)))

(provide 'move-text)

;;; move-text.el ends here
