;; -*-mode: Emacs-Lisp; folded-file:t-*-
;;; my-appearance.el --- Graphical appearance settings

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Color theming

;; (require 'color-theme)
(set-variable 'color-theme-is-global t)
(defun my-color-theme ()
  (interactive)
  (color-theme-install
   '(my-color-theme
     ;; Frame parameters
     ((background-color . "black")
      (background-mode . dark)

      (foreground-color . "#c0c0c0")

      (border-color . "#888a85")
      (cursor-color . "#fce94f")
      ;; (mouse-color . "#8ae234")
      )

     ;; ;; Variable settings
     ;; ((help-highlight-face . underline)
     ;;  (ibuffer-dired-buffer-face . font-lock-function-name-face)
     ;;  (ibuffer-help-buffer-face . font-lock-comment-face)
     ;;  (ibuffer-hidden-buffer-face . font-lock-warning-face)
     ;;  (ibuffer-occur-match-face . font-lock-warning-face) 
     ;;  (ibuffer-read-only-buffer-face . font-lock-type-face)
     ;;  (ibuffer-special-buffer-face . font-lock-keyword-face)
     ;;  (ibuffer-title-face . font-lock-type-face))
     ()

     ;; Outer widgets
     (mode-line ((t (:foreground "#c0c0c0" :background "#444444"
                                 :box (:line-width 1 :color nil :style released-button)))))
     (mode-line-inactive ((t (:foreground "#a0a0a0" :background "#222222"
                                          :box (:line-width 1 :color nil :style released-button)))))
     (mode-line-buffer-id ((t (:bold t :foreground "orange" :background nil))))

     ;; General text editing area
     (highlight ((t (:background "#283242" :foreground nil))))

     ;; Specifics
     (sml-modeline-end-face ((t (:background "#000000"))))
     (sml-modeline-vis-face ((t (:background "#555555"))))
     (py-XXX-tag-face ((t (:bold t :foreground "red"))))
     )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Frame parameters

(defun my-frame-parameters (frame)
  "Set font and color theme on a frame."
  (set-variable 'color-theme-is-global nil)
  (select-frame frame)
  (if (window-system frame)
      (progn
        (my-color-theme)
        (set-frame-parameter frame 'font "Terminus-10")
        )
    (color-theme-tty-dark)))

(add-hook 'after-make-frame-functions 'my-frame-parameters)
(my-frame-parameters (next-frame))

;; Set a more informative frame title
(setq frame-title-format
      '("" invocation-name "@" system-name ":" "%b %&"))


(provide 'my-appearance)
