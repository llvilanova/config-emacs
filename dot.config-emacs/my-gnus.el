;;; my-gnus.el --- GNUS settings.


(setq gnus-parameters nil               ; reset parameters
      gnus-posting-styles nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data folders and files

(setq gnus-startup-file (path my-data-dir "gnus")
      gnus-save-newsrc-file nil         ; no .newsrc file ...
      gnus-read-newsrc-file nil         ; ... ever
      )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Group
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq gnus-keep-same-level 'best)       ; got to next higher-level group
(add-hook 'gnus-group-mode-hook 'gnus-topic-mode) ; always start with topics

;; Sorting
(add-hook 'gnus-summary-exit-hook       ; increase score of visited groups
          'gnus-summary-bubble-group)
(add-hook 'gnus-summary-exit-hook       ; automatically re-sort by rank (slow)
          'gnus-group-sort-groups-by-rank)

;; New groups
(setq gnus-check-new-newsgroups 'ask-server ; check if new newsgroups are available
      gnus-save-killed-list     nil
      gnus-subscribe-options-newsgroups-method 'gnus-subscribe-hierarchically
      gnus-subscribe-newsgroup-method 'gnus-subscribe-hierarchically)

;; Searching
(require 'nnir)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Summary
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Expiration
(add-to-list 'gnus-parameters '("^[^+:]+\\+GMX:"
                                (total-expire             .    t)
                                (expiry-wait              .  180))) ; 6 months
(add-to-list 'gnus-parameters '("^[^+:]+\\+AC:"
                                (total-expire             .    t)
                                (expiry-wait              . 1461))) ; 4 years
(add-to-list 'gnus-parameters '("^[^+:]+\\+BSC:"
                                (total-expire             .    t)
                                (expiry-wait              . 1461))) ; 4 years
(add-to-list 'gnus-parameters '("^[^+:]+\\+[^:]*:Lists\\."
                                (total-expire             .    t)
                                (expiry-wait              .   90))) ; 2 months

;; Format
(setq gnus-summary-line-format "%U%R%z %(%-16&user-date; %[%4L: %-23,23f%] %B%s%)\n"
      gnus-summary-thread-gathering-function 'gnus-gather-threads-by-references
      gnus-sum-thread-tree-false-root      "┈┬──▷ "
      gnus-sum-thread-tree-single-indent   " ●  "
      gnus-sum-thread-tree-root            "┌─▶ "
      gnus-sum-thread-tree-vertical        "│"
      gnus-sum-thread-tree-leaf-with-other "├──► "
      gnus-sum-thread-tree-single-leaf     "└──► "
      gnus-sum-thread-tree-indent          " "

      gnus-summary-mode-line-format "Gnus: %p %Z")

;; Sorting
(setq gnus-thread-sort-functions
      (list 'gnus-thread-sort-by-number
            'gnus-thread-sort-by-score
            'gnus-thread-sort-by-total-score))

;; Scoring
(add-hook 'message-sent-hook 'gnus-score-followup-thread) ; highlight followups
(defun my-gnus-lower-thread ()                            ; lower thread score
     "Permanently lower score for a whole (sub)thread."
     (interactive)
     (kmacro-exec-ring-item (quote ([?L ?i ?e ?t return] 0 "%d")) nil) ; message-id
     (kmacro-exec-ring-item (quote ([?L ?t ?f ?t return] 0 "%d")) nil) ;thread
     (gnus-summary-hide-thread)
     (gnus-summary-next-thread 1))
(define-key gnus-summary-mode-map [(control meta shift k)] 'my-gnus-lower-thread)

;; Misc
(setq gnus-fetch-old-headers t          ; try to make 'A T' work ...
      gnus-refer-thread-limit t)        ; ... (without success)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Article
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Format
(setq gnus-article-mode-line-format "Gnus: %p ► %S%m")

;; `gravatar' support
(add-hook 'gnus-part-display-hook 'gnus-treat-from-gravatar)
(add-hook 'gnus-part-display-hook 'gnus-treat-mail-gravatar)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Compose
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Default posting settings
(add-to-list 'gnus-posting-styles
             '(".*"
               (signature-file signature-file-name)))
;; Mailing-list support
(setq gnus-add-to-list . t)             ; TODO: only apply to certain groups
(add-to-list 'gnus-parameters '("^[^+:]+\\+[^:]*:Lists\\." (subscribed . t)))
(setq message-subscribed-address-functions
      '(gnus-find-subscribed-addresses)) ; support `Mail-Followup-To'

;; `bbdb'
(add-hook 'gnus-startup-hook 'bbdb-insinuate-gnus)
(add-hook 'gnus-startup-hook 'bbdb-insinuate-message)
(add-hook 'message-setup-hook 'bbdb-define-all-aliases)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sending
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq message-send-mail-function 'message-send-mail-with-sendmail
      sendmail-program "/usr/bin/msmtp"
      message-sendmail-extra-arguments '("--read-recipients"))
(add-to-list 'message-send-hook
             '(lambda ()
                (setq message-sendmail-envelope-from
                      (mail-strip-quoted-names (mail-fetch-field "From")))))
;; Save sent messages
;; (add-to-list 'gnus-parameters '("" (gcc-self . t)))
(setq gnus-message-archive-group
      '((lambda (group)
          (cond
           ;; argument might be null when composing from group buffer
           ((null group) "nnimap+GMX:INBOX")
           ;; do not store if sending to a subscribed list
           ((gnus-group-find-parameter group 'subscribed) nil)
           ;; store in current group
           (t group)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Accounts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-add-gnus-account (id name mail)
  (add-to-list 'gnus-secondary-select-methods
               `(nnimap ,id
                        (nnimap-stream shell)
                        ;; (imap-shell-program ,(format "MAIL=maildir:$HOME/Maildir/%s /usr/lib/dovecot/imap" (downcase id)))
                        (nnimap-shell-program ,(format "/usr/sbin/dovecot -c ~/.dovecotrc-%s --exec-mail imap" (downcase id)))
                        (nnir-search-engine imap)))
  (add-to-list 'gnus-posting-styles
               `(,(concat "^[^\+:]+\\+" id ":")
                 (name ,name)
                 (address ,mail))))

(setq gnus-select-method            '(nnnil "nil")
      gnus-secondary-select-methods nil)

(my-add-gnus-account "GMX" "Lluís" "xscript@gmx.net")
(my-add-gnus-account "AC"  nil     "vilanova@ac.upc.edu")
(my-add-gnus-account "BSC" nil     "lluis.vilanova@bsc.es")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Temporal fixes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'nnimap)
(deffoo nnimap-request-newgroups (date &optional server)
  (when (nnimap-possibly-change-server server)
    (with-current-buffer nntp-server-buffer
      (gnus-message 5 "nnimap: Listing subscribed mailboxes%s%s..."
                    (if (> (length server) 0) " on " "") server)
      (erase-buffer)
      (nnimap-before-find-minmax-bugworkaround)
      (dolist (pattern (nnimap-pattern-to-list-arguments
                        nnimap-list-pattern))
        (dolist (mbx (funcall nnimap-request-list-method (cdr pattern) (car pattern) nil
                              nnimap-server-buffer))
          (or (catch 'found
                (dolist (mailbox (imap-mailbox-get 'list-flags mbx
                                                   nnimap-server-buffer))
                  (if (string= (downcase mailbox) "\\noselect")
                      (throw 'found t)))
                nil)
              (let ((info (nnimap-find-minmax-uid mbx 'examine)))
                (when info
                  (insert (format "\"%s\" %d %d y\n"
                                  mbx (or (nth 2 info) 0)
                                  (max 1 (or (nth 1 info) 1)))))))))
      (gnus-message 5 "nnimap: Listing subscribed mailboxes%s%s...done"
                    (if (> (length server) 0) " on " "") server))
    t))

;; (provide 'my-gnus)
