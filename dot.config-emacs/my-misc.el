;;; my-misc.el --- Miscellaneous function definitions and settings

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
    (insert-string
     (concat (if (= 0 (forward-line 1)) "" "\n") str "\n"))
    (forward-line -1)))

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Local code book-keeping
;; Taken from `starter-kit-defuns'

(defvar my-recompile-cmds (list)
  "List of extra functions to call or paths to recompile code.")

(defun my-recompile-init ()
  "Byte-compile all local code."
  (interactive)
  (message "Recompiling local code...")
  (byte-recompile-directory my-config-dir 0)
  (byte-recompile-directory my-code-dir 0)
  (mapcar '(lambda (item)
             (case item
               ((symbolp item) (item))
               ((and (stringp item) (file-directory-p item))
                (byte-recompile-directory item))
               ((error))))
          my-recompile-cmds))

(defun my-regenerate-autoloads (&optional force)
  "Regenerate the autoload definitions file if necessary and load it."
  (interactive "P")
  (let* ((autoload-dir my-code-dir)
         (autoload-file (path my-config-dir "loaddefs.el")))
    (let ((generated-autoload-file autoload-file))
      (when (or force
                (not (file-exists-p autoload-file))
                (some (lambda (f) (file-newer-than-file-p f autoload-file))
                      (directory-files autoload-dir t "\\.el$")))
        (message "Updating autoloads...")
        (let (emacs-lisp-mode-hook)
          (update-directory-autoloads autoload-dir))))
    ;; TODO: missing `bookmark-bmenu-mode-map'
    (require 'bookmark)
    (load autoload-file)))


(provide 'my-misc)
