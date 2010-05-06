;; -*-mode: Emacs-Lisp; folded-file:t-*-
;;; my-elpa.el --- Automagic installation of base package set.
;;
;; Taken from `starter-kit-elpa.el'

(require 'cl)

(defvar my-packages (list 'auto-dictionary
                          'company
                          'gdb-shell
                          'highlight-80+
                          'highlight-parentheses
                          'highlight-symbol
                          'tempo-snippets)
  "Libraries that should be installed b default.")

(defun my-elpa-install ()
  "Install all my default packages that aren't installed."
  (interactive)
  (dolist (package my-packages)
    (unless (or (member package package-activated-list)
                (functionp package))
      (message "Installing %s" (symbol-name package))
      (package-install package))))

(defun my-online? ()
  "See if we're online."
  (some (lambda (iface) (unless (equal "lo" (car iface))
                          (member 'up (first (last (network-interface-info
                                                    (car iface)))))))
        (network-interface-list)))

;; Pull in packages
(when (my-online?)
  (unless package-archive-contents (package-refresh-contents)
          (my-elpa-install)))

(provide 'my-elpa)
