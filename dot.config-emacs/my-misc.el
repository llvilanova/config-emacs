;;; my-misc.el --- Miscellaneous function definitions and settings

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


(defun my-toggle-dedicated-window (&optional window)
  "Toggle whether WINDOW is dedicated or not.
If nil, WINDOW is `selected-window'."
  (interactive)
  (let* ((window (or window (selected-window)))
         (dedicated (window-dedicated-p window)))
    (set-window-dedicated-p window (not dedicated))))

(defun my--mode-line-toggle-dedicated-window (event)
  "Like `my-toggle-dedicated-window', but for the mode-line."
  (interactive "e")
  (my-toggle-dedicated-window (posn-window (event-start event))))

(let ((value (default-value 'mode-line-buffer-identification)))
  (add-to-list 'value
               '(:propertize
                 (:eval (if (window-dedicated-p (selected-window))
                            " [D]" " [ ]"))
                 local-map
                 (keymap
                  (mode-line keymap
                             (mouse-1 . my--mode-line-toggle-dedicated-window)))
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

;; TODO: unused and not working
;; (add-hook 'after-init-hook '(lambda ()
;;                               (require 'ecb-layout)
;;                               (ecb-initialize-layout)
;;                               (my--setup-helper-buffers)))


(defun my-run-async (program args callback)
  "Asynchronously run the given PROGRAM with arguments ARGS and invoke CALLBACK
  once finished."
  (let ((buffer (get-buffer-create (format "*%s*" program))))
    (unless (get-buffer-process buffer)
      (with-current-buffer buffer
        (erase-buffer))
      (let ((process (start-process-shell-command
                      program buffer (format "%s %s" program args))))
        (set-process-sentinel process callback)
        nil))))

(defun my-goto-line-with-feedback ()
  "Show line numbers temporarily, while prompting for the line number input"
  (interactive)
  (unwind-protect
      (progn
        (linum-mode 1)
        (goto-line (read-number "Goto line: ")))
    (linum-mode -1)))

(defun my-dwim-vc (&optional buf)
  "Start version control interface according to the backend for given buffer."
  (interactive)
  (require 'vc)
  (let ((dir (or (and (buffer-file-name buf)
                   (file-name-directory (buffer-file-name buf)))
                (and (called-interactively-p 'interactive)
                   (read-directory-name "Select directory: ")))))
    (case (vc-responsible-backend dir)
      ('Git (magit-status dir))
      (t    (vc-dir dir)))))

;; TODO: remove once Gnus is updated
(defun gnus-funcall-no-warning (function &rest args)
  (when (fboundp function)
    (apply function args)))


;; Temporary work around for packages using disappeared `make-local-hook'
(defalias 'make-local-hook
  (if (featurep 'xemacs)
      'make-local-hook
    'ignore))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Applications

;; `shell'
(defun comint-delchar-or-eof-or-kill-buffer (arg)
  (interactive "p")
  (if (null (get-buffer-process (current-buffer)))
      (kill-buffer)
    (comint-delchar-or-maybe-eof arg)))
(add-hook 'shell-mode-hook
          (lambda ()
            (define-key shell-mode-map
              (kbd "C-d") 'comint-delchar-or-eof-or-kill-buffer)))

(provide 'my-misc)
