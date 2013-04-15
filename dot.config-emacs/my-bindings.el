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
(global-set-key [(control z)] popwin:keymap)


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
;; Copy line and increment numbers
(global-set-key [(control c) (meta y)] 'my-copy-increment)
;; DWIM kill word or region
(global-set-key [(control w)] 'my-kill-word-or-region-dwim)
;; Show line numbers when using `goto-line'
(global-set-key (vector 'remap 'goto-line) 'my-goto-line-with-feedback)

;; `ace-jump-mode'
(global-set-key [(control c) (control j) (c)] 'ace-jump-char-mode)
(global-set-key [(control c) (control j) (w)] 'ace-jump-word-mode)
(global-set-key [(control c) (control j) (l)] 'ace-jump-line-mode)

;; `expand-region'
(global-set-key [(control shift return)] 'er/expand-region)

;; `multiple-cursors'
(global-set-key [(control \;)] 'mc/mark-all-like-this-dwim)
(global-set-key [(control meta \;)] 'mc/edit-lines)
(global-set-key [(control meta \,)] 'mc/mark-more-like-this-extended)
(global-set-key (kbd "C-S-<mouse-1>") 'mc/add-cursor-on-click)

;; `dired'
(global-set-key [(control x) (control j)] 'dired-jump)

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
             (lambda ()
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
                  (lambda ()
                    ;; `company'
                    (local-set-key [(meta tab)] 'company-complete)))))
(eval-after-load 'auto-complete
  '(progn
     (add-hook 'auto-complete-mode-hook
               (lambda ()
                 ;; `auto-complete'
                 (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
                 (define-key ac-mode-map (kbd "C-c h") 'ac-last-quick-help)
                 (define-key ac-mode-map (kbd "C-c H") 'ac-last-help)))))

;; `my-writing-mode'
(my-add-hook 'my-writing-mode-hook
             (lambda ()
               (local-set-key [(control c) (w)] 'wordnet-search)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Applications
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; `compile'
(global-set-key [f8] 'my-dwim-compile)

;; `flymake'
(add-hook 'flymake-mode-hook
          (lambda ()
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
          (lambda ()
            (define-key gnus-summary-mode-map [(control meta shift k)] 'my-gnus-lower-thread)
            (define-key gnus-summary-mode-map [(shift g) (shift g)] 'gnus-group-make-nnir-group)))

;; `org-mode'
(global-set-key [(control shift o) (l)] 'org-store-link)
(global-set-key [(control shift o) (a)] 'org-agenda)
(global-set-key [(control shift o) (s)] 'org-search-view)
(global-set-key [(control shift o) (f)]
                (lambda ()
                  (interactive)
                  (ido-find-file-in-dir org-directory)))
(global-set-key [(control shift o) (b)] 'org-iswitchb)
(global-set-key [(control shift o) (control c) (c)] 'org-capture)
(when (require 'org-secretary nil t)
  (global-set-key [(control shift o) (w)] 'org-sec-set-with)
  (global-set-key [(control shift o) (shift w)] 'org-sec-set-where)
  (global-set-key [(control shift o) (d)] 'org-sec-set-dowith)
  (global-set-key [(control shift o) (shift d)] 'org-sec-set-doat))

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
(defun my-eshell ()
  "Bring up a full-screen eshell or restore previous config."
  (interactive)
  (if (string= "eshell-mode" major-mode)
      (jump-to-register :shell-fullscreen)
    (progn
      (window-configuration-to-register :shell-fullscreen)
      (call-interactively 'eshell)
      (delete-other-windows))))
(defun my-eshell-in-current-dir ()
  (interactive)
  (let ((dir default-directory))
    (call-interactively 'my-eshell)
    (when (string= "eshell-mode" major-mode)
      (eshell/cd dir)
      (eshell-send-input))))
(global-set-key [(super e)] 'my-eshell)
(global-set-key [(control super e)] 'my-eshell-in-current-dir)


(provide 'my-bindings)
