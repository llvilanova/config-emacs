;;; lv-gem5-trace.el --- Log filter and highlighter for GEM5 traces

;; Copyright (C) 2012 Lluís Vilanova

;; Author: Lluís Vilanova <vilanova@ac.upc.edu>
;; URL:
;; Keywords:
;; Version: 1.4

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This extension specializes `lv-mode' to work with GEM5 traces.

;;; Code:

(require 'lv)


(defvar lv--sn nil
  "List of GEM5 instruction sequence numbers to select.")
(make-local-variable 'lv--sn)

(defvar lv--sn-history nil
  "List of arguments to `lv-add-sn' so far.")

(defvar lv--sn-history-str nil
  "List of arguments to `lv-add-sn' so far (stringified version).")


(defun lv--sn-to-re (sn)
  "Return an appropriate regexp for the given sequence number."
  (format "\\[sn:%d\\]" sn))


;;;###autoload
(defun lv-add-sn (&optional sn)
  "Add a GEM5 instruction sequence number."
  (interactive)
  (when (and (not (called-interactively-p)) (not sn))
    (error))
  (when (called-interactively-p)
    (setq sn (string-to-int
              (completing-read "Sequence number: " nil nil nil nil
                               'lv--sn-history-str))))
  (add-to-list 'lv--sn-history sn t)
  (setq lv--sn-history-str (mapcar 'int-to-string lv--sn-history))
  (add-to-list 'lv--sn sn)
  (lv-add (lv--sn-to-re sn)))

;;;###autoload
(defun lv-del-sn (&optional sn)
  "Remove a GEM5 instruction sequence number."
  (interactive)
  (when (and (not (called-interactively-p)) (not sn))
    (error))
  (when (called-interactively-p)
    (setq sn (string-to-int
              (completing-read "Sequence number: "
                               (mapcar 'int-to-string lv--sn)))))
  (setq lv--sn (remove sn lv--sn))
  (lv-del (lv--sn-to-re sn)))


(define-key lv-mode-map (kbd "C-c s") 'lv-add-sn)
(define-key lv-mode-map (kbd "C-c S") 'lv-del-sn)


(provide 'lv-gem5-trace)
;;; lv-gem5-trace.el ends here
