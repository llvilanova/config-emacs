;;; my-org.el --- OrgMode's preferences.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org Mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
(setq org-ditaa-jar-path "/usr/share/ditaa/ditaa.jar")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Appointment notification
(setq appt-message-warning-time 15      ; warn 15min in advance
      appt-display-mode-line t          ; show in modeline
      appt-display-format 'window)      ; use our function
(appt-activate 1)
(display-time)
(add-hook 'org-finalize-agenda-hook     ; update `appt' when agenda is opened
          '(lambda () (org-agenda-to-appt t)))
(defun my-appt-popup (min-to-app new-time msg)
  (my-popup (format "Appointment in %s minute(s)" min-to-app) msg
            "/usr/share/icons/hicolor/32x32/apps/gnome-panel-clock.png"
            "/usr/share/sounds/ekiga/ring.wav"))
(setq appt-disp-window-function (function my-appt-popup))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous

;; Common tags
(setq org-tag-alist '(
                      ("PROJECT" . ?P)
                      ))

;; Appearance
(setq org-agenda-ndays 14              ; show 2 weeks...
      org-agenda-start-on-weekday 1    ; ...starting on Monday
      org-hide-leading-stars t)        ; hide stars...
      ;; org-odd-levels-only t)           ; ...and increase separation
      ;; org-startup-indented t)          ; still experimental


;; Hide information
(setq org-agenda-todo-ignore-deadlines t  ; TODO's with scheduled date...
      org-agenda-todo-ignore-with-date t  ; ... in the TODO list...
      org-agenda-todo-ignore-scheduled t  ; (they'll eventually appear)
      org-agenda-skip-scheduled-if-done t ; completed tasks
      org-agenda-skip-deadline-if-done t
      org-agenda-dim-blocked-tasks t)     ; tasks blocked by dependencies

;; Lifecycle
(setq org-enforce-todo-dependencies t   ; hold state if unfinished children
      org-stuck-projects                ; find stuck projects
      '("+PROJECT/-MAYBE-DONE" ("NEXT" "TODO") ("@SHOP")
        "\\<IGNORE\\>")
      org-log-done 'time                ; add timestamp when moving to `DONE'
      )

;; To follow links with RET, rather than a 2 key combo:
(setq org-return-follows-link t)

;; Export the current agenda whenever one of its files is updated
(add-hook 'org-mode-hook
          '(lambda ()
             (add-hook 'after-save-hook 'my-org-update-agenda-file t t)
             ))
;; export function
(defun my-org-update-agenda-file ()
  (let ((save-frame (and (boundp 'framepop-frame)
                         (eq (selected-frame) framepop-frame))))
    (if (not save-frame)
        (save-excursion
          (save-window-excursion
            (let ((file my-org-agenda-file))
              (org-agenda-list)
              (org-write-agenda file)
              (org-agenda-to-appt)))))))
;; ;; do it once at startup
;; (if (window-system) (my-org-update-agenda-file t))

;; Show locations with `google-maps'
(add-hook 'org-mode-hook
          '(lambda ()
             (require 'org-location-google-maps)))
(add-to-list 'org-use-property-inheritance "LOCATION") ; inherit property
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; [END] Org Mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Capture Mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq
 org-capture-templates
 '(("w" "Web" entry (file+headline "Personal.org" "Interessant")
    "* %U %^{Description}\n  %c"
    :immediate-finish t)
   ("c" "Clipboard" entry (file+headline "Personal.org" "Interessant")
    "* %U %^{Description}\n  %c\n  %x"
    :immediate-finish t)

   ("t" "Todo" entry (file+headline "Personal.org" "Tasques")
    "* TODO %?\n  %i\n  %a")
   ("s" "Schedule" entry (file+headline "Personal.org" "Tasques")
    "* %?\n  SCHEDULED: %^{Schedule}T")
   ("d" "Deadline" entry (file+headline "Personal.org" "Tasques")
    "* TODO %?\n  DEADLINE: %^{Deadline}t")

   ("p" "Préstec" entry (file+headline "Personal.org" "Préstecs")
    "* %u %^{Objecte} -> %^{Persona}"
    :immediate-finish t)

   ("T" "Todo" entry (file+headline "Work.org" "Tasks")
    "* TODO %?\n  %i\n  %a")

   ("S" "Schedule" entry (file+headline "Work.org" "Tasks")
    "* %?\n  SCHEDULED: %^{Schedule}T")
   ("D" "Deadline" entry (file+headline "Work.org" "Tasks")
    "* TODO %?\n  DEADLINE: %^{Deadline}t")

   ("I" "Idea" entry (file+headline "Work.org" "Brainstorming")
    "* %^{Title}\n  %i\n  %a")
   ("F" "Conference" entry (file+headline "Events.org" "Conferences")
    "* %^{Conference}    :%^{Acronym}:%?
*** TODO Abstract
    DEADLINE: <%(org-read-date nil nil nil \"Abstract deadline\") ++1y -1w>
*** TODO Paper
    DEADLINE: <%(org-read-date nil nil nil \"Paper deadline\") ++1y -6m>
*** TODO Rebuttal
    SCHEDULED: <%(org-read-date nil nil nil \"Rebuttal deadline\") ++1y>
*** TODO Acceptance notification
    SCHEDULED: <%(org-read-date nil nil nil \"Acceptance notification\") ++1y>")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; [END] Capture Mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(provide 'my-org)
