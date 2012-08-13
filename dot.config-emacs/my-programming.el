;;; my-programming.el --- Programming preferences.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Semantic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; [END] Semantic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code editing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General preferences

(my-define-hook 'my-programming-mode-hook
                '(c-mode-hook
                  c++-mode-hook
                  python-mode-hook
                  emacs-lisp-mode-hook
                  makefile-mode-hook))

;; ;; Make scripts executable on Save (saves having to do the chmod every time)
;; (add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

;; Use year ranges instead of a (possibly) long list of years
(setq copyright-year-ranges t)
(defcustom my-copyright-fixes t
  "Whether to try to fix copyright information before writing.")

(my-add-hook 'my-programming-mode-hook
          '(lambda ()
             ;; (flyspell-prog-mode)       ; flyspell for comments and strings

             ;; Highlight parentheses around point
             (highlight-parentheses-mode 1)

             ;; Highlight a symbol
             (local-set-key [(meta f5)] 'highlight-symbol-at-point)
             (local-set-key [(meta f6)] 'highlight-symbol-at-point)
             (local-set-key [f5] 'highlight-symbol-prev)
             (local-set-key [f6] 'highlight-symbol-next)

             ;; Highlight TODO's and the like
             (fic-ext-mode 1)

             ;; (which-function-mode 1)    ; show current tag in modeline

             ;; Update the year in copyright message
             (add-hook 'before-save-hook
                       '(lambda ()
                          (when my-copyright-fixes
                            (save-excursion (copyright-fix-years)))))
             (add-hook 'before-save-hook 'copyright-update)

             ;; Auto-indent new line
             (local-set-key [return] 'newline-and-indent)
             ;; ;; Auto-indent new line (plus previous)
             ;; (local-set-key [return] 'reindent-then-newline-and-indent)

             ;; ECB
             (my-define-ecb-layouts '("my-programming-left-right"
                                      "my-programming-right"
                                      "my-files"))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CC Mode -- C, C++, Objective-C, Java, IDL, Pike, ...

(setq-default
 c-default-style "stroustrup"           ; indentation style
 ;; c-basic-offset tab-width               ; indentation width
 cpp-face-type 'dark                    ; use colors suitable for a dark bg
 cpp-known-face 'highlight)
(add-hook 'c-mode-common-hook
          '(lambda ()
             (setq c-electric-pound-behavior '(alignleft))
             (c-toggle-auto-newline 1)  ; auto-newline on semi-colon, etc.
             (c-toggle-hungry-state 1)  ; hungry backspace
             ;; Fixup for auto-added spaces on braces
             (add-to-list 'c-cleanup-list 'defun-close-semi)
             (add-to-list 'c-cleanup-list 'list-close-comma)
             (cpp-highlight-buffer t)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Makefile

;; Highlight white spaces
(add-hook 'makefile-mode-hook 'whitespace-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python

;; `flymake'
(add-hook 'python-mode-hook
          '(lambda ()
             (when (buffer-file-name)
               ;; Configure to wait a bit longer after edits before starting
               (setq-default flymake-no-changes-timeout '3)
               (flymake-mode t))))

;; `ipython'
(add-hook 'python-mode-hook
          '(lambda ()
             (setq python-shell-interpreter "ipython"
                   python-shell-interpreter-args "--colors=nocolor"
                   python-shell-prompt-regexp "In \\[[0-9]+\\]: "
                   python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: "
                   python-shell-completion-setup-code "from IPython.core.completerlib import module_completion"
                   python-shell-completion-module-string-code "';'.join(module_completion('''%s'''))\n"
                   python-shell-completion-string-code "';'.join(get_ipython().Completer.all_completions('''%s'''))\n")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; [END] Code editing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Documentation

;; Comment editing
(my-add-hook 'my-programming-mode-hook
             '(lambda ()
                (auto-fill-mode 1)         ; auto-wrap lines in comments
                (require 'filladapt)
                (turn-on-filladapt-mode)))
(add-hook 'c-mode-common-hook
          '(lambda ()
             ;; Auto-end comment block when inserting `/' (override: C-q /)
             (add-to-list 'c-cleanup-list 'comment-close-slash)
             (doc-mode t)               ; manage doxygen documentation
             (c-setup-filladapt)))


;; Documentation editors
(setq c-doc-comment-style nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Templates

;; `template': File templates
;; TODO: replace with cedet's `srecode'
(autoload 'template-initialize (path my-code-dir "template" "lisp" "template"))
(add-to-list 'my-recompile-objs (path my-code-dir "template" "lisp"))
(my-add-hook 'my-programming-mode-hook
             '(lambda ()
                (setq template-default-directories
                      (cons
                       (if (file-directory-p (path my-data-dir "templates" ""))
                           (path my-data-dir "templates" "")
                         nil)
                       nil))
                (template-initialize)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code completion

;; `company-mode'
;; http://nschum.de/src/emacs/company-mode
;; http://www.emacswiki.org/emacs/CompanyMode

;; (require 'company)
;; (global-company-mode t)

(eval-after-load 'company
  '(progn

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
               '(lambda (manually) (my-set-minibuffer-helpers -1)))
     (add-hook 'company-completion-cancelled-hook
               '(lambda (manually) (my-set-minibuffer-helpers 1)))
     (add-hook 'company-completion-finished-hook
               '(lambda (candidate) (my-set-minibuffer-helpers 1)))

     ;; Special treatment for documentation buffer
     (my-add-helper-buffer "*Company meta-data*")

     ;; ;; Show documentation buffer when selecting a completion
     ;; ;; taken from `company-show-doc-buffer'
     ;; (add-hook 'company-completion-finished-hook
     ;;           '(lambda (candidate)
     ;;              (let ((doc-buffer (company-call-backend 'doc-buffer candidate)))
     ;;                (if doc-buffer
     ;;                    (progn
     ;;                      (with-current-buffer doc-buffer
     ;;                        (goto-char (point-min)))
     ;;                      (display-buffer doc-buffer t))))))

     (my-add-hook 'my-programming-mode-hook
                  '(lambda ()
                     (local-set-key [(meta tab)] 'company-complete)))))


;; `auto-complete'

;; TODO: not declared as auto-loaded...
(require 'auto-complete)
(global-auto-complete-mode t)

(defun my-ac-source-semantic-enable ()
  (add-to-list 'ac-sources 'ac-source-semantic-raw)
  (add-to-list 'ac-sources 'ac-source-semantic))

(eval-after-load 'auto-complete
  '(progn
     (require 'auto-complete-config)
     (ac-flyspell-workaround)
     (setq ac-dwim t                    ; be clever on TAB/RET
           ac-use-quick-help t          ; show popup (otherwise use f1/C-?) ...
           ac-quick-help-delay 0.2      ; ... almost immediately
           ;; ac-auto-start nil              ; do not start automatically
           ac-auto-show-menu nil          ; do not show menu when auto-starting
           ac-use-menu-map t)           ; allow C-n/C-p in completion menu
     (add-hook 'auto-complete-mode-hook
               '(lambda ()
                  ;; (setq yas/trigger-key nil)
                  (ac-set-trigger-key "TAB")
                  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
                  (define-key ac-mode-map (kbd "C-c h") 'ac-last-quick-help)
                  (define-key ac-mode-map (kbd "C-c H") 'ac-last-help)))

     (my-add-hook 'c-mode-common-hook
                  '(lambda ()
                     (add-to-list 'ac-sources 'ac-source-filename)
                     (my-ac-source-semantic-enable)))

     (add-hook 'emacs-lisp-mode-hook 'ac-emacs-lisp-mode-setup)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code navigation

;; Special treatment for tags buffer
(my-add-helper-buffer "*cscope*")

(my-add-hook 'my-programming-mode-hook
             '(lambda ()
                (require 'xcscope)
                (cscope-minor-mode)
                (local-set-key [(control c) (i)] ; open included file at point
                               'semantic-decoration-include-visit)
                (local-set-key [(control c) (g)] ; jump to declaration
                               'semantic-ia-fast-jump)
                (local-set-key [(control c) (t)] ; toggle declaration / definition
                               'semantic-analyze-proto-impl-toggle)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code help

;; Special treatment for documentation buffer
(my-add-helper-buffer "*TAG DOCUMENTATION*")

(my-add-hook 'my-programming-mode-hook
             '(lambda ()
                (local-set-key [f1] 'semantic-ia-show-summary)
                (local-set-key [(meta f1)] 'semantic-ia-show-doc)
                (local-set-key [(shift f1)] 'semantic-ia-describe-class)))


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
      (call-interactively 'compile)
    (condition-case nil
        (call-interactively 'kill-compilation)
      (error (call-interactively 'recompile))))
  nil)
;; global keybinding
(global-set-key [f8] 'my-dwim-compile)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Debug

(setq gdb-many-windows t)               ; it's usually nicer to have them all


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; `flymake': Continuous compilation

;; Show error message in minibuffer
(defun my-flymake-show-message ()
  (if (get-char-property (point) 'flymake-overlay)
      (let ((help (get-char-property (point) 'help-echo)))
        (if help (message "%s" help)))))
(add-hook 'post-command-hook
          '(lambda ()
             (my-set-minibuffer-helpers (not (my-flymake-show-message)))))


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

(global-set-key [(meta shift down)]  'gud-next)   ;; next line
(global-set-key [(meta shift right)] 'gud-step)   ;; step into line
(global-set-key [(meta shift up)]    'gud-finish) ;; finish function
(global-set-key [(meta shift left)]  'gud-until)  ;; until line


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Version control

;; psvn
(add-hook 'svn-status-mode-hook
          '(lambda ()
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

(provide 'my-programming)
