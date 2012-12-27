;;; my-behaviour.el --- Global behaviour settings.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Frames
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; `framepop': Toggle visibility of a buffer pinned in a frame
(when window-system
  (setq framepop-enable-keybinding "<f7>")
  (require 'framepop)

  (defvar my-framepop-with-focus t)
  (defun my-framepop-toggle-with-focus ()
    "Toggle whether framepop should retain input focus."
    (interactive)
    (setq my-framepop-with-focus (not my-framepop-with-focus))
    (if my-framepop-with-focus
        (message "FramePop focused")
      (message "FramePop unfocused")))

  ;; advice framepop to allow input focus
  (defadvice framepop-toggle-frame (after my-framepop-toggle-frame
                                          activate)
    "Switch input focus if necessary."
    (if (and my-framepop-with-focus
           framepop-frame
           (eq t (frame-visible-p framepop-frame)))
        (select-frame-set-input-focus framepop-frame)))
  (defadvice framepop-display-buffer (after my-framepop-display-buffer
                                            activate)
    "Do not redirect input focus if thus is wanted."
    (when my-framepop-with-focus
      (redirect-frame-focus framepop-frame))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Scrolling
(setq scroll-margin 1                   ; do smooth scrolling, ...
      scroll-conservatively 100000      ; ... the defaults ...
      scroll-up-aggressively 0.01       ; ... are very ...
      scroll-down-aggressively 0.01)    ; ... annoying

;; Window sizes
(setq window-combination-resize t       ; try to be fair creating windows ...
      window-combination-limit t)       ; ... as well as deleting them

(put 'narrow-to-region 'disabled nil)     ; enable region narrowing
(put 'erase-buffer 'disabled nil)

;; Undo / redo window configurations
(winner-mode 1)

;; Quickly change buffer organization
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Buffers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Default editing parameters
(setq-default fill-column       80      ; text width
              comment-column    40      ; `comment-indent'
              indent-tabs-mode nil      ; never use tabs
              tab-width          8)     ; just 'cause almost everybody uses 8

(setq require-final-newline t)          ; end files with a newline

(transient-mark-mode t)                 ; show current 'selection'
(delete-selection-mode t)               ; delete the selection with a keypress
(cua-selection-mode t)                  ; enable CUA behaviour without C-[zxvc]

(setq search-highlight t                ; highlight when searching...
      query-replace-highlight t         ; ...and replacing
      isearch-allow-scroll t)

