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
;; Searching
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'nnir)
;; TODO: hack to disallow broken official version
(load-file (path my-code-dir "nnir.el"))
(setq nnir-search-engine 'namazu
      nnir-namazu-remove-prefix (concat nnir-namazu-remove-prefix "bsc/"))

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
(setq gnus-check-new-newsgroups 'always ; check if new newsgroups are available
      gnus-subscribe-options-newsgroups-method 'gnus-subscribe-hierarchically
      gnus-subscribe-newsgroup-method 'gnus-subscribe-hierarchically)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Summary
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Expiration
(add-to-list 'gnus-parameters '("^[^+:]+\\+GMX:"
                                (total-expire .    t)
                                (nnmail-expiry-wait  .  180))) ; 6 months
(add-to-list 'gnus-parameters '("^[^+:]+\\+GMX:Lists\\."
                                (nnmail-expiry-wait  .   90))) ; 2 months
(add-to-list 'gnus-parameters '("^[^+:]+\\+AC:"
                                (total-expire .    t)
                                (nnmail-expiry-wait  . 1461))) ; 4 years
(add-to-list 'gnus-parameters '("^[^+:]+\\+BSC:"
                                (total-expire .    t)
                                (nnmail-expiry-wait  . 1461))) ; 4 years

;; Format
(setq gnus-summary-line-format "%U%R%z %(%-11&user-date; %[%4L: %-23,23f%] %B%s%)\n"
      gnus-summary-thread-gathering-function 'gnus-gather-threads-by-references
      gnus-sum-thread-tree-false-root      "┈┬──▷ "
      gnus-sum-thread-tree-single-indent   " ●  "
      gnus-sum-thread-tree-root            "┌─▶ "
      gnus-sum-thread-tree-vertical        "│"
      gnus-sum-thread-tree-leaf-with-other "├──► "
      gnus-sum-thread-tree-single-leaf     "└──► "
      gnus-sum-thread-tree-indent          " ")

;; Scoring
(add-hook 'message-sent-hook 'gnus-score-followup-thread) ; highlight followups

;; Misc
(setq gnus-fetch-old-headers t          ; try to make 'A T' work ...
      gnus-refer-thread-limit t)        ; ... (without success)
(require 'gnus-ml)                      ; mailing list support


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Article
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-hook 'gnus-article-display-hook 'gnus-article-fill-cited-article)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Compose
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Default posting settings
(add-to-list 'gnus-posting-styles
             '(".*"
               (signature-file signature-file-name)))

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Accounts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-add-gnus-account (id name mail)
  (add-to-list 'gnus-secondary-select-methods
               `(nnimap ,id
                        (nnimap-stream shell)
                        ;; (imap-shell-program ,(format "MAIL=maildir:$HOME/Maildir/%s /usr/lib/dovecot/imap" (downcase id)))
                        (imap-shell-program ,(format "/usr/sbin/dovecot -c ~/.dovecotrc-%s --exec-mail imap" (downcase id)))
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

;; (provide 'my-gnus)
