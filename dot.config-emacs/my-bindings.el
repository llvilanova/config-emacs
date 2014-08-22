;;; my-bindings.el --- User-defined key bindings.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Windows

(global-set-key [(meta f9)] 'maximize-window)
(global-set-key [(control f9)] 'minimize-window)
(global-set-key [pause] 'my-toggle-dedicated-window)
(define-key ctl-x-4-map (kbd "s") 'my-swap-buffers-in-windows)

;; Move between windows
(windmove-default-keybindings 'super)
(global-set-key [(control x) (left)]  'windmove-left)
(global-set-key [(control x) (right)] 'windmove-right)
(global-set-key [(control x) (up)]    'windmove-up)
(global-set-key [(control x) (down)]  'windmove-down)
(global-set-key [(control x) (o)] 'ace-window)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Buffers

(global-set-key [(control x) (r) (b)] 'my-jump-to-bookmark)
(global-set-key [(control z)] popwin:keymap)
(global-set-key [(meta shift up)] 'my-move-line-up)
(global-set-key [(meta shift down)] 'my-move-line-down)
(global-set-key [(control x) (control shift j)] 'my-dwim-dired-jump)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Minibuffer

(global-set-key [(meta x)]       'smex)
(global-set-key [(meta shift x)] 'smex-major-mode-commands)

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
;; Quickly insert ';' at the end of the line
(key-chord-define-global ";;" "\C-e;")
;; Make C-a smarter
(global-set-key [remap move-beginning-of-line] 'my-move-beginning-of-line)
;; Eval-and-replace
(global-set-key [(control c) (control e)] 'my-eval-and-replace)

;; `ace-jump-mode'
(global-set-key [(control c) (control j) (c)] 'ace-jump-char-mode)
(global-set-key [(control c) (control j) (w)] 'ace-jump-word-mode)
(global-set-key [(control c) (control j) (l)] 'ace-jump-line-mode)

;; `expand-region'
(global-set-key [(control shift return)] 'er/expand-region)

;; `multiple-cursors'
(global-set-key [(control \;)] 'mc/mark-all-dwim)
(global-set-key [(control meta \;)] 'mc/edit-lines)
(global-set-key [(control meta \,)] 'mc/mark-more-like-this-extended)
(global-set-key (kbd "C-S-<mouse-1>") 'mc/add-cursor-on-click)

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
(after 'company
  (add-hook 'prog-mode-hook
            (lambda ()
              ;; `company'
              (local-set-key [(meta tab)] 'company-complete))))
(after 'auto-complete
  (add-hook 'auto-complete-mode-hook
            (lambda ()
              ;; `auto-complete'
              (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
              (define-key ac-mode-map (kbd "C-c h") 'ac-last-quick-help)
              (define-key ac-mode-map (kbd "C-c H") 'ac-last-help))))

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

;; `framepop'
(after 'framepop
  (define-key framepop-map [f7] 'framepop-toggle-frame)
  (define-key framepop-map "f" 'my-framepop-toggle-with-focus))

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
(when (require 'org-secretary nil t)
  (global-set-key [(super o) (w)] 'org-sec-set-with)
  (global-set-key [(super o) (shift w)] 'org-sec-set-where)
  (global-set-key [(super o) (d)] 'org-sec-set-dowith)
  (global-set-key [(super o) (shift d)] 'org-sec-set-doat))

;; `magit' in fullscreen
(setq my-magit-status-windows nil)
(make-variable-frame-local 'my-magit-status-windows)
(defadvice magit-status (around magit-fullscreen activate)
  (setq my-magit-status-windows (current-window-configuration))
  ad-do-it
  (delete-other-windows)
  (define-key magit-status-mode-map (kbd "q") 'my-magit-quit-session))
(defun my-magit-quit-session ()
  "Restores the previous window configuration and kills the magit buffer"
  (interactive)
  (kill-buffer)
  (set-window-configuration my-magit-status-windows))

;; `vc' in fullscreen
(setq my-vc-dir-windows nil)
(make-variable-frame-local 'my-vc-dir-windows)
(defadvice vc-dir (around vc-dir-fullscreen activate)
  (setq my-vc-dir-windows (current-window-configuration))
  ad-do-it
  (delete-other-windows)
  (define-key vc-dir-mode-map (kbd "q") 'my-vc-dir-quit-session))
(defun my-vc-dir-quit-session ()
  "Restores the previous window configuration and exits the vc buffer"
  (interactive)
  (quit-window)
  (set-window-configuration my-vc-dir-windows))

;; Start version control interface
(global-set-key [f9] 'my-dwim-vc)
(global-set-key [(meta f9)] 'vc-dir)          ; force `vc'
(global-set-key [(control f9)] 'magit-status) ; force `magit'

;; `eshell' in fullscreen
(global-set-key [(super e)] '(lambda () (interactive) (my-eshell 'other-window nil)))
(global-set-key [(control super e)] '(lambda () (interactive) (my-eshell 'other-window t)))
(global-set-key [(super shift e)] '(lambda () (interactive) (my-eshell 'fullscreen nil)))
(global-set-key [(control super shift e)] '(lambda () (interactive) (my-eshell 'fullscreen t)))


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
