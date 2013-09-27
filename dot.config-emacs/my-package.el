;;; my-package.el --- Package management

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package sources

;; `el-get' auto-installation
(setq el-get-dir (path my-config-dir "el-get" ""))
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


;; `package' auto-installation
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
          (when (not (file-exists-p autoload-file))
            (add-hook 'after-init-hook 'my-recompile-init))
          (update-directory-autoloads autoload-dir))))
    (load autoload-file)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package list
(setq el-get-sources
      '(
        (:name ace-jump-mode
               :features nil)
        (:name ack                   :type http
               :url "http://nschum.de/src/emacs/full-ack/full-ack.el"
               :after (setq ack-executable (executable-find "ack-grep")))
        (:name asciidoc              :type elpa)
        auctex                          ; TODO: temporarily using upstream
        auto-complete
        (:name auto-dictionary       :type git
               :url "https://github.com/nschum/auto-dictionary-mode.git")
        (:name bibtex-utils          :type emacswiki)
        ;; (:name company               :type elpa)
        ;; (:name cssh                  :type elpa)
        cedet
        cl-lib
        (:name cursor-chg            :type emacswiki)
        (:name diminish
               :after (progn
                        (defmacro my-diminish-after (mode-name)
                          `(after ',mode-name
                             (diminish (intern (format "%s-mode" ',mode-name)))))
                        (my-diminish-after elisp-slime-nav)
                        (my-diminish-after flyspell)
                        (my-diminish-after smartparens)
                        (my-diminish-after visual-line)
                        (my-diminish-after whitespace)
                        (my-diminish-after filladapt)
                        (my-diminish-after auto-complete)
                        (my-diminish-after auto-fill)
                        (my-diminish-after highlight-parentheses)))
        (:name dired-details
               :after (progn
                        (setq-default dired-details-hidden-string "--- ")
                        (dired-details-install)))
        (:name disaster              :type git
               :url "https://github.com/jart/disaster.git"
               :after (after 'cc-mode
                        (require 'disaster)))
        (:name doc-mode              :type http
               :url "http://nschum.de/src/emacs/doc-mode/doc-mode.el")
        (:name doc-present           :type git
               :url "https://github.com/dengste/doc-present.git")
        (:name dpkg-dev-el           :type apt-get)
        (:name elisp-slime-nav       :type elpa
               :after (progn
                        (add-hook 'emacs-lisp-mode-hook 'elisp-slime-nav-mode)))
        (:name emacs-goodies-el      :type apt-get)
        expand-region
        (:name fic-ext-mode
               :lazy t
               :after (add-to-list 'fic-highlighted-words "XXX"))
        (:name flymake               :type git
               :url "https://github.com/illusori/emacs-flymake"
               :after (progn
                        (setq flymake-number-of-errors-to-display nil)))
        (:name flymake-lua           :type http
               :website "https://github.com/sroccaserra/emacs/blob/master/flymake-lua.el"
               :description "Flymake support for Lua."
               :url "https://raw.github.com/sroccaserra/emacs/master/flymake-lua.el"
               :post-init (add-hook 'lua-mode-hook 'flymake-lua-load))
        (:name fuzzy                 :type git
               :url "https://github.com/auto-complete/fuzzy-el"
               :features fuzzy
               :after (turn-on-fuzzy-isearch))
        (:name gdb-shell             :type elpa)
        (:name gnus-notifications    :type http
               :url "http://git.gnus.org/cgit/gnus.git/plain/lisp/gnus-notifications.el")
        (:name google-maps
               :features nil)
        (:name google-weather
               :features nil)
        (:name guess-style           :type http
               :url "http://nschum.de/src/emacs/guess-style/guess-style.el")
        (:name highlight-parentheses :type elpa)
        (:name highlight-symbol      :type elpa)
        (:name hl-line+              :type emacswiki
               :after (progn
                        (require 'cursor-chg)
                        (toggle-hl-line-when-idle t)
                        (hl-line-when-idle-interval (+ 1 curchg-idle-interval))))
        (:name ido-settings          :type http
               :depends ido-yes-or-no
               :url "https://raw.github.com/DarwinAwardWinner/dotemacs/master/site-lisp/settings/ido-settings.el"
               :features (ido-settings))
        (:name ido-ubiquitous
               :after (progn
                        (ido-mode 1)
                        (ido-ubiquitous-mode 1)))
        (:name key-chord             :type emacswiki
               :after (key-chord-mode t))
        (:name lisppaste             :type elpa)
        (:name lua-mode              :type apt-get)
        (:name lv                    :type git
               :url "https://github.com/llvilanova/lv.git")
        magithub
        (:name magit
               :after (progn
                        (add-hook 'magit-mode-hook 'turn-on-magit-stgit)
                        (setq magit-diff-refine-hunk t)))
        (:name multiple-cursors
               :features multiple-cursors)
        ;; multi-term
        (:name org-mode              :type apt-get)
        (:name org-exp-bibtex        :type http
               :url "http://orgmode.org/w/?p=org-mode.git;a=blob_plain;f=contrib/lisp/org-exp-bibtex.el"
               :after (after 'org-bibtex
                        (require 'org-exp-bibtex)))
        (:name org-gnome-calendar    :type git
               :url "https://github.com/llvilanova/org-gnome-calendar"
               :after (progn
                        (require 'dbus)
                        (when (dbus-ignore-errors (dbus-init-bus :session))
                          (global-org-gnome-calendar-mode))))
        (:name outshine              :type git
               :url "https://github.com/tj64/outshine.git"
               :after (progn
                        (autoload 'outshine-hook-function "outshine")
                        (add-hook 'outline-minor-mode-hook 'outshine-hook-function)))
        paredit
        (:name popwin
               :features popwin
               :after (setq display-buffer-function 'popwin:display-buffer))
        (:name pos-tip               :type elpa)
        (:name predictive
               :after (progn
                        (autoload 'predictive-mode "predictive" nil t)
                        (autoload 'predictive-create-dict "predictive" nil t)))
        (:name pretty-mode           :type git
               :features (pretty-mode)
               :url "https://github.com/mattharrison/pretty-mode.git"
               ;; Seems `global-pretty-mode' is broken
               :after (add-hook 'find-file-hook 'turn-on-pretty-if-desired))
        (:name pylint                :type apt-get
               :after (when (load "flymake" t)
                        (defun my--flymake-pylint-init ()
                          (let* ((temp-file (flymake-init-create-temp-buffer-copy
                                             'flymake-create-temp-inplace))
                                 (local-file (file-relative-name
                                              temp-file
                                              (file-name-directory buffer-file-name))))
                            (list "epylint" (list local-file))))
                        (add-to-list 'flymake-allowed-file-name-masks
                                     '("\\.py\\'" my--flymake-pylint-init))))
        (:name smartparens
               :after (progn
                        (require 'smartparens-config)
                        (add-to-list 'LaTeX-mode-hook
                                     (lambda () (require 'smartparens-latex)))
                        (smartparens-global-mode)))
        (:name smex                  :type elpa)
        (:name sml-modeline          :type elpa)
        switch-window
        ;; (:name tempo-snippets        :type elpa)
        (:name undo-tree
               :after (progn
                        (defadvice undo-tree-undo (around keep-region activate)
                          "Keep region when undoing in region."
                          (if (use-region-p)
                              (let ((m (set-marker (make-marker) (mark)))
                                    (p (set-marker (make-marker) (point))))
                                ad-do-it
                                (goto-char p)
                                (set-mark m)
                                (set-marker p nil)
                                (set-marker m nil))
                            ad-do-it))
                        (global-undo-tree-mode)))
        (:name unipoint              :type git
               :url "https://github.com/apgwoz/unipoint.git"
               :after (autoload 'unipoint-mode "unipoint"))
        (:name wgrep                 :type git
               :url "https://github.com/mhayashi1120/Emacs-wgrep.git")
        (:name wordnet               :type http
               :url "http://xwl.appspot.com/ref/wordnet.el")
        (:name xcscope
               :features nil)
        yasnippet
        ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(el-get 'sync '(el-get diminish))
(el-get-cleanup (append '(el-get)
                        (mapcar 'el-get-source-name el-get-sources)))
(el-get 'sync (append '(el-get)
                      (mapcar 'el-get-source-name el-get-sources)))
(my-regenerate-autoloads)

(provide 'my-package)
