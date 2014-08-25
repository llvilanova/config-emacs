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
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
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
        (:name ace-jump-mode
               :features nil)
        (:name ace-window            :type github
               :pkgname "abo-abo/ace-window")
        (:name ack                   :type http
               :url "http://nschum.de/src/emacs/full-ack/full-ack.el"
               :after (setq ack-executable (executable-find "ack-grep")))
        (:name asciidoc              :type elpa)
        (:name auctex                :type apt-get)
        auto-complete
        (:name auto-dictionary       :type github
               :pkgname "nschum/auto-dictionary-mode")
        (:name bibtex-utils          :type emacswiki)
        ;; (:name company               :type elpa)
        ;; (:name cssh                  :type elpa)
        (:name cedet
               :after (add-to-list 'load-path (concat (el-get-package-directory 'cedet) "contrib")))
        cl-lib
        (:name cursor-chg            :type emacswiki)
        (:name diminish
               :after (progn
                        (defmacro my-diminish-after (mode-name)
                          `(after ',mode-name
                             (diminish (intern (format "%s-mode" ',mode-name)))))
                        (my-diminish-after abbrev)
                        (my-diminish-after auto-fill)
                        (my-diminish-after elisp-slime-nav)
                        (my-diminish-after flyspell)
                        (my-diminish-after smartparens)
                        (my-diminish-after visual-line)
                        (my-diminish-after whitespace)
                        (my-diminish-after filladapt)
                        (my-diminish-after auto-complete)
                        (my-diminish-after auto-fill)
                        (my-diminish-after highlight-parentheses)
                        (my-diminish-after hi-lock)
                        (my-diminish-after yas-minor)))
        (:name dired-details
               :after (progn
                        (setq-default dired-details-hidden-string "--- ")
                        (dired-details-install)))
        (:name disaster              :type github
               :pkgname "jart/disaster"
               :after (after 'cc-mode
                        (require 'disaster)))
        (:name doc-mode              :type http
               :url "http://nschum.de/src/emacs/doc-mode/doc-mode.el")
        (:name doc-present           :type github
               :pkgname "dengste/doc-present")
        (:name dpkg-dev-el           :type apt-get)
        (:name elisp-slime-nav       :type elpa
               :after (progn
                        (add-hook 'emacs-lisp-mode-hook 'elisp-slime-nav-mode)))
        (:name emacs-goodies-el      :type apt-get)
        expand-region
        (:name fic-ext-mode
               :lazy t
               :after (add-to-list 'fic-highlighted-words "XXX"))
        flx
        (:name flycheck
               :after (global-flycheck-mode t))
        (:name flycheck-color-mode-line :type github
               :pkgname "flycheck/flycheck-color-mode-line"
               :after (after 'flycheck
                        (require 'flycheck-color-mode-line)
                        (add-hook 'flycheck-mode-hook
                                  'flycheck-color-mode-line-mode))
               )
        (:name fuzzy
               :features fuzzy
               :after (turn-on-fuzzy-isearch))
        (:name gdb-shell             :type elpa)
        (:name gnus-notifications    :type http
               :url "http://git.gnus.org/cgit/gnus.git/plain/lisp/gnus-notifications.el")
        (:name guess-style           :type http
               :url "http://nschum.de/src/emacs/guess-style/guess-style.el")
        (:name highlight-parentheses :type elpa)
        (:name highlight-symbol      :type elpa)
        (:name hl-line+              :type emacswiki
               :after (progn
                        (require 'cursor-chg)
                        (toggle-hl-line-when-idle t)
                        (hl-line-when-idle-interval (+ 1 curchg-idle-interval))))
        hungry-delete
        (:name ido-ubiquitous
               :after (progn
                        (ido-mode 1)
                        (ido-ubiquitous-mode 1)))
        jinja2-mode
        (:name key-chord             :type emacswiki
               :after (key-chord-mode t))
        (:name lua-mode              :type apt-get)
        (:name lv                    :type github
               :pkgname "llvilanova/lv")
        (:name magit
               :after (progn
                        (add-hook 'magit-mode-hook 'turn-on-magit-stgit)
                        (setq magit-diff-refine-hunk t)))
        (:name multiple-cursors
               :features multiple-cursors)
        ;; multi-term
        (:name org-mode
               ;:branch "maint"
               :after (after 'org-bibtex
                        (require 'ox-bibtex)))
        (:name org-gnome-calendar    :type github
               :pkgname "llvilanova/org-gnome-calendar"
               :after (progn
                        (require 'dbus)
                        (when (dbus-ignore-errors (dbus-init-bus :session))
                          (global-org-gnome-calendar-mode))))
        (:name outshine
               :after (progn
                        (autoload 'outshine-hook-function "outshine")
                        (add-hook 'outline-minor-mode-hook
                        'outshine-hook-function)))
        (:name popwin
               :features popwin
               :after (setq display-buffer-function 'popwin:display-buffer))
        (:name pos-tip               :type elpa)
        powerline
        ;; (:name predictive
        ;;        :after (progn
        ;;                 (autoload 'predictive-mode "predictive" nil t)
        ;;                 (autoload 'predictive-create-dict "predictive" nil t)))
        (:name pylint                :type apt-get)
        (:name smartparens
               :after (progn
                        (require 'smartparens-config)
                        (add-to-list 'LaTeX-mode-hook
                                     (lambda () (require 'smartparens-latex)))))
        smex
        (:name sml-modeline          :type elpa)
        switch-window
        ;; (:name tempo-snippets        :type elpa)
        undo-tree
        (:name wgrep                 :type github
               :pkgname "mhayashi1120/Emacs-wgrep")
        (:name wordnet               :type http
               :url "http://xwl.appspot.com/ref/wordnet.el")
        (:name xcscope
               :features nil)
        yasnippet
        ))


(provide 'my-package)
