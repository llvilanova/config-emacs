;;; my-programming.el --- Programming preferences.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Semantic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; show summary of symbol under point
(add-to-list 'semantic-default-submodes 'global-semantic-idle-summary-mode)
;; decore tags based on their attributes
(add-to-list 'semantic-default-submodes 'global-semantic-decoration-mode)
;; highlight current tag
(add-to-list 'semantic-default-submodes 'global-semantic-highlight-func-mode)
;; display header for topmost tag
(add-to-list 'semantic-default-submodes 'global-semantic-stickyfunc-mode)
;; C-x B => MRU list of edited tags
(add-to-list 'semantic-default-submodes 'global-semantic-mru-bookmark-mode)

(semantic-mode 1)                       ; global minor mode

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
(which-func-mode 1)                     ; show current tag in modeline
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
             ;; Highlight parentheses around point
             (highlight-parentheses-mode 1)

             ;; Highlight a symbol
             (local-set-key [(meta f5)] 'highlight-symbol-at-point)
             (local-set-key [(meta f6)] 'highlight-symbol-at-point)
             (local-set-key [f5] 'highlight-symbol-prev)
             (local-set-key [f6] 'highlight-symbol-next)
             ;; Highlight TODO's and the like
             (fic-mode t)               ; TODO: must be re-enabled before it
             (font-lock-fontify-buffer) ;       works (like `doc-mode')

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
                                      "my-files"))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CC Mode -- C, C++, Objective-C, Java, IDL, Pike, ...

(setq my-cc-mode-hook nil)
(add-hook 'c-mode-common-hook
          '(lambda () (run-hooks 'my-programming-mode-hook 'my-cc-mode-hook)))

(setq-default
 c-default-style "stroustrup"           ; indentation style
 ;; c-basic-offset tab-width               ; indentation width
 cpp-face-type 'dark                    ; use colors suitable for a dark bg
 cpp-known-face 'highlight)
(add-hook 'my-cc-mode-hook
          '(lambda ()
             (c-toggle-auto-newline 1)  ; auto-newline on semi-colon, etc.
             (c-toggle-hungry-state 1)  ; hungry backspace
             ;; Fixup for auto-added spaces on braces
             (add-to-list 'c-cleanup-list 'defun-close-semi)
             (add-to-list 'c-cleanup-list 'list-close-comma)
             (cpp-highlight-buffer t)))


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

;; `ipython': Use `py-shell' to bring an ipython shell up, while `python-shell'
;;            still uses the regular shell
(add-hook 'my-python-mode-hook
          '(lambda ()
             (require 'ipython)))

;; `flymake'
(add-hook 'my-python-mode-hook
          '(lambda ()
             (when (buffer-file-name)
               ;; Configure to wait a bit longer after edits before starting
               (setq-default flymake-no-changes-timeout '3)
               (flymake-mode t))))


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
             (turn-on-filladapt-mode)))
(add-hook 'my-cc-mode-hook
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
          '(lambda (manually) (my-set-minibuffer-helpers nil)))
(add-hook 'company-completion-cancelled-hook
          '(lambda (manually) (my-set-minibuffer-helpers t)))
(add-hook 'company-completion-finished-hook
          '(lambda (candidate) (my-set-minibuffer-helpers t)))

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

;; Special treatment for documentation buffer
(my-add-helper-buffer "*Company meta-data*")

(add-hook 'my-programming-mode-hook
          '(lambda ()
             (company-mode 1)
             (local-set-key [(meta tab)] 'company-complete)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code navigation

;; Special treatment for tags buffer
(my-add-helper-buffer "*cscope*")

(add-hook 'my-programming-mode-hook
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

(add-hook 'my-programming-mode-hook
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
