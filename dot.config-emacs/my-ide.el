;;; my-ide.el --- General development evironment preferences.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Packages

(my-add-packages
 '((:name magit
          :type github
          :pkgname "magit/magit"
          :branch "next"
          :depends (dash magit-git-modes))
   (:name magit-git-modes
          :type github
          :pkgname "magit/git-modes"
          :branch "next"
          )
   (:name magit-stgit
          :type github
          :pkgname "magit/magit-stgit"
          :branch "next"
          :depends magit)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Project management (EDE)

(use-package cedet
  :config
  (progn
    (setq ede-project-placeholder-cache-file (path my-cache-dir "ede-projects.el"))
    (global-ede-mode 1)
    (setq ede-project-directories t)        ; TODO: unsafe
    (add-to-list 'load-path (concat (el-get-package-directory 'cedet) "contrib"))))

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
      (set-window-configuration my-vc-dir-windows))))

(use-package magit
  :diminish magit-auto-revert-mode
  :defer t
  :commands magit-status
  :config
  (progn
    (setq magit-diff-refine-hunk nil)

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
      (set-window-configuration my-magit-status-windows))))

(use-package magit-stgit
  :defer t
  :commands magit-stgit-mode
  :init (add-hook 'magit-mode-hook 'magit-stgit-mode))

(provide 'my-ide)
