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
    (insert (concat (if (= 0 (forward-line 1)) "" "\n") str "\n"))
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


(defun my-toggle-dedicated-window ()
  "Toggle whether the current active window is dedicated or not."
  (interactive)
  (let* ((window (selected-window))
         (dedicated (window-dedicated-p window)))
    (set-window-dedicated-p window (not dedicated))))

(let ((value (default-value 'mode-line-buffer-identification)))
  (add-to-list 'value
               '(:propertize
                 (:eval (if (window-dedicated-p (selected-window)) " [D]" " [ ]"))
                 local-map
                 (keymap (mode-line keymap
                                    (mouse-1 . my-toggle-dedicated-window)))
                 mouse-face mode-line-highlight
                 help-echo "Dedicated window\nmouse-1: Toggle dedicated window")
               t)
  (setq-default mode-line-buffer-identification value))


(defvar my-helper-buffers nil)

(defun my-add-helper-buffer (buffer)
  "Register BUFFER as a helper buffer.
Helper buffers are treated as `ecb-compilation-buffer-names',
even when ECB is not active."
  (add-to-list 'my-helper-buffers buffer))

(defun my--setup-helper-buffers ()
  (mapc '(lambda (item) (add-to-list 'ecb-compilation-buffer-names
                                     '(item . nil)))
        my-helper-buffers))

;; (add-hook 'ecb-activate-hook 'my-setup-helper-buffers)
(add-hook 'after-init-hook '(lambda ()
                              (require 'ecb-layout)
                              (ecb-initialize-layout)
                              (my--setup-helper-buffers)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Local code book-keeping
;; Taken from `starter-kit-defuns'

(defvar my-recompile-objs (list my-config-dir
                                my-code-dir)
  "List of recompilation objectives.
If the element is a function, it is called to recompile.  If the
element is the path to an existing directory, all its elisp files
are compiled.  If the element is a string, it is assumed as a
command to be run in a shell.")

(defun my-recompile-init ()
  "Byte-compile all local code."
  (interactive)
  (message "Recompiling local code...")
  (mapcar '(lambda (item)
             (cond ((functionp item)
                    (funcall item))
                   ((and (stringp item) (file-directory-p item))
                    (mapcar 'byte-compile-file
                            (directory-files item t "\\.el$")))
                   ((stringp item)
                    (message "Running '%s'..." item)
                    (call-process-shell-command item nil "*Compile-Log*" t))
                   ((error "Unknown recompilation objective: %s" item))))
          my-recompile-objs))

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
