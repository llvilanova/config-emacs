;; -*-mode: Emacs-Lisp; outline-minor-mode:t-*-
;; Time-stamp: <2010-04-30 14:48:47 (vilanova)>


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org Mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Location
(defvar org-directory (path my-home-dir "plans" ""))
(setq org-agenda-files (list org-directory))
(setq org-default-notes-file (path org-directory "notes.org"))
(setq my-org-agenda-file (path my-cache-dir "org-agenda.txt"))
(setq org-agenda-skip-unavailable-files t)
;; Contributed extensions
(add-to-list 'load-path "/usr/share/org-mode/lisp")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pervasive Bindings
(global-set-key [(control shift o) (l)] 'org-store-link)
(global-set-key [(control shift o) (a)] 'org-agenda)
(global-set-key [(control shift o) (s)] 'org-search-view)
;; TODO: integrate with `ido'
(global-set-key [(control shift o) (f)]
                '(lambda ()
                   (interactive)
                   (ido-find-file-in-dir org-directory)
                   ))
(global-set-key [(control shift o) (b)] 'org-iswitchb)
(global-set-key [(control shift o) (r)] 'org-remember)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Babel
(require 'org-babel-init)
;; For a list of supported languages / backends see:
;; http://orgmode.org/worg/org-contrib/babel/org-babel.php#reference-and-documentation
(require 'org-babel-ditaa)     ;; ditaa
;; (setq org-ditaa-jar-path "/usr/share/org-mode/scripts/ditaa.jar")
(setq org-ditaa-jar-path (path my-home-dir "bin" "ditaa.jar"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Appointment notification
(setq appt-message-warning-time 15     ; warn 15min in advance
      appt-display-mode-line t         ; show in modeline
      appt-display-format 'window)     ; use our function
(appt-activate 1)
(display-time)
(add-hook 'org-finalize-agenda-hook    ; update `appt' when agenda is opened
          '(lambda () (org-agenda-to-appt t)))
(defun my-appt-popup (min-to-app new-time msg)
  (my-popup (format "Appointment in %s minute(s)" min-to-app) msg
            "/usr/share/icons/hicolor/32x32/apps/gnome-panel-clock.png"
            "/usr/share/sounds/ekiga/ring.wav"))
(setq appt-disp-window-function (function my-appt-popup))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous
;;
;; Common tags
(setq org-tag-alist '(
                      ("PROJECT" . ?P)
                      ))
;;
;; Appearance
(setq org-agenda-ndays 14              ; show 2 weeks...
      org-agenda-start-on-weekday 1    ; ...starting on Monday
      org-hide-leading-stars t         ; hide stars...
      org-odd-levels-only t)           ; ...and increase separation
;; ;; Still experimental
;; (setq org-startup-indented t)
;;
;; Do not show TODOs with scheduled date in the TODO list
;; (they'll eventually appear in agenda)
(setq org-agenda-todo-ignore-deadlines t)
(setq org-agenda-todo-ignore-with-date t)
(setq org-agenda-todo-ignore-scheduled t)
;;
;; Do not show completed tasks
(setq org-agenda-skip-scheduled-if-done t)
(setq org-agenda-skip-deadline-if-done t)
;;
;; Do not show tasks blocked due to dependencies
(setq org-agenda-dim-blocked-tasks t)
;;
;; Cannot change state if children are unfinished
(setq org-enforce-todo-dependencies t)
;;
;; Finding stuck projects
(setq org-stuck-projects
      '("+PROJECT/-MAYBE-DONE" ("NEXT" "TODO") ("@SHOP")
        "\\<IGNORE\\>"))
;;
;; Add time stamp when moving to state `DONE'
(setq org-log-done 'time)
;;
;; To follow links with RET, rather than a 2 key combo:
(setq org-return-follows-link t)
;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; [END] Org Mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Remember Mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General settings
(org-remember-insinuate)               ; integrate into Org Mode
(setq org-remember-templates           ; note templates
                                       ; defaults into `org-default-notes-file'
      '(
        ;; ;; org-protocol:remember
        ;; ("Browser" ?w "* %^{Title}\n\n  Source: %u, %c\n\n  %i" nil "Notes")
        ;; ("Journal"    ?j "* %U %?\n\n  %i\n  %a"     nil)
        ("Todo"       ?t "* TODO %?\n  %i\n  %a"     nil "Tasks")
        ("Schedule"   ?s "* TODO %?\n  SCHEDULE: $^{Schedule}t" nil "Tasks")
        ("Deadline"   ?d "* TODO %?\n  DEADLINE: $^{Deadline}t" nil "Tasks")
        ("Clipboard"  ?c "* %T %^{Description}\n %x" nil "Interesting")
        ("Idea"       ?i "* %^{Title}\n  %i\n  %a"   nil "New Ideas")
        ("Conference" ?f
         "* %^{Conference}    :%^{Acronym}:%?
*** TODO Abstract
    DEADLINE: <%(org-read-date nil nil nil \"Abstract deadline\") ++1y -1w>
*** TODO Paper
    DEADLINE: <%(org-read-date nil nil nil \"Paper deadline\") ++1y -6m>
*** TODO Rebuttal
    SCHEDULED: <%(org-read-date nil nil nil \"Rebuttal deadline\") ++1y>
*** TODO Acceptance notification
    SCHEDULED: <%(org-read-date nil nil nil \"Acceptance notification\") ++1y>"
         "Events.org" "Conferences")
        ("Préstec" ?P "* %t %^{Objecte} -> %^{Persona}" "Personal.org" "Préstecs")
        ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Quick note-taking
;;
;; Run with `emacsclient -e "(remember-other-frame)"
;; TODO: if no frame is present `emacsclient' needs the `-c' argument, but then
;;       only the `*Remember*' frame is deleted
(defadvice remember-other-frame (around remember-frame-parameters activate)
 "Set some frame parameters for the remember frame."
 (let ((default-frame-alist (append
                             '(
                               (name . "*Remember*")
                               (width . 80)
                               (height . 10)
                               (vertical-scroll-bars . nil)
                               (menu-bar-lines . 0)
                               (tool-bar-lines . 0)
                               )
                             default-frame-alist)))
   ad-do-it
   ))
;;
;; ;; http://orgmode.org/worg/org-contrib/org-protocol.php
;; (require 'org-protocol)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; [END] Remember Mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
