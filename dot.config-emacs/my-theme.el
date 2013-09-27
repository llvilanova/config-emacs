(deftheme my
  "My theme.")

(setq my-theme-frame-parameters
      '((background-color . "black")
        (background-mode  . dark)

        (foreground-color . "#c0c0c0")

        (border-color     . "#888a85")
        (cursor-color     . "#fce94f")))

(mapc (lambda (elem)
        (add-to-list 'default-frame-alist elem)
        (set-frame-parameter nil (car elem) (cdr elem)))
      my-theme-frame-parameters)

(custom-theme-set-faces
 'my
 ;; Outer widgets
 '(mode-line ((t (:box (:line-width 1 :color nil :style released-button)
                       :foreground "#c0c0c0" :background "#555555"))))
 '(mode-line-buffer-id ((t (:bold t :foreground "orange"))))
 '(mode-line-inactive ((t (:box (:line-width 1 :color nil :style released-button)
                                :foreground "#a0a0a0" :background "#222222"))))
 ;; General text editing area
 '(highlight ((t (:background "#283242"))))
 '(hl-line   ((t (:background "#283242"))))
 ;; Specifics
 '(diff-function         ((t (:foreground "#00bbdd"))))
 '(diff-header           ((t (:foreground "LightBlue1"))))
 '(diff-hunk-header      ((t (:foreground "#fbde2d"))))
 '(py-XXX-tag-face       ((t (:bold t :foreground "red"))))
 '(sml-modeline-end-face ((t (:background "#000000"))))
 '(sml-modeline-vis-face ((t (:background "#666666")))))

;; (custom-theme-set-variables
;;  'my
;;  '(help-highlight-face . underline)
;;  '(ibuffer-dired-buffer-face . font-lock-function-name-face)
;;  '(ibuffer-help-buffer-face . font-lock-comment-face)
;;  '(ibuffer-hidden-buffer-face . font-lock-warning-face)
;;  '(ibuffer-occur-match-face . font-lock-warning-face)
;;  '(ibuffer-read-only-buffer-face . font-lock-type-face)
;;  '(ibuffer-special-buffer-face . font-lock-keyword-face)
;;  '(ibuffer-title-face . font-lock-type-face))

(provide-theme 'my)
