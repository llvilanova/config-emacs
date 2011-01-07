;;; my-appearance.el --- Graphical appearance settings

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Color theming

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
     (diff-added         ((t (:foreground "#559944"))))
     ;; (diff-context       ((t nil)))
     (diff-file-header   ((((class color) (min-colors 88) (background dark)) (:foreground "RoyalBlue1"))))
     (diff-function      ((t (:foreground "#00bbdd"))))
     (diff-header        ((((class color) (min-colors 88) (background dark)) (:foreground "RoyalBlue1"))))
     (diff-hunk-header   ((t (:foreground "#fbde2d"))))
     (diff-nonexistent   ((t (:inherit diff-file-header :strike-through nil))))
     (diff-refine-change ((t (:bold t :background "#202030"))))
     (diff-removed       ((t (:foreground "#de1923"))))
     )))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Frame parameters

(defun my-frame-parameters (frame)
  "Set font and color theme on a frame."
  (set-variable 'color-theme-is-global nil)
  (select-frame frame)
  (when (window-system frame)
        (my-color-theme)
        (set-frame-parameter frame 'font "Terminus-10")))

(add-hook 'after-make-frame-functions 'my-frame-parameters)
(my-frame-parameters (next-frame))

;; Set a more informative frame title
(setq frame-title-format
      '("" invocation-name "@" system-name ":" "%b %&"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global appearance

(menu-bar-mode  t)                           ; show the menu...
(tool-bar-mode -1)                           ; ... but not the the toolbar

(set-fringe-mode 'half)                      ; space left of col1
(setq-default indicate-empty-lines t         ; fringe indicators
              indicate-buffer-boundaries 'left)

(setq visible-bell t)                        ; no annoying sounds

(setq inhibit-startup-message t              ; don't show ...
      inhibit-startup-echo-area-message t)   ; ... startup messages

;; `cursor-chg': context-specific cursor appearence
(require 'cursor-chg)
(setq curchg-default-cursor-color "Yellow")
(curchg-toggle-cursor-type-when-idle 1)
(change-cursor-mode 1)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Modeline appearance

(line-number-mode t)                         ; line numbers
(column-number-mode t)                       ; column numbers
(size-indication-mode t)                     ; file size
(display-time-mode t)                        ; current time
(scroll-bar-mode -1)                         ; no good'ol scrollbar...
(sml-modeline-mode 1)                        ; ... but in modeline
(set-variable 'sml-modeline-len 10)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; utf8 / input-method
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(set-language-environment "UTF-8")
(set-input-method nil)
(setq read-quoted-char-radix 10)             ; use decimal, not octal


(provide 'my-appearance)
