;;; my-package.el --- Package management

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Package sources

;; `el-get' auto-installation
(setq el-get-dir (path my-cache-dir "el-get" ""))
(add-to-list 'load-path (path el-get-dir "el-get"))
(unless (require 'el-get nil t)
  ;; download, build & load
  (let ((buffer
         (or (url-retrieve-synchronously
             "https://github.com/dimitri/el-get/raw/master/el-get-install.el")
            (error "Could not download el-get installer")))
        (el-get-install-branch "master")
        (user-emacs-directory my-config-dir))
    (with-current-buffer buffer
      (end-of-buffer)
      (eval-print-last-sexp))))
(el-get 'sync '(el-get))

;; `package' auto-installation
(setq package-user-dir (path my-cache-dir "elpa"))
(el-get 'sync '(package))
(add-to-list 'package-archives          ; additional repositiories
             '("melpa" . "http://melpa.org/packages/") t)
(unless (file-exists-p (path package-user-dir "archives"))
  ;; first-time initialization
  (package-refresh-contents))
(package-initialize t)

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
                (some (lambda (f) (file-newer-than-file-p f autoload-file))
                      (directory-files autoload-dir t "\\.el$")))
        (message "Updating autoloads...")
        (let (emacs-lisp-mode-hook)
          (my-recompile-init)
          (update-directory-autoloads autoload-dir))))
    (load autoload-file)))

;; Re-generate autoloads and re-compile local code (if necessary)
(my-regenerate-autoloads)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Package management

(defun my-add-packages (packages)
  "Install list of packages using `el-get' and add to `el-get-sources'."
  (setq el-get-sources (append el-get-sources packages))
  (el-get 'sync (mapcar 'el-get-source-name packages)))

(setq el-get-sources '(use-package))
(el-get 'sync '(el-get use-package))
(require 'use-package)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Initial package list
(my-add-packages
 '(
   cedet
        (:name dpkg-dev-el           :type apt-get)
        (:name emacs-goodies-el      :type apt-get)
        (:name key-chord             :type emacswiki
               :after (key-chord-mode t))
        (:name hungry-delete         :type elpa)
        (:name lua-mode              :type apt-get)
        (:name lv                    :type github
               :pkgname "llvilanova/lv")
        ;; (:name multi-term            :type elpa)
        (:name popwin                :type elpa
               :after (setq display-buffer-function 'popwin:display-buffer))
        (:name pos-tip               :type elpa)
        (:name powerline             :type elpa)
        ;; (:name predictive
        ;;        :after (progn
        ;;                 (autoload 'predictive-mode "predictive" nil t)
        ;;                 (autoload 'predictive-create-dict "predictive" nil t)))
        (:name sml-modeline          :type elpa)
        (:name switch-window         :type elpa)
        ;; (:name tempo-snippets        :type elpa)
        (:name wgrep                 :type elpa)
        (:name wordnet               :type http
               :url "http://xwl.appspot.com/ref/wordnet.el")
        ))


(provide 'my-package)
