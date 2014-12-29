;;; my-bindings.el --- User-defined key bindings.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Windows

(global-set-key [(meta f9)] 'maximize-window)
(global-set-key [(control f9)] 'minimize-window)
(global-set-key [pause] 'my-toggle-dedicated-window)
(define-key ctl-x-4-map (kbd "s") 'my-swap-buffers-in-windows)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Buffers

(global-set-key [(control x) (r) (b)] 'my-jump-to-bookmark)
(global-set-key [(meta shift down)] 'move-text-down)
(global-set-key [(meta shift up)] 'move-text-up)
(global-set-key [(control x) (control shift j)] 'my-dwim-dired-jump)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Minibuffer

(global-set-key [(control x) (control b)] 'ibuffer)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Editing

;; Smart open line
(when (display-graphic-p)
  (global-set-key [(meta shift o)] 'my-smart-open-line-above)
  (global-set-key [(meta o)] 'my-smart-open-line))
;; Delete line and remaining blanks (like `dd' in VIM)
(global-set-key [(control delete)] 'kill-whole-line)
;; Duplicate current line
(global-set-key [(control c) (y)] 'my-duplicate-line)
;; Duplicate and comment current line
(global-set-key [(control c) (control y)] 'my-duplicate-and-comment-line)
;; Copy line and increment numbers
(global-set-key [(control c) (meta y)] 'my-copy-increment)
;; DWIM kill word or region
(global-set-key [(control w)] 'my-kill-word-or-region-dwim)
;; Show line numbers when using `goto-line'
(global-set-key (vector 'remap 'goto-line) 'my-goto-line-with-feedback)
;; Join following line into this one
(global-set-key [(meta j)] (lambda () (interactive) (join-line -1)))
;; Make C-a smarter
(global-set-key [remap move-beginning-of-line] 'my-move-beginning-of-line)
;; Eval-and-replace
(global-set-key [(control c) (control e)] 'my-eval-and-replace)

;; `dired'
(global-set-key [(control x) (control j)] 'dired-jump)
(define-key dired-mode-map
  (vector 'remap 'beginning-of-buffer)
  (lambda () (interactive) (beginning-of-buffer) (next-line 2)))
(define-key dired-mode-map
  (vector 'remap 'end-of-buffer)
  (lambda () (interactive) (end-of-buffer) (next-line -1)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Files


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Mode-specific bindings

;; `prog-mode'
(add-hook 'prog-mode-hook
          (lambda ()
            ;; Auto-indent new line (TODO: `electric-indent-mode')
            (local-set-key [return] 'newline-and-indent)
            ;; ;; Auto-indent new line (plus previous)
            ;; (local-set-key [return] 'reindent-then-newline-and-indent)

            ;; `semantic'
            (local-set-key [(control c) (i)] ; open included file at point
                           'semantic-decoration-include-visit)
            (local-set-key [(control c) (g)] ; jump to declaration
                           'semantic-ia-fast-jump)
            (local-set-key [(control c) (t)] ; toggle declaration / definition
                           'semantic-analyze-proto-impl-toggle)
            (local-set-key [f1] 'semantic-ia-show-summary)
            (local-set-key [(meta f1)] 'semantic-ia-show-doc)
            (local-set-key [(shift f1)] 'semantic-ia-describe-class)))

;; `my-writing-mode'
(add-hook 'text-mode-hook
          (lambda () (local-set-key [(control c) (w)] 'wordnet-search)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Applications

;; `compile'
(global-set-key [f8] 'my-dwim-compile)

;; `flycheck'
(add-hook 'flycheck-mode-hook
          (lambda ()
            ;; Keymaps to navigate between the errors
            (local-set-key [(meta n)] 'flycheck-next-error)
            (local-set-key [(meta p)] 'flycheck-previous-error)))

;; `gnus'
(global-set-key [f12] 'my-gnus-start-or-hide)
(add-hook 'gnus-startup-hook
          (lambda ()
            (define-key gnus-summary-mode-map [(control meta shift k)] 'my-gnus-lower-thread)
            (define-key gnus-summary-mode-map [(shift g) (shift g)] 'gnus-group-make-nnir-group)))

;; `org-mode'
(global-set-key [(super o) (l)] 'org-store-link)
(global-set-key [(super o) (a)] 'org-agenda)
(global-set-key [(super o) (s)] 'org-search-view)
(global-set-key [(super o) (f)]
                (lambda ()
                  (interactive)
                  (ido-find-file-in-dir org-directory)))
(global-set-key [(super o) (b)] 'org-iswitchb)
(global-set-key [(super o) (c)] 'my-org-capture)
(global-set-key [(super o) (C)] 'my-org-capture-other-frame)

;; `eshell' in fullscreen
(global-set-key [(super e)] '(lambda () (interactive) (my-eshell 'other-window nil)))
(global-set-key [(control super e)] '(lambda () (interactive) (my-eshell 'other-window t)))
(global-set-key [(super shift e)] '(lambda () (interactive) (my-eshell 'fullscreen nil)))
(global-set-key [(control super shift e)] '(lambda () (interactive) (my-eshell 'fullscreen t)))

;; `info-display-manual'
(global-set-key [(control h) (i)] #'info-display-manual)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Miscellaneous

(define-prefix-command 'my-toggle-map)
(define-key ctl-x-map "t" 'my-toggle-map)
(define-key my-toggle-map "e" 'toggle-debug-on-error)
(define-key my-toggle-map "f" 'auto-fill-mode)
(define-key my-toggle-map "l" 'linum-mode)
(define-key my-toggle-map "n" 'my-narrow-or-widen-dwim)
(define-key my-toggle-map "q" 'toggle-debug-on-quit)
(define-key my-toggle-map "r" 'read-only-mode)
(define-key my-toggle-map "v" 'visual-line-mode)
(define-key my-toggle-map "w" 'whitespace-mode)


(provide 'my-bindings)
