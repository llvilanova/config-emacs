;;; my-mail.el --- General mail preferences.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Settings
(setq wl-init-file (path my-config-dir "my-wl.el")
      mail-user-agent   'wl-user-agent  ; C-x m
      read-mail-command 'wl)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BBDB

(setq bbdb-file (path my-data-dir "bbdb"))
(bbdb-initialize)
(setq
 bbdb-offer-save 1                      ; 1 means save-without-asking

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
;; `footnote'
(add-hook 'mail-mode-hook 'footnote-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; `boxquote'
(defvar my--mail-boxquote-map (make-sparse-keymap))
(define-key my--mail-boxquote-map [(u)] 'boxquote-unboxa)
(define-key my--mail-boxquote-map [(t)] 'boxquote-title)
(define-key my--mail-boxquote-map [(r)] 'boxquote-region)
(define-key my--mail-boxquote-map [(f)] 'boxquote-insert-file)
(define-key my--mail-boxquote-map [(b)] 'boxquote-insert-buffer)
(define-key my--mail-boxquote-map [(y)] 'boxquote-yank)
(define-key my--mail-boxquote-map [(d)] 'boxquote-defun)
(define-key my--mail-boxquote-map [(p)] 'boxquote-paragraph)
(define-key my--mail-boxquote-map [(s)] 'boxquote-shell-command)
(define-key my--mail-boxquote-map [(T)] 'boxquote-text)
(define-key my--mail-boxquote-map [(k)] 'boxquote-kill-ring-save)
(define-key my--mail-boxquote-map [(shift f)] 'boxquote-fill-paragraph)

(defun my-mail-setup-boxquote (&optional prefix)
  "Install `my--mail-boxquote-map' into current buffer's local keymap."
  (interactive)
  (let ((prefix (or prefix [(control c) (b)])))
    (local-set-key prefix my--mail-boxquote-map)))


(provide 'my-mail)
