;;; my-mail.el --- General mail preferences.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Settings

;; Default
(setq mail-user-agent   'gnus-user-agent  ; C-x m
      read-mail-command 'gnus)
;; (setq mail-user-agent   'wl-user-agent  ; C-x m
;;       read-mail-command 'wl)

;; Sending
(setq sendmail-program "/usr/bin/msmtp"
      send-mail-function 'message-send-mail-with-sendmail)
(use-package message
  :defer t
  :config
  (progn
    (setq message-send-mail-function 'message-send-mail-with-sendmail
          message-sendmail-extra-arguments '("--read-recipients"))
    (add-to-list 'message-send-hook
                 (lambda ()
                   (setq message-sendmail-envelope-from
                         (mail-strip-quoted-names (mail-fetch-field "From")))))))

;; Gnus
(setq gnus-init-file (path my-config-dir "my-gnus.el"))
(setq my-gnus-start-or-hide-windows nil)
(make-variable-frame-local 'my-gnus-start-or-hide-windows)
(defun my-gnus-start-or-hide ()
  (interactive)
  (let ((found nil))
    (mapc (lambda (window)
            (let* ((buf (window-buffer window))
                   (mode (buffer-local-value 'major-mode buf))
                   (name (symbol-name mode)))
              (if (string-match "^gnus-" name)
                  (setq found t))))
          (window-list))
    (if found
        (progn
          (gnus-group-suspend)
          (if my-gnus-start-or-hide-windows
              (set-window-configuration my-gnus-start-or-hide-windows))
          (setq my-gnus-start-or-hide-windows nil))
      (setq my-gnus-start-or-hide-windows (current-window-configuration))
      (delete-other-windows)
      (gnus))))

;; Wanderlust
(setq wl-init-file (path my-config-dir "my-wl.el"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BBDB

(use-package bbdb
  :ensure t)

(setq bbdb-file (path my-data-dir "bbdb"))
(require 'bbdb)                         ; TODO: autoload should take care of it
(bbdb-initialize)
(setq
 bbdb-offer-save 1                      ; 1 means save-without-asking
 bbdb-notice-auto-save-file t           ; revert if externally modified

 bbdb-expand-mail-aliases t             ; use the `mail-alias' field

 bbdb-use-pop-up nil                    ; allow popups for addresses
 bbdb-electric-p t                      ; be disposable with SPC
 bbdb-pop-up-target-lines  1            ; very small

 bbdb-dwim-net-address-allow-redundancy t ; always use full name
 bbdb-quiet-about-name-mismatches 2     ; show name-mismatches 2 secs
 bbdb-use-alternate-names t             ; use AKA
 bbdb-canonicalize-redundant-nets-p t   ; foo@bar.baz.com => foo@baz.com

 bbdb-completion-type nil               ; complete on anything
 bbdb-complete-name-allow-cycling t     ; cycle through matches
                                        ; this only works partially

 bbdb-message-caching-enabled t         ; be fast

 bbdb-elided-display t                  ; single-line addresses

 bbdb-north-american-phone-numbers-p nil

 bbdb-always-add-addresses 'ask         ; new addresses for existing contacts
 bbdb/mail-auto-create-p nil)           ; new contacts

;; automatically add mailing list fields
(add-hook 'bbdb-notice-hook 'bbdb-auto-notes-hook)
(setq bbdb-auto-notes-alist '(("X-ML-Name" (".*$" ML 0))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; `supercite'
(setq sc-nested-citation-p t
      sc-citation-leader ""
      sc-auto-fill-region-p nil
      sc-confirm-always-p nil
      sc-reference-tag-string ""
      sc-preferred-header-style 5)
;; (add-hook 'sc-load-hook 'sc-setup-filladapt)
(add-hook 'mail-citation-hook 'sc-cite-original)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; `signature'
(setq message-signature-separator "^-- ?"
      signature-file-name (path my-data-dir "signature")
      signature-insert-at-eof t
      signature-delete-blank-lines-at-eof t
      signature-use-bbdb t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Misc
(setq message-from-style 'angles)
(add-hook 'message-mode-hook (lambda () (setq fill-column 80)))


(provide 'my-mail)
