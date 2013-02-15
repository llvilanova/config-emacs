;;; init.el --- Start configuration process.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This configuration assumes the following packages/libraries are available:
;;   - ditaa
;;   - chktex
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Definition of pervasive paths
(defun path (&rest list)
  "Build a path by concatenating a list of strings.

If last element in LIST is an empty string, the resulting path ends as a
directory path."
  (let ((res (car list)))
    (dolist (elem (cdr list))
      (setq res (concat (file-name-as-directory res) elem)))
    res))

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
;; Add local lisp repositories
(add-to-list 'load-path my-config-dir)
(require 'my-package)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; External programs
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "epiphany"
      browse-url-generic-args '("--new-tab"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mode hooks
(defvar my-add-hook-alist nil
  "Alist mapping \"abstract\" mode hooks to real mode hooks.
Use `my-define-hook' to add values to it.")

(defun my-define-hook (hook hooks)
  "Add a new entry into `my-add-hook-alist'.
HOOK is the symbol for the \"abstract\" hook variable.  HOOKS is
a list with the symbols of the real hook variables it refers to."
  (when (assq hook my-add-hook-alist)
    (error "Hook already defined"))
  (add-to-list 'my-add-hook-alist (cons hook hooks)))

(defun my-add-hook (hook function &optional append local)
  "Add to the value of HOOK the function FUNCTION.
If HOOK is a car in `my-add-hook-alist', add to all hooks in its
cdr instead."
  (let ((hooks (or (assq hook my-add-hook-alist) (list hook))))
    (dolist (hook hooks)
      (add-hook hook function append local))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pull the rest of configuration
(require 'cl)
(require 'my-misc)
(require 'my-personal nil t)            ; personal information, never upload
(require 'my-cmdline)
(require 'my-appearance)
(require 'my-behaviour)
(require 'my-ide)
(require 'my-projects nil t)            ; personal project list, never upload
(require 'my-writing)
(require 'my-programming)
(require 'my-org)
(require 'my-mail)
(require 'my-bindings)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; custom-set-*
(load custom-file 'noerror)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