(global-font-lock-mode t)               ; always do syntax highlighting
(blink-cursor-mode -1)                  ; don't blink cursor
(global-hl-line-mode t)                 ; highlight current line
(show-paren-mode t)                     ; highlight matching parenthesis...
(setq show-paren-style 'mixed)          ; ...but whole region if out of window

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

;; `iedit'
(eval-after-load 'iedit
  '(defun my-iedit-dwim (arg)
     "Starts iedit but uses \\[narrow-to-defun] to limit its scope."
     (interactive "P")
     (if arg
         (iedit-mode)
       (save-excursion
         (save-restriction
           (widen)
           ;; this function determines the scope of `iedit-start'.
           (narrow-to-defun)
           (if iedit-mode
               (iedit-done)
             ;; `current-word' can of course be replaced by other
             ;; functions.
             (iedit-mode)))))))

;; `multiple-cursors'
(defun my-mc/mark-all (region)
  "Use `mc/mark-all-like-this' in current function or `mc/mark-all-in-region'."
  (interactive "P")
  (if region
      (call-interactively 'mc/mark-all-in-region)
    (save-excursion
      (save-restriction
        (if nil nil nil)
        (widen)
        (narrow-to-defun)
        (mc/mark-all-like-this)))))

;; `saveplace': restore last cursor position in file
(setq save-place-file (path my-cache-dir "places"))
(setq-default save-place t)             ; activate it for all buffers
(require 'saveplace)

;; backups: all in one single place
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

;; auto-save files
(defconst my-auto-saves-root (path my-cache-dir "auto-saves" ""))
(make-directory my-auto-saves-root t)
(setq auto-save-file-name-transforms `(("\\(?:[^/]*/\\)*\\(.*\\)"
                                        ,(path my-auto-saves-root "\\1") t)))

;; auto-save sessions
(setq auto-save-list-file-prefix        ; location for auto-save sessions
      (path my-cache-dir "auto-save-list" ""))

;; `uniquify': nicer unique names for buffers
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward
      uniquify-separator ":"
      uniquify-after-kill-buffer-p t
      uniquify-ignore-buffers-re "^\\*")

;; `whitespace': highlight and fix lines breaking formatting rules
(setq whitespace-style
      '(face trailing lines-tail space-before-tab indentation empty space-after-tab)
      whitespace-line-column nil)
(global-whitespace-mode t)
;; nuke whitespaces when writing to a file
(add-hook 'find-file-hook
          '(lambda ()
             (setq whitespace-indent-tabs-mode indent-tabs-mode)))
;; (add-hook 'before-save-hook 'whitespace-cleanup)

(defun my-toggle-tabs ()
  "Toggle TAB usage on the visualization of lines breaking formatting rules."
  (interactive)
  (setq indent-tabs-mode (not indent-tabs-mode)
        whitespace-indent-tabs-mode indent-tabs-mode)
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

;; `global-auto-revert-mode'
(global-auto-revert-mode 1)                  ; auto refresh buffers ...
(setq global-auto-revert-non-file-buffers t) ; ... including dired ...
(setq auto-revert-verbose nil)                 ; ... but be quiet about it


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Minibuffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fset 'yes-or-no-p 'y-or-n-p)           ; enable y/n answers to yes/no
(file-name-shadow-mode t)               ; shadow / dim parts of file names

;; `ido': integrates both buffers and files completion
;;        supersedes `iswitchb' `icicles'
;; http://www.emacswiki.org/emacs/InteractivelyDoThings
(ido-mode 1)
(ido-everywhere 1)                      ; use for many file dialogs
(setq ido-save-directory-list-file (path my-cache-dir "ido.last")
      ido-ignore-buffers '("\\` " "^\*Mess" "^\*Back" ".*Completion" "^\*Ido")
      ido-default-file-method 'maybe-frame ; ask if buffer in other frame must be re-opened
      ido-case-fold  t                  ; be case-insensitive
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

;; `filecache': find files using a pre-loaded cache
;; http://www.emacswiki.org/cgi-bin/wiki/FileNameCache
(defvar my-filecache-dirs
  (list my-home-dir
        (path my-home-dir ".config" "emacs")
        (path my-home-dir "Desktop")
        (path my-home-dir "Documents")
        (path my-home-dir "Projects"))
  "Directories to cache with `filecache'.")
(eval-after-load
    "filecache"
  '(progn
     (message "Loading file cache...")
     (file-cache-add-directory-list my-filecache-dirs)))
(defun my-file-cache-ido-find-file (file)
  "Using ido, interactively open file from file cache'.
First select a file, matched using ido-switch-buffer against the contents
in `file-cache-alist'. If the file exist in more than one
directory, select directory. Lastly the file is opened."
  (interactive (progn
                 (require 'filecache)
                 (list (my--file-cache-ido-read
                        "File: "
                        (mapcar
                         (lambda (x)
                           (car x))
                         file-cache-alist)))))
  (let* ((record (assoc file file-cache-alist)))
    (find-file
     (expand-file-name
      file
      (if (= (length record) 2)
          (car (cdr record))
        (my--file-cache-ido-read
         (format "Find %s in dir: " file) (cdr record)))))))
(defun my--file-cache-ido-read (prompt choices)
  (let ((ido-make-buffer-list-hook
         (lambda ()
           (setq ido-temp-list choices))))
    (ido-read-buffer prompt)))

;; `smex': command-completion interface on top of `ido'
;;         replaces emacs's default `execute-extended-command'
;;         supersedes `icomplete+'
(setq smex-save-file (path my-cache-dir "smex.save"))
(smex-initialize)

;; `icomplete-mode'
;; Complements `smex' where it is not used
(icomplete-mode)

;; `ibuffer': dired-style buffer selection
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
          '(lambda ()
             (ibuffer-switch-to-saved-filter-groups "default")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Misc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq tramp-persistency-file-name (path my-cache-dir "tramp"))

;; `browse-kill-ring': kill ring browser on M-y
(browse-kill-ring-default-keybindings)
(setq browse-kill-ring-quit-action 'save-and-restore) ; restore window config

;; `time-stamp': Insert timestamp text if buffer has text "Time-stamp: <>"
(setq time-stamp-active t               ; do enable time-stamps
      time-stamp-line-limit 10               ; check first 10 buffer lines
      time-stamp-format "%04y-%02m-%02d %02H:%02M:%02S (%u)") ; date format
(add-hook 'write-file-hooks 'time-stamp) ; update when saving

;; `desktop': maintain per-directory session information
;;            supersedes `recentf'
(desktop-save-mode 1)
(setq desktop-save 'if-exists)          ; only save if desktop file exists

;; `savehist': save minibuffer history
(setq savehist-file (path my-cache-dir "history"))
(savehist-mode t)

;; `bookmark+': bookmark everything
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

;; `url'
(setq url-configuration-directory (path my-cache-dir "url" ""))

;; `em-smart'
;; Be clever on `eshell' output
(add-hook 'eshell-mode-hook
          '(lambda ()
             (require 'em-smart)
             (setq eshell-where-to-jump 'begin
                   esell-review-quick-commands nil
                   eshell-smart-space-goes-to-end t)
             (eshell-smart-initialize)))

(put 'narrow-to-page 'disabled nil)     ; do not barf about narrowing

;; `re-builder'
(add-hook 'reb-mode-hook
          '(lambda ()
             (setq reb-re-syntax 'string)))


(provide 'my-behaviour)
