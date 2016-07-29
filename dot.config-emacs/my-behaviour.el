;;; my-behaviour.el --- Global behaviour settings.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Packages

(my-add-packages
 '(
   ace-window
   anzu
   (:name cssh                  :type elpa)
   (:name expand-region         :type elpa)
   (:name fancy-narrow          :type elpa)
   flx
   (:name fuzzy                 :type elpa)
   god-mode
   (:name hungry-delete         :type elpa)
   ido-ubiquitous
   (:name key-chord             :type elpa)
   multiple-cursors
   outshine
   smartparens
   smex
   undo-tree
   ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Frames


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

(put 'narrow-to-region 'disabled nil)     ; enable region narrowing
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
  :diminish smartparens-mode
  :init
  (progn
    (require 'smartparens-config)
    (smartparens-global-mode t)         ; highlight matching parenthesis
    (show-smartparens-global-mode t)
    (defvar LaTeX-mode-hook nil)
    (add-to-list 'LaTeX-mode-hook (lambda () (require 'smartparens-latex)))))

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
(setq-default save-place t)             ; activate it for all buffers
(require 'saveplace)

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
  :config (global-anzu-mode))

;;;; `uniquify': nicer unique names for buffers
(setq-default uniquify-ignore-buffers-re "^\\*")

(setq-default show-trailing-whitespace t)

;;;; `whitespace': highlight lines breaking formatting rules
(use-package whitespace
  :diminish whitespace-mode
  :init
  (add-hook 'fund-file-hook #'whitespace-mode)
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
  :config (global-hungry-delete-mode))

