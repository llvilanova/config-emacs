;;; my-package.el --- Package management

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Package sources

;; `package'
(require 'package)
(setq package-enable-at-startup nil)
(setq package-user-dir (path my-cache-dir "elpa"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))


;; `use-package'
;(setq use-package-verbose t)
(unless (package-installed-p 'use-package)
  (package-install 'use-package))


;; local site-lisp
(defconst my-code-dir (path my-config-dir "site-lisp"))
(add-to-list 'load-path my-code-dir)


;; Taken from `starter-kit-defuns'
(defvar my-recompile-objs (list ;; my-config-dir
                                my-code-dir)
  "List of recompilation objectives.
If the element is a function, it is called to recompile.  If the
element is the path to an existing directory, all its elisp files
are compiled.  If the element is a string, it is assumed as a
command to be run in a shell.")

(defun my-recompile-init ()
  "Byte-compile all local code."
  (interactive)
  (message "Recompiling local code...")
  (mapcar (lambda (item)
            (cond ((functionp item)
                   (funcall item))
                  ((and (stringp item) (file-directory-p item))
                   (mapcar 'byte-compile-file
                           (directory-files item t "\\.el$")))
                  ((stringp item)
                   (message "Running '%s'..." item)
                   (call-process-shell-command item nil "*Compile-Log*" t))
                  ((error "Unknown recompilation objective: %s" item))))
          my-recompile-objs))

(defun my-regenerate-autoloads (&optional force)
  "Regenerate the autoload definitions file if necessary and load it."
  (interactive "P")
  (let* ((autoload-dir my-code-dir)
         (autoload-file (path my-config-dir "loaddefs.el")))
    (let ((generated-autoload-file autoload-file))
      (when (or force
                (not (file-exists-p autoload-file))
                (seq-filter (lambda (f) (file-newer-than-file-p f autoload-file))
			    (directory-files autoload-dir t "\\.el$")))
        (message "Updating autoloads...")
        (let (emacs-lisp-mode-hook)
          (my-recompile-init)
          (update-directory-autoloads autoload-dir))))
    (load autoload-file)))

;; Re-generate autoloads and re-compile local code (if necessary)
(my-regenerate-autoloads)

(provide 'my-package)
