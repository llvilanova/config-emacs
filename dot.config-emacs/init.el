;; -*-mode: Emacs-Lisp; folded-file:t-*-

;; ;; Show backtrace on error
;; (toggle-debug-on-error t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This configuration assumes that the following packages/libraries are present
;; in the system:
;;   - auctex
;;   - develock-el
;;   - yasnippet
;;   - org-mode (>= 6.33f)
;;   - emacs-goodies-el (debian package)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Definition of pervasive directories
(defun path (&rest list)
  "Build a path by concatenating a list of strings.

If last element in LIST is an empty string, the resulting path ends as a
directory path."
  (let ((res (car list)))
    (dolist (elem (cdr list))
      (setq res (concat (file-name-as-directory res) elem)))
    res
    ))
;; Where to store files
(defconst my-home-dir   (expand-file-name "~"))
(defconst my-config-dir (path my-home-dir ".config" "emacs"))
(defconst my-data-dir   (path my-home-dir ".local"  "share" "emacs"))
(defconst my-cache-dir  (path my-home-dir ".cache"  "emacs"))
(make-directory my-cache-dir t)
(defconst user-emacs-directory my-data-dir)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add local lisp repository
(defconst my-code-dir (path my-config-dir "site-lisp")) ;; Local packages
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
(load (path my-config-dir "package.el"))
(package-initialize)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pull the rest of configuration
(load-file (path my-config-dir "general.el"))

(load-file (path my-config-dir "ide.el"))
(load-file (path my-config-dir "writing.el"))
(load-file (path my-config-dir "programming.el"))

(load-file (path my-config-dir "organization.el"))
(load-file (path my-config-dir "mail.el"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; custom-set-*
;; TODO: should probably move to respective configuration file
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(ecb-options-version "2.40")
 '(ecb-source-path (quote (("." ".") ("/" "/"))))
 '(font-latex-user-keyword-classes (quote (("mycommon-to-revise" (("TODO" "{")) font-latex-warning-face command))))
 '(org-agenda-files (quote ("~/Projects/vilanova/pmvirt/pvm.org" "/home/users/vilanova/plans/Brainstorming.org" "/home/users/vilanova/plans/Events.org" "/home/users/vilanova/plans/Main.org" "/home/users/vilanova/plans/Personal.org" "/home/users/vilanova/plans/Projects.org" "/home/users/vilanova/plans/TODO.org" "/home/users/vilanova/plans/notes.org")))
 '(safe-local-variable-values (quote ((org-export-latex-append-header . "\\usepackage{tikz}") (outline-minor-mode . t) (folded-file . t) (c-auto-newline . t) (c-default-style . "stroustrup")))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(cscope-line-face ((default (:foreground "gray")) (nil nil))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
