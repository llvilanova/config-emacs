;;; my-appearance.el --- Graphical appearance settings

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Color theming

(load-theme 'my t)
(setq initial-major-mode 'fundamental-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Frame parameters

(defun my-frame-parameters (frame)
  "Set font and color theme on a frame."
  (set-variable 'color-theme-is-global nil)
  (select-frame frame)
  ;; (when (display-graphic-p frame)
  ;;   (set-frame-parameter frame 'font "Terminus-12"))
  )

(add-hook 'after-make-frame-functions 'my-frame-parameters)
(my-frame-parameters (next-frame))

;; Set a more informative frame title
(setq frame-title-format
      '("" invocation-name "@" system-name ":" "%b %&"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Global appearance

(tool-bar-mode -1)                           ; do not show the toolbar ...
(menu-bar-mode -1)                           ; ... nor the menu ...
(defun my-menu-bar-close ()                  ; ... except when asked to
  (when (eq menu-bar-mode 42)
    (menu-bar-mode -1)))
(defun my-menu-bar-open (&rest args)
  (interactive)
  (let ((open menu-bar-mode))
    (unless open
      (menu-bar-mode 1))
    (funcall 'menu-bar-open args)
    (unless open
      (setq menu-bar-mode 42)
      (my-delay-function 'my-menu-bar-close))))
(global-set-key [f10] 'my-menu-bar-open)

(setq-default indicate-empty-lines t         ; fringe indicators
              indicate-buffer-boundaries 'left)

(setq visible-bell t)                        ; no annoying sounds

(setq inhibit-startup-message t)                     ; don't show ...


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Modeline appearance

(line-number-mode t)                         ; line numbers
(column-number-mode t)                       ; column numbers
(size-indication-mode t)                     ; file size
(unless (display-graphic-p)
  (display-time-mode t))                     ; current time
(require 'scroll-bar)
(scroll-bar-mode -1)                         ; no good'ol scrollbar...

(use-package diminish
  :ensure t
  :diminish (abbrev-mode
             auto-fill-function))

(use-package nerd-icons
  :ensure t)

(use-package doom-modeline
  :ensure t
  :init
  (let* ((font-dest (cl-case system-type
                      (gnu/linux (concat (or (getenv "XDG_DATA_HOME")
                                             (concat (getenv "HOME") "/.local/share"))
                                         "/fonts/"
                                         nerd-icons-fonts-subdirectory))
                      (darwin (concat (getenv "HOME") "/Library/Fonts/" ))))
         (font-file (concat font-dest "/NFM.ttf")))
    (unless (file-exists-p font-file)
      (nerd-icons-install-fonts)))
  :if (display-graphic-p)
  :hook(after-init . doom-modeline-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; utf8 / input-method
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(set-language-environment "UTF-8")
(set-input-method nil)
(setq read-quoted-char-radix 10)             ; use decimal, not octal


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Buffer

(global-prettify-symbols-mode 1)
(diminish 'visual-line-mode)

;; temporarily highlight changes from pasting etc
(use-package volatile-highlights
  :ensure t
  :diminish volatile-highlights-mode
  :config
  (volatile-highlights-mode t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Miscellaneous

;; Add vertical window separator (console mode)
(defun my-change-window-divider ()
  "Set a prettier window divider in console mode."
  (unless standard-display-table
    (setq standard-display-table (make-display-table)))
  (set-display-table-slot standard-display-table 'vertical-border 
                          (make-glyph-code ?\s 'vertical-border)))
(add-hook 'emacs-startup-hook
          (lambda ()
            (add-hook 'window-configuration-change-hook 'my-change-window-divider)))

;; Change shell's color scheme
(add-hook 'after-init-hook
          (lambda ()
            (require 'ansi-color)
            (ansi-color-map-update 'ansi-color-names-vector
                                   (vconcat (mapcar (lambda (elem)
                                                      (cond
                                                       ((string= elem "blue")
                                                        "deep sky blue")
                                                       (t
                                                        elem)))
                                                    ansi-color-names-vector)))))

;; `eww'
(defun my-eww-appearance ()
  (setq show-trailing-whitespace nil))
(add-hook 'eww-mode-hook 'my-eww-appearance)

(provide 'my-appearance)
