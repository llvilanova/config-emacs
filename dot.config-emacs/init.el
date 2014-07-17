;;; init.el --- Start configuration process.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This configuration assumes the following packages/libraries are available:
;;   - ditaa
;;   - chktex
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; * Common routines and macros
(defun path (&rest list)
  "Build a path by concatenating a list of strings.

If last element in LIST is an empty string, the resulting path ends as a
directory path."
  (let ((res (car list)))
    (dolist (elem (cdr list))
      (setq res (concat (file-name-as-directory res) elem)))
    res))

(defmacro after (mode &rest body)
  "`eval-after-load' MODE and evaluate BODY."
  (declare (indent defun))
  `(eval-after-load ,mode
     '(progn ,@body)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; * Definition of pervasive paths
;; Where to store files
(defconst my-home-dir   (expand-file-name "~"))
(defconst my-config-dir (path my-home-dir ".config" "emacs"))
(defconst my-data-dir   (path my-home-dir ".local"  "share" "emacs"))
(defconst my-cache-dir  (path my-home-dir ".cache"  "emacs"))
(make-directory my-cache-dir t)

;; Some emacs-defined paths
(defconst user-emacs-directory my-data-dir)
(defconst custom-file (path my-config-dir "custom.el"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; * Add local lisp repositories
(add-to-list 'load-path my-config-dir)
(require 'my-package)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; External programs
;; (setq browse-url-browser-function 'browse-url-generic
;;       browse-url-generic-program "epiphany"
;;       browse-url-generic-args '("--new-tab"))
(setq browse-url-browser-function 'eww-browse-url)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; * Pull the rest of configuration
(require 'cl)
(require 'my-misc)
(require 'my-cmdline)
(require 'my-appearance)
(require 'my-behaviour)
(require 'my-ide)
(require 'my-writing)
(require 'my-programming)
(require 'my-org)
(require 'my-mail)
(require 'my-bindings)
(require 'my-personal nil t)           ; personal code & information, never upload
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; * custom-set-*
(load custom-file 'noerror)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
