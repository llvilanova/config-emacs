;;; my-programming.el --- Programming preferences.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Semantic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(semantic-mode 1)                       ; global minor mode

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code tagging (semanticdb)
(setq semanticdb-default-save-directory ; where to store tag cache files
      (path my-cache-dir "semanticdb")) ; TODO: use a project-specific dir

(global-semanticdb-minor-mode 1)

(require 'semantic/db-global)           ; enable support for `GNU global'
(semanticdb-enable-gnu-global-databases 'c-mode)
(semanticdb-enable-gnu-global-databases 'c++-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Idle scheduler
(global-semantic-idle-summary-mode 1)   ; show summary of symbol under point
(global-semantic-idle-tag-highlight-mode 1) ; highlight tag under point

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous
(require 'semantic/sb)                  ; display semantic tags in SpeedBar
(global-semantic-mru-bookmark-mode 1)   ; C-x B => MRU list of edited tags
(global-semantic-stickyfunc-mode 1)     ; display header for topmost tag
(global-semantic-highlight-func-mode 1) ; highlight current tag
(which-func-mode 1)                     ; show current tag in modeline
(global-semantic-decoration-mode 1)     ; decore tags based on their attributes
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
;; Setup activation hooks (`my-programming-mode-hook')
(setq my-programming-mode-hook nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General preferences

;; ;; Make scripts executable on Save (saves having to do the chmod every time)
;; (add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

(add-hook 'my-programming-mode-hook
          '(lambda ()
             ;; Show trailing whitespaces
             (setq show-trailing-whitespace t)

             ;; Highlight parentheses around point
             (highlight-parentheses-mode 1)

             ;; Highlight a symbol
             (local-set-key [(meta f5)] 'highlight-symbol-at-point)
             (local-set-key [(meta f6)] 'highlight-symbol-at-point)
             (local-set-key [f5] 'highlight-symbol-prev)
             (local-set-key [f6] 'highlight-symbol-next)

             ;; Show current function in the modeline
             (which-func-mode 1)

             ;; Update the year in copyright message
             (add-hook 'before-save-hook
                       '(lambda ()
                          (copyright-update)
                          ))

             ;; Auto-indent new line
             (local-set-key [return] 'newline-and-indent)
             ;; ;; Auto-indent new line (plus previous)
             ;; (local-set-key [return] 'reindent-then-newline-and-indent)

             ;; ECB
             (my-define-ecb-layouts '("my-programming-left-right"
                                      "my-programming-right"
                                      "my-files"))
            ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CC Mode -- C, C++, Objective-C, Java, IDL, Pike, ...

(setq my-cc-mode-hook nil)
(add-hook 'c-mode-common-hook
          '(lambda () (run-hooks 'my-programming-mode-hook 'my-cc-mode-hook)))

(setq-default
 c-default-style "stroustrup"           ; indentation style
 ;; c-basic-offset tab-width               ; indentation width
 )
(add-hook 'my-cc-mode-hook
          '(lambda ()
             (c-toggle-auto-newline 1)  ; auto-newline on semi-colon, etc.
             (c-toggle-hungry-state 1)  ; hungry backspace
             ;; Fixup for auto-added spaces on braces
             (add-to-list 'c-cleanup-list 'defun-close-semi)
             (add-to-list 'c-cleanup-list 'list-close-comma)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Makefile

(setq my-makefile-mode-hook nil)
(add-hook 'makefile-mode-hook
          '(lambda () (run-hooks 'my-programming-mode-hook
                                 'my-makefile-mode-hook)))

(add-hook 'my-makefile-mode
          '(lambda ()
            ;; Highlight white spaces
            (delq (set-local whitespace-style) 'newline-mark)
            (whitespace-mode 1)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python

(setq my-python-mode-hook nil)
(add-hook 'python-mode-hook
          '(lambda () (run-hooks 'my-programming-mode-hook
                                 'my-python-mode-hook)))

(add-hook 'my-python-mode-hook
          '(lambda ()
             (highlight-80+-mode t)))   ; TODO: `develock' not in `python-mode'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emacs Lisp
(setq my-emacs-lisp-mode-hook nil)
(add-hook 'emacs-lisp-mode-hook
          '(lambda () (run-hooks 'my-programming-mode-hook
                                 'my-emacs-lisp-mode-hook)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; [END] Code editing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Documentation

;; Comment editing
(add-hook 'my-programming-mode-hook
          '(lambda ()
             (auto-fill-mode 1)         ; auto-wrap lines in comments
             (require 'filladapt)
             (add-to-list (make-local-variable 'filladapt-token-table)
                          '("^[ \t]*\\*[^ \t]*" c++-comment))
             (turn-on-filladapt-mode)))
(add-hook 'my-cc-mode-hook
          '(lambda ()
             ;; Auto-end comment block when inserting `/' (override: C-q /)
             (add-to-list 'c-cleanup-list 'comment-close-slash)))


;; Documentation editors
(setq c-doc-comment-style nil)
;; TODO: a bug in `doc-mode' requires manual activation to show font locks
;; (add-hook 'c-mode-common-hook doc-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Templates

;; `template': File templates
;; TODO: replace with cedet's `srecode'
(autoload 'template-initialize (path my-code-dir "template" "lisp" "template"))
(add-to-list 'my-recompile-cmds (path my-code-dir "template" "lisp"))
(add-hook 'my-programming-mode-hook
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

(setq company-idle-delay nil)           ; no idle completion

;; temporally disable `semantic-idle-summary-mode' when completing
(add-hook 'company-completion-started-hook
          '(lambda (manually) (semantic-idle-summary-mode -1)))
(add-hook 'company-completion-cancelled-hook
          '(lambda (manually) (semantic-idle-summary-mode 1)))
(add-hook 'company-completion-finished-hook
          '(lambda (candidate)
             (semantic-idle-summary-mode 1)))

;; Show documentation buffer when selecting a completion
;; taken from `company-show-doc-buffer'
(add-hook 'company-completion-finished-hook
          '(lambda (candidate)
             (let ((doc-buffer (company-call-backend 'doc-buffer candidate)))
               (if doc-buffer
                   (progn
                     (with-current-buffer doc-buffer
                       (goto-char (point-min)))
                     (display-buffer doc-buffer t))))))

;; Special treatment for documentation buffer
(add-hook 'ecb-activate-hook
          '(lambda ()
             (add-to-list 'ecb-compilation-buffer-names
                          '("*Company meta-data*" . nil))))

(add-hook 'my-programming-mode-hook
          '(lambda ()
             (company-mode 1)
             (local-set-key [(meta tab)] 'company-complete)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code navigation

;; Special treatment for tags buffer
(add-hook
 'ecb-activate-hook
 '(lambda () (add-to-list 'ecb-compilation-buffer-names '("*cscope*" . nil))))

(add-hook 'my-programming-mode-hook
          '(lambda ()
             (require 'xcscope)
             (local-set-key [(control c) (i)] ; open included file at point
                            'semantic-decoration-include-visit)
             (local-set-key [(control c) (g)] ; jump to declaration
                            'semantic-ia-fast-jump)
             (local-set-key [(control c) (t)] ; toggle declaration / definition
                            'semantic-analyze-proto-impl-toggle)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code help

;; Special treatment for documentation buffer
(add-hook
 'ecb-activate-hook
 '(lambda ()
    (add-to-list 'ecb-compilation-buffer-names '("*TAG DCUMENTATION*" . nil))))

(add-hook 'my-programming-mode-hook
          '(lambda ()
             (local-set-key [f1] 'semantic-ia-show-summary)
             (local-set-key [(meta f1)] 'semantic-ia-show-doc)
             (local-set-key [(shift f1)] 'semantic-ia-describe-class)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Compilation

(setq compilation-scroll-output t   ; follow compilation output
      compilation-window-height 10)

;; Save compilation commands in desktop
(add-to-list 'desktop-globals-to-save 'compile-command)
(add-to-list 'desktop-globals-to-save 'compile-history)


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


(provide 'my-programming)
