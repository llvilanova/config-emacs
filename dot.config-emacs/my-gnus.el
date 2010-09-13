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
(add-to-list 'gnus-parameters '("^nnmaildir\\+GMX:"
                                (total-expire .    t)
                                (expiry-wait  .  180))) ; 6 months
(add-to-list 'gnus-parameters '("^nnmaildir\\+GMX:Lists\\."
                                (expiry-wait  .   90))) ; 2 months
(add-to-list 'gnus-parameters '("^nnmaildir\\+AC:"
                                (total-expire .    t)
                                (expiry-wait  . 1461))) ; 4 years
(add-to-list 'gnus-parameters '("^nnmaildir\\+BSC:"
                                (total-expire .    t)
                                (expiry-wait  . 1461))) ; 4 years

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Article
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Compose
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Default posting settings
(add-to-list 'gnus-posting-styles
             '(".*"
               (signature-file signature-file-name)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sending
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq message-send-mail-function 'message-send-mail-with-sendmail
      sendmail-program "/usr/bin/msmtp")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Accounts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my-add-gnus-account (id name mail)
  (add-to-list 'gnus-secondary-select-methods
               `(nnmaildir ,id
                           (directory ,(concat "~/Mail/" (downcase id) "/"))
                           (directory-files nnheader-directory-files-safe)
                           (get-new-mail nil)
                           (nnir-search-engine namazu)
                           (nnir-namazu-index-directory
                            ,(path my-home-dir "Mail" "namazu" ""))
                           (nnir-namazu-remove-prefix
                            ,(path my-home-dir "Mail" (downcase id) ""))
                           ))
  (add-to-list 'gnus-parameters
               `(,(concat "^nnmaildir\\+" id ":")
                 (eval (setq message-sendmail-extra-arguments
                             '("-t" "-a" ,(downcase id))))))
  (add-to-list 'gnus-posting-styles
               `(,(concat "^nnmaildir\\+" id ":")
                 (name ,name)
                 (address ,mail))))

(setq gnus-select-method            '(nnnil "nil")
      gnus-secondary-select-methods nil)

(my-add-gnus-account "GMX" "Lluís" "xscript@gmx.net")
(my-add-gnus-account "AC"  nil     "vilanova@ac.upc.edu")
(my-add-gnus-account "BSC" nil     "lluis.vilanova@bsc.es")

;; (provide 'my-gnus)
