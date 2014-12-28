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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Version control

(use-package magit
  :diminish magit-auto-revert-mode
  :defer t
  :commands magit-status
  :config (setq magit-diff-refine-hunk nil))
(use-package magit-stgit
  :defer t
  :commands magit-stgit-mode
  :init (add-hook 'magit-mode-hook 'magit-stgit-mode))

(provide 'my-ide)
