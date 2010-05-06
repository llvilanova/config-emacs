;; -*-mode: Emacs-Lisp; folded-file:t-*-
;; Time-stamp: <2010-05-06 23:10:10 (vilanova)>

;; To be run on every file
(setq my-generic-hook nil)
(add-hook 'find-file-hook (lambda () (run-hooks 'my-generic-hook)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ General settings

(setq scroll-margin 1                    ; do smooth scrolling, ...
  scroll-conservatively 100000           ; ... the defaults ...
  scroll-up-aggressively 0.01            ; ... are very ...
  scroll-down-aggressively 0.01)         ; ... annoying

(transient-mark-mode t)                  ; make the current 'selection' visible
(delete-selection-mode t)                ; delete the selection with a keypress
(setq x-select-enable-clipboard t        ; copy-paste should work ...
  interprogram-paste-function            ; ...with...
  'x-cut-buffer-or-selection-value)      ; ...other X clients

(setq search-highlight t                 ; highlight when searching...
  query-replace-highlight t              ; ...and replacing
  isearch-allow-scroll t)
(fset 'yes-or-no-p 'y-or-n-p)            ; enable y/n answers to yes/no

(global-font-lock-mode t)                ; always do syntax highlighting

(put 'narrow-to-region 'disabled nil)    ; enable...
(put 'erase-buffer 'disabled nil)        ; ... useful things
(file-name-shadow-mode t)                ; be smart about filenames in mbuf

(setq inhibit-startup-message t          ; don't show ...
  inhibit-startup-echo-area-message t)   ; ... startup messages

(setq require-final-newline t)           ; end files with a newline

(setq cua-enable-cua-keys nil)           ; enable CUA only for rectangles
(cua-mode t)

;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Pervasive completion settings

;; `ido': integrates both buffers and files
;;        supersedes `iswitchb' `icicles'
;; http://www.emacswiki.org/emacs/InteractivelyDoThings
;; TODO: ido.last
(ido-mode 1)
(ido-everywhere 1)                     ; use for many file dialogs
(setq
  ido-save-directory-list-file (path my-cache-dir "ido.last")
  ido-ignore-buffers                   ; ignore these
  '("\\` " "^\*Mess" "^\*Back" ".*Completion" "^\*Ido")
  ido-default-file-method 'maybe-frame ; ask if buffer in other frame must be re-opened
  ido-case-fold  t                     ; be case-insensitive
  ido-enable-last-directory-history t  ; remember last used dirs
  ido-max-work-directory-list 30       ; should be enough
  ido-max-work-file-list      50       ; remember many
  ido-use-filename-at-point 'guess     ; use filename at point if looks like one
  ido-use-url-at-point t               ; use url at point
  ido-enable-flex-matching t           ; be flexible
  ido-enable-tramp-completion nil
  ido-confirm-unique-completion nil    ; wait for RET even on one completion
  ido-show-dot-for-dired nil           ; show '.' as first completion
  ido-max-prospects 10                 ; don't spam my minibuffer
  ido-confirm-unique-completion t      ; wait for RET, even with unique completion
  )
;;
;; `filecache': http://www.emacswiki.org/cgi-bin/wiki/FileNameCache
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
(global-set-key [(control c) (control x) (control f)]
                'my-file-cache-ido-find-file)
;;
;; `smex': command-completion interface on top of `ido'
;;         replaces emacs's default `execute-extended-command'
;;         supersedes `icomplete+'
(add-to-list 'load-path (path my-code-dir "smex"))
(setq smex-save-file (path my-cache-dir "smex.save"))
(require 'smex)
(add-hook 'after-init-hook 'smex-initialize)
(setq smex-prompt-string "M-x ")
(global-set-key [(meta x)]       'smex-update-and-run)
(global-set-key [(meta shift x)] 'smex-major-mode-commands)

;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Window management

;;
;; Move between windows
(windmove-default-keybindings 'meta)
(global-set-key [(control x) (left)] 'windmove-left)
(global-set-key [(control x) (right)] 'windmove-right)
(global-set-key [(control x) (up)] 'windmove-up)
(global-set-key [(control x) (down)] 'windmove-down)
;;
;; Undo / redo window configurations
(winner-mode 1)
;;
;; ;; Save / restore window configurations
;; ;; TODO: weird usage patterns
;; (setq win:configuration-file (path my-data-dir "windows")
;;       win:frame-title-function '(lambda (index)
;;                                   (format "%s[%d]"
;;                                           system-name index)))
;; (require 'windows)
;; (win:startup-with-window)
;; (add-hook 'kill-emacs-hook 'win-save-all-configurations)

;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Extra bindings

;;
;; Some bindings to remember
;; - C-x r w   (window-configuration-to-register)
;; - C-x r j   (jump-to-register)
;; - C-x C-SPC (pop-global-mark)
;; - C-x * q   (calq-dispatch)
;;
;; Delete line and remaining blanks (like `dd' in VIM)
(global-set-key [(control delete)] 'kill-whole-line)
;;
;; ibuffer: dired-style buffer selection
;; TODO: use EDE's project name to group files that would otherwise be in
;; "Programming" or "Default"
(global-set-key [(control x) (control b)] 'ibuffer)
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
;;
;; ;; ;; "easier" searching
;; ;; (define-key isearch-mode-map [next]  'isearch-repeat-forward)
;; ;; (define-key isearch-mode-map [prior] 'isearch-repeat-backward)
;;
;; ;; Smart Tab
;; (add-to-list 'load-path (path my-code-dir "smart-tab"))
;; (require 'smart-tab)
;; ;; TODO: move down of `org-mode'
;; (add-hook 'my-generic-hook
;;           '(lambda ()
;;              (unless (eq major-mode 'org-mode) (smart-tab-mode 1))))
;;
;; ;; `home-end'
;; (global-set-key [end]  'home-end-end)
;; (global-set-key [home] 'home-end-home)
;;
;; Duplicate and (optionally) comment line
;; http://emacs-fu.blogspot.com/2010/01/duplicating-lines-and-commenting-them.html
(defun my-duplicate-line (&optional commentfirst)
  "Duplicate line at point; if COMMENTFIRST is non-nil, comment the original"
  (interactive)
  (beginning-of-line)
  (push-mark)
  (end-of-line)
  (let ((str (buffer-substring (region-beginning) (region-end))))
    (when commentfirst
      (comment-region (region-beginning) (region-end)))
    (insert-string
     (concat (if (= 0 (forward-line 1)) "" "\n") str "\n"))
    (forward-line -1)))
;; duplicate a line
(global-set-key [(control c) (y)] 'my-duplicate-line)
;; duplicate a line and comment the first
(global-set-key [(control c) (c)] '(lambda ()
                                     (interactive)
                                     (my-duplicate-line t)))
;;
;; framepop
(setq framepop-enable-keybinding "<f7>");; use <f7> as framepop kbd-map prefix
(when window-system
  (require 'framepop)
  (define-key framepop-map [f7] 'framepop-toggle-frame)
  ;; let the user decide if framepop should retain input focus
  (define-key framepop-map "f" 'my-framepop-toggle-with-focus)
  (defvar my-framepop-with-focus t)
  (defun my-framepop-toggle-with-focus ()
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
             (eq t (frame-visible-p framepop-frame)))
        (select-frame-set-input-focus framepop-frame)))
  (defadvice framepop-display-buffer (after my-framepop-display-buffer
                                            activate)
    "Do not redirect input focus if thus is wanted."
    (if my-framepop-with-focus
        (redirect-frame-focus framepop-frame)))
  )

;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Save things across sessions

;;
;; saveplace: restore last cursor position in file
(setq save-place-file (path my-cache-dir "places"))
(setq-default save-place t)            ;; activate it for all buffers
(require 'saveplace)
;;
;; abbrevs (abbreviations)
(setq abbrev-file-name                 ;; tell emacs where to read abbrev
      (path my-data-dir "abbrev_defs"));; definitions from...
(abbrev-mode t)                        ;; enable abbrevs (abbreviations) ...
(setq default-abbrev-mode t            ;; turn it on
      save-abbrevs t)                  ;; don't ask
(when (file-exists-p abbrev-file-name)
  (quietly-read-abbrev-file))          ;;  don't tell
(add-hook 'kill-emacs-hook             ;; write when ...
          'write-abbrev-file)          ;; ... exiting emacs
;;
;; backups: all in one single place
(setq my-backup-dir (path my-cache-dir "backups" ""))
(setq make-backup-files t              ;; do make backups
      backup-by-copying t              ;; and copy them here
      backup-directory-alist (list (cons "." my-backup-dir))
      version-control t
      kept-new-versions 2
      kept-old-versions 5
      delete-old-versions t)
;;
;; Auto-save session
;; (add-hook 'auto-save-hook              ;; save desktop on every file save
;;           'desktop-save-in-desktop-dir)
(setq auto-save-list-file-prefix       ; location for auto-save sessions
      (path my-cache-dir "auto-save-list" ""))
;;
;; auto-save files
(defvar auto-saves-root
  (path my-cache-dir "auto-saves" ""))
(make-directory auto-saves-root t)
(setq auto-save-file-name-transforms
      `(("\\(?:[^/]*/\\)*\\(.*\\)"
         ,(path auto-saves-root "\\1") t)))
;;
;; `desktop': maintain per-directory session information
;;            supersedes `savehist', `recentf'
(desktop-save-mode 1)
(setq desktop-save 'if-exists)         ; only save if desktop file exists
;; (setq desktop-buffers-not-to-save      ;; ignore some files
;;       (concat "\\(" "^nn\\.a[0-9]+\\|\\.log\\|(ftp)\\|^tags\\|^TAGS"
;;            "\\|\\.emacs.*\\|\\.diary\\|\\.newsrc-dribble\\|\\.bbdb"
;;            "\\)$"))
;; (set desktop-modes-not-to-save         ;; some modes to avoid saving
;;      (append
;;       'dired-mode
;;       'Info-mode
;;       'info-lookup-mode
;;       'fundamental-mode
;;       desktop-modes-not-to-save))
;;
;; `bookmark+': bookmark everything
(setq bookmark-default-file (path my-data-dir "bookmarks")
      bookmarkp-bmenu-commands-file (path my-data-dir "bmk-bmenu-commands.el")
      bookmarkp-bmenu-state-file (path my-data-dir "bmk-bmenu-state.el"))
(require 'bookmark+)
(defun my-jump-to-bookmark (bookmark)
  (interactive (my--bookmark-ido-read "Jump to bookmark: "))
  (bookmark-jump bookmark))
(defun my--bookmark-ido-read (prompt)
  (let ((ido-make-buffer-list-hook
         (lambda ()
           (setq ido-temp-list (bookmark-all-names)))))
    (ido-read-buffer prompt)))
(global-set-key [(control x) (r) (b)] 'my-ido-find-bookmark)

;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ Misc small stuff
;;
;; time-stamps
(setq ;; when there's "Time-stamp: <>" in the first 10 lines of the file
 time-stamp-active t        ; do enable time-stamps
 time-stamp-line-limit 10   ; check first 10 buffer lines for Time-stamp: <>
 time-stamp-format "%04y-%02m-%02d %02H:%02M:%02S (%u)") ; date format
(add-hook 'write-file-hooks 'time-stamp) ; update when saving
;;
;; cursor
(blink-cursor-mode -1)                ; don't blink cursor
;; ;; http://www.emacswiki.org/cgi-bin/wiki/download/cursor-chg.el
;; ;; change cursor for overwrite/read-only/input
;; (require 'cursor-chg)
;; (change-cursor-mode 1) ; On for overwrite/read-only/input mode
;; (toggle-cursor-type-when-idle 1)
;; ;; (setq curchg-default-cursor-color "Black")
;;
;; highlight the current line
(global-hl-line-mode t)                ; turn it on for all modes by default
;;
;; show-paren-mode: subtle blinking of matching paren (defaults are ugly)
;; http://www.emacswiki.org/cgi-bin/wiki/ShowParenMode
(show-paren-mode t)
(setq show-paren-style 'mixed)
;;
;; ;; higlight changes
;; (global-highlight-changes-mode t)
;;
;; Nicer unique names for buffers
(require 'uniquify)
(setq
  uniquify-buffer-name-style 'post-forward
  uniquify-separator ":"
  uniquify-after-kill-buffer-p t
  uniquify-ignore-buffers-re "^\\*")
;;
;; ;; Hide/Show mode
;; (add-hook 'my-generic-hook (lambda () (hs-minor-mode 1)))
;;
;; Smart drag'n'drop
(require 'smart-dnd)
;;
;; Enhanced secondary selection
(require 'second-sel)
;;
;; Set up browse-kill-ring.  M-y invokes browse-kill-ring.
(require 'browse-kill-ring+)
(browse-kill-ring-default-keybindings)
(setq browse-kill-ring-quit-action 'save-and-restore) ; restore config
;;
;; Explicit text folding
(require 'folding)
(folding-mode 1)
;;
;; Interactive string replacement
(autoload 'iedit-mode "iedit" nil t)
(global-set-key [(control \;)] 'iedit-mode)
;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ My generic functions

(defun my-program-exists (program-name)
  "Checks whenever we can locate program and launch it.
Taken from org-mode's `org-prgram-exists'."
  (if (eq system-type 'gnu/linux)
      (= 0 (call-process "which" nil nil nil program-name))))

(defun my-popup (title msg &optional icon sound)
  "Show a popup through `awesome' if we're on X, or echo it otherwise."
  (interactive)
  (if sound
      (if (my-program-exists "mplayer")
          (start-process "my-popup-play" nil "mplayer" sound)
        (condition-case nil
            (play-sound-file sound)
          (progn (beep t) (beep t)))))
  (if (my-program-exists "notify-send")
      (start-process "my-popup-show" nil "notify-send"
                     "-i" (if icon icon "''") title msg)
    (message "%s: %s" title msg)))

;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

