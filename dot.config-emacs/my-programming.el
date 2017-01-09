;;; my-programming.el --- Programming preferences.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Packages

(defun my-programming-setup ()
  (my-add-packages
   '(
     (:name irony-mode            :type apt-get)
     (:name lua-mode              :type apt-get)
     (:name pylint                :type apt-get)
     )))
(my-add-init-hook 'prog-mode-hook #'my-programming-setup)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Semantic

;; ;; show summary of symbol under point
;; (add-to-list 'semantic-default-submodes 'global-semantic-idle-summary-mode)
;; decore tags based on their attributes
(add-to-list 'semantic-default-submodes 'global-semantic-decoration-mode)
;; highlight current tag
(add-to-list 'semantic-default-submodes 'global-semantic-highlight-func-mode)
;; ;; display header for topmost tag
;; (add-to-list 'semantic-default-submodes 'global-semantic-stickyfunc-mode)
;; C-x B => MRU list of edited tags
(add-to-list 'semantic-default-submodes 'global-semantic-mru-bookmark-mode)

;; ;; Convenience menu in 'mouse-3'
;; (use-package cedet-m3
;;   :commands global-cedet-m3-minor-mode
;;   :init
;;   (add-to-list 'semantic-default-submodes 'global-cedet-m3-minor-mode))

(semantic-mode 1)                       ; global minor mode

;; TODO: not available through `semantic-default-submodes'
;; display header with FQN of symbol under point
(global-semantic-idle-breadcrumbs-mode 1)

;; Let the user temporarily disable some minibuffer output
(setq my--enable-semantic-idle-summary-idle-function t)
(make-variable-buffer-local 'my--enable-semantic-idle-summary-idle-function)
(defadvice semantic-idle-summary-idle-function (around
                                                my--semantic-idle-summary-idle-function
                                                activate compile)
  (when my--enable-semantic-idle-summary-idle-function
    ad-do-it))
(defun my-set-minibuffer-helpers (state)
  "Temporarily enable/disable helpers that show state in the minibuffer."
  (setq my--enable-semantic-idle-summary-idle-function state))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code tagging (semanticdb)
(setq semanticdb-default-save-directory ; where to store tag cache files
      (path my-cache-dir "semanticdb")) ; TODO: use a project-specific dir

(global-semanticdb-minor-mode 1)

(semanticdb-enable-gnu-global-databases 'c-mode)
(semanticdb-enable-gnu-global-databases 'c++-mode)
;; (use-package semantic/db-cscope
;;   :init
;;   (semanticdb-enable-cscope-databases))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Idle scheduler
(global-semantic-idle-local-symbol-highlight-mode 1) ; highlight symbol under point

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous
(require 'semantic/sb)                  ; display semantic tags in SpeedBar
(semantic-toggle-decoration-style "semantic-tag-boundary" -1)
(semantic-toggle-decoration-style "semantic-decoration-on-private-members" t)
(semantic-toggle-decoration-style "semantic-decoration-on-protected-members" t)
(setq pulse-iterations 3)               ; make pulsing faster
(ede-enable-generic-projects)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Code editing

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General preferences

;; ;; Make scripts executable on Save (saves having to do the chmod every time)
;; (add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

;; Use year ranges instead of a (possibly) long list of years
(setq copyright-year-ranges t)
(defcustom my-copyright-fixes t
  "Whether to try to fix copyright information before writing.")

(add-hook 'prog-mode-hook
          (lambda ()
            (flyspell-prog-mode)        ; flyspell for comments and strings

            ;; (which-function-mode 1)    ; show current tag in modeline

            ;; Update the year in copyright message
            (add-hook 'before-save-hook
                      (lambda ()
                        (when my-copyright-fixes
                          (save-excursion (copyright-fix-years)))))
            (add-hook 'before-save-hook 'copyright-update)


            (outline-minor-mode t)))

;; `highlight-parentheses': highlight parentheses around point
(use-package highlight-parentheses
  :ensure t
  :defer t
  :diminish highlight-parentheses-mode
  :init (add-hook 'prog-mode-hook #'highlight-parentheses-mode))

