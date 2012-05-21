;;; my-package.el --- Package management

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package sources

;; `el-get' auto-installation
(setq el-get-dir (path my-config-dir "el-get" ""))
(add-to-list 'load-path (path el-get-dir "el-get"))
;; Handle auto-installation
(unless (require 'el-get nil t)
  ;; download, build & load
  (let ((buffer
         (or (url-retrieve-synchronously
             "https://github.com/dimitri/el-get/raw/master/el-get-install.el")
            (error "Could not download el-get installer")))
        (user-emacs-directory my-config-dir))
    (with-current-buffer buffer
      (end-of-buffer)
      (eval-print-last-sexp))))


;; `package' auto-installation
(el-get 'wait '(package24))
;; TODO: handle URL bug in recipe (for marmalade)
(setq package-archives
      (delq nil (mapcar (lambda (x) (if (string= (car x) "marmalade") nil x))
                      package-archives)))
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
;; additional repositiories
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
;; first-time initialization
(unless (file-exists-p (path package-user-dir "archives"))
  (package-refresh-contents))


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
  (mapcar '(lambda (item)
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
          (when (not (file-exists-p autoload-file))
            (add-hook 'after-init-hook 'my-recompile-init))
          (update-directory-autoloads autoload-dir))))
    (load autoload-file)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package list
(setq el-get-sources
      '(
        (:name ack                   :type http
               :url "http://nschum.de/src/emacs/full-ack/full-ack.el"
               :after (lambda ()
                        (setq ack-executable "ack-grep")))
        (:name asciidoc              :type elpa)
        (:name auctex                :type apt-get)
        ;; (:name auto-complete
        ;;        :after
        ;;        '(lambda ()
        ;;           (require 'pos-tip)
        ;;           (setq ac-dwim t
        ;;                 ac-use-quick-help t)))
        (:name auto-dictionary       :type elpa)
        (:name bibtex-utils          :type emacswiki)
        (:name company               :type elpa)
        ;; (:name cssh                  :type elpa)
        (:name cursor-chg            :type emacswiki)
        (:name doc-mode              :type http
               :url "http://nschum.de/src/emacs/doc-mode/doc-mode.el")
        (:name ecb                   :type cvs
               :url ":pserver:anonymous@ecb.cvs.sourceforge.net:/cvsroot/ecb"
               :module "ecb"
               :build ("make CEDET= all" "make autoloads EMACS=\"emacs -L .\"")
               :info "info-help")
        (:name emacs-goodies-el      :type apt-get)
        (:name enclose               :type http
               :url "https://github.com/rejeep/enclose/raw/master/enclose.el"
               :features (enclose))
        (:name fic-ext-mode
               :lazy t
               :after (lambda () (add-to-list 'fic-highlighted-words "XXX")))
        flymake-fringe-icons
        (:name flymake-lua           :type http
               :website "https://github.com/sroccaserra/emacs/blob/master/flymake-lua.el"
               :description "Flymake support for Lua."
               :url "https://raw.github.com/sroccaserra/emacs/master/flymake-lua.el"
               :post-init (lambda ()
                            (add-hook 'lua-mode-hook 'flymake-lua-load)))
        (:name fuzzy                 :type svn
               :url "http://dea.googlecode.com/svn/trunk/lisps/auto-complete"
               :features (fuzzy)
               :after (lambda () (turn-on-fuzzy-isearch)))
        (:name gdb-shell             :type elpa)
        google-maps
        google-weather
        (:name highlight-parentheses :type elpa)
        (:name highlight-symbol      :type elpa)
        (:name ido-settings          :type http
               :url "https://raw.github.com/DarwinAwardWinner/dotemacs/master/site-lisp/settings/ido-settings.el"
               :features (ido-settings))
        (:name iedit                 :type emacswiki)
        (:name lisppaste             :type elpa)
        (:name lua-mode              :type apt-get)
        magithub
        (:name magit                 :type apt-get
               :after (lambda ()
                        ;; For some reason, the autoload is not working
                        (require 'magit-stgit)
                        (add-hook 'magit-mode-hook 'turn-on-magit-stgit)))
        ;; multi-term
        (:name org-mode              :type apt-get)
        (:name predictive
               :build ("make")
               :load-path ("." "latex" "texinfo" "html")
               :after (lambda ()
                        (autoload 'predictive-mode "predictive" nil t)
                        (autoload 'predictive-create-dict "predictive" nil t)))
        (:name pretty-mode           :type git
               :features (pretty-mode)
               :url "https://github.com/mattharrison/pretty-mode.git"
               :after (lambda () (global-pretty-mode t)))
        (:name pylint                :type apt-get
               :after (lambda ()
                        (when (load "flymake" t)
                          (defun my--flymake-pylint-init ()
                            (let* ((temp-file (flymake-init-create-temp-buffer-copy
                                               'flymake-create-temp-inplace))
                                   (local-file (file-relative-name
                                                temp-file
                                                (file-name-directory buffer-file-name))))
                              (list "epylint" (list local-file))))
                          (add-to-list 'flymake-allowed-file-name-masks
                                       '("\\.py\\'" my--flymake-pylint-init)))))
        (:name smex                  :type elpa)
        (:name sml-modeline          :type elpa)
        switch-window
        ;; (:name tempo-snippets        :type elpa)
        (:name undo-tree
               :features (undo-tree)
               :after global-undo-tree-mode)
        (:name unipoint              :type git
               :features (unipoint)
               :url "https://github.com/apgwoz/unipoint.git")
        (:name wordnet               :type http
               :url "http://xwl.appspot.com/ref/wordnet.el")
        (:name wrap-region           :type http
               :url "https://github.com/rejeep/wrap-region/raw/master/wrap-region.el"
               :features (wrap-region)
               :after wrap-region-global-mode)
        xcscope
        ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(setq my-packages
      (append
       '(el-get)
       (mapcar 'el-get-source-name el-get-sources)))
(el-get 'wait my-packages)
(my-regenerate-autoloads)

(provide 'my-package)
