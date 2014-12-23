;;; my-programming.el --- Programming preferences.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Packages

(defun my-programming-setup ()
  (my-add-packages
   '(
     auto-complete
     ;; (:name company               :type elpa)
     (:name doc-mode              :type http
            :url "http://nschum.de/src/emacs/doc-mode/doc-mode.el")
     (:name elisp-slime-nav       :type elpa
            :after (progn
                     (add-hook 'emacs-lisp-mode-hook 'elisp-slime-nav-mode)))
     (:name fic-ext-mode
            :lazy t
            :after (add-to-list 'fic-highlighted-words "XXX"))
     flycheck
     (:name flycheck-color-mode-line :type github
            :pkgname "flycheck/flycheck-color-mode-line"
            :after (after 'flycheck
                     (require 'flycheck-color-mode-line)
                     (add-hook 'flycheck-mode-hook
                               'flycheck-color-mode-line-mode))
            )
     (:name guess-style           :type http
            :url "http://nschum.de/src/emacs/guess-style/guess-style.el")
     (:name highlight-parentheses :type elpa)
     (:name highlight-symbol      :type elpa)
     jinja2-mode
     (:name pylint                :type apt-get)
     (:name xcscope
            :features nil)
     )))
(my-hook-once 'prog-mode-hook #'my-programming-setup)


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
;; Convenience menu in 'mouse-3'
(use-package cedet-m3
  :init
  (add-to-list 'semantic-default-submodes 'global-cedet-m3-minor-mode))

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
(use-package semantic/db-cscope
  :init
  (semanticdb-enable-cscope-databases))

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
            ;; (flyspell-prog-mode)       ; flyspell for comments and strings

            ;; Highlight parentheses around point
            (after 'highlight-parentheses
              (highlight-parentheses-mode 1))

            ;; (which-function-mode 1)    ; show current tag in modeline

            ;; Update the year in copyright message
            (add-hook 'before-save-hook
                      (lambda ()
                        (when my-copyright-fixes
                          (save-excursion (copyright-fix-years)))))
            (add-hook 'before-save-hook 'copyright-update)


            (outline-minor-mode t)
            ))

;; `fic-ext-mode': Highlight TODO's and the like
(use-package fic-ext-mode
  :diminish fic-ext-mode
  :config (add-hook 'prog-mode-hook 'fic-ext-mode))

;; `guess-style': guess indentation style
(use-package guess-style
  :init
  (defcustom my-guess-style t
    "Whether opening a new file should try to guess the indentation stule.")

  :config
  (progn
    (defadvice guess-style-guess-all (around my-guess-style-guess-all)
      (when my-guess-style
        ad-do-it))))

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
(after 'smartparens-mode
  (sp-local-pair 'c-mode "{" nil :actions nil)
  (sp-local-pair 'c++-mode "{" nil :actions nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python

;; `ipython'
(add-hook 'python-mode-hook
          (lambda ()
            (setq python-shell-interpreter "ipython"
                  python-shell-interpreter-args "--colors=nocolor"
                  python-shell-prompt-regexp "In \\[[0-9]+\\]: "
                  python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: "
                  python-shell-completion-setup-code "from IPython.core.completerlib import module_completion"
                  python-shell-completion-module-string-code "';'.join(module_completion('''%s'''))\n"
                  python-shell-completion-string-code "';'.join(get_ipython().Completer.all_completions('''%s'''))\n")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Documentation

;; Comment editing
(add-hook 'prog-mode-hook
          (lambda ()
            (auto-fill-mode 1)         ; auto-wrap lines in comments
            (require 'filladapt)
            (turn-on-filladapt-mode)))
(add-hook 'c-mode-common-hook
          (lambda ()
            ;; Auto-end comment block when inserting `/' (override: C-q /)
            (add-to-list 'c-cleanup-list 'comment-close-slash)
            (doc-mode t)               ; manage doxygen documentation
            (c-setup-filladapt)))


;; Documentation editors
(setq c-doc-comment-style nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Templates

(setq srecode-map-save-file (path my-cache-dir "srecode-map.el")
      srecode-insert-ask-variable-method 'field)
(use-package srecode/mode
  :init (global-srecode-minor-mode t))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code completion

;; `company-mode'
;; http://nschum.de/src/emacs/company-mode
;; http://www.emacswiki.org/emacs/CompanyMode

;; (require 'company)
;; (global-company-mode t)

(after 'company
  (defun company-semantic (command &optional arg &rest ignored)
    "A `company-mode' completion back-end using CEDET Semantic."
    (interactive (list 'interactive))
    (case command
      ('interactive (company-begin-backend 'company-semantic))
      ('prefix (and (memq major-mode company-semantic-modes)
                  (semantic-active-p)
                  (not (company-in-string-or-comment))
                  (or (company-semantic--grab) 'stop)))
      ;; ('candidates (if (and (equal arg "")
      ;;                     (looking-back " "))
      ;;                  (company-semantic-completions-raw arg)
      ;;                (company-semantic-completions arg)))
      ('candidates (or (company-semantic-completions arg)
                      (company-semantic-completions-raw arg)))
      ('meta (funcall company-semantic-metadata-function
                      (assoc arg company-semantic--current-tags)))
      ('doc-buffer (company-semantic-doc-buffer
                    (assoc arg company-semantic--current-tags)))
      ;; because "" is an empty context and doesn't return local variables
      ('no-cache (equal arg ""))
      ('location (let ((tag (assoc arg company-semantic--current-tags)))
                   (when (buffer-live-p (semantic-tag-buffer tag))
                     (cons (semantic-tag-buffer tag)
                           (semantic-tag-start tag)))))))

  ;; Temporarily disable `semantic-idle-summary-mode' when completing
  (add-hook 'company-completion-started-hook
            (lambda (manually) (my-set-minibuffer-helpers -1)))
  (add-hook 'company-completion-cancelled-hook
            (lambda (manually) (my-set-minibuffer-helpers 1)))
  (add-hook 'company-completion-finished-hook
            (lambda (candidate) (my-set-minibuffer-helpers 1)))

  ;; Special treatment for documentation buffer
  (my-register-helper-buffer "*Company meta-data*" 'help)

  ;; ;; Show documentation buffer when selecting a completion
  ;; ;; taken from `company-show-doc-buffer'
  ;; (add-hook 'company-completion-finished-hook
  ;;           (lambda (candidate)
  ;;             (let ((doc-buffer (company-call-backend 'doc-buffer candidate)))
  ;;               (if doc-buffer
  ;;                   (progn
  ;;                     (with-current-buffer doc-buffer
  ;;                       (goto-char (point-min)))
  ;;                     (display-buffer doc-buffer t))))))
  )


;; `auto-complete'

;; TODO: not declared as auto-loaded...
(use-package auto-complete
  :init
  (progn
    (setq ac-comphist-file (path my-cache-dir "ac-comphist.dat"))
    (global-auto-complete-mode t)))

;; Enhance semantic completion with yasnippet
(after 'auto-complete-config
  (defun ac-semantic-action ()
    (when (and (boundp 'yas/minor-mode) yas/minor-mode)
      (let* ((tag (car (last (oref (semantic-analyze-current-context) prefix))))
             (class (semantic-tag-class tag))
             (args))
        (when (eq class 'function)
          (setq args (semantic-tag-function-arguments tag))
          (yas/expand-snippet
           (concat "("
                   (mapconcat
                    (lambda (arg)
                      (let ((arg-type (semantic-format-tag-type arg nil))
                            (arg-name (semantic-format-tag-name arg nil)))
                        (concat "${"
                                (if (string= arg-name "")
                                    arg-type
                                  (concat arg-type " " arg-name))
                                "}")))
                    args
                    ", ")
                   ")$0"))))))
  (add-to-list 'ac-source-semantic
               '((action . ac-semantic-action)))
  (add-to-list 'ac-source-semantic-raw
               '((action . ac-semantic-action))))

(defun my-ac-source-semantic-enable ()
  (yas-minor-mode 1)                    ; enable yasnippet for arg placeholders
  (add-to-list 'ac-sources 'ac-source-semantic-raw)
  (add-to-list 'ac-sources 'ac-source-semantic))

(after 'auto-complete
  (require 'semantic/ia)
  (require 'auto-complete-config)
  (ac-flyspell-workaround)
  (setq ac-dwim t                    ; be clever on TAB/RET
        ac-use-quick-help t          ; show popup (otherwise use f1/C-?) ...
        ac-quick-help-delay 0.2      ; ... almost immediately
        ac-auto-start nil              ; do not start automatically
        ac-auto-show-menu nil          ; do not show menu when auto-starting
        ac-use-menu-map t)           ; allow C-n/C-p in completion menu
  (add-hook 'auto-complete-mode-hook
            (lambda ()
              ;; (setq yas-trigger-key nil)
              (ac-set-trigger-key "TAB")))

  (add-hook 'c-mode-common-hook
            (lambda ()
              (add-to-list 'ac-sources 'ac-source-filename)
              (my-ac-source-semantic-enable)))

  (add-hook 'emacs-lisp-mode-hook 'ac-emacs-lisp-mode-setup))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code navigation

;; `xcscope'
(use-package xcscope
  :init
  (progn
    ;; ;; Special treatment for tags buffer
    ;; (my-register-helper-buffer "*cscope*" 'long-help)
    (add-hook 'prog-mode-hook 'cscope-minor-mode)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code help

;; Special treatment for documentation buffer
(my-register-helper-buffer "*TAG DOCUMENTATION*" 'help)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Compilation

(setq compilation-scroll-output t)      ; follow compilation output
;; compilation-window-height 10         ; fix maximum number of lines

;; Save compilation commands in desktop
(add-to-list 'desktop-globals-to-save 'compile-command)
(add-to-list 'desktop-globals-to-save 'compile-history)

;; All-in-one DWIM compilation
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
  nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; `flycheck': Continuous compilation

(use-package flycheck
  :defer t
  :init (global-flycheck-mode t))

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
(my-register-helper-buffer 'diff-mode 'long-info)
(my-register-helper-buffer 'log-edit-mode 'info)
(my-register-helper-buffer 'vc-git-log-edit-mode 'info)

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

(provide 'my-programming)
