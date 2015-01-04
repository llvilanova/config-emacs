;;; my-org.el --- OrgMode's preferences.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Packages

(my-add-packages
 '(
   (:name org-gnome-calendar    :type github
          :pkgname "llvilanova/org-gnome-calendar")
   ))
(defun my-org-setup ()
  (my-add-packages
   '(
     (:name org-ref               :type http
            :url "https://raw.githubusercontent.com/jkitchin/jmax/master/org-ref.org"
            :build (list
                    "emacs --batch --eval \"(progn (require 'ob-tangle) (org-babel-tangle-file \\\"org-ref.org\\\"))\"")
            :compile "org-ref.el")
     )))
(my-add-init-hook 'org-mode-hook #'my-org-setup)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Location
(defconst org-directory (path my-home-dir "plans" ""))
(setq org-default-notes-file (path org-directory "Personal.org")
      org-completion-use-ido t
      org-pretty-entities t)
;; Contributed extensions
(add-to-list 'load-path "/usr/share/org-mode/lisp")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Babel
;; For a list of supported languages / backends see:
;; http://orgmode.org/worg/org-contrib/babel/languages.php
(use-package org
  :defer t
  :config
  (progn
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((C . t)
       (ditaa . t)
       (dot . t)
       (gnuplot . t)
       (latex . t)
       (octave . t)
       (perl . t)
       (python . t)
       (R . t)
       (screen . t)))
    (setq org-ditaa-jar-path "/usr/share/ditaa/ditaa.jar")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Agenda

(use-package org-agenda
  :defer t
  :bind (("C-M-S-o a" . org-agenda))
  :config
  (progn
    (setq
     ;; location
     org-agenda-files (list org-directory)
     my-org-agenda-file (path my-cache-dir "org-agenda.txt")
     org-agenda-skip-unavailable-files t
     ;; appearance
     org-agenda-span 14                  ; show 2 weeks...
     org-agenda-start-on-weekday 1       ; ...starting on Monday
     ;; hide information
     org-agenda-todo-ignore-deadlines t  ; TODO's with scheduled date...
     org-agenda-todo-ignore-with-date t  ; ... in the TODO list...
     org-agenda-todo-ignore-scheduled t  ; (they'll eventually appear)
     org-agenda-skip-scheduled-if-done t ; completed tasks
     org-agenda-skip-deadline-if-done t
     org-agenda-dim-blocked-tasks t      ; tasks blocked by dependencies
     )
    (add-to-list 'org-agenda-custom-commands
                 '("p" "CFPs (Calls For Papers)"
                   agenda ""
                   ((org-agenda-skip-function-global nil)
                    (org-agenda-skip-function
                     '(my-org-agenda-skip-tag "conference" t)))))

    ;; Handle CFPs in a separate agenda view
    (defun my-org-agenda-skip-tag (tag &optional others)
      "Skip all entries that correspond to TAG.

If OTHERS is true, skip all entries that do not correspond to TAG."
      (show-all)
      (let ((next-headline (save-excursion (or (outline-next-heading) (point-max))))
            (current-headline (or (and (org-at-heading-p)
                                       (point))
                                  (save-excursion (org-back-to-heading)))))
        (if others
            (if (not (member tag (org-get-tags-at current-headline)))
                next-headline
              nil)
          (if (member tag (org-get-tags-at current-headline))
              next-headline
            nil))))

    (setq org-agenda-skip-function-global
          (lambda ()
            (or (apply 'my-org-agenda-skip-tag "conference" nil)
                (apply 'my-org-agenda-skip-tag "gohome" nil))))))

(use-package org-gnome-calendar
  :config
  (progn
    (require 'dbus)
    (when (dbus-ignore-errors (dbus-init-bus :session))
      (global-org-gnome-calendar-mode))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Notifications
(defun my-org-notify-expire (plist)
  (with-current-buffer (find-buffer-visiting (plist-get plist :file))
    (save-excursion
      (goto-char (plist-get plist :begin))
      (org-todo 'done)
      (save-buffer nil))))

(use-package org-notify
  :defer t
  :commands org-notify-start
  :init (org-notify-start)
  :config
  (progn
    (require 'org-agenda)
    (org-notify-add 'default
                    '(:time "1h" :actions (-notify/window -sound)
                            :period "2m" :duration 60))
    (org-notify-add 'conference
                    '(:time "1m" :actions (-email))
                    '(:time "1w" :actions (-email))
                    '(:time "1d" :actions (-email)))
    (org-notify-add 'go-home
                    '(:time "-10m"
                            :actions (my-org-notify-expire))
                    '(:time "-1s" :period "20s" :duration 10
                            :actions (-message -ding -notify/window -sound))
                    '(:time "20m" :period "5m"  :duration 60
                            :actions (-message -notify/window -sound)))))

(display-time)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Exporting

(use-package org-bibtex
  :defer t
  :config (require 'ox-bibtex))

(use-package ox-latex
  :defer t
  :config
  (progn
    (setq org-latex-listings 'minted)
    (add-to-list 'org-latex-packages-alist '("" "minted"))

    ;; ;; Create bibliography file
    ;; (add-hook 'org-export-latex-after-save-hook
    ;;           (lambda ()
    ;;             (with-current-buffer cbuf
    ;;               (org-bibtex (concat (file-name-sans-extension
    ;;                                    (buffer-file-name)) ".bib")))))

    ;; moderncv
    (add-to-list 'org-latex-classes
                 '("moderncv"
                   "\\documentclass[1pt]{moderncv}"
                   ("\\section{%s}" . "\\section*{%s}")
                   ))
    ;; moderncv conflicts with marvosym
    (setq org-latex-default-packages-alist
          (cl-remove-if
           (lambda (elem) (and (listp elem)
                          (or (string= "marvosym" (cadr elem))
                              (string= "hyperref" (cadr elem)))))
           org-latex-default-packages-alist))
    (setq org-latex-hyperref-template "")

    ;; Remove temporary files when done
    (setq org-latex-logfiles-extensions
          (append '("bbl" "blg" "bib")    ; bibliography
                  '("loe" "lof")          ; other
                  '("synctex.gz" "tex")   ; LaTeX
                  org-latex-logfiles-extensions))

    ;; (setq org-latex-to-pdf-process ; use `rubber' to export LaTeX to PDF
    ;;       '("rubber -c 'setlist arguments -shell-escape' --pdf --into %o %f"))
    (setq org-latex-pdf-process
          (map 'list
               (lambda (elem)
                 (replace-regexp-in-string
                  " -interaction "
                  " -shell-escape -interaction "
                  elem))
               org-latex-pdf-process))))

(use-package ox
  :defer t
  :config
  (progn
    (defvar my-org-latex-filter-fancyvrb-options "")

    ;; (defadvice org-export (around my-disable-flyspell activate)
    ;;   "Disable flyspell while generating intermediate files for exporting."
    ;;   (let ((my-flyspell-mode-maybe-enabled nil))
    ;;     ad-do-it)))

    (defun my-org-latex-filter-fancyvrb (text backend info)
      "Convert begin/end{verbatim} to begin/end{Verbatim}.
    Allows use of the fancyvrb latex package."
      (when (org-export-derived-backend-p backend 'latex)
        (replace-regexp-in-string
         "\\\\begin{verbatim}"
         (format "\\\\begin{Verbatim}%s" my-org-latex-filter-fancyvrb-options)
         (replace-regexp-in-string
          "\\\\end{verbatim}"
          "\\\\end{Verbatim}"
          text))))

    (add-to-list 'org-export-filter-final-output-functions
                 'my-org-latex-filter-fancyvrb)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous

;; Common tags
(setq org-tag-alist '(
                      ("PROJECT" . ?P)
                      ))

;; Appearance
(setq org-startup-indented t            ; automatically indent headers and text
      org-startup-with-inline-images t) ; display known image types

;; Tags
(setq org-tags-exclude-from-inheritance '("PROJECT"))

;; Lifecycle
(require 'org-faces)
(setq org-todo-keywords                 ; TODO states
      '((sequence "TODO(t)" "|" "DONE(d)" "CANCELLED(c)")
        (sequence "TASK(f)" "|" "DONE(d)")
        (sequence "MAYBE(m)" "|" "CANCELLED(c)"))
      org-todo-keyword-faces
      '(("MAYBE" . (:foreground "Pink"))
        ("CANCELLED" . (:foreground "Pale Green")))
      org-enforce-todo-dependencies t   ; hold state if unfinished children
      org-stuck-projects                ; find stuck projects
      '("+PROJECT/-MAYBE-DONE" ("NEXT" "TODO" "TASK") ("@SHOP")
        "\\<IGNORE\\>")
      org-log-done 'time)               ; add timestamp when moving to `DONE'

;; To follow links with RET, rather than a 2 key combo:
(setq org-return-follows-link t)

;; Code block editing
(setq org-src-tab-acts-natively t   ; use TAB as in the native mode of the block
      org-src-fontify-natively t)   ; and fontify accordingly

;; Auto-update cookies
(defun my-org-update-parent-cookie ()
  (when (equal major-mode 'org-mode)
    (save-excursion
      (ignore-errors
        (org-back-to-heading)
        (org-update-parent-todo-statistics)))))
(defadvice org-kill-line (after fix-cookies activate)
  (my-org-update-parent-cookie))
(defadvice kill-whole-line (after fix-cookies activate)
  (my-org-update-parent-cookie))

;; ;; Linking
;; (require 'org-wikinodes)                ; enable camelcase auto-linking
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Secretary
(use-package org-secretary
  :defer t
  :bind (("C-M-S-o w" . org-sec-set-with)
         ("C-M-S-o S-w" . org-sec-set-where)
         ("C-M-S-o d" . org-sec-set-dowith)
         ("C-M-S-o S-d" . org-sec-set-doat))
  :config
  (progn
    (require 'org-agenda)
    (setq org-sec-me "Lluis"
          org-agenda-custom-commands
          (append
           org-agenda-custom-commands
           '(("h" "Work todos" tags-todo
              "-personal -doat={.+}-dowith={.+}/!-TASK"
              ((org-agenda-todo-ignore-scheduled t)))
             ("H" "All work todos" tags-todo "-personal/!-TASK-MAYBE"
              ((org-agenda-todo-ignore-scheduled nil)))
             ("A" "Work todos with doat or dowith" tags-todo
              "-personal+doat={.+}|dowith={.+}/!-TASK"
              ((org-agenda-todo-ignore-scheduled nil)))
             ("j" "TODO dowith and TASK with"
              ((org-sec-with-view "TODO dowith")
               (org-sec-where-view "TODO doat")
               (org-sec-assigned-with-view "TASK with")
               (org-sec-stuck-with-view "STUCK with")))
             ("J" "Interactive TODO dowith and TASK with"
              ((org-sec-who-view "TODO dowith"))))))))
(use-package org-agenda
 :defer t
 :config (require 'org-secretary))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Capture
(setq
 org-capture-templates
 '(
   ;; work templates
   ("a" "Appointment"                     entry (file+headline "Work.org"
                                                               "Tasks")
    "* %^{Appointment}T %?\n%a\n  %i")
   ("s" "Schedule"                        entry (file+headline "Work.org"
                                                               "Tasks")
    "* %?\nSCHEDULED: %^{Schedule}T\n%a\n  %i")
   ("d" "Deadline"                        entry (file+headline "Work.org"
                                                               "Tasks")
    "* TODO %?\nDEADLINE: %^{Deadline}t")
   ("t" "Todo"                            entry (file+headline "Work.org"
                                                               "Tasks")
    "* TODO %?\n%a\n  %i")

   ("i" "Idea"                            entry (file+headline "Work.org"
                                                               "Brainstorming")
    "* %^{Title}\n%a\n  %i")
   ("c" "Conference"                      entry (file+headline "Events.org"
                                                               "Conferences")
    ;; (function 'org-capture-cfp-reuse "Events.org" "Conferences" 'org-capture-cfp-mail-conference)
    "* [[%(org-capture-cfp-url)][%(org-capture-cfp-mail-conference)]]    :%^{Acronym}:%?
** Abstract
DEADLINE: <%(org-capture-cfp-date \"Abstract submission: \" \"abstract\" \"submission\") ++1y -1w>
** Paper
DEADLINE: <%(org-capture-cfp-date \"Paper submission: \" \"submission\") ++1y -6m>"
    )

   ;; personal templates
   ("W" "Web"                             entry (file+headline "Personal.org"
                                                               "Interessant")
    "* %U %^{Description}\n%c"
    :immediate-finish t)
   ("C" "Clipboard"                       entry (file+headline "Personal.org"
                                                               "Interessant")
    "* %U %^{Description}\n%c\n%x"
    :immediate-finish t)

   ("A" "Appointment"                     entry (file+headline "Personal.org"
                                                               "Tasques")
    "* %^{Appointment}T %?")
   ("S" "Schedule"                        entry (file+headline "Personal.org"
                                                               "Tasques")
    "* %?\nSCHEDULED: %^{Schedule}T")
   ("D" "Deadline"                        entry (file+headline "Personal.org"
                                                               "Tasques")
    "* TODO %?\nDEADLINE: %^{Deadline}t")
   ("T" "Todo"                            entry (file+headline "Personal.org"
                                                               "Tasques")
    "* TODO %?\n%i\n%a")

   ("P" "Préstec"                         entry (file+headline "Personal.org"
                                                               "Préstecs")
    "* %u %^{Objecte} -> %^{Persona}"
    :immediate-finish t)
   ))

(defun my-org-capture ()
  (interactive)
  (org-store-link nil)
  (org-capture))

(defun my-org-capture-other-frame ()
  "Create a new frame and run org-capture."
  (interactive)
  (make-frame '((name . "Org-Capture")
                (width  . 120)
                (height .  20)
                (menu-bar-lines . 0)
                (tool-bar-lines . 0)
                (auto-lower . nil)
                (auto-raise . t)))
  (select-frame-by-name "Org-Capture")
  (if (condition-case nil
          (progn (my-org-capture) t)
        (error nil))
      (delete-other-windows)
    (my-org-capture-other-frame--cleanup)))

(defun my-org-capture-other-frame--cleanup ()
  "Close the Org-Capture frame."
  (if (equal "Org-Capture" (frame-parameter nil 'name))
      (delete-frame)))

(add-hook 'org-capture-after-finalize-hook 'my-org-capture-other-frame--cleanup)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(provide 'my-org)
