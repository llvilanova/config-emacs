;;; init.el --- Start configuration process.

;; ;; Show backtrace on error
;; (toggle-debug-on-error t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This configuration assumes that the following packages/libraries are present
;; in the system:
;;   - auctex
;;   - develock-el
;;   - org-mode (>= 6.33f)
;;   - emacs-goodies-el (debian package)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add local lisp repository
(add-to-list 'load-path my-config-dir)
(defconst my-code-dir (path my-config-dir "site-lisp")) ; local packages
(add-to-list 'load-path my-code-dir)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; External programs
(setq
 browse-url-browser-function 'browse-url-epiphany
 browse-url-epiphany-new-window-is-tab t ; for tab instead of new window.

 browse-url-browser-function 'browse-url-generic
 browse-url-generic-program "epiphany"
 browse-url-generic-args '("--new-tab"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ELPA
(setq package-user-dir (path my-config-dir "elpa" ""))
(require 'package)
(package-initialize)
(require 'my-elpa)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pull the rest of configuration
(require 'cl)
(require 'my-misc)
(my-regenerate-autoloads)

(require 'my-appearance)
(require 'my-behaviour)

;; (load-file (path my-config-dir "ide.el"))
;; (load-file (path my-config-dir "writing.el"))
;; (load-file (path my-config-dir "programming.el"))

;; (load-file (path my-config-dir "organization.el"))
;; (load-file (path my-config-dir "mail.el"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; custom-set-*
(load custom-file 'noerror)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
