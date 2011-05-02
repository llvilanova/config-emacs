;;; org-capture-cfp.el --- Capture or update calls for papers

;; Copyright (C) 2010, 2011  Lluís Vilanova

;; Author: Lluís Vilanova <vilanova at ac dot upc dot edu>
;; Keywords: outlines, hypermedia, calendar, wp
;; X-URL: not distributed yet
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;; This file provides functionalities to capture with `org-capture' new "Call
;; For Papers" for conferences and the like, which are usually recieved through
;; mail.

;; When the user is prompted for filling in a field, the prompt history will
;; contain the possible completions that have been auto-detected.

;; Example:

;; (add-to-list 'org-capture-templates
;;  ("c" "Conference" entry (file+headline "Events.org" "Conferences")
;;   "* [[%(org-capture-cfp-url)][%(org-capture-cfp-mail-conference)]]    :%^{Acronym}:%?
;; ** TODO Abstract
;;    DEADLINE: <%(org-capture-cfp-date \"Abstract submission: \" \"abstract\" \"submission\") ++1y -1w>
;; ** TODO Paper
;;    DEADLINE: <%(org-capture-cfp-date \"Paper submission: \" \"submission\") ++1y -6m>
;; ** TODO Acceptance
;;    SCHEDULED: <%(org-capture-cfp-date \"Acceptance notification: \" \"notification\") ++1y>"
;;              )

;;; TODO

;; - `org-capture-cfp:extract-mail-conference' is not very robust and the
;;   conference name (not the acronym) is sometimes only available on the mail
;;   body.

;; - no support for updating an existing CFP


;;; Code:

(eval-when-compile
  (require 'cl))
(require 'org)

;;; API

;;;###autoload
(defun org-capture-cfp-mail-conference ()
  "Capture conference name from the subject in a mail."
  (org-capture-cfp:prompt "Conference name: " nil
                          'org-capture-cfp:extract-mail-conference
                          'org-capture-cfp:extract-conference))

;;;###autoload
(defun org-capture-cfp-date (msg &rest alternatives)
  "Capture a date.
ALTERNATIVES is a list of case-insensitive regular expressions
that might appear prefixed to the date.

The result will be the first successfully extracted date on
ALTERNATIVES, or the result of prompting the user with MSG if no date can be
extracted."
  (let ((calls (mapcar (lambda (text)
                         (list 'org-capture-cfp:extract-date text))
                       alternatives)))
    (apply 'org-capture-cfp:prompt msg t calls)))

;;;###autoload
(defun org-capture-cfp-url ()
  "Capture conference web URL."
  (org-capture-cfp:prompt "Conference Web URL: " nil
                          (list 'org-capture-cfp:extract
                                "\\(https?://[^ )\n]*\\)" nil nil)))


;;; Internal functions

(defun org-capture-cfp:prompt (msg noask &rest extracts)
  "Prompt for the validity of an extracted field from the captured buffer.

Prompts the user with MSG for the extractions defined in EXTRACTS. If NOASK is
true, no prompt is shown, and the extraction is silently accepted if one is
found, otherwise, the prompt is always shown.

EXTRACTS is a list of extraction descriptors, which are used in order until one
returns a non-nil result.

Extraction descriptors in EXTRACTS can have two formats:
- A list with a function as the first element, and function arguments on the
  rest.
- A function to call with no arguments.

The result is the extracted text, if any.
"
  (save-excursion
    (with-current-buffer (org-capture-get :original-buffer)
      (let ((res nil)
            (choices nil))
        (while (not res)
          (goto-char (point-min))
          (setq extract (or (pop extracts) 'ignore))
          (setq choices
                (if (listp extract)
                    (apply (car extract) (cdr extract))
                  (funcall extract)))
          (message "=> %s:" msg)
          (message "%s" extracts)
          (if choices
              (setq res
                    (if (> (length choices) 1)
                        (if (listp choices)
                            (let ((choice (nth 0 choices)))
                              (read-string msg choice '(choices . 1) choice)))
                      (if noask
                          (car choices)
                        (let ((choice choices)
                              (choices nil))
                          (read-string msg choice '(choices . 1) choice)))))
            (if (eq 'ignore extract)
                (setq res (read-string msg)))))
        res))))


(defun org-capture-cfp:extract-trim (trim text)
  "Return TEXT without appearances of TRIM on the begginning and end."
  (let ((res text))
    (setq res (replace-regexp-in-string
               (format "^%s" trim) "" res))
    (setq res (replace-regexp-in-string
               (format "%s$" trim) "" res))
    res))

(defun org-capture-cfp:extract-replace (replace text)
  "Return TEXT replacing the 0th element in REPLACE with the 1st."
  (let ((res text)
        (from (nth 0 replace))
        (to (nth 1 replace)))
    (if (functionp replace)
        (replace text)
      (replace-regexp-in-string from to res))))

(defun org-capture-cfp:extract (re trims replaces)
  "Extract the 1st expression in RE from current point.
TRIMS and REPLACES will be applied to the result using
`org-capture-cfp:extract-trim' and `org-capture-cfp:extract-replace',
respectively."
  (let ((res nil)
        (text nil))
    (while (re-search-forward re nil t)
      (setq text (substring-no-properties (match-string 1)))
      (mapc '(lambda (trim)
               (setq text (org-capture-cfp:extract-trim trim text)))
            trims)
      (mapc '(lambda (replace)
               (setq text (org-capture-cfp:extract-replace replace text)))
            replaces)
      (add-to-list 'res text t))
    res))


(defun org-capture-cfp:extract-mail-conference ()
  "Extract the conference name from the Subject line of a mail."
  (org-capture-cfp:extract
   "^Subject: \\[[^]]*\\] *\\(.*\\) *$"
   '("(.*)" " *call *for *papers *" "[[:digit:]]\\{4\\}" " ")
   '(("  *" " "))))

(defun org-capture-cfp:extract-conference ()
  "Extract the conference name."
  (org-capture-cfp:extract
   "^Subject: \\[[^]]*\\] *\\(.*\\) *$"
   '("(.*)" " *call *for *papers *" "[[:digit:]]\\{4\\}" " ")
   '(("  *" " "))))

(defun org-capture-cfp:extract-date (re)
  "Extract a date prefixed by RE.
The result is ignored if it returns the date of today."
  (let ((dates (org-capture-cfp:extract (concat re " *.*: *\\(.*\\)")
                                        '("(.*)" " ")
                                        nil))
        (tmp nil))
    (mapc (lambda (date)
            (add-to-list 'tmp (org-read-date nil nil date)))
          dates)
    (setq dates nil)
    (mapc (lambda (date)
            (add-to-list 'dates
                         (if (string= date (org-read-date nil nil ""))
                             nil
                           date)))
          tmp)
    dates))

(provide 'org-capture-cfp)

;;; org-capture-cfp.el ends here
