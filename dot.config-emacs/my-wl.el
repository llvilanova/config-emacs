;;; my-wl.el --- Wanderlust mail client preferences.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data folders
(setq
 elmo-maildir-folder-path "~/Mail"               ; where i store my mail
 wl-folders-file (path my-data-dir "wl-folders") ; list of folders
 elmo-msgdb-directory (path my-cache-dir "elmo") ; message database
 mime-situation-examples-file (path my-data-dir "mime-example") ; file with unknown purpose
 )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Offline and synchronization
(setq wl-plugged t
      elmo-imap4-use-modified-utf7 t
      elmo-imap4-use-cache t
      elmo-nntp-use-cache t
      elmo-pop3-use-cache t
      wl-ask-range nil
      elmo-message-fetch-confirm t
      elmo-message-fetch-threshold 250000)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mail retrieval
(add-hook 'wl-plugged-hook
          '(lambda () (run-at-time nil 300 'my-mail-fetch)))
(add-hook 'wl-unplugged-hook
          '(lambda () (cancel-function-timers 'my-mail-fetch)))
(defun my-mail-fetch ()
  "Fetch through all defined mail sources."
  (interactive)
  (start-process-shell-command "mail" " *Mail*"
                               "fetchmail; offlineimap -u TTY.TTYUI"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Misc
(setq wl-interactive-exit nil)          ; ask for confirmation on exit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Folder
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq wl-stay-folder-window t           ; show the folder pane (left)
      wl-folder-window-width 40)        ; toggle folder visibility (l)

(defun my-get-folder-list ()
  (interactive)
  (let ((entities (list wl-folder-entity))
        entity-stack
        res)
    (while entities
      (setq entity (wl-pop entities))
      (cond
       ((consp entity)
        (and entities (wl-push entities entity-stack))
        (setq entities (nth 2 entity)))
       ((and (stringp entity)
             (string-match-p "^\\.[^/]*/\\(inbox\\|INBOX\\|Lists\\)" entity))
        (add-to-list 'res entity)))
      (unless entities
        (setq entities (wl-pop entity-stack))))
    res))
(add-hook
 'wl-folder-init-hook
 '(lambda ()
    (setq wl-biff-check-folder-list (my-get-folder-list) ; periodical checks...
          wl-biff-check-interval 360)))                ; ...every these seconds

(add-hook 'wl-biff-notify-hook
          '(lambda ()
             (my-popup "Wanderlust" "You have new mail!"
                       "/usr/share/icons/Tango/32x32/apps/email.png"
                       "/usr/share/sounds/gnome/default/alerts/sonar.ogg")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Summary
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Settings
(setq wl-summary-line-format "[%n] %T%P %Y/%M/%D %t[%20(%c %f%)] %s"
      wl-summary-width nil              ; eat up all horizontal space
      wl-message-ignored-field-list '("^.*:") ; hide all fields...
      wl-message-visible-field-list           ; ... except these...
      '("^\\(To\\|Cc\\):"

        "^Subject:"
        "^\\(From\\|Reply-To\\):"
        "^Organization:"
        "^Message-Id:"
        "^\\(Posted\\|Date\\):")
      wl-message-sort-field-list        ; ... which are shown in given order
      '("^From"

        "^Organization:"
        "^X-Attribution:"
        "^Subject"
        "^Date"
        "^To"
        "^Cc"))


;; ;; Scoring
;; (setq wl-summary-target-above 1000
;;       wl-summary-expunge-below -1000
;;       wl-summary-score-marks '(wl-summary-new-uncached-mark
;;                                wl-summary-new-cached-mark
;;                                )
;;       ;; wl-score-folder-alist '(("^.bsc/INBOX" "bsc.SCORE"))
;;       )
;; (add-hook 'wl-summary-prepared-pre-hook 'wl-summary-rescore)


;; Expiration
(setq wl-expire-alist
      '(
        ;; ("^\\.gmx/"       (date  30) hide)
        ("^\\.gmx/trash$" (date 182) remove)
        ("^\\.gmx/sent$"  (date 182) remove)
        ;; ("^\\.ac/"        (date  60) hide)
        ("^\\.ac/trash$"  (date 365) remove)
        ("^\\.ac/sent$"   (date 365) remove)
        ("^\\.ac/spam$"   (date  90) remove)
        ("^\\.ac/virus$"  (date  90) remove)
        ;; ("^\\.bsc/"       (date  60) hide)
        ("^\\.bsc/trash$" (date 365) remove)
        ("^\\.bsc/sent$"  (date 365) remove)))
