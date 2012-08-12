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
(add-hook 'org-mode-hook
          '(lambda ()
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
             ))
(setq org-ditaa-jar-path "/usr/share/ditaa/ditaa.jar")
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
              (org-agenda-write file)
              (org-agenda-to-appt)))))))
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
            "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"))
(setq appt-disp-window-function (function my-appt-popup))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Exporting
(add-hook 'org-mode-hook
          '(lambda ()
             (setq org-latex-to-pdf-process          ; use `rubber' to export LaTeX into PDF
                   '("rubber --pdf --into %o %f"))
             ;; (setq org-export-latex-minted t)        ; export source code using `minted'
             ;; (add-to-list 'org-export-latex-packages-alist "\\usepackage{minted}")
             ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous

;; Common tags
(setq org-tag-alist '(
                      ("PROJECT" . ?P)
                      ))

;; Appearance
(setq org-startup-indented t)           ; automatically indent headers and text

;; Lifecycle
(setq org-enforce-todo-dependencies t   ; hold state if unfinished children
      org-stuck-projects                ; find stuck projects
      '("+PROJECT/-MAYBE-DONE" ("NEXT" "TODO") ("@SHOP")
        "\\<IGNORE\\>")
      org-log-done 'time)               ; add timestamp when moving to `DONE'

;; To follow links with RET, rather than a 2 key combo:
(setq org-return-follows-link t)

;; Show locations with `google-maps'
(add-hook 'org-mode-hook '(lambda () (require 'org-location-google-maps)))

;; Show weather forecast with `google-weather'
(add-hook 'org-mode-hook '(lambda () (require 'org-google-weather)))

;; Display known image types
(add-hook 'org-mode-hook 'org-display-inline-images)

;; Code block editing
(setq org-src-tab-acts-natively t   ; use TAB as in the native mode of the block
      org-src-fontify-natively t)   ; and fontify accordingly

;; ;; Linking
;; (require 'org-wikinodes)                ; enable camelcase auto-linking
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
