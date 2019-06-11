;;; my-ide.el --- General development evironment preferences.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Project management (EDE)

(use-package cedet
  :config
  (progn
    (setq ede-project-placeholder-cache-file (path my-cache-dir "ede-projects.el"))
    (global-ede-mode 1)
    (setq ede-project-directories t)        ; TODO: unsafe
    ))

(defun my-cedet-toggle ()
  (interactive)
  (call-interactively #'global-semanticdb-minor-mode)
  (call-interactively #'global-semantic-idle-scheduler-mode)
  (call-interactively #'global-semantic-decoration-mode)
  (call-interactively #'global-semantic-highlight-func-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Version control

(use-package emacs
  :bind (("<f9>" . my-dwim-vc)
         ;; ("M-<f9>" . vc-dir)
         ;; ("C-<f9>" . magit-status)
         )
  :config
  (progn
    (defun my-dwim-vc (path &optional backend)
  "Start version control interface according to the backend of current buffer.

If called with a prefix, prompts the user for the backend."
      (interactive
       (list
        (or (buffer-file-name)
            (read-directory-name "Select directory: "))
        (if current-prefix-arg
            (intern
             (completing-read
              "Use VC backend: "
              (mapcar (lambda (b) (list (symbol-name b)))
                      vc-handled-backends)
              nil t nil nil)))))
      (require 'vc)
      (setq backend (or backend (vc-responsible-backend path)))
      (let ((root (vc-call-backend backend 'root path)))
        (case backend
          ('Git (magit-status root))
          (t    (vc-dir root backend)))))))

(use-package vc-dir
  :defer t
  :config
  (progn
    ;; `vc' in fullscreen
    (defadvice vc-dir (around vc-dir-fullscreen activate)
      (set-frame-parameter nil 'my-vc-dir-windows (current-window-configuration))
      ad-do-it
      (delete-other-windows)
      (define-key vc-dir-mode-map (kbd "q") 'my-vc-dir-quit-session))
    (defun my-vc-dir-quit-session ()
      "Restores the previous window configuration and exits the vc buffer"
      (interactive)
      (quit-window)
      (set-window-configuration (frame-parameter nil 'my-vc-dir-windows)))))

(use-package magit
  :ensure t
  :commands magit-status
  :config
  (setq magit-diff-refine-hunk nil)

  ;; `magit' in fullscreen
  (defadvice magit-status (around magit-fullscreen activate)
    (set-frame-parameter nil 'my-magit-status-windows (current-window-configuration))
    ad-do-it
    (delete-other-windows)
    (define-key magit-status-mode-map (kbd "q") 'my-magit-quit-session))
  (defun my-magit-quit-session ()
    "Restores the previous window configuration and kills the magit buffer"
    (interactive)
    (kill-buffer)
    (set-window-configuration (frame-parameter nil 'my-magit-status-windows)))

  :init
  (global-magit-file-mode))

(use-package magit-stgit
  :ensure t
  :defer t
  :commands magit-stgit-mode
  :init (add-hook 'magit-mode-hook 'magit-stgit-mode))

(provide 'my-ide)
