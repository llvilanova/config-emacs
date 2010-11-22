;;; my-package.el --- Package management

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package sources

;; `package'
(require 'package)
(setq package-user-dir (path my-config-dir "elpa" ""))
(add-to-list 'package-archives '("elpa". "http://tromey.com/elpa/"))
(package-initialize)

;; `el-get'
(setq el-get-dir (path my-config-dir "el-get" ""))
(add-to-list 'load-path (path el-get-dir "el-get"))
;; Handle auto-installation
(unless (require 'el-get nil t)
  (let* ((dummy             (unless (file-directory-p el-get-dir)
                              (make-directory el-get-dir t)))
         (package           "el-get")
         (pdir              (concat (file-name-as-directory el-get-dir) package))
         (git               (or (executable-find "git") (error "Unable to find `git'")))
         (url               "git://github.com/dimitri/el-get.git")
         (el-get-sources    `((:name ,package :type "git" :url ,url :features el-get :compile "el-get.el"))))
    (setq default-directory el-get-dir)
    (call-process git nil t t "--no-pager" "clone" "-v" url pdir)
    (insert "Performing initial package installation...\n")
    (load (concat (file-name-as-directory pdir) package ".el"))
    (el-get-init "el-get"))
  (package-refresh-contents)            ; get initial list of available packages
  (load-file (path my-config-dir "el-get" "el-get" "el-get.el")))

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
        ;; el-get
        (:name asciidoc              :type elpa)
        (:name auto-dictionary       :type elpa)
        (:name bibtex-utils          :type emacswiki)
        (:name bookmark+-mac         :type emacswiki)
        (:name bookmark+-bmu         :type emacswiki)
        (:name bookmark+-1           :type emacswiki)
        (:name bookmark+-lit         :type emacswiki)
        (:name bookmark+-doc         :type emacswiki)
        (:name bookmark+-chg         :type emacswiki)
        (:name bookmark+             :type emacswiki)
        ;; (:name pymacs                :type apt-get)
        ;; (:name pysmell               :type git
        ;;  :url "http://github.com/orestis/pysmell.git")
        (:name company               :type elpa)
        ;; (:name cssh                  :type elpa)
        (:name cursor-chg            :type emacswiki)
        (:name doc-mode              :type http
         :url "http://nschum.de/src/emacs/doc-mode/doc-mode.el"
         :after (lambda () (autoload 'doc-mode "doc-mode" nil t)))
        (:name ecb                   :type cvs
         :url ":pserver:anonymous@ecb.cvs.sourceforge.net:/cvsroot/ecb"
         :module "ecb"
         :build ("make CEDET= all" "make autoloads EMACS=\"emacs -L .\"")
         :features (ecb-autoloads)
         :info "info-help")
        (:name gdb-shell             :type elpa)
        google-maps
        google-weather
        (:name highlight-80+         :type elpa)
        (:name highlight-parentheses :type elpa)
        (:name highlight-symbol      :type elpa)
        (:name iedit                 :type emacswiki
         :after (lambda ()
                  (autoload 'iedit-mode "iedit" nil t)))
        (:name lisppaste             :type elpa)
        ;; multi-term
        (:name predictive            :type git
         :url "http://www.dr-qubit.org/git/predictive.git"
         :build ("make")
         ;; Does not generate the `dir' file, so no info will appear on the menu
         :info "."
         :load-path ("." "latex" "texinfo" "html")
         :after (lambda ()
                  (autoload 'predictive-mode "predictive" nil t)
                  (autoload 'predictive-create-dict "predictive" nil t)))
        (:name smex                  :type elpa)
        switch-window
        ;; (:name tempo-snippets        :type elpa)
        (:name wordnet               :type http
         :url "http://xwl.appspot.com/ref/wordnet.el")
        undo-tree
        ;; (:name xml-rpc               :type elpa)
        ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(el-get 'wait)
(my-regenerate-autoloads)

(provide 'my-package)
