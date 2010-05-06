;; -*-mode: Emacs-Lisp; outline-minor-mode:t-*-
;; Time-stamp: <2010-02-15 22:51:56 (lluis)>

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Settings
(setq wl-init-file (path my-config-dir "wl.el"))
(setq mail-user-agent   'wl-user-agent ; C-x m
      read-mail-command 'wl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BBDB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq bbdb-file (path my-data-dir "bbdb"))
(require 'bbdb)
(bbdb-initialize)
(setq
 bbdb-offer-save 1                        ; 1 means save-without-asking

 bbdb-expand-mail-aliases t               ; use the `mail-alias' field

 bbdb-use-pop-up nil                      ; allow popups for addresses
 bbdb-electric-p t                        ; be disposable with SPC
 bbdb-popup-target-lines  1               ; very small

 bbdb-dwim-net-address-allow-redundancy t ; always use full name
 bbdb-quiet-about-name-mismatches 2       ; show name-mismatches 2 secs
 bbdb-canonicalize-redundant-nets-p t     ; x@foo.bar.cx => x@bar.cx

 bbdb-completion-type nil                 ; complete on anything
 bbdb-complete-name-allow-cycling t       ; cycle through matches
                                          ; this only works partially

 bbbd-message-caching-enabled t           ; be fast
 bbdb-use-alternate-names t               ; use AKA

 bbdb-elided-display t                    ; single-line addresses

 bbdb-north-american-phone-numbers-p nil

 ;; auto-create addresses from mail
 bbdb-always-add-address nil              ; do not add new contacts
 bbdb/mail-auto-create-p nil
 ;; bbdb-always-add-address t
 ;; bbdb/mail-auto-create-p 'bbdb-ignore-some-messages-hook
 ;; bbdb-ignore-some-messages-alist          ; don't ask about fake addresses
 ;; ;; NOTE: there can be only one entry per header (such as To, From)
 ;; ;; http://flex.ee.uec.ac.jp/texi/bbdb/bbdb_11.html
 ;; '(("From" . "no.?reply\\|DAEMON\\|daemon\\|facebookmail\\|twitter"))
 )
;;
;; TODO:
(setq signature-use-bbdb t)
;; automatically add mailing list fields
(add-hook 'bbdb-notice-hook 'bbdb-auto-notes-hook)
(setq bbdb-auto-notes-alist '(("X-ML-Name" (".*$" ML 0))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mail writing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Supercite
(autoload 'sc-cite-original "supercite" nil t)
(setq sc-nested-citation-p t
      sc-citation-leader ""
      sc-auto-fill-region-p nil
      sc-confirm-always-p nil)

;; (defun my-sc-header ()
;;   "Insert `Dear <sc-author>,' at the beginning of replies."
;;   (let ((sc-mumble "")
;;         (whofrom (sc-whofrom)))
;;     (if whofrom
;;         (insert "Dear "
;;                 (sc-hdr "" (sc-mail-field "sc-author"))
;;                 ","))))
;; (add-to-list 'sc-rewrite-header-list '(my-sc-header) t)
;; (setq sc-preferred-header-style 8)

(add-hook 'mail-citation-hook 'sc-cite-original)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; MuCite
;; (autoload 'mu-cite-original "mu-cite" nil t)
;; (add-hook 'mail-citation-hook (function mu-cite-original))
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Signature
(setq
 message-signature-separator "^-- ?"   ; `footnote-mode'
 signature-file-name (path my-data-dir "signature")
 signature-insert-at-eof t
 signature-delete-blank-lines-at-eof t
 )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
