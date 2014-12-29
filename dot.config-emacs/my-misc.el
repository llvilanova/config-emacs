;;; my-misc.el --- Miscellaneous function definitions and settings
;;
;; Copyright (C) 2014 Lluís Vilanova
;;
;; Author: Lluís Vilanova <vilanova@ac.upc.edu>
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see http://www.gnu.org/licenses/.

;;; Commentary:
;;
;; Miscellaneous function definitions and settings.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Packages

(my-add-packages
 '(
   (:name lv                    :type github
          :pkgname "llvilanova/lv")
   (:name multi-term            :type elpa)
   (:name wgrep                 :type elpa)
   ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Functions

(defun my-program-exists (program-name)
  "Checks whenever we can locate program and launch it.
Taken from org-mode's `org-prgram-exists'."
  (if (eq system-type 'gnu/linux)
      (= 0 (call-process "which" nil nil nil program-name))))


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
        (call-interactively 'goto-line))
    (linum-mode -1)))

(defun my-dwim-vc (path &optional backend)
  "Start version control interface according to the backend of current buffer.

If called with a prefix, prompts the user for the backend."
  (interactive
   (list
    (or (buffer-file-name)
       (read-directory-name "Select directory: "))
    (if current-prefix-arg
        (intern
         (completing-read
          "Use VC backend: "
          (mapcar (lambda (b) (list (symbol-name b)))
                  vc-handled-backends)
          nil t nil nil)))))
  (require 'vc)
  (setq backend (or backend (vc-responsible-backend path)))
  (let ((root (vc-call-backend backend 'root path)))
    (case backend
      ('Git (magit-status root))
      (t    (vc-dir root backend)))))

;; TODO: remove once Gnus is updated
(defun gnus-funcall-no-warning (function &rest args)
  (when (fboundp function)
    (apply function args)))


;; Temporary work around for packages using disappeared `make-local-hook'
(defalias 'make-local-hook
  (if (featurep 'xemacs)
      'make-local-hook
    'ignore))

(defun my-hook-once-generate (hook func)
  "Generate function to remove FUNC from hook HOOK."
  (let ((sym (intern (concat "my-hook-once--" (symbol-name func)))))
    (eval (macroexpand `(defun ,sym ()
                          (remove-hook ',hook ',sym)
                          (,func))))
    sym))

(defun my-hook-once (hook func &optional append)
  "Add FUNC in HOOK to execute only once."
  (let ((cb (my-hook-once-generate hook func)))
    (add-hook hook cb append)))

(defun my-add-init-hook (hook func)
  "Add FUNC in HOOK after Emacs has initialized.

This ensures the hook will be the first element."
  (lexical-let ((hook hook)
                (func func))
    (add-hook 'after-init-hook
              (lambda () (my-hook-once hook func)))))

(defun my-delay-function (func)
  "Delay execution of FUNC until next user's command."
  (my-hook-once 'pre-command-hook func))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Buffers

(defun rename-current-buffer-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (if (get-buffer new-name)
            (error "A buffer named '%s' already exists!" new-name)
          (rename-file filename new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil)
          (message "File '%s' successfully renamed to '%s'"
                   name (file-name-nondirectory new-name)))))))

(defun delete-current-buffer-file ()
  "Removes file connected to current buffer and kills buffer."
  (interactive)
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (if (not (and filename (file-exists-p filename)))
        (ido-kill-buffer)
      (when (yes-or-no-p "Are you sure you want to remove this file? ")
        (delete-file filename)
        (kill-buffer buffer)
        (message "File '%s' successfully removed" filename)))))

(defun copy-current-buffer-file-name-to-clipboard ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))

(defun my-dwim-dired-jump (&optional other-window)
  "If in a project, jump to its root directory, otherwise call `dired-jump'."
  (interactive "P")
  (dired-jump other-window
              (and (ede-current-project)
                 (ede-project-root-directory (ede-current-project)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Windows

(defun rotate-windows ()
  "Rotate your windows."
  (interactive)
  (cond ((not (> (count-windows)1))
         (message "You can't rotate a single window!"))
        (t
         (setq i 1)
         (setq numWindows (count-windows))
         (while  (< i numWindows)
           (let* (
                  (w1 (elt (window-list) i))
                  (w2 (elt (window-list) (+ (% i numWindows) 1)))

                  (b1 (window-buffer w1))
                  (b2 (window-buffer w2))

                  (s1 (window-start w1))
                  (s2 (window-start w2))
                  )
             (set-window-buffer w1  b2)
             (set-window-buffer w2 b1)
             (set-window-start w1 s2)
             (set-window-start w2 s1)
             (setq i (1+ i)))))))

(defun toggle-window-split ()
  "Toggle between vertical/horizontal splits."
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
             (next-win-buffer (window-buffer (next-window)))
             (this-win-edges (window-edges (selected-window)))
             (next-win-edges (window-edges (next-window)))
             (this-win-2nd (not (and (<= (car this-win-edges)
                                         (car next-win-edges))
                                     (<= (cadr this-win-edges)
                                         (cadr next-win-edges)))))
             (splitter
              (if (= (car this-win-edges)
                     (car (window-edges (next-window))))
                  'split-window-horizontally
                'split-window-vertically)))
        (delete-other-windows)
        (let ((first-win (selected-window)))
          (funcall splitter)
          (if this-win-2nd (other-window 1))
          (set-window-buffer (selected-window) this-win-buffer)
          (set-window-buffer (next-window) next-win-buffer)
          (select-window first-win)
          (if this-win-2nd (other-window 1))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Editing

(defun my-move-beginning-of-line (arg)
  "Move point back to indentation of beginning of line.

Move point to the first non-whitespace character on this line.
If point is already there, move to the beginning of the line.
Effectively toggle between the first non-whitespace character and
the beginning of the line.

If ARG is not nil or 1, move forward ARG - 1 lines first.  If
point reaches the beginning or end of the buffer, stop there."
  (interactive "^p")
  (setq arg (or arg 1))

  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

(defun my-smart-open-line ()
  "Insert an empty line after the current line.
Position the cursor at its beginning, according to the current mode."
  (interactive)
  (move-end-of-line nil)
  (newline-and-indent))

(defun my-smart-open-line-above ()
  "Insert an empty line above the current line.
Position the cursor at it's beginning, according to the current mode."
  (interactive)
  (move-beginning-of-line nil)
  (newline-and-indent)
  (forward-line -1)
  (indent-according-to-mode))

(defun my-eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))

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

;; `eshell'
(defun my-eshell (mode to-current-dir)
  (if (string= "eshell-mode" major-mode)
      (jump-to-register :my-eshell-window-config)
    (let ((dir default-directory))
      (window-configuration-to-register :my-eshell-window-config)
      (case mode
        ('fullscreen
         (call-interactively 'eshell)
         (delete-other-windows))
        ('other-window
         (if (one-window-p)
             (split-window)
           (other-window 1))
         (call-interactively 'eshell))
        (t (error "Unknown my-esshell mode: %s" mode)))
      (when to-current-dir
        (eshell/cd dir)
        (eshell-send-input)))))

(provide 'my-misc)
;;; my-misc.el ends here