;;;; `undo-tree'
(use-package undo-tree
  :init (global-undo-tree-mode)
  :diminish undo-tree-mode
  :config
  (progn
    (defadvice undo-tree-undo (around keep-region activate)
      "Keep region when undoing in region."
      (if (use-region-p)
          (let ((m (set-marker (make-marker) (mark)))
                (p (set-marker (make-marker) (point))))
            ad-do-it
            (goto-char p)
            (set-mark m)
            (set-marker p nil)
            (set-marker m nil))
        ad-do-it))))

(use-package multiple-cursors
  :bind (("C-;"   . mc/mark-all-dwim)
         ("C-M-;" . mc/edit-lines)
         ("C-M-," . mc/mark-mode-like-this-extended)
         ("C-S-<mouse-1>" . mc/add-cursor-on-click)))

(use-package ace-link
  :ensure t
  :defer 2
  :bind ("C-x C-M-o" . ace-link-addr)
  :init
  ;; bound to "C-x C-M-o"
  (use-package org
    :config
    (define-key org-mode-map (kbd "C-x C-M-o") 'ace-link-org))
  ;; bound to "M-o"
  (use-package gnus
    :config
    (progn
      (define-key gnus-summary-mode-map (kbd "M-o") 'ace-link-gnus)
      (define-key gnus-article-mode-map (kbd "M-o") 'ace-link-gnus)))
  :config
  ;; bound to "o"
  (ace-link-setup-default))

;;;; `outshine'
(use-package outshine
  :defer t
  :init
  (progn
    (autoload 'outshine-hook-function "outshine")
    (add-hook 'outline-minor-mode-hook
              'outshine-hook-function)))

;;;; `outline'
(use-package outline
  :defer t
  :diminish outline-minor-mode)

;;;; `expand-region'
(use-package expand-region
  :defer t
  :bind ("C-M-<return>" . er/expand-region))

;;;; `fancy-narrow'
(use-package fancy-narrow
  :bind (([remap narrow-to-region] . fancy-narrow-to-region)
         ([remap widen] . fancy-widen)))

(use-package narrow-or-widen-dwim
  :bind ("C-x n" . narrow-or-widen-dwim))

;;;; `key-chord'
(use-package key-chord
  :config
  (progn
    (key-chord-mode t)
    ;; insert ';' at the end of the line
    (key-chord-define-global ";;" "\C-e;")))

(use-package aggressive-indent
  :ensure t
  :commands (aggressive-indent-mode)
  :init
  (add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Minibuffer

(fset 'yes-or-no-p 'y-or-n-p)           ; enable y/n answers to yes/no
(file-name-shadow-mode t)               ; shadow / dim parts of file names

;;;; `ido': integrates both buffers and files completion
;;        supersedes `iswitchb' `icicles'
;; http://www.emacswiki.org/emacs/InteractivelyDoThings
(ido-mode 1)
(ido-everywhere 1)                      ; use for many file dialogs
(setq ido-save-directory-list-file (path my-cache-dir "ido.last")
      ido-ignore-buffers '("\\` " "^\*Mess" "^\*Back" ".*Completion" "^\*Ido")
      ido-auto-merge-delay-time 9999    ; do not look for file names on other dirs
      ido-default-file-method 'maybe-frame ; ask if buffer in other frame must be re-opened
      ido-case-fold  t                  ; be case-insensitive
      ido-use-faces nil                   ; do not hide `flx' highlighting
      ido-enable-last-directory-history t ; remember last used dirs
      ido-max-work-directory-list 30    ; should be enough
      ido-max-work-file-list      50    ; remember many
      ido-use-filename-at-point 'guess  ; use filename at point if looks like one
      ido-use-url-at-point t            ; use url at point
      ido-use-virtual-buffers t         ; show closed files in buffer list
      ido-enable-flex-matching t        ; be flexible
      ido-enable-tramp-completion nil
      ido-confirm-unique-completion nil ; wait for RET even on one completion
      ido-show-dot-for-dired nil        ; show '.' as first completion
      ido-max-prospects 10              ; don't spam my minibuffer
      ido-confirm-unique-completion t)  ; wait for RET, even with unique completion

;;;; `ido-ubiquitous'
(use-package ido-ubiquitous
  :config (ido-ubiquitous-mode 1))

;;;; `flx-ido': smarter flexible search
(use-package flx-ido
  :init (flx-ido-mode 1))

;;;; `smex': command-completion interface on top of `ido'
;;         replaces emacs's default `execute-extended-command'
;;         supersedes `icomplete+'
(use-package smex
  :init
  (progn
    (el-get nil '(smex))
    (setq smex-save-file (path my-cache-dir "smex.save")))
  :config (smex-initialize)
  :bind (("M-x" . smex)
         ("M-X" . smex-major-mode-commands)))

;;;; `icomplete-mode'
;; Complements `smex' where it is not used
(icomplete-mode)

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
    (when (yes-or-no-p (format "Create directory \"%s\"?" dir))
      (make-directory dir t))))
(add-hook 'find-file-not-found-functions #'my-make-parent-directory)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Misc

(setq load-prefer-newer t)         ; prefer the newer file when loading .el/.elc

(setq tramp-persistency-file-name (path my-cache-dir "tramp"))

;;;; `browse-kill-ring': kill ring browser on M-y
(use-package browse-kill-ring
  :config
  (progn
    (browse-kill-ring-default-keybindings)
    (setq browse-kill-ring-quit-action 'save-and-restore))) ; restore window config

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
(setq savehist-file (path my-cache-dir "history"))
(savehist-mode t)

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

(put 'narrow-to-page 'disabled nil)     ; do not barf about narrowing

;;;; `re-builder'
(add-hook 'reb-mode-hook
          (lambda ()
            (setq reb-re-syntax 'string)))

;;;; `popwin'
(use-package popwin
  :ensure t
  :commands
  popwin:display-buffer
  popwin-mode
  :bind-keymap
  ("C-z" . popwin:keymap)
  :init
  (setq display-buffer-function 'popwin:display-buffer)
  (setq popwin:special-display-config)
  (defun my-register-helper-buffer (pattern &optional type &rest other)
    "Register given buffer PATTERN as being for a specific TYPE of usage.
Valid types are: help long-help info long-info

Any other type is passed as-is to `popwin' as keywords, together with OTHER."
    (let ((keywords
           (append other
                   (case type
                     (nil)
                     ('help)
                     ('long-help '(:position right :width 90))
                     ('info '(:position bottom :stick t))
                     ('long-info '(:position right :width 90 :stick t))
                     (t (error (format "Unknown type: %s" type)))))))
      (setq popwin:special-display-config
            (delq (assoc pattern popwin:special-display-config)
                  popwin:special-display-config))
      (if keywords
          (push (cons pattern keywords) popwin:special-display-config)
        (push pattern popwin:special-display-config))))
  :config
  (popwin-mode 1)
  ;; Integrate customized values into the variable
  (let ((orig (or (cadar (get 'popwin:special-display-config 'customized-value))
                  (cadar (get 'popwin:special-display-config 'saved-value))
                  (cadar (get 'popwin:special-display-config 'standard-value)))))
    (mapc
     (lambda (elem)
       (let ((key (if (listp elem) (car elem) elem)))
         (unless (assoc key popwin:special-display-config)
           (add-to-list 'popwin:special-display-config elem t))))
     orig)))

;; `god-mode': Control- and Meta-less commands
(use-package god-mode
  :bind (("M-ESC" . god-local-mode)))

;; `cssh'
(use-package cssh
  :config (cssh-define-global-bindings))

;; `dired'
(add-hook 'dired-mode-hook #'dired-hide-details-mode)

;; `dired-filter'
(use-package dired-filter
  :ensure t
  :init (add-hook 'dired-mode-hook #'dired-filter-mode)
  :config (define-key dired-mode-map (kbd "/") dired-filter-map))

;; `fuzzy'
(use-package fuzzy
  :commands turn-on-fuzzy-isearch
  :init (turn-on-fuzzy-isearch))

;; `ediff'
(use-package ediff
  :init (progn
          (setq ediff-split-window-function 'split-window-horizontally
                ediff-window-setup-function 'ediff-setup-windows-plain)
          (add-hook 'ediff-after-quit-hook-internal 'winner-undo)))

;; `info+'
(use-package info+
  :ensure t)

(use-package which-key
  :ensure t
  :defer 1
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

;;; Postamble

(provide 'my-behaviour)
;;; my-behaviour.el ends here