(add-hook 'wl-summary-prepared-pre-hook 'wl-summary-expire)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draft
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq wl-forward-subject-prefix "Fwd: " ; use "Fwd: " not "Forward: "
      wl-draft-always-delete-myself t   ; do not send mail to myself
      wl-draft-reply-buffer-style 'keep ; how to present the draft
      wl-interactive-send nil           ; ask for confirmation on send
      wl-draft-reply-without-argument-list ; default to Reply-to-Sender
      '(("Reply-To" ("Reply-To") nil nil)
        ("Mail-Reply-To" ("Mail-Reply-To") nil nil)
        ("From" ("From") nil nil))
      wl-draft-reply-with-argument-list ; Reply-to-All with `universal-argument'
      '(("Followup-To" nil nil ("Followup-To"))
        ("Mail-Followup-To" ("Mail-Followup-To") nil ("Newsgroups"))
        ("Reply-To" ("Reply-To") ("To" "Cc" "From") ("Newsgroups"))
        ("From" ("From") ("To" "Cc") ("Newsgroups"))))

(add-hook 'wl-draft-mode
          '(lambda ()
             (set-fill-column 75)
             (my-mail-setup-boxquote)))


;; BBDB
(require 'bbdb-wl)
(bbdb-wl-setup)
(setq wl-summary-from-function 'bbdb-wl-from-func) ; show name from BBDB in summary
(add-hook 'wl-mail-setup-hook           ; auto-expand BBDB aliases
          '(lambda () (bbdb-define-all-aliases) (mail-abbrevs-setup)))

;; `signature' integration
(add-hook 'wl-init-hook
          '(lambda ()
             (add-to-list 'wl-draft-config-sub-func-alist
                          '(signature . wl-draft-config-sub-signature))))
(defun mime-edit-insert-signature (&optional arg)
  "Redefine to insert a signature file directly, not as a tag."
  (interactive "P")
  (insert-signature arg))
(defun wl-draft-config-sub-signature (content)
  "Insert the signature at the end of the MIME message."
  (let ((signature-insert-at-eof nil)
        (signature-file-name (or content signature-file-name)))
    (goto-char (mime-edit-content-end))
    (insert-signature)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sending
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq wl-draft-send-mail-function 'wl-draft-send-mail-with-qmail
      wl-qmail-inject-program "/usr/bin/msmtp"
      wl-fcc-force-as-read t)           ; mark sent messages as read


;; Check subject in outgoing mail
(defun my-wl-draft-subject-check ()
  "Check whether the message has a subject before sending"
  (if (and (< (length (std11-field-body "Subject")) 1)
           (null (y-or-n-p "No subject! Send current draft?")))
      (error "Abort.")))
(add-hook 'wl-mail-send-pre-hook 'my-wl-draft-subject-check)


;; Check for attachments in outgoing mail
(defun my-wl-draft-attachment-check ()
  "if attachment is mention but none included, warn the the user"
  (save-excursion
    (goto-char 0)
    (unless                             ; don't we have an attachment?
        (re-search-forward "^Content-Disposition: attachment" nil t)
      (when                             ; no attachment; did we mention it?
          (re-search-forward "attach" nil t)
        (unless (y-or-n-p "Possibly missing an attachment. Send current draft?")
          (error "Abort."))))))
(add-hook 'wl-mail-send-pre-hook 'my-wl-draft-attachment-check)


;; Automatically reply to mailing list, if any
(defun my-extract-list-post-mail ()
  (let (list-addrs)
    (dolist (to (mapcar
                 (lambda (addr)
                   (nth 1 (std11-extract-address-components
                           (replace-regexp-in-string "mailto:" "" addr))))
                 (wl-parse-addresses
                  (wl-concat-list
                   (elmo-multiple-fields-body-list (list "List-Post"))
                   ","))))
      (setq list-addrs (cons to list-addrs)))
    (message "%s" (nreverse list-addrs))
  (nreverse list-addrs)))
(add-to-list 'wl-draft-reply-without-argument-list
             '("List-Post" . (my-extract-list-post-mail nil nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Accounts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Per-account configuration interface
(setq wl-user-mail-address-list nil     ; list our accounts
      wl-dispose-folder-alist nil       ; where to send disposed messages
      wl-draft-config-alist nil         ; apply transformations on mail edition
      wl-template-alist nil             ; setup accounts as templates...
      wl-template-visible-select t)     ; ... and interactively select them

(defun my-add-account (account-id name mail)
  "Interface to define accounts."
  (let ((md-re  (concat "^." account-id))
        (name   (or name user-full-name))
        (trash  (concat "." account-id "/trash"))
        (drafts (concat "." account-id "/drafts"))
        (sent   (concat "." account-id "/sent")))
    (add-to-list 'wl-user-mail-address-list mail)
    (add-to-list 'wl-dispose-folder-alist (cons md-re trash))
    (add-to-list 'wl-draft-config-alist
                 `((string-match ,md-re wl-draft-parent-folder)
                   (template . ,(concat "account-" account-id))))
    (add-to-list 'wl-template-alist
                 `(,(concat "account-" account-id)
                   ("From" . ,(format "%s <%s>" name mail))
                   (my-msmtp-account . ,mail)
                   ;; (wl-draft-folder . ,drafts)
                   (wl-fcc . ,sent)    ; `wl-fcc' is just the default...
                   ("Fcc" . ,sent)     ; ...so we have to setup the header
                   (signature . nil)
                   (wl-qmail-inject-args . '("-t" "-f" ,mail))))))

;; Setup account-specific info before edit, not before send
;; (add-hook 'wl-draft-reply-hook 'wl-draft-config-exec)
(add-hook 'wl-mail-setup-hook 'wl-draft-config-exec)
(add-hook 'wl-mail-reedit-hook 'wl-draft-config-exec)
(remove-hook 'wl-draft-send-hook 'wl-draft-config-exec)


;; Setup accounts
(my-add-account "gmx" "Lluís" "xscript@gmx.net")
(my-add-account "ac"  nil     "vilanova@ac.upc.edu")
(my-add-account "bsc" nil     "lluis.vilanova@bsc.es")


;; Default folders
(setq wl-default-folder ".gmx/inbox"
      wl-draft-folder   ".gmx/drafts"
      wl-fcc            ".gmx/sent"
      wl-trash-folder   ".gmx/trash"
      wl-spam-folder    ".gmx/spam"
      ;; TODO: check
      wl-queue-folder   ".gmx/queue"
      my-msmtp-account  "gmx"
      ; wl-from
      ; wl-organization
      )
