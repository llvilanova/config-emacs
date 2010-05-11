;;; my-ide.el --- General development evironment preferences.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Project management (EDE)
(global-ede-mode 1)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emacs Code Browser (ECB)

(add-to-list 'load-path (path my-code-dir "ecb"))
(add-to-list 'my-recompile-objs 'ecb-byte-compile)
(setq ecb-layouts-path (path my-data-dir "ecb-layouts"))

;; Byte-compile for first time if no autoload file exists
(if (not (require 'ecb-autoloads nil t))
    (progn
      (require 'ecb)
      (ecb-byte-compile)
      (ecb-update-autoloads)))

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
  (set (make-local-variable ecb-toggle-layout-sequence) layouts)
  (set (make-local-variable 'ecb-layout-name) (car layouts)))


(provide 'my-ide)
