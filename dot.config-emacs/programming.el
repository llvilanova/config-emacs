;; -*-mode: Emacs-Lisp; folded-file:t-*-
;; Time-stamp: <2010-05-05 19:38:25 (vilanova)>


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Semantic

(semantic-mode 1)                      ; global minor mode

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
;; TODO: Obsolete (?)
;; (global-senator-minor-mode 1)         ;; Semantic Navigator menu
;; srecode
;; eassist

;;}}} [END] Semantic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Code editing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Configuration parameters

(defvar my-programming-width 80)
(defvar my-insert-tabs nil)
(defvar my-tab-width 4)
(defvar my-programming-style "stroustrup")

(defvar my-programming-ecb-layouts
  '("my-programming-left-right" "my-programming-right" "my-files"))

;;}}}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Generic code editing

;;
;; Activation hooks
(setq my-programming-mode-hook nil)
;;
;; ;; Make scripts executable on Save (saves having to do the chmod every time)
;; (add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)
;;
;; Just set it for everybody
(setq-default
 indent-tabs-mode my-insert-tabs
 tab-width        my-tab-width
 )
;;
;; Settings
(add-hook 'my-programming-mode-hook
          '(lambda ()
             ;; Show trailing whitespaces
             (setq show-trailing-whitespace t)

             ;; Highlight parentheses around point
             (require 'highlight-parentheses)
             (highlight-parentheses-mode 1)

             ;; Highlight a symbol
             (require 'highlight-symbol)
             (local-set-key [(meta f5)] 'highlight-symbol-at-point)
             (local-set-key [(meta f6)] 'highlight-symbol-at-point)
             (local-set-key [f5] 'highlight-symbol-prev)
             (local-set-key [f6] 'highlight-symbol-next)

             ;; Maximum line width
             (setq fill-column my-programming-width)

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
             (my-define-ecb-layouts my-programming-ecb-layouts)
            ))
;;
;; TODO: smart-tab

;; Force usage of tabs
(defun my-use-tabs ()
  (interactive)
  (setq indent-tabs-mode t)
  (develock-mode nil)
  (develock-mode nil))
;;}}}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ CC Mode (C, C++, Objective-C, Java, IDL, Pike, ...)

;;
;; Activation hooks
(setq my-cc-mode-hook nil)
(add-hook 'c-mode-common-hook
          '(lambda () (run-hooks 'my-programming-mode-hook 'my-cc-mode-hook)))
;;
;; Settings
(setq-default
 c-default-style my-programming-style  ; indentation style
 c-basic-offset tab-width              ; indentation width
 )
(add-hook 'my-cc-mode-hook
          '(lambda ()
             (c-toggle-auto-newline 1) ; auto-newline on semi-colon, etc.
             (c-toggle-hungry-state 1) ; backspace deletes all preceding spaces
             ;; Fixup for auto-added spaces on braces
             (add-to-list 'c-cleanup-list 'defun-close-semi)
             (add-to-list 'c-cleanup-list 'list-close-comma)
            ))

;;}}}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Makefile
;;
;; Activation hooks
(setq my-makefile-mode-hook nil)
(add-hook 'makefile-mode-hook
          '(lambda () (run-hooks 'my-programming-mode-hook
                                 'my-makefile-mode-hook)))
;;
;; Settings
(add-hook 'my-makefile-mode
          '(lambda ()
            ;; Highlight white spaces
            (delq (set-local whitespace-style) 'newline-mark)
            (whitespace-mode 1)
            ))
;;}}}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Python
;;
;; Activation hooks
(setq my-python-mode-hook nil)
(add-hook 'python-mode-hook
          '(lambda () (run-hooks 'my-programming-mode-hook
                                 'my-python-mode-hook)))
;;
;; Settings
(add-hook
 'my-python-mode-hook
 '(lambda ()
    (highlight-80+-mode t)             ; TODO: `develock' not in `python-mode'
    ))
