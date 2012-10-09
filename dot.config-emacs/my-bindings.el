;;; my-bindings.el --- User-defined key bindings.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(global-set-key [(meta f9)] 'maximize-window)
(global-set-key [(control f9)] 'minimize-window)
(global-set-key [pause] 'my-toggle-dedicated-window)
(define-key ctl-x-4-map (kbd "s") 'my-swap-buffers-in-windows)

;; Move between windows
(windmove-default-keybindings 'meta)
(global-set-key [(control x) (left)]  'windmove-left)
(global-set-key [(control x) (right)] 'windmove-right)
(global-set-key [(control x) (up)]    'windmove-up)
(global-set-key [(control x) (down)]  'windmove-down)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Buffers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(global-set-key [(control x) (r) (b)] 'my-jump-to-bookmark)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Minibuffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(global-set-key [(meta x)]       'smex)
(global-set-key [(meta shift x)] 'smex-major-mode-commands)

(global-set-key [(control x) (control b)] 'ibuffer)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Editing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Delete line and remaining blanks (like `dd' in VIM)
(global-set-key [(control delete)] 'kill-whole-line)
;; Duplicate current line
(global-set-key [(control c) (y)] 'my-duplicate-line)
;; Duplicate and comment current line
(global-set-key [(control c) (control y)] 'my-duplicate-and-comment-line)
;; DWIM kill word or region
(global-set-key [(control w)] 'my-kill-word-or-region-dwim)

;; `iedit': interactive string replacement
(global-set-key [(control \;)] 'iedit-mode)

;; `ace-jump-mode'
(eval-after-load 'ace-jump-mode
  '(progn
     (global-set-key [(control c) (j) (c)] 'ace-jump-char-mode)
     (global-set-key [(control c) (j) (w)] 'ace-jump-word-mode)
     (global-set-key [(control c) (j) (l)] 'ace-jump-line-mode)))

;; `expand-region'
(eval-after-load 'expand-region
  '(progn
     (global-set-key (kbd "C-M-S-m") 'er/expand-region)))

;; `mark-multiple'
(eval-after-load 'mark-multiple
  '(progn
     (global-set-key (kbd "C-M-m") 'mark-more-like-this)
     (global-set-key (kbd "C-*") 'mark-all-like-this)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(global-set-key [(control c) (control x) (control f)]
                'my-file-cache-ido-find-file)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mode-specific bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; `my-programming-mode'
(my-add-hook 'my-programming-mode-hook
             '(lambda ()
                ;; Auto-indent new line
                (local-set-key [return] 'newline-and-indent)
                ;; ;; Auto-indent new line (plus previous)
                ;; (local-set-key [return] 'reindent-then-newline-and-indent)

                ;; `highlight-symbol'
                (local-set-key [(meta f5)] 'highlight-symbol-at-point)
                (local-set-key [(meta f6)] 'highlight-symbol-at-point)
                (local-set-key [f5] 'highlight-symbol-prev)
                (local-set-key [f6] 'highlight-symbol-next)

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
(eval-after-load 'company
  '(progn
     (my-add-hook 'my-programming-mode-hook
                  '(lambda ()
                     ;; `company'
                     (local-set-key [(meta tab)] 'company-complete)))))
(eval-after-load 'auto-complete
  '(progn
     (add-hook 'auto-complete-mode-hook
               '(lambda ()
                  ;; `auto-complete'
                  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
                  (define-key ac-mode-map (kbd "C-c h") 'ac-last-quick-help)
                  (define-key ac-mode-map (kbd "C-c H") 'ac-last-help)))))

;; `my-writing-mode'
(my-add-hook 'my-writing-mode-hook
             '(lambda ()
                (local-set-key [(control c) (w)] 'wordnet-search)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Applications
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; `compile'
(global-set-key [f8] 'my-dwim-compile)

;; `flymake'
(add-hook 'flymake-mode-hook
          '(lambda ()
             ;; Keymaps to navigate between the errors
             (local-set-key [(meta n)] 'flymake-goto-next-error)
             (local-set-key [(meta p)] 'flymake-goto-prev-error)))

;; `framepop'
(eval-after-load 'framepop
  '(progn
     (define-key framepop-map [f7] 'framepop-toggle-frame)
     (define-key framepop-map "f" 'my-framepop-toggle-with-focus)))

;; `gud'
(global-set-key [(meta shift down)]  'gud-next)   ;; next line
(global-set-key [(meta shift right)] 'gud-step)   ;; step into line
(global-set-key [(meta shift up)]    'gud-finish) ;; finish function
(global-set-key [(meta shift left)]  'gud-until)  ;; until line

;; `gnus'
(global-set-key [f12] 'my-gnus-start-or-hide)
(add-hook 'gnus-startup-hook
          '(lambda ()
             (define-key gnus-summary-mode-map [(control meta shift k)] 'my-gnus-lower-thread)
             (define-key gnus-summary-mode-map [(shift g) (shift g)] 'gnus-group-make-nnir-group)))

;; `org-mode'
(global-set-key [(control shift o) (l)] 'org-store-link)
(global-set-key [(control shift o) (a)] 'org-agenda)
(global-set-key [(control shift o) (s)] 'org-search-view)
(global-set-key [(control shift o) (f)]
                '(lambda ()
                   (interactive)
                   (ido-find-file-in-dir org-directory)
                   ))
(global-set-key [(control shift o) (b)] 'org-iswitchb)
(global-set-key [(control shift o) (control c) (c)] 'org-capture)
(when (require 'org-secretary nil t)
  (global-set-key [(control shift o) (w)] 'org-sec-set-with)
  (global-set-key [(control shift o) (shift w)] 'org-sec-set-where)
  (global-set-key [(control shift o) (d)] 'org-sec-set-dowith)
  (global-set-key [(control shift o) (shift d)] 'org-sec-set-doat))


(provide 'my-bindings)
