;;; my-elpa.el --- Automagic installation of base package set.
;;
;; Taken from `starter-kit-elpa.el'

(require 'cl)
(require 'package)

(defvar my-packages (list 'auto-dictionary
                          'company
                          ;; 'cssh
                          'gdb-shell
                          'highlight-80+
                          'highlight-parentheses
                          'highlight-symbol
                          'smex
                          'tempo-snippets)
  "Libraries that should be installed by default.")

(setq package-user-dir (path my-config-dir "elpa" ""))
(add-to-list 'package-archives '("elpa". "http://tromey.com/elpa/"))

(defun my-elpa-install (&optional fast)
  "Install all my default packages that aren't installed."
  (interactive)
  (unless fast
    (package-refresh-contents))
  (dolist (package my-packages)
    (unless (assoc package package-alist)
      (message "Installing %s" (symbol-name package))
      (package-install package))))

(defun my-online? ()
  "See if we're online."
  (some (lambda (iface) (unless (equal "lo" (car iface))
                          (member 'up (first (last (network-interface-info
                                                    (car iface)))))))
        (network-interface-list)))


;; See if packages have to be downloaded
(package-initialize)
(when (my-online?)
  (my-elpa-install package-alist))


(provide 'my-elpa)
