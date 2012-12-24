;;; my-appearance.el --- Graphical appearance settings

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Color theming

(load-theme 'my t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Frame parameters

(defun my-frame-parameters (frame)
  "Set font and color theme on a frame."
  (set-variable 'color-theme-is-global nil)
  (select-frame frame)
  (when (window-system frame)
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

;; `diminish'
(diminish 'undo-tree-mode)


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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous

;; Change shell's color scheme
(ansi-color-map-update 'ansi-color-names-vector
                       (vconcat (mapcar '(lambda (elem)
                                           (cond
                                            ((string= elem "blue")
                                             "deep sky blue")
                                            (t
                                             elem)))
                                        ansi-color-names-vector)))

(provide 'my-appearance)
