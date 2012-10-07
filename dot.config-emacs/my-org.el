;;; my-org.el --- OrgMode's preferences.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Location
(defconst org-directory (path my-home-dir "plans" ""))
(setq org-agenda-files (list org-directory)
      org-default-notes-file (path org-directory "Personal.org")
      my-org-agenda-file (path my-cache-dir "org-agenda.txt")
      org-agenda-skip-unavailable-files t
      org-completion-use-ido t
      org-pretty-entities t)
;; Contributed extensions
(add-to-list 'load-path "/usr/share/org-mode/lisp")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pervasive Bindings
(global-set-key [(control shift o) (l)] 'org-store-link)
(global-set-key [(control shift o) (a)] 'org-agenda)
(global-set-key [(control shift o) (s)] 'org-search-view)
(global-set-key [(control shift o) (f)]
                '(lambda ()
                   (interactive)
                   (ido-find-file-in-dir org-directory)
                   ))
(global-set-key [(control shift o) (b)] 'org-iswitchb)
(global-set-key [(control shift o) (control c) (c)] 'org-capture)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Babel
;; For a list of supported languages / backends see:
;; http://orgmode.org/worg/org-contrib/babel/languages.php
(eval-after-load 'org
  '(progn
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

;; Appearance
(setq org-agenda-span 14                ; show 2 weeks...
      org-agenda-start-on-weekday 1)    ; ...starting on Monday

;; Hide information
(setq org-agenda-todo-ignore-deadlines t  ; TODO's with scheduled date...
      org-agenda-todo-ignore-with-date t  ; ... in the TODO list...
      org-agenda-todo-ignore-scheduled t  ; (they'll eventually appear)
      org-agenda-skip-scheduled-if-done t ; completed tasks
      org-agenda-skip-deadline-if-done t
      org-agenda-dim-blocked-tasks t)     ; tasks blocked by dependencies

;; Handle CFPs in a separate agenda view
(defun my-org-agenda-skip-tag (tag &optional others)
  "Skip all entries that correspond to TAG.

If OTHERS is true, skip all entries that do not correspond to TAG."
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
(add-to-list 'org-agenda-custom-commands
             '("p" "CFPs (Calls For Papers)"
               agenda ""
               ((org-agenda-skip-function-global nil)
                (org-agenda-skip-function
                 '(my-org-agenda-skip-tag "conference" t)))))
(setq org-agenda-skip-function-global (apply-partially 'my-org-agenda-skip-tag "conference"))

;; Export the current agenda whenever one of its files is updated
(add-hook 'org-mode-hook
          '(lambda ()
             (add-hook 'after-save-hook 'my-org-update-agenda-file-maybe t t)))
;; export functions
(defun my-org-update-agenda-file-maybe ()
  (when (and (buffer-file-name)
             (string-equal (substring (buffer-file-name)
                                      0 (length org-directory))
                           org-directory))
    (my-org-update-agenda-file)))
(defun my-org-update-agenda-file ()
  (interactive)
  (let ((save-frame (and (boundp 'framepop-frame)
                         (eq (selected-frame) framepop-frame))))
    (if (not save-frame)
        (save-excursion
          (save-window-excursion
            (let ((file my-org-agenda-file))
              (org-agenda-list)
              (org-agenda-write file)))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Notifications
(require 'org-notify)
(require 'org-notify-sound)
(org-notify-start)
(org-notify-add 'default
                '(:time "1h" :actions (-notify/window -sound)
                        :period "2m" :duration 60))
(org-notify-add 'conference
                '(:time "1m" :actions (-email))
                '(:time "1w" :actions (-email))
                '(:time "1d" :actions (-email)))
(org-notify-add 'go-home
                '(:time "-1s" :period "20s" :duration 10
                  :actions (-message -ding -notify/window -sound))
                '(:time "15m" :period "5m"  :duration 60
                        :actions (-message -notify/window -sound)))
(display-time)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Exporting
(eval-after-load 'org-latex
  '(progn
     (setq org-latex-to-pdf-process ; use `rubber' to export LaTeX to PDF
           '("rubber --pdf --into %o %f"))
     ;; (setq org-export-latex-minted t)        ; export source code using `minted'
     ;; (add-to-list 'org-export-latex-packages-alist "\\usepackage{minted}")

     ;; Create bibliography file
     (add-hook 'org-export-latex-after-save-hook
               '(lambda ()
                  (with-current-buffer cbuf
                    (org-bibtex (concat (file-name-sans-extension
                                         (buffer-file-name)) ".bib")))))
     ;; Remove temporary bibliography files when done
     (setq org-export-pdf-logfiles
           (append org-export-pdf-logfiles '("bbl" "blg" "bib")))
     ;; Remove other temporary files when done
     (setq org-export-pdf-logfiles
           (append org-export-pdf-logfiles '("loe" "lof")))
     ;; Remove LaTeX file when done
     (add-to-list 'org-export-pdf-logfiles "tex")))
(eval-after-load 'org-exp
  '(defadvice org-export (around my-disable-flyspell activate)
     "Disable flyspell while generating intermediate files for exporting."
     (let ((my-flyspell-mode-maybe-enabled nil))
       ad-do-it)))
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

;; Show locations with `google-maps'
(eval-after-load 'org
  '(require 'org-location-google-maps))

;; Code block editing
(setq org-src-tab-acts-natively t   ; use TAB as in the native mode of the block
      org-src-fontify-natively t)   ; and fontify accordingly

;; ;; Linking
;; (require 'org-wikinodes)                ; enable camelcase auto-linking
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Secretary
(when (require 'org-secretary nil t)
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
            ((org-sec-who-view "TODO dowith"))))))
  (global-set-key [(control shift o) (w)] 'org-sec-set-with)
  (global-set-key [(control shift o) (shift w)] 'org-sec-set-where)
  (global-set-key [(control shift o) (d)] 'org-sec-set-dowith)
  (global-set-key [(control shift o) (shift d)] 'org-sec-set-doat))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Capture
(setq
 org-capture-templates
 '(
   ;; work templates
   ("a" "Appointment"                     entry (file+headline "Work.org"
                                                               "Tasks")
    "* %^{Appointment}T %?")
   ("s" "Schedule"                        entry (file+headline "Work.org"
                                                               "Tasks")
    "* %?\nSCHEDULED: %^{Schedule}T")
   ("d" "Deadline"                        entry (file+headline "Work.org"
                                                               "Tasks")
    "* TODO %?\nDEADLINE: %^{Deadline}t")
   ("t" "Todo"                            entry (file+headline "Work.org"
                                                               "Tasks")
    "* TODO %?\n%i\n  %a")

   ("i" "Idea"                            entry (file+headline "Work.org"
                                                               "Brainstorming")
    "* %^{Title}\n%i\n  %a")
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
          (progn (org-capture) t)
        (error nil))
      (delete-other-windows)
    (my-org-capture-other-frame-cleanup)))

(defun my-org-capture-other-frame-cleanup ()
  "Close the Org-Capture frame."
  (if (equal "Org-Capture" (frame-parameter nil 'name))
      (delete-frame)))
(add-hook 'org-capture-after-finalize-hook 'my-org-capture-other-frame-cleanup)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(provide 'my-org)
