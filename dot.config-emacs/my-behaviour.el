;; -*- lexical-binding: t; -*-
;;; my-behaviour.el --- Global behaviour settings.


;;; Code:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Frames

(add-hook 'server-switch-hook
          #'(lambda ()
              (raise-frame (selected-frame))))

(defun my-new-frame-hook (frame)
  (raise-frame frame)
  (select-frame-set-input-focus frame))
(add-hook 'after-make-frame-functions 'my-new-frame-hook)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Windows

;;;; Scrolling
(setq scroll-margin 1                   ; do smooth scrolling, ...
      scroll-conservatively 100000      ; ... the defaults ...
      scroll-up-aggressively 0.01       ; ... are very ...
      scroll-down-aggressively 0.01)    ; ... annoying

;;;; Window sizes
(setq window-combination-resize t       ; try to be fair creating windows ...
      window-combination-limit t)       ; ... as well as deleting them

(put 'narrow-to-region 'disabled nil)   ; enable region narrowing
(put 'narrow-to-page 'disabled nil)     ; do not barf about narrowing
(put 'erase-buffer 'disabled nil)

;;;; Undo / redo window configurations
(winner-mode 1)

;;;; Move between windows
(use-package windmove
  :config (windmove-default-keybindings 'super)
  :bind (("C-x <left>"  . windmove-left)
         ("C-x <right>" . windmove-right)
         ("C-x <up>"    . windmove-up)
         ("C-x <down>"  . windmove-down)))
(use-package ace-window
  :ensure t
  :config (setq aw-leading-char-style 'path)
  :bind ("C-x o" . ace-window))

;;;; Quickly change buffer organization
(setq my--swapping-buffer nil)
(setq my--swapping-window nil)
(defun my-swap-buffers-in-windows ()
  "Swap buffers between two windows"
  (interactive)
  (if (and my--swapping-window
           my--swapping-buffer)
      (let ((this-buffer (current-buffer))
            (this-window (selected-window)))
        (if (and (window-live-p my--swapping-window)
                 (buffer-live-p my--swapping-buffer))
            (progn (switch-to-buffer my--swapping-buffer)
                   (select-window my--swapping-window)
                   (switch-to-buffer this-buffer)
                   (select-window this-window)
                   (message "Swapped buffers."))
          (message "Old buffer/window killed.  Aborting."))
        (setq my--swapping-buffer nil)
        (setq my--swapping-window nil))
    (progn
      (setq my--swapping-buffer (current-buffer))
      (setq my--swapping-window (selected-window))
      (message "Buffer and window marked for swapping."))))

;;;; Dedicated windows
(use-package dedicated
  :ensure t
  :bind ("<pause>" . dedicated-mode))

;;;; Reuse existing visible windows instead of producing new splits
(defun enable-window-reuse-for-modes (&rest modes)
  "Enables window reuse for given MODES.
In case there already exist window of given mode, new incarnation
will reuse them.
Examples:
   (require 'my-window-reuse)
   (enable-window-reuse-for-modes 'Man-mode)
   ; or
   (enable-window-reuse-for-modes 'Man-mode 'Info-mode)
"
  (let ((checked-modes modes))
    (add-to-list 'display-buffer-alist
                 (cons (lambda (buffer alist)
                         (with-current-buffer buffer
                           (memq major-mode checked-modes)))
                       (cons 'display-buffer-reuse-major-mode-window
                             '((inhibit-same-window . nil)
                               (reusable-frames . visible)
                               (inhibit-switch-frame . nil)))))))
;;
(enable-window-reuse-for-modes 'compilation-mode 'cscope-list-entry-mode)
;;
(defun display-buffer-reuse-major-mode-window (buffer alist)
  "Return a window displaying a buffer in BUFFER's major mode.
Return nil if no usable window is found.

If ALIST has a non-nil `inhibit-same-window' entry, the selected
window is not eligible for reuse.

If ALIST contains a `reusable-frames' entry, its value determines
which frames to search for a reusable window:
  nil -- the selected frame (actually the last non-minibuffer frame)
  A frame   -- just that frame
  `visible' -- all visible frames
  0   -- all frames on the current terminal
  t   -- all frames.

If ALIST contains no `reusable-frames' entry, search just the
selected frame if `display-buffer-reuse-frames' and
`pop-up-frames' are both nil; search all frames on the current
terminal if either of those variables is non-nil.

If ALIST has a non-nil `inhibit-switch-frame' entry, then in the
event that a window on another frame is chosen, avoid raising
that frame."
  (let* ((alist-entry (assq 'reusable-frames alist))
         (frames (cond (alist-entry (cdr alist-entry))
                       ((if (eq pop-up-frames 'graphic-only)
                            (display-graphic-p)
                          pop-up-frames)
                        0)
                       (display-buffer-reuse-frames 0)
                       (t (last-nonminibuffer-frame))))
         (window (let ((mode (with-current-buffer buffer major-mode)))
                   (if (and (eq mode (with-current-buffer (window-buffer)
                                       major-mode))
                            (not (cdr (assq 'inhibit-same-window alist))))
                       (selected-window)
                     (catch 'window
                       (walk-windows
                        (lambda (w)
                          (and (window-live-p w)
                               (eq mode (with-current-buffer (window-buffer w)
                                          major-mode))
                               (not (eq w (selected-window)))
                               (throw 'window w)))
                        'nomini frames))))))
    (when (window-live-p window)
      (prog1 (window--display-buffer buffer window 'reuse alist)
        (unless (cdr (assq 'inhibit-switch-frame alist))
          (window--maybe-raise-frame (window-frame window)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Buffers

;;;; Default editing parameters
(setq-default fill-column       80        ; text width
              comment-column    40        ; `comment-indent'
              tab-always-indent 'complete ; indent or complete otherwise
              indent-tabs-mode nil        ; never use tabs
              tab-width          8)       ; just 'cause almost everybody uses 8

(setq require-final-newline t)          ; end files with a newline

(transient-mark-mode t)                 ; show current 'selection'
(delete-selection-mode t)               ; delete the selection with a keypress
(cua-selection-mode t)                  ; enable CUA behaviour without C-[zxvc]
(setq scroll-margin 3)                  ; always show some lines around cursor

(setq search-highlight t                ; highlight when searching...
      query-replace-highlight t         ; ...and replacing
      isearch-allow-scroll t)

(global-font-lock-mode t)               ; always do syntax highlighting
(blink-cursor-mode -1)                  ; don't blink cursor
(use-package smartparens
  :ensure t
  :diminish smartparens-mode
  :init
  (progn
    (require 'smartparens-config)
    (smartparens-global-mode t)         ; highlight matching parenthesis
    (show-smartparens-global-mode t)
    (defvar LaTeX-mode-hook nil)))

(defun my-smart-kill-whole-line (&optional arg)
  "A simple wrapper around `kill-whole-line' that respects indentation."
  (interactive "P")
  (kill-whole-line arg)
  (back-to-indentation))
(global-set-key [remap kill-whole-line] 'my-smart-kill-whole-line)

(defmacro my-with-bol-prefix (function)
  "Define a new function which calls FUNCTION.
Except it moves to beginning of line before calling FUNCTION when
called with a prefix argument. The FUNCTION still receives the
prefix argument."
  (let ((name (intern (format "my-%s-BOL" function))))
    `(progn
       (defun ,name (p)
         ,(format
           "Call `%s', but move to BOL when called with a prefix argument."
           function)
         (interactive "P")
         (when p
           (forward-line 0))
         (call-interactively ',function))
       ',name)))
(global-set-key [remap kill-line] (my-with-bol-prefix kill-line))

(defun my-duplicate-line (&optional commentfirst)
  "Duplicate line at point.
If COMMENTFIRST is non-nil, comment the original line."
  (interactive)
  (beginning-of-line)
  (push-mark)
  (end-of-line)
  (let ((str (buffer-substring (region-beginning) (region-end))))
    (when commentfirst
      (comment-region (region-beginning) (region-end)))
    (insert (concat (if (= 0 (forward-line 1)) "" "\n") str "\n"))
    (forward-line -1)))

(defun my-duplicate-and-comment-line ()
  (interactive)
  (my-duplicate-line t))

(defun my-kill-word-or-region-dwim ()
  (interactive)
  (call-interactively
   (cond
    ((region-active-p) 'kill-region)
    (cua--rectangle    'cua-cut-rectangle)
    (t                 'backward-kill-word))))

;;;; `saveplace': restore last cursor position in file
(setq save-place-file (path my-cache-dir "places"))
(save-place-mode t)

;;;; backups: all in one single place
(setq my-backup-dir (path my-cache-dir "backups" ""))
(make-directory my-backup-dir t)
(setq make-backup-files t               ; do make backups ...
      vc-make-backup-files t            ; ... even for VC ...
      backup-by-copying t               ; ... and copy them ...
      backup-directory-alist (list (cons "." my-backup-dir)) ; ... here
      version-control t
      kept-new-versions 2
      kept-old-versions 5
      delete-old-versions t)

;;;; auto-save files
(defconst my-auto-saves-root (path my-cache-dir "auto-saves" ""))
(make-directory my-auto-saves-root t)
(setq auto-save-file-name-transforms `(("\\(?:[^/]*/\\)*\\(.*\\)"
                                        ,(path my-auto-saves-root "\\1") t)))

;;;; auto-save sessions
(setq auto-save-list-file-prefix        ; location for auto-save sessions
      (path my-cache-dir "auto-save-list" ""))

;;;; `avy'
(use-package avy
  :ensure t
  :bind (("C-c C-j c" . avy-goto-char)
         ("C-c C-j w" . avy-goto-word-1)
         ("C-c C-j l" . avy-goto-line)
         ("C-'" . avy-isearch)))

;;;; `anzu'
(use-package anzu
  :ensure t
  :diminish anzu-mode
  :init (setq-default anzu-cons-mode-line-p nil)
  :config (global-anzu-mode))

;;;; `uniquify': nicer unique names for buffers
(setq-default uniquify-ignore-buffers-re "^\\*")

;;;; `whitespace': highlight lines breaking formatting rules
(use-package whitespace
  :diminish whitespace-mode
  :init
  (add-hook 'find-file-hook #'whitespace-mode)
  :config
  (progn
    (setq whitespace-style
          '(face trailing lines-tail space-before-tab indentation empty
                 space-after-tab)
          whitespace-line-column nil)))

(defun my-toggle-tabs ()
  "Toggle TAB usage on the visualization of lines breaking formatting rules."
  (interactive)
  (setq indent-tabs-mode (not indent-tabs-mode))
  (if indent-tabs-mode
      (message "Using tabs")
    (message "Using spaces"))
  (whitespace-turn-off)
  (whitespace-turn-on))

(defun my-copy-increment (num-lines)
  "Copies line, preserving cursor column, and increments any numbers found.
Copies a block of optional NUM-LINES lines.  If no optional argument is given,
then only one line is copied."
  (interactive "p")
  (if (not num-lines) (setq num-lines 0) (setq num-lines (1- num-lines)))
  (let* ((col (current-column))
         (bol (save-excursion (forward-line (- num-lines)) (beginning-of-line) (point)))
         (eol (progn (end-of-line) (point)))
         (line (buffer-substring bol eol)))
    (goto-char bol)
    (while (re-search-forward "[0-9]+" eol 1)
      (let ((num (string-to-int (buffer-substring
                                 (match-beginning 0) (match-end 0)))))
        (replace-match (int-to-string (1+ num))))
      (setq eol (save-excursion (goto-char eol) (end-of-line) (point))))
    (goto-char bol)
    (insert line "\n")
    (move-to-column col)))

(defun my-auto-make-directory (&optional buf)
  "Create intermediate directories for file."
  (let* ((buf (or buf (current-buffer)))
         (parent (file-name-directory (buffer-file-name buf))))
    (unless (file-accessible-directory-p parent)
      (when (yes-or-no-p (format "Create intermediate directories? (%s)"
                                 parent))
        (make-directory parent t)))))
(add-hook 'before-save-hook 'my-auto-make-directory)

;;;; `global-auto-revert-mode'
(global-auto-revert-mode 1)                  ; auto refresh buffers ...
(setq global-auto-revert-non-file-buffers t) ; ... including dired ...
(setq auto-revert-verbose nil)                 ; ... but be quiet about it

;;;; `hungry-delete-mode'
(use-package hungry-delete
  :ensure t
  :diminish hungry-delete-mode
  :config (global-hungry-delete-mode))

(use-package multiple-cursors
  :ensure t
  :bind (("C-;"   . mc/mark-all-dwim)
         ("C-M-;" . mc/edit-lines)
         ("C-M-," . mc/mark-mode-like-this-extended)
         ("C-S-<mouse-1>" . mc/add-cursor-on-click)))

;;;; `ace-link'
(use-package ace-link
  :ensure t
  :init
  ;; bound to "C-x C-M-o"
  (use-package goto-address
    :bind ("C-x C-M-o" . ace-link-addr)
    :init (add-hook 'find-file-hook 'goto-address-mode))
  (use-package org
    :bind (:map org-mode-map
                ("C-x C-M-o" . ace-link-org)))
  ;; bound to "M-o"
  (use-package gnus
    :bind
    (:map gnus-summary-mode-map
          ("M-o" . ace-link-gnus))
    (:map gnus-article-mode-map
          ("M-o" . ace-link-gnus)))
  :config
  ;; bound to "o"
  (ace-link-setup-default))

;;;; `outshine'
(use-package outshine
  :ensure t
  :defer t
  :init
  (progn
    (add-hook 'outline-minor-mode-hook
              'outshine-mode)))

;;;; `outline'
(use-package outline
  :defer t
  :diminish outline-minor-mode)

;;;; `expand-region'
(use-package expand-region
  :ensure t
  :defer t
  :bind ("C-M-<return>" . er/expand-region))

;;;; `fancy-narrow'
(use-package fancy-narrow
  :bind (([remap narrow-to-region] . fancy-narrow-to-region)
         ([remap widen] . fancy-widen)))

(use-package narrow-or-widen-dwim
  :init
  (defun my-narrow-or-widen-dwim (p)
    "`narrow-or-widen-dwim' with an indirect buffer when called with prefix."
    (interactive "P")
    (if p
        (let ((buf (clone-indirect-buffer nil nil)))
          (with-current-buffer buf
            (narrow-or-widen-dwim nil)
            (switch-to-buffer buf)))
      (narrow-or-widen-dwim nil)))
  :commands narrow-or-widen-dwim
  :bind ("C-x n" . my-narrow-or-widen-dwim))

;;;; `key-chord'
(use-package key-chord
  :ensure t
  :config
  (progn
    (key-chord-mode t)
    ;; insert ';' at the end of the line
    (key-chord-define-global ";;" "\C-e;")))

(use-package aggressive-indent
  :ensure t
  :commands aggressive-indent-mode
  :init
  (add-hook 'emacs-lisp-mode-hook 'aggressive-indent-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Minibuffer

(fset 'yes-or-no-p 'y-or-n-p)           ; enable y/n answers to yes/no
(file-name-shadow-mode t)               ; shadow / dim parts of file names

;;;; `vertico': vertical completion window
(use-package vertico
  :ensure t
  :init (vertico-mode)
  :config
  (progn
    (keymap-set vertico-map "?" #'minibuffer-completion-help) 
    (keymap-set vertico-map "M-RET" #'minibuffer-force-complete-and-exit)
    (keymap-set vertico-map "M-TAB" #'minibuffer-complete)))

;;;; `orderless': completion matching styles
(use-package orderless
  :ensure t
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))

;;;; `marginalia': rich minibuffer annotations
(use-package marginalia
  :ensure t
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map ("M-a" . marginalia-cycle))
  :init
  (marginalia-mode))

;;;; `embark': minibuffer actions during completions
(use-package embark
  :ensure t
  :bind
  (("M->" . embark-act)         ;; pick some comfortable binding
   ("M-." . embark-dwim)        ;; good alternative to default M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  :config
  ;; additional file actions
  (define-key embark-file-map "r" #'rename-file)
  (define-key embark-file-map "c" #'copy-file)

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;;;; `consult': better minibuffer completions
(use-package consult
  :ensure t
  :bind
  (("C-s" . consult-line)
   ("C-x b" . consult-buffer)
   ("C-x 4 b" . consult-buffer-other-window)
   ("C-x 5 b" . consult-buffer-other-frame)
   ("M-g g" . consult-goto-line))
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5))

;;;; `embark-consult': consult integration for embark
(use-package embark-consult
  :ensure t
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package recentf
  :ensure t
  :custom
  (recentf-save-file (path my-cache-dir "recentf"))
  :init (recentf-mode))

;;;; `ibuffer': dired-style buffer selection
;; TODO: use EDE's project name to group files that would otherwise be in
;; "Programming" or "Default"
(defvar my-ibuffer-saved-filter-groups
  '(("default"
     ("Org" (or
             (mode . org-mode)
             (mode . org-agenda-mode)
             ))
     ("Mail" (or (mode . message-mode) (mode . mail-mode)))
     ("Programming" (or
                     (mode . c-mode)
                     (mode . c++-mode)
                     (mode . python-mode)
                     (mode . emacs-lisp-mode)
                     )))))
(setq ibuffer-saved-filter-groups my-ibuffer-saved-filter-groups)
(add-hook 'ibuffer-mode-hook
          (lambda () (ibuffer-switch-to-saved-filter-groups "default")))

;;;; Create parents
(defun my-make-parent-directory ()
  "Make sure the directory of `buffer-file-name' exists."
  (let ((dir (file-name-directory buffer-file-name)))
    (when (and (not (file-directory-p dir))
               (yes-or-no-p (format "Create directory \"%s\"?" dir)))
      (make-directory dir t))))
(add-hook 'find-file-not-found-functions #'my-make-parent-directory)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Misc

;; Increase internal buffers / caches
(setq read-process-output-max (* 1024 1024)) ;; 1mb
(setq gc-cons-threshold 100000000) ;; 10mb

(setq load-prefer-newer t)         ; prefer the newer file when loading .el/.elc

(setq tramp-persistency-file-name (path my-cache-dir "tramp"))

;;;; `browse-kill-ring': kill ring browser on M-y
(use-package browse-kill-ring
  :ensure t
  :config
  (browse-kill-ring-default-keybindings)
  (setq browse-kill-ring-quit-action 'save-and-restore)) ; restore window config

;; Save whatever’s in the current (system) clipboard before
;; replacing it with the Emacs’ text.
;; https://github.com/dakrone/eos/blob/master/eos.org
(setq save-interprogram-paste-before-kill t)

;;;; `time-stamp': Insert timestamp text if buffer has text "Time-stamp: <>"
(use-package time-stamp
  :init (add-hook 'write-file-hooks 'time-stamp) ; update when saving
  :config
  (setq time-stamp-active t             ; do enable time-stamps
        time-stamp-line-limit 10        ; check first 10 buffer lines
        time-stamp-format "%04y-%02m-%02d %02H:%02M:%02S (%u)")) ; date format

;;;; `desktop': maintain per-directory session information
(desktop-save-mode 1)
(setq desktop-save 'if-exists)          ; only save if desktop file exists

;;;; `savehist': save minibuffer history
(use-package savehist
  :ensure t
  :init
  (progn
    (setq savehist-file (path my-cache-dir "history"))
    (savehist-mode t)))

;;;; `bookmark+': bookmark everything
(setq bookmark-default-file (path my-data-dir "bookmarks"))
(defun my-jump-to-bookmark (bookmark)
  (interactive (list (my--bookmark-ido-read "Jump to bookmark: ")))
  (bookmark-jump bookmark))
(defun my--bookmark-ido-read (prompt)
  (let ((ido-make-buffer-list-hook
         (lambda ()
           (require 'bookmark)
           (setq ido-temp-list (bookmark-all-names)))))
    (ido-read-buffer prompt)))

;;;; `url'
(setq url-configuration-directory (path my-cache-dir "url" ""))

;;;; `eshell'
(setq eshell-directory-name (path my-cache-dir "eshell"))

;;;; `em-smart'
;; Be clever on `eshell' output
(add-hook 'eshell-mode-hook
          (lambda ()
            (require 'em-smart)
            (setq eshell-where-to-jump 'begin
                  esell-review-quick-commands nil
                  eshell-smart-space-goes-to-end t)
            (eshell-smart-initialize)))

;;;; `re-builder'
(add-hook 'reb-mode-hook
          (lambda ()
            (setq reb-re-syntax 'string)))

;; `god-mode': Control- and Meta-less commands
(use-package god-mode
  :ensure t
  :bind (("M-ESC" . god-local-mode)))

;; `dired'
(add-hook 'dired-mode-hook #'dired-hide-details-mode)

;; `dired-filter'
(use-package dired-filter
  :ensure t
  :init (add-hook 'dired-mode-hook #'dired-filter-mode)
  :config (define-key dired-mode-map (kbd "/") dired-filter-map))

;; `ediff'
(use-package ediff
  :init (progn
          (setq ediff-split-window-function 'split-window-horizontally
                ediff-window-setup-function 'ediff-setup-windows-plain)
          (add-hook 'ediff-after-quit-hook-internal 'winner-undo)))

(use-package info-buffer
  :ensure t
  :bind (("C-h i" . info-buffer)))

(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config (which-key-mode))


;;;; Editing as sudo

;; (defadvice ido-find-file (after find-file-sudo activate)
;;   "Find file as root if necessary."
;;   (unless (and buffer-file-name
;;                (file-writable-p buffer-file-name))
;;     (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

(defun my-find-alternate-file-or-as-sudo ()
  (interactive)
  (let ((file-name (buffer-file-name)))
    (if (or (file-writable-p file-name) (not file-name))
        (ido-find-alternate-file)
      (find-alternate-file (concat "/sudo::" file-name)))))
;; (global-set-key [remap ido-find-alternate-file] 'my-find-alternate-file-or-as-sudo)
(global-set-key [(control x) (control v)] 'my-find-alternate-file-or-as-sudo)

;;;; GnuPG
(use-package epg
  :ensure t
  :defer 2
  :config
  (epa-file-enable))


;;; Postamble

(provide 'my-behaviour)
;;; my-behaviour.el ends here
