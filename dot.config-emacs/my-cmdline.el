;;; my-cmdline.el --- Extra command-line switches

;; You can invoke these command line switches with `emacs -<switch>'

(add-to-list
 'command-switch-alist
 '("gnus" . (lambda (&rest ignore)
              (setq frame-title-format "Gnus")
              ;; Start Gnus when Emacs starts
              (add-hook 'emacs-startup-hook 'gnus t)
              ;; Exit Emacs after quitting Gnus
              (add-hook 'gnus-after-exiting-gnus-hook
                        'save-buffers-kill-emacs))))

(provide 'my-cmdline)
