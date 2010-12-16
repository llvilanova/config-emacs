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

(add-to-list
 'command-switch-alist
 '("gdb" . (lambda (&rest ignore)
             (require 'gdb-mi)
             (let* ((eargs (mapconcat 'identity
                                      command-line-args-left
                                      " "))
                    (parts)
                    (pargs)
                    (gargs)
                    (errmsg (concat "Don't know how to start gdb. "
                                    "Usage: emacs -gdb "
                                    "[<program to run gdb with...> -gdb] "
                                    "[<gdb args...> -args] "
                                    "<program> <program args...>")))

               (setq parts (split-string eargs "\\(^\\|\s\\)-?-args\\($\\|\s\\)"))
               (case (length parts)
                 (1 (setq eargs ""
                          pargs (nth 0 parts)))
                 (2 (setq eargs (nth 0 parts)
                          pargs (nth 1 parts)))
                 (t (error errmsg)))

               (setq parts (split-string eargs "\\(^\\|\s\\)-?-gdb\\($\\|\s\\)"))
               (case (length parts)
                 (1 (setq gargs
                          (concat gud-gdb-command-name
                                  " "
                                  (nth 0 parts))))
                 (2 (setq gargs
                          (concat (nth 0 parts)
                                  " "
                                  gud-gdb-command-name
                                  " "
                                  (nth 1 parts))))
                 (t (error errmsg)))

               (setq command-line-args-left nil)
               (gdb (concat gargs " -args " pargs))))))

(provide 'my-cmdline)
