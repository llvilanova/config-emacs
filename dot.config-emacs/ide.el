;; -*-mode: Emacs-Lisp; folded-file:t-*-
;; Time-stamp: <2010-02-15 22:06:30 (lluis)>

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Project management (EDE)
(global-ede-mode 1)
;(load-file (path my-config-dir "projects.el")) ; TODO: move to data dir
;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ ECB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Settings
(add-to-list 'load-path (path my-code-dir "ecb"))
(setq ecb-layouts-path (path my-data-dir "ecb-layouts"))

;; (require 'ecb)
(require 'ecb-autoloads)

(add-hook 'ecb-before-activate-hook
          (lambda ()
            ;; Do not show tip-of-the-day as ECB is always activated by default
            (setq ecb-tip-of-the-day nil)

            ;; Integrate with `escreen'
            ;; TODO: only activates escreen when ecb is activated...
            (require 'escreen)
            (ecb-winman-escreen-enable-support)
            (escreen-install)

            ;; Always have an ECB compilation-window
            (setq ecb-compile-window-height 10)
            ;; When to show an enlarged version of the compilation window
            (setq ecb-compile-window-temporally-enlarge 'both)
            ;; Path to user-defined layouts
            (setq ecb-create-layout-file (path my-data-dir "ecb-user-layouts.el"))

            ;; Add buffers to compilation window
            ;; TODO: should probably be added from each mode
            (setq ecb-compilation-buffer-names
                  (append ecb-compilation-buffer-names
                          '(
                            ;; `xcscope'
                            ("*cscope*" . nil)
                            ;; `semantic-ia-show-doc'
                            ("*TAG DOCUMENTATION*" . nil)
                            ;; `wordnet'
                            ("*WordNet*" . nil)
                            )))
            ))

(add-hook 'ecb-speedbar-before-activate-hook
          '(lambda ()
             (speedbar-change-initial-expansion-list "Project")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Handy hotkeys
(defvar my-ide-toggle-layouts [f8]
  "Hotkey to toggle between buffer-specific ECB layouts.")
(defvar my-ide-toggle-layout-visibility [(shift f8)]
  "Hotkey to toggle visibility of ECB windows.")

(defvar my-ide-toggle-compile-window [f9]
  "Hotkey to toggle the ECB compile window.")
(defvar my-ide-toggle-enlarged-compile-window [(shift f9)]
  "Hotkey to toggle the enlargement of the ECB compile window.")

(defvar my-ide-toggle-scroll-other [(control f9)]
  "Hotkey to toggle the behaviour of `scroll-other-window' between the ECB
compile window or any other window.")

(add-hook 'ecb-activate-hook
          '(lambda ()
             (ecb-hide-ecb-windows)
             (global-set-key my-ide-toggle-layouts
                             'ecb-toggle-layout)
             (global-set-key my-ide-toggle-layout-visibility
                             'ecb-toggle-ecb-windows)
             (global-set-key my-ide-toggle-compile-window
                             'ecb-toggle-compile-window)
             (global-set-key my-ide-toggle-enlarged-compile-window
                             'ecb-toggle-compile-window-height)
             (global-set-key my-ide-toggle-scroll-other
                             'ecb-toggle-scroll-other-window-scrolls-compile)
             ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Layout declaration interface for next code...
(defun my-define-ecb-layouts (layouts)
  "Sequence of layouts to use with `ecb-toggle-layout' in current major mode."
  (make-variable-buffer-local 'ecb-toggle-layout-sequence)
  (setq ecb-toggle-layout-sequence layouts)
  (make-variable-buffer-local 'ecb-layout-name)
  (setq ecb-layout-name (car layouts))
  )

;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
