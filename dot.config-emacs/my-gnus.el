;;; my-gnus.el --- GNUS settings.


(setq gnus-parameters nil               ; reset parameters
      gnus-posting-styles nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data folders and files

(setq gnus-startup-file (path my-data-dir "gnus")
      gnus-save-newsrc-file nil         ; no .newsrc file ...
      gnus-read-newsrc-file nil         ; ... ever
      )

;; Keep read articles and marks automatically synchronized
(setq gnus-sync-backend "/heygate:.local/share/emacs/gnus-sync"
      gnus-sync-global-vars `(gnus-newsrc-last-checked-date)
      gnus-sync-newsrc-groups `("nntp" "nnrss")
      ;; gnus-sync-newsrc-offsets `(2 3)
      )
(add-hook 'gnus-get-new-news-hook 'gnus-sync-read)
(add-hook 'gnus-read-newsrc-el-hook 'gnus-sync-read)
(require 'gnus-sync)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mail scanning

(setq gnus-notifications-minimum-level 2)
(add-hook 'gnus-after-getting-new-news-hook 'gnus-notifications)

(defun my-check-mail ()
  (interactive)
  (my-run-async
   "fetchmail" ""
   (lambda (&rest args)
     (my-run-async
      "offlineimap" ""
      (lambda (&rest args) (gnus-demon-scan-news))))))

(gnus-demon-add-handler 'my-check-mail 5 nil)
;; Immediately start checking for new mail
(my-check-mail)


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

;; Expiration
(remove-hook 'gnus-summary-prepare-exit-hook 'gnus-summary-expire-articles)
(gnus-demon-add-handler 'gnus-group-expire-all-groups 240 t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Summary
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Format

;; Default
(defun my-gnus-summary-tree-arrows-ascii-default ()
  "Use default tree layout with ascii arrows."
  ;; See `gnus-sum.el'.  Useful for restoring defaults.
  (interactive)
  (setq
   ;; Defaults from `gnus-sum.el'
   gnus-sum-thread-tree-false-root      "> "
   gnus-sum-thread-tree-single-indent   ""
   gnus-sum-thread-tree-root            "> "
   gnus-sum-thread-tree-vertical        "| "
   gnus-sum-thread-tree-leaf-with-other "+-> "
   gnus-sum-thread-tree-single-leaf "  \\-> "
   gnus-sum-thread-tree-indent          "  ")
  (gnus-message 5 "Using default ascii tree layout."))

;; Wide
(defun my-gnus-summary-tree-arrows-wide ()
  "Use tree layout with wide unicode arrows."
  (interactive)
  (setq
   gnus-sum-thread-tree-false-root      "┈┬▶ "
   gnus-sum-thread-tree-single-indent   " o  "
   gnus-sum-thread-tree-root            "┌─▶ "
   gnus-sum-thread-tree-vertical        "│"
   gnus-sum-thread-tree-leaf-with-other "├──▶ "
   gnus-sum-thread-tree-single-leaf     "└──▶ "
   gnus-sum-thread-tree-indent          " ")
  (gnus-message 5 "Using tree layout with wide unicode arrows."))

;; Size formatter
(defun my-gnus-summary-line-message-size (head)
  "Return pretty-printed version of message size.

Like `gnus-summary-line-message-size' but more verbose.  This function is
intended to be used in `gnus-summary-line-format-alist', with
\(defalias 'gnus-user-format-function-X 'my-gnus-summary-line-message-size).

See (info \"(gnus)Group Line Specification\")."
  (let ((c (or (mail-header-chars head) -1)))
    (gnus-message 9 "c=%s chars in article %s" c (mail-header-number head))
    (cond ((< c 0) "n/a") ;; chars not available
          ((< c (* 1000))       (format "%db"  c))
          ((< c (* 1000 10))    (format "%1.1fk" (/ c 1024.0)))
          ((< c (* 1000 1000))  (format "%dk" (/ c 1024.0)))
          ((< c (* 1000 10000)) (format "%1.1fM" (/ c (* 1024.0 1024))))
          (t (format "%dM" (/ c (* 1024.0 1024)))))))
(defalias 'gnus-user-format-function-size 'my-gnus-summary-line-message-size)

;; Score formatter
(defun my-gnus-summary-line-score (head)
  "Return pretty-printed version of article score.

See (info \"(gnus)Group Line Specification\")."
  (let ((c (gnus-summary-article-score (mail-header-number head))))
    ;; (gnus-message 9 "c=%s chars in article %s" c (mail-header-number head))
    (cond ((< c -1000)     "vv")
          ((< c  -100)     " v")
          ((< c   -10)     "--")
          ((< c     0)     " -")
          ((= c     0)     "  ")
          ((< c    10)     " +")
          ((< c   100)     "++")
          ((< c  1000)     " ^")
          (t               "^^"))))
(defalias 'gnus-user-format-function-score 'my-gnus-summary-line-score)

;; Faces
(copy-face 'default 'my-gnus-face-sep)
(set-face-foreground 'my-gnus-face-sep "grey60")
(setq gnus-face-10 'my-gnus-face-sep)

(copy-face 'default 'my-gnus-face-info)
(set-face-foreground 'my-gnus-face-info "grey60")
(set-face-italic-p 'my-gnus-face-info t)
(setq gnus-face-11 'my-gnus-face-info)

;; Actual format
(my-gnus-summary-tree-arrows-wide)
(setq gnus-summary-line-format
      (concat
       "%0{%U%R%z%}"
       "%10{│%}"
       ;; "%d"
       "%11{%-16&user-date;%}"
       "%10{│%}"
       ;; "%11{%4k%}"
       "%11{%4u&size;%}"
       "%10{│%}"
       "%("
       ;; "%[%-23,23f%]"
       "%-23,23f"
       "%10{│%}"
       "%u&score;"
       "%10{│%}"
       "%*"
       "%B%s"
       "%)\n")
      gnus-summary-thread-gathering-function 'gnus-gather-threads-by-references
      gnus-summary-mode-line-format "Gnus: %p %Z")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous

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
     (kmacro-exec-ring-item (quote ([?\C-2 ?\C-0 ?\C-0 ?\C-0 ?L ?i ?e ?t ?\C-m] 0 "%d")) nil) ; message-id
     (kmacro-exec-ring-item (quote ([?\C-2 ?\C-0 ?\C-0 ?\C-0 ?L ?t ?f ?t ?\C-m] 0 "%d")) nil) ; thread
     (gnus-summary-hide-thread)
     (gnus-summary-next-thread 1))

;; Misc
(setq gnus-fetch-old-headers nil          ; only fetch unread/marked messages
      gnus-refer-thread-limit t)        ; try to make 'A T' work


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Article
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Format
(setq gnus-article-mode-line-format "Gnus: %p ► %S%m")

;; `gravatar' support
(add-hook 'gnus-part-display-hook 'gnus-treat-from-gravatar)
(add-hook 'gnus-part-display-hook 'gnus-treat-mail-gravatar)

;; Hide article parts
(setq gnus-treat-hide-signature t)

;; Execute external commands on messages
(defvar my-gnus-article-apply-command-history nil)
(defun my-gnus-article-apply-command (command)
  (interactive
   (list (read-string "Run command (%f: message file): "
                      (gnus-group-get-parameter gnus-newsgroup-name
                                                'my-gnus-article-apply-command)
                      'my-gnus-article-apply-command-history)))
  (unless (string= command
                   (gnus-group-get-parameter gnus-newsgroup-name
                                             'my-gnus-article-apply-command))
    (add-to-list 'my-gnus-article-apply-command-history command))
  (let ((file (make-temp-file "gnus-article-"))
        (buf (get-buffer-create " *my-gnus-article-apply-command*")))
    (save-window-excursion
      (unless (eq major-mode 'gnus-article-mode)
        (gnus-summary-select-article-buffer))
      (write-region (point-min) (point-max) file)
      (with-temp-buffer
        (insert command)
        (format-replace-strings (list (cons "%f" file))
                                nil (point-min) (point-max))
        (setq command (buffer-substring (point-min) (point-max)))))
    (display-buffer buf)
    (shell-command command buf buf)
    (delete-file file)))

;; Add line indicating patch reviewal
(defun my-gnus-patch-process (tag)
  (interactive)
  (unless (eq major-mode 'message-mode)
    (error (format "Unsupported mode %s" major-mode)))
  (save-excursion
    (goto-char (point-min))
    (search-forward "Signed-off-by")
    (when (eq (point) 0)
      (error "Could not find where to insert the tag"))
    (search-forward "---")
    (beginning-of-line)
    (insert (format "\n%s: %s <%s>\n\n\n"
                    tag user-full-name user-mail-address))))

(defun my-gnus-patch-review ()
  (interactive)
  (my-gnus-patch-process "Reviewed-by"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Compose
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Default posting settings
(add-to-list 'gnus-posting-styles
             '(".*"
               (signature-file signature-file-name)))
;; Mailing-list support
(setq gnus-add-to-list t)               ; TODO: only apply to certain groups
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

(defun my-add-gnus-account (id name mail &rest extra)
  (add-to-list 'gnus-secondary-select-methods
               (let ((res
                      `(nnimap ,id
                               (nnimap-inbox "INBOX")
                               (nnimap-split-inbox nnimap-inbox)
                               ;; (nnimap-unsplittable-articles '(%Deleted))
                               (nnimap-stream shell)
                               (nnimap-shell-program
                                ,(format "/usr/lib/dovecot/imap -c ~/.dovecotrc-%s"
                                         (downcase id)))
                               (nnir-search-engine imap))))
                 (append res extra)))
  (add-to-list 'gnus-posting-styles
               `(,(concat "^[^\+:]+\\+" id ":")
                 (name ,name)
                 (address ,mail))))

(setq gnus-select-method            '(nnnil "nil")
      gnus-secondary-select-methods nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Personal settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(load "my-gnus-personal" t)
