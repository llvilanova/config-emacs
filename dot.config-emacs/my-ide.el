;;; my-ide.el --- General development evironment preferences.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Project management (EDE)
(global-ede-mode 1)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emacs Code Browser (ECB)

(add-to-list 'load-path (path my-code-dir "ecb"))
(setq ecb-layouts-path (path my-data-dir "ecb-layouts")
      my--ecb-autogen-file (path my-code-dir "ecb" "ecb-autoloads.el"))

;; (Re)compile
(defun my--ecb-update-autoloads ()
  (require 'ecb-autogen)
  (setq ecb-autogen-file my--ecb-autogen-file)
  (ecb-update-autoloads))
(add-to-list 'my-recompile-objs 'my--ecb-update-autoloads)
(add-to-list 'my-recompile-objs 'ecb-byte-compile)
(when (not (require 'ecb-autoloads nil t))
  (my--ecb-update-autoloads)
  (require 'ecb-autoloads))

(add-hook
 'ecb-before-activate-hook
 (lambda ()
   (setq ecb-tip-of-the-day nil
         ecb-compile-window-height 10
         ecb-compile-window-temporally-enlarge 'after-selection
         ecb-create-layout-file (path my-data-dir "ecb-user-layouts.el"))))

(add-hook
 'ecb-activate-hook
 '(lambda ()
    (ecb-hide-ecb-windows)
    (global-set-key [(f8)]         'ecb-toggle-layout)
    (global-set-key [(shift f8)]   'ecb-toggle-ecb-windows)
    (global-set-key [(f9)]         'ecb-toggle-compile-window)
    (global-set-key [(shift f9)]   'ecb-toggle-compile-window-height)
    (global-set-key [(control f9)] 'ecb-toggle-scroll-other-window-scrolls-compile)))

(add-hook 'ecb-speedbar-before-activate-hook ; default speedbar view
          '(lambda () (speedbar-change-initial-expansion-list "Project")))

(defun my-define-ecb-layouts (layouts)
  "Sequence of layouts to use with `ecb-toggle-layout' in current major mode."
  (set (make-local-variable 'ecb-toggle-layout-sequence) layouts)
  (set (make-local-variable 'ecb-layout-name) (car layouts)))


(provide 'my-ide)
