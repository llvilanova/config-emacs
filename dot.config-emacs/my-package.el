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
;; Generate package autoloads
(add-hook 'el-get-post-install-hooks
          '(lambda (package)
             (let* ((method   (plist-get (el-get-package-def package) :type))
                    (generate (or (eq method 'http)
                                  (eq method 'emacswiki)))
                    (generated-autoload-file (path (el-get-package-directory package) "loaddefs.el")))
               (message "-> %s %s" package generate)
               (when generate
                 (update-directory-autoloads (path el-get-dir package))))))

;; local site-lisp
(defconst my-code-dir (path my-config-dir "site-lisp"))
(add-to-list 'load-path my-code-dir)
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
         :url "http://nschum.de/src/emacs/doc-mode/doc-mode.el")
        (:name gdb-shell             :type elpa)
        google-maps
        google-weather
        (:name highlight-80+         :type elpa)
        (:name highlight-parentheses :type elpa)
        (:name highlight-symbol      :type elpa)
        (:name iedit                 :type emacswiki
               :load "loaddefs.el")
        (:name lisppaste             :type elpa)
        ;; multi-term
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

(provide 'my-package)
