;;; my-ide.el --- General development evironment preferences.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Project management (EDE)
(setq ede-project-placeholder-cache-file (path my-cache-dir "ede-projects.el"))
(global-ede-mode 1)
(setq ede-project-directories t)        ; TODO: unsafe


(provide 'my-ide)
