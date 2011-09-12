;;; my-behaviour.el --- Global behaviour settings.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Frames
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; `framepop': Toggle visibility of a buffer pinned in a frame
(when window-system
  (setq framepop-enable-keybinding "<f7>")
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq scroll-margin 1                   ; do smooth scrolling, ...
      scroll-conservatively 100000      ; ... the defaults ...
      scroll-up-aggressively 0.01       ; ... are very ...
      scroll-down-aggressively 0.01)    ; ... annoying

(put 'narrow-to-region 'disabled nil)   ; enable region narrowing
(put 'erase-buffer 'disabled nil)

(global-set-key [pause] 'my-toggle-dedicated-window)

;; Move between windows
(windmove-default-keybindings 'meta)
(global-set-key [(control x) (left)] 'windmove-left)
(global-set-key [(control x) (right)] 'windmove-right)
(global-set-key [(control x) (up)] 'windmove-up)
(global-set-key [(control x) (down)] 'windmove-down)

;; Undo / redo window configurations
(winner-mode 1)


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

(setq x-select-enable-clipboard t)      ; copy & paste

(setq search-highlight t                ; highlight when searching...
  query-replace-highlight t             ; ...and replacing
  isearch-allow-scroll t)

(global-font-lock-mode t)               ; always do syntax highlighting
(blink-cursor-mode -1)                  ; don't blink cursor
(global-hl-line-mode t)                 ; highlight current line
(show-paren-mode t)                     ; highlight matching parenthesis...
(setq show-paren-style 'mixed)          ; ...but whole region if out of window

;; Delete line and remaining blanks (like `dd' in VIM)
(global-set-key [(control delete)] 'kill-whole-line)
;; Duplicate current line
(global-set-key [(control c) (y)] 'my-duplicate-line)
;; Duplicate and comment current line
(global-set-key [(control c) (control y)] '(lambda ()
                                             (interactive)
                                             (my-duplicate-line t)))
;; ;; DWIM kill word or region
;; ;; TODO: cua-rectangle already overloads kill-region
;; (global-set-key [(control w)]
;;                 '(lambda ()
;;                    (interactive)
;;                    (call-interactively
;;                     (if (or (region-active-p) cua--rectangle)
;;                         'kill-region
;;                       'backward-kill-word))))

;; `iedit': interactive string replacement
(global-set-key [(control \;)] 'iedit-mode)

;; `saveplace': restore last cursor position in file
(setq save-place-file (path my-cache-dir "places"))
(setq-default save-place t)             ; activate it for all buffers
(require 'saveplace)

;; backups: all in one single place
(setq my-backup-dir (path my-cache-dir "backups" ""))
(make-directory my-backup-dir t)
(setq make-backup-files t               ; do make backups
      backup-by-copying t               ; and copy them here
      backup-directory-alist (list (cons "." my-backup-dir))
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
(global-set-key [(control c) (control x) (control f)]
                'my-file-cache-ido-find-file)

;; `smex': command-completion interface on top of `ido'
;;         replaces emacs's default `execute-extended-command'
;;         supersedes `icomplete+'
(setq smex-save-file (path my-cache-dir "smex.save"))
(smex-initialize)
(global-set-key [(meta x)]       'smex)
(global-set-key [(meta shift x)] 'smex-major-mode-commands)

;; `ibuffer': dired-style buffer selection
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
(global-set-key [(control x) (r) (b)] 'my-jump-to-bookmark)

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

;; `flymake'
(add-hook 'flymake-mode-hook
          '(lambda ()
             ;; Keymaps to navigate between the errors
             (local-set-key [(meta n)] 'flymake-goto-next-error)
             (local-set-key [(meta p)] 'flymake-goto-prev-error)))

;; `re-builder'
(add-hook 'reb-mode-hook
          '(lambda ()
             (setq reb-re-syntax 'string)))


(provide 'my-behaviour)
