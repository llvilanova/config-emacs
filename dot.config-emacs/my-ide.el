;;; my-ide.el --- General development evironment preferences.

;;; Code:


(use-package lsp-mode
  :ensure t
  :init
  (setq lsp-warn-no-matched-clients nil)
  (add-hook 'prog-mode-hook  #'lsp)
  ;; better embark+lsp integration
  (with-eval-after-load 'embark
    (defun embark-target-lsp-identifier-at-point ()
      (when lsp-mode
        (when-let ((sym (embark-target-identifier-at-point)))
          (cons 'lsp-identifier (cdr (car sym))))))
    (cl-pushnew 'embark-target-lsp-identifier-at-point embark-target-finders)
    (defvar-keymap embark-lsp-identifier-actions
      :doc "Keymap for actions on LSP identifiers."
      :parent embark-identifier-map
      "a" #'lsp-execute-code-action
      "s" #'lsp-describe-thing-at-point)
    (add-to-list 'embark-keymap-alist '(lsp-identifier . embark-lsp-identifier-actions))
    (add-to-list 'embark-target-injection-hooks '(lsp-execute-code-action embark--ignore-target))
    (add-to-list 'embark-target-injection-hooks '(lsp-describe-thing-at-point embark--ignore-target))
    ;;(add-to-list 'embark-keymap-alist '(lsp-identifier embark-file-map))
    ))

(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :init
  (add-hook 'lsp-mode-hook #'lsp-ui-mode)
  (setq lsp-ui-flycheck-enable nil)
  (setq lsp-ui-sideline-enable nil)
  :config
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
  (define-key lsp-ui-mode-map (kbd "C-c l") #'lsp-ui-imenu))

(use-package consult-lsp
  :ensure t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Project management


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Version control

(use-package magit
  :ensure t
  :commands magit-status
  :bind (("<f9>" . magit-status)
         ("C-x g" . magit-status)
         ("S-<f9>" . my-magit-status-fullscreen)
         ("C-x G" . my-magit-status-fullscreen))
  :config
  (setq magit-diff-refine-hunk t)
  (defun my-magit-bury-buffer (kill-buffer)
    "Restores the previous window configuration and kills the magit buffer"
    (funcall magit-bury-buffer-function-prev kill-buffer)
    (set-window-configuration (frame-parameter nil 'my-magit-status-windows)))
  (defun my-magit-status-fullscreen ()
    (interactive)
    (set-frame-parameter nil 'my-magit-status-windows (current-window-configuration))
    (call-interactively #'magit-status)
    (delete-other-windows)
    (make-local-variable 'magit-bury-buffer-function)
    (make-local-variable 'magit-bury-buffer-function-prev)
    (setq magit-bury-buffer-function-prev magit-bury-buffer-function)
    (setq magit-bury-buffer-function #'my-magit-bury-buffer)))

(with-eval-after-load 'magit
  (require 'my-magit-opencode))

(use-package magit-stgit
  :ensure t
  :defer t
  :commands magit-stgit-mode
  :init (add-hook 'magit-mode-hook 'magit-stgit-mode))

;; (use-package forge
;;   :ensure t
;;   :after magit
;;   :config
;;   (add-to-list 'forge-alist '("lsds.doc.ic.ac.uk" "lsds.doc.ic.ac.uk/gitlab/api/v4" "lsds" forge-gitlab-repository)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; AI

(use-package agent-shell
  :ensure t
  :after transient
  :bind (("M-o" . my-ai-menu)
         :map agent-shell-mode-map
         ("RET" . newline)
         ("C-c C-c" . shell-maker-submit)
         ("C-c C-k" . agent-shell-interrupt))

  :config
  (setq
   agent-shell-agent-configs (list (agent-shell-opencode-make-agent-config))
   agent-shell-session-strategy 'prompt
   agent-shell-prefer-session-resume nil
   agent-shell-prefer-viewport-interaction t)
  (eval
   `(transient-define-prefix my-ai-menu ()
      "AI actions"
      [;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ["All modes"
        ("M-o" "AgentShell sidebar" agent-shell-sidebar-toggle-focus)
        ("o" "Open AgentShell" agent-shell)
        ("T" "AgentShell Manager" agent-shell-manager-toggle)
        ("O" "Open GPTel" gptel)
        ]])))
(provide 'my-ide)