;;}}}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Emacs Lisp
(setq my-emacs-lisp-mode-hook nil)
(add-hook 'emacs-lisp-mode-hook '(lambda () (run-hooks 'my-programming-mode-hook 'my-emacs-lisp-mode-hook)))
;;}}}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;}}} [END] Code editing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Documentation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Comment editing

;; TODO: move to `generic.el'
(add-hook 'my-programming-mode-hook
          '(lambda ()
             (auto-fill-mode 1) ; TODO: move to `generic.el'
             ;; Fill comments but not code
             ;; TODO: `cc-mode' already provides this via `c-ignore-auto-fill'
             (set (make-local-variable 'fill-nobreak-predicate)
                  '(lambda ()
                     (not (eq (get-text-property (point) 'face)
                              'font-lock-comment-face))))

             ;; Clever comment filling
             (require 'filladapt)
             (make-variable-buffer-local 'filladapt-token-table)
             (setq filladapt-token-table
                   (append
                    '(
                      ("^[ \t]*\\*[^ \t]*" c++-comment)
                      ("[\\@]\\(param\\|throw\\|exception\\|addtogroup\\|defgroup\\)[ \t]*[A-Za-z_][A-Za-z_0-9]*[ \t]+" bullet)
                      ("[\\@][A-Za-z_]+[ \t]*" bullet)
                      )
                    filladapt-token-table
                    ))
             (turn-on-filladapt-mode) ; TODO: move to `generic.el'
            ))
(add-hook 'my-cc-mode-hook
          '(lambda ()
             ;; Auto-end comment block when inserting `/' (override: C-q /)
             (add-to-list 'c-cleanup-list 'comment-close-slash)
            ))

;;}}}
;; Remember:
;;   C-j  : indented newline
;;   C-M-j: indented newline in a comment


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Documentation editors
(add-hook 'my-cc-mode-hook
          '(lambda ()
             (require 'doc-mode)
             ;; TODO: a bug in `doc-mode' requires manual re-activation to
             ;;       show font-locks
             ;; (doc-mode 1)
             ;; (setq doc-mode-template-start "/*!")
             ))
;; (add-hook 'my-cc-mode-hook
;;           '(lambda ()
;;              (require 'doxymacs)
;;              (doxymacs-mode 1)
;;              (add-hook 'font-lock-mode-hook 'doxymacs-font-lock)
;;              (setq doxymacs-doxygen-style "JavaDoc")
;;              ))
;;}}}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;}}} [END] Documentation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Templates
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ File templates

;; ;; Auto-insert
;; (require 'autoinsert)
;; (auto-insert-mode 1)
;; (add-hook 'find-file-hook 'auto-insert)

;; ;; Create file headers on request (make-header)
;; (require 'header)
;; (require 'header2)
;; (require 'file-template)

;; (require 'file-template)
;; ;; Automatically insert templates
;; (setq file-template-insert-automatically t)
;; (add-hook 'find-file-not-found-hooks 'file-template-find-file-not-found-hook 'append)
;; ;;
;; (add-to-list 'file-template-mapping-alist '("\\.ipp$" . "template.ipp"))
;; (add-to-list 'file-template-paths "~/Projects/oss1/code/trunk/src/emacs-templates/")

;; template
(add-hook 'my-programming-mode-hook
          '(lambda ()
             (add-to-list 'load-path (path my-code-dir "template" "lisp"))
             ;; TODO: does not insert template when creating file from `ido'
             (require 'template)
             ;; TODO: what's `locate-data-directory'?
             (setq template-default-directories
                   (cons
                    (if (file-directory-p (path my-data-dir "templates" ""))
                        (path my-data-dir "templates" "")
                      nil)
                    nil))
             (template-initialize)
             ))

;; ;; Common code skeletons
;; (add-hook 'my-programming-mode-hook
;;           '(lambda ()
;;              (require 'skeleton)
;;              (make-local-variable 'skeleton-pair)
;;              (make-local-variable 'skeleton-pair-on-word)
;;              (make-local-variable 'skeleton-pair-filter-function)
;;              (make-local-variable 'skeleton-pair-alist)
;;              (setq skeleton-pair-on-word t
;;                    skeleton-pair t)
;;              (local-set-key (kbd "(") 'skeleton-pair-insert-maybe)
;;              ;; (local-set-key (kbd "[") 'skeleton-pair-insert-maybe)
;;              ;; (local-set-key (kbd "{") 'skeleton-pair-insert-maybe)
;;              ))

;;}}}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Code templates

;; ;; TODO: Obsolete (?)
;; ;; Enable SRecode (Template management) minor-mode.
;; (setq srecode-map-load-path
;;       (list (srecode-map-base-template-dir)
;;             (path my-data-dir "srecode" "")
;;             ))
;; (add-hook 'my-programming-mode-hook
;;           '(lambda ()
;;          (srecode-minor-mode 1)
;;          (local-set-key [(control c) (r)] 'semantic-symref-rename-local-variable)
;;          ))


;; yasnippet
;; (setq yas/trigger-key [(meta tab)])
;; (require 'yasnippet)
;; (yas/initialize)


;; ;; Tempo code snippets (M-x tempo-template-<template name>)
;; (require 'tempo-snippets)
;; (tempo-define-snippet "iterator"
;;                       '(> "for (" (p "Type: " type) "::iterator " (p "Iterator: " it) " = "
;;                           (p "Container: " container) ".begin();" n>
;;                           (s it) " != " (s container) ".end(); " (s it) "++) {" > n> r n "}" >)
;;                       "fori"
;;                       "Insert a C++ for loop iterating over an STL container."
;;                       nil)
;;
;; ;; Hack to allow TAB to move between overlay elements in `tempo-snippets'
;; (defvar tempo-snippets-source-map (make-sparse-keymap))
;; (define-key tempo-snippets-source-map (kbd "<tab>") 'tempo-snippets-next-field)
;; (define-key tempo-snippets-source-map (kbd "<backtab>") 'tempo-snippets-previous-field)
;; (define-key tempo-snippets-source-map (kbd "C-m") 'tempo-snippets-clear-latest)
;; (defadvice tempo-snippets-finish-source (before clear-post-overlay (o) act)
;;   (delete-overlay (overlay-get o 'tempo-snippets-post)))
;; (defadvice tempo-snippets-insert-source (after install-custom-map act)
;;   (let ((overlay (car tempo-snippets-sources)))
;;     (overlay-put overlay 'keymap tempo-snippets-source-map)
;;     (overlay-put overlay 'tempo-snippets-post (point))))
;; (defadvice tempo-snippets-insert-template (after install-post-map act)
;;   (dolist (s tempo-snippets-sources)
;;     (let ((pos (overlay-get s 'tempo-snippets-post)))
;;       (when (integerp pos)
;;         (let ((o (make-overlay pos (1+ pos))))
;;           (overlay-put o 'keymap tempo-snippets-source-map)
;;           (overlay-put s 'tempo-snippets-post o)))))
;;   ad-return-value)

;;}}}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;}}} [END] Templates
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Code completion

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq tab-always-indent  'complete      ; let TAB do completion
      completions-format 'vertical)     ; clearly separate completions

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;{{{ Generic interface

;; (defun my-code-completion-set-frontend (func &optional mode)
;;   ;; TODO: only completes partiaally entered symbol names, not from C/C++
;;   ;; "."/"->" prefixes
;;   ;; (add-to-list 'smart-tab-completion-functions-alist
;;   ;;              (cons (or mode major-mode) func))
;;   (local-set-key my-code-completion-key func)
;;   )

;; ;;}}}

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;{{{ Auto Complete

;; ;; http://www.emacswiki.org/emacs/AutoComplete
;; (defun my-code-completion-frontend--auto-complete ()
;;   "Auto Complete."
;;   (add-to-list 'load-path (path my-code-dir "auto-complete"))
;;   (require 'auto-complete-config)

;;   (define-key ac-complete-mode-map [(control n)] 'ac-next)
;;   (define-key ac-complete-mode-map [(control p)] 'ac-previous)
;;   ;; (define-key ac-complete-mode-map [(meta tab)] 'ac-previous)

;;   ;; "Do What I Mean"- mode
;;   (setq ac-dwim t)

;;   ;; Initialize selected backends
;;   (setq-default ac-sources '())
;;   ;; (ac-c++-keywords-initialize)
;;   ;; (ac-ropemacs-initialize)
;;   (ac-semantic-initialize)
;;   (ac-yasnippet-initialize)

;;   ;; When to enable `auto-complete-mode'
;;   (add-hook 'my-programming-mode-hook
;;             '(lambda ()
;;                (auto-complete-mode 1)
;;                ;; Do not start completion automatically
;;                (setq ac-auto-start nil)
;;                (my-code-completion-set-frontend 'ac-start)
;;                ;; ;; Start completion after 3 chars
;;                ;; (setq ac-auto-start 3)
;;                ;; TODO: should be automatically setup'ed on `initialize'
;;                (push 'ac-source-semantic ac-sources)
;;                (push 'ac-source-yasnippet ac-sources)
;;                ))

;;   (add-hook 'my-cc-mode-hook
;;             '(lambda ()
;;                (push '("\\." ac-source-semantic) ac-omni-completion-sources)
;;                (push '("\\-\\>"  ac-source-semantic) ac-omni-completion-sources)
;;                ))
;;   )

;; ;;}}}

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;{{{ Company mode
;; ;; http://nschum.de/src/emacs/company-mode
;; ;; http://www.emacswiki.org/emacs/CompanyMode
;; (defun my-code-completion-frontend--company-mode ()
;;   "company-mode."
;;   (add-to-list 'load-path (path my-code-dir "company"))
;;   ;; (autoload 'company-mode "company" nil t)
;;   ;; (require 'semantic-ia)
;;   (add-hook 'my-programming-mode-hook
;;             '(lambda ()
;;                (require 'company)
;;                (setq company-idle-delay nil)
;;                (company-mode 1)
;;                ;; Bindings
;;                (my-code-completion-set-frontend 'company-complete)
;;                ;; ;; Trigger auto-completion
;;                ;; (setq (make-local-variable 'company-auto-complete-chars) (?. ?>))
;;                ;; ;; Show summary of completed result
;;                ;; (add-hook 'company-completion-finished-hook
;;                ;;           '(lambda (candidate)
;;                ;;              (semantic-ia-show-summary)
;;                ;;              ;; (semantic-ia-show-doc)
;;                ;;              ))
;;                ))
;;   )
;; ;;}}}

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;{{{ Completion UI
;; ;; http://www.emacswiki.org/emacs/CompletionUI
;; ;; http://www.emacswiki.org/emacs/PredictiveMode
;; (defun my-code-completion-frontend--completion-ui ()
;;   "CompletionUI."
;;   (add-to-list 'load-path (path my-code-dir "auto-overlays"))
;;   (require 'auto-overlays)
;;   (add-to-list 'load-path (path my-code-dir "completion-ui"))
;;   (require 'completion-ui)
;;   (add-hook 'my-programming-mode-hook
;;             '(lambda ()
;;                (setq auto-completion-source 'semantic)
;;                (local-set-key my-code-completion-key 'complete-semantic)
;;                (my-code-completion-set-frontend 'complete-semantic)
;;                ;; (add-hook 'completion-accept-functions
;;                ;;           '(lambda (prefix completion &optional arg)
;;                ;;              (semantic-ia-show-summary)
;;                ;;              (semantic-ia-show-doc)
;;                ;;             ))
;;                ))
;;   )
;; ;;}}}

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;{{{ Generic interface (cont'd)
;; (defvar my-code-completion-key [(meta tab)])
;; (defvar my-code-completion-frontend 'my-code-completion-frontend--company-mode)
;; ;; (if (fboundp my-code-completion-frontend)
;; ;;     (funcall my-code-completion-frontend))
;; ;;}}}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;}}} [END] Code completion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Code navigation

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TODO: use M-. to find definitions
(add-hook 'my-programming-mode-hook
          '(lambda ()
             ;; Cscope
             (require 'xcscope)

             ;; ;; gtags
             ;; (gtags-mode 1)
             ;; (global-set-key <key> <cmd>)

             ;; etags
             ;;(defun my-code-nav-keys ()
             ;;  (define-key

	     ;; ;; TODO: Obsolete (?)
             ;; ;; CEDET's eassist
             ;; (require 'eassist)
             ;; ;; Switch between header and implementation files
             ;; (local-set-key [(meta o)] 'eassist-switch-h-cpp)
             ;; ;; List methods in current file
             ;; (local-set-key [(meta m)] 'eassist-list-methods)
             ;; ;;(define-key c-mode-base-map (kbd "M-o") 'eassist-switch-h-cpp)
             ;; ;;(define-key c-mode-base-map (kbd "M-m") 'eassist-list-methods)

             ;; Open included file under point
             (local-set-key [(control c) (i)] 'semantic-decoration-include-visit)
             ;; Jump to declaration
             (local-set-key [(control c) (g)] 'semantic-ia-fast-jump)
             ;; Toggle between declaration and implementation
             (local-set-key [(control c) (t)] 'semantic-analyze-proto-impl-toggle)
             ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;}}} [END] Code navigation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Code help
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'my-programming-mode-hook
          '(lambda ()
             (local-set-key [f1] 'semantic-ia-show-summary)
             (local-set-key [(shift f1)] 'semantic-ia-show-doc)
             (local-set-key [(control f1)] 'semantic-ia-describe-class)
             ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;}}} [END] Code help
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Compilation

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TODO: C-c C-c as project-specific `dwim-compile'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Settings
;;
;; Follow compilation output
(setq compilation-scroll-output t)
;;
;; Set default height for compilation window
;; (setq compilation-window-height 10)
;;
;; ;; Compile wrapper
;; (require 'mode-compile)
;;
;; Save compilation commands in desktop
(add-to-list 'desktop-globals-to-save 'compile-command)
(add-to-list 'desktop-globals-to-save 'compile-history)
;;}}}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Remote compilation

;; You can use `remote-compile' instead of compile to run compilation in
;; another host.
;; This is specially useful when editing remote files (`tramp') or to avoid
;; cross compilations if the edited source is shared among the editing
;; and compiling hosts (e.g., nfs).
(setq remote-compile-prompt-for-host t)      ; prompt for host if undefined
(require 'rcompile)
;; extra state to save in desktop
(add-to-list 'desktop-globals-to-save 'remote-compile-host)
(add-to-list 'desktop-globals-to-save 'remote-shell-program)
(setq remote-shell-program "ssh")

;;}}}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Auto-close

;;; Helper for compilation. Close the compilation window if
;;; there was no error at all.
;(defun compilation-exit-autoclose (status code msg)
;  ;; If M-x compile exists with a 0
;  (when (and (eq status 'exit) (zerop code))
;    ;; then bury the *compilation* buffer, so that C-x b doesn't go there
;    (bury-buffer)
;    ;; and delete the *compilation* window
;    (delete-window (get-buffer-window (get-buffer "*compilation*"))))
;  ;; Always return the anticipated result of compilation-exit-message-function
;  (cons msg code))
;;; Specify my function (maybe I should have done a lambda function)
;(setq compilation-exit-message-function 'compilation-exit-autoclose)


;; ;; Close the compilation window if there was no error at all.
;; (setq compilation-exit-message-function
;;       '(lambda (status code msg)
;;          ;; If M-x compile exists with a 0
;;          (when (and (eq status 'exit) (zerop code))
;;            ;; then bury the *compilation* buffer, so that C-x b doesn't go there
;;            (bury-buffer "*compilation*")
;;            ;; and return to whatever were looking at before
;;           (replace-buffer-in-windows "*compilation*"))
;;          ;; Always return the anticipated result of compilation-exit-message-function
;;          (cons msg code)))

;;}}}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Misc (1)
;; ;; Small Compile Window w/Highlighted Errors
;;
;; (defun my-recompile ()
;;   "Run compile and resize the compile window closing the old one if necessary"
;;   (interactive)
;;   (progn
;;     (if (get-buffer "*compilation*") ; If old compile window exists
;;         (progn
;;           (delete-windows-on (get-buffer "*compilation*")) ; Delete the compilation windows
;;           (kill-buffer "*compilation*") ; and kill the buffers
;;           )
;;       )
;;     (call-interactively 'compile)
;;     (enlarge-window 20)
;;     )
;;   )
;;
;; (defun my-next-error ()
;;   "Move point to next error and highlight it"
;;   (interactive)
;;   (progn
;;     (next-error)
;;     (end-of-line-nomark)
;;     (beginning-of-line-mark)
;;     )
;;   )
;;
;; (defun my-previous-error ()
;;   "Move point to previous error and highlight it"
;;   (interactive)
;;   (progn
;;     (previous-error)
;;     (end-of-line-nomark)
;;     (beginning-of-line-mark)
;;     )
;;   )
;;
;; (global-set-key (kbd "C-n") 'my-next-error)
;; (global-set-key (kbd "C-p") 'my-previous-error)
;; (global-set-key [f9] 'my-recompile)
;;}}}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Misc (2)
;; ;; Another Small Compiler Window
;; ;;
;; ;; Here we keep the compiler window 10 lines height, and also make sure that its
;; ;; always does a vertical split (prevents using other window), also this version
;; ;; does not close the compilation window. (default binding to F9)
;; (defun my-compile (&optional args)
;;   "Run compile and resize the compile window"
;;   (interactive)
;;   (progn
;;     (if args
;;         (compile args)
;;       (call-interactively 'compile)
;;       )
;;     (setq cur (selected-window))
;;     (setq w (get-buffer-window "*compilation*"))
;;     (select-window w)
;;     (setq h (window-height w))
;;     (shrink-window (- h 10))
;;     (select-window cur)
;;     )
;;   )
;; (defun my-compilation-hook ()
;;   "Make sure that the compile window is splitting vertically"
;;   (progn
;;     (if (not (get-buffer-window "*compilation*"))
;;         (progn
;;           (split-window-vertically)
;;           )
;; 	  )
;;     )
;;   )
;; (add-hook 'compilation-mode-hook 'my-compilation-hook)
;; (global-set-key [f9] 'my-compile)
;;}}}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Misc (3)
;; ;; Some code that will make it so the background color of the lines
;; ;; that gcc found errors on, should be in another color.
;; (require 'custom)
;;
;; (defvar all-overlays ())
;;
;; (defun delete-this-overlay(overlay is-after begin end &optional len)
;;   (delete-overlay overlay)
;;   )
;;
;; (defun highlight-current-line()
;;   (interactive)
;;   (setq current-point (point))
;;   (beginning-of-line)
;;   (setq beg (point))
;;   (forward-line 1)
;;   (setq end (point))
;;   ;; Create and place the overlay
;;   (setq error-line-overlay (make-overlay 1 1))
;;
;;   ;; Append to list of all overlays
;;   (setq all-overlays (cons error-line-overlay all-overlays))
;;
;;   (overlay-put error-line-overlay
;; 	           'face '(background-color . "pink"))
;;   (overlay-put error-line-overlay
;;     	       'modification-hooks (list 'delete-this-overlay))
;;   (move-overlay error-line-overlay beg end)
;;   (goto-char current-point)
;;   )
;;
;; (defun delete-all-overlays()
;;   (while all-overlays
;;     (delete-overlay (car all-overlays))
;;     (setq all-overlays (cdr all-overlays))
;;     )
;;   )
;;
;; (defun highlight-error-lines(compilation-buffer, process-result)
;;   (interactive)
;;   (delete-all-overlays)
;;   (condition-case nil
;;       (while t
;; 	    (next-error)
;;         (highlight-current-line)
;;         )
;;     (error nil))
;;   )
;;
;; (setq compilation-finish-function 'highlight-error-lines)
;;}}}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Flymake
;; (require 'flymake)
;; (defun flymake-elisp-init ()
;;   (let* ((temp-file   (flymake-init-create-temp-buffer-copy
;;                        'flymake-create-temp-inplace))
;;          (local-file  (file-relative-name
;;                        temp-file
;;                        (file-name-directory buffer-file-name))))
;;     (list "elisplint" (list local-file))))
;; (push '("\\.el$" flymake-elisp-init) flymake-allowed-file-name-masks)
;; ;; (add-hook 'emacs-lisp-mode-hook 'flymake-mode)
;;}}}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;}}} [END] Compilation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Debugging
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key [(meta shift down)]  'gud-next)   ;; next line
(global-set-key [(meta shift right)] 'gud-step)   ;; step into line
(global-set-key [(meta shift up)]    'gud-finish) ;; finish function
(global-set-key [(meta shift left)]  'gud-until)  ;; until line
;;; Run valgrind with GUD
;(defun valgrind (args)
;  "Start GDB on top of Valgrind."
;  (gdb "valgind --db-attach=yes" args)
;  )

;; Valgrind integration (not working)
;(require 'valgrind)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;}}} [END] Debugging
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Version control
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ psvn

(add-hook 'svn-status-mode-hook
          '(lambda ()
             (add-to-list 'svn-status-default-log-arguments '("--use-merge-history"))
             ))

;;}}}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ vc
(setq vc-delete-logbuf-window nil      ; bury log after commit (do not delete)
      vc-diff-switches "-u")           ; use unified diff by default
;;
;; TODO: version with pending patches
;(if (file-exists-p (path my-home-dir "Projects" "emacs" "lisp" "add-log.el"))
;    (progn
;      (add-hook 'log-edit-mode-hook
;                '(lambda ()
;                   (set-fill-column my-programming-width)
;                   (refill-mode nil)
;                   (auto-fill-mode t)
;                   ))
;      (load-file (path my-home-dir "Projects" "emacs" "log-entries" "lisp" "emacs-lisp" "byte-run.el"))
;      (load-file (path my-home-dir "Projects" "emacs" "log-entries" "lisp" "add-log.el"))
;      ;; (load-file (path my-home-dir "Projects" "emacs" "log-entries" "lisp" "log-eit.el"))
;      (setq change-log-use-buffer t)
;      ))
;;}}}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;}}} [END] Version control
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Miscellaneous
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; Automatically break into multiple names functions' arguments when they exceed a defined width
;; (defconst my-c-lineup-maximum-indent 30)
;; (defun my-c-lineup-arglist (langelem)
;;  (let ((ret (c-lineup-arglist langelem)))
;;    (if (< (elt ret 0) my-c-lineup-maximum-indent)
;;      ret
;;      (save-excursion
;;        (goto-char (cdr langelem))
;;        (vector (+ (current-column) 8))))))
;; (defun my-indent-setup ()
;;  (setcdr (assoc 'arglist-cont-nonempty c-offsets-alist)
;;          '(c-lineup-gcc-asm-reg my-c-lineup-arglist)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;}}} [END] Miscellaneous
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TODO: integrate `find-file' (provided by `ido') with EDE source of current
;; project files
;; TODO: integrate `compile-bookmarks' with EDE project files