;; `fic-ext-mode': Highlight TODO's and the like
(use-package fic-ext-mode
  :ensure t
  :defer t
  :diminish fic-ext-mode
  :init (add-hook 'prog-mode-hook 'fic-ext-mode)
  :config (add-to-list 'fic-highlighted-words "XXX"))

;; `dtrt-indent': guess indentation style
(use-package dtrt-indent
  :ensure t
  :init
  (add-hook 'emacs-startup-hook #'dtrt-indent-mode))

;; `highlight-symbol': text/symbol highlighting
(use-package highlight-symbol
  :ensure t
  :bind (("M-<f6>" . highlight-symbol-at-point)
         ("<f5>" . highlight-symbol-prev)
         ("<f6>" . highlight-symbol-next)))

(use-package page-break-lines
  :ensure t
  :init
  (add-hook 'emacs-startup-hook #'global-page-break-lines-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Lisp

(add-hook 'eval-expression-minibuffer-setup-hook 'eldoc-mode)
;; TODO: electric-pair-mode

(use-package elisp-slime-nav
  :ensure t
  :defer t
  :diminish elisp-slime-nav-mode
  :init (add-hook 'emacs-lisp-mode-hook #'elisp-slime-nav-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CC Mode -- C, C++, Objective-C, Java, IDL, Pike, ...

(setq-default
 c-default-style "stroustrup"           ; indentation style
 ;; c-basic-offset tab-width               ; indentation width
 cpp-face-type 'dark                    ; use colors suitable for a dark bg
 cpp-known-face 'highlight)
(add-hook 'c-mode-common-hook
          (lambda ()
            (setq c-electric-pound-behavior '(alignleft))
            (c-toggle-auto-newline 1)  ; auto-newline on semi-colon, etc.
            (c-toggle-hungry-state 1)  ; hungry backspace
            ;; Fixup for auto-added spaces on braces
            (add-to-list 'c-cleanup-list 'defun-close-semi)
            (add-to-list 'c-cleanup-list 'list-close-comma)
            (cpp-highlight-buffer t)))

;; Otherwise overrides `c-toggle-auto-newline'
(use-package smartparens
  :defer t
  :init
  (add-hook 'c-mode-common-hook
            (lambda ()
              (sp-local-pair 'c-mode "{" nil :actions nil)
              (sp-local-pair 'c++-mode "{" nil :actions nil))))

(use-package disaster
  :defer t
  :init (add-hook 'c-mode-common-hook (lambda () (require 'disaster))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python

;; `ipython'
(when (executable-find "ipython")
  (add-hook 'python-mode-hook
            (lambda ()
              (setq python-shell-interpreter "ipython"))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Documentation

;; Comment editing
(add-hook 'c-mode-common-hook
          (lambda ()
            ;; Auto-end comment block when inserting `/' (override: C-q /)
            (add-to-list 'c-cleanup-list 'comment-close-slash)))

;; `filladapt-mode': fill comment blocks
;; http://wonderworks.com/download/filladapt.el
(use-package filladapt
  :diminish filladapt-mode
  :init
  (add-hook 'prog-mode-hook
            (lambda ()
              (auto-fill-mode 1)
              (turn-on-filladapt-mode)))
  (add-hook 'c-mode-common-hook #'c-setup-filladapt))

;; Documentation editors
(setq c-doc-comment-style nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Templates

(setq srecode-map-save-file (path my-cache-dir "srecode-map.el")
      srecode-insert-ask-variable-method 'field)
;; (use-package srecode/mode
;;   :init (global-srecode-minor-mode t))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code completion

;; `yasnippet'
(use-package yasnippet
  :ensure t
  :defer t
  :diminish yas-minor-mode)


;; `company'
(use-package company
  :ensure t
  :bind (("M-<tab>" . company-complete))
  :config
  (global-company-mode t)

  (use-package company-c-headers
    :ensure t
    :commands 'company-c-headers
    :init (add-hook 'company-backends 'company-c-headers))

  (use-package company-irony
    :ensure t
    :commands 'company-irony
    :init (add-hook 'company-backends 'company-irony))

  (use-package company-quickhelp
    :ensure t
    :commands 'company-quickhelp-mode
    :init (add-hook 'company-mode-hook 'company-quickhelp-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code navigation

;; `xcscope'
(use-package xcscope
  :ensure t
  :defer t
  :init
  (add-hook 'c-mode-common-hook #'cscope-minor-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code help


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Compilation

(use-package compile
  :bind ("<f8>" . my-dwim-compile)

  :init
  (setq compilation-scroll-output t  ; follow compilation output
        ;; compilation-window-height 10 ; fix maximum number of lines
        )

  :config
  ;; Save compilation commands in desktop
  (use-package desktop
    :config
    (add-to-list 'desktop-globals-to-save 'compile-command)
    (add-to-list 'desktop-globals-to-save 'compile-history))

  (require 'ansi-color)
  (defun my-colorize-compilation ()
    "Colorize from `compilation-filter-start' to `point'."
    (let ((inhibit-read-only t))
      (ansi-color-apply-on-region
       compilation-filter-start (point))))

  (add-hook 'compilation-filter-hook #'my-colorize-compilation)

  (defun my-dwim-compile (arg)
    "DWIM compilation.
If compilation is running, use `kill-compilation'.
Otherwise, use `recompile'.

If ARG is not nil, force a call to `compile'."
    (interactive "P")
    (if arg
        (call-interactively 'compile nil (vector (list 4)))
      (condition-case nil
          (call-interactively 'kill-compilation)
        (error (call-interactively 'recompile))))
    nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; `flycheck': Continuous compilation

(use-package flycheck
  :ensure t
  :commands global-flycheck-mode
  :init
  (add-hook 'after-init-hook 'global-flycheck-mode)
  (add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c++11"))))

;; Linux-specific includes & defines
(defun my-flycheck-linux ()
  (require 'ede/linux)
  (when (ede-linux-project-p (ede-current-project))
    (setq flycheck-clang-include-path
          (oref (ede-current-project) include-path))
    (setq flycheck-clang-definitions
          '("-D__KERNEL__"))))
(add-hook 'find-file-hook 'my-flycheck-linux t)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Remote compilation

;; You can use `remote-compile' instead of compile to run compilation in
;; another host.
;; This is specially useful when editing remote files (`tramp') or to avoid
;; cross compilations if the edited source is shared among the editing
;; and compiling hosts (e.g., nfs).
(setq remote-compile-prompt-for-host t  ; prompt for host if undefined
      remote-shell-program "ssh")

;; extra state to save in desktop
(add-to-list 'desktop-globals-to-save 'remote-compile-host)
(add-to-list 'desktop-globals-to-save 'remote-shell-program)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Debugging

(setq gdb-many-windows t)               ; it's usually nicer to have them all


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Version control

;; psvn
(add-hook 'svn-status-mode-hook
          (lambda ()
            (add-to-list 'svn-status-default-log-arguments
                         '("--use-merge-history"))))

;; vc
(setq vc-delete-logbuf-window nil       ; bury log after commit (do not delete)
      vc-diff-switches "-u")            ; use unified diff by default

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous

;; `diff-mode'
(setq diff-mode-hook '(diff-delete-empty-files ; do not show empty files
                       diff-make-unified))     ; "diff -u" style
;; `diff'
(unless (listp diff-switches)
  (setq diff-switches (list diff-switches)))
(add-to-list 'diff-switches "-u")
(setq diff-switches (remove "-c" diff-switches))

;; `disaster'
(use-package disaster
  :ensure t)

;; `jinja2-mode'
(use-package jinja2-mode
  :ensure t)

;; `macrostep'
(use-package macrostep
  :ensure t)


(provide 'my-programming)
