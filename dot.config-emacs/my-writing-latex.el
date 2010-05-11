;;; my-writing-latex.el --- (La)TeX editing preferences.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup activation hooks (`my-latex-mode-hook')
(setq my-latex-mode-hook nil)
(add-hook 'LaTeX-mode-hook
          '(lambda ()
             (run-hooks 'my-writing-mode-hook 'my-latex-mode-hook)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General settings
(setq font-latex-user-keyword-classes   ; user-defined keyword highlighting
      '(("my-latex-todo" (("TODO" "{")) font-latex-warning-face command))
      TeX-parse-self t                  ; parse file on load
      TeX-auto-save t                   ; store parsed information...
      TeX-auto-local (path ".auto" "")  ; ...here
      TeX-style-local (path ".style" "")
      TeX-fold-auto t)                  ; auto-fold new macros
(setq-default TeX-master nil)           ; query for master file

(add-hook
 'my-latex-mode-hook
 '(lambda ()
    (setq fill-column 100)
    (predictive-mode 1)                 ; predictive text
    (LaTeX-math-mode 1)                 ; nice math insertion menu
    (TeX-fold-mode 1)                   ; nicely foldable environments...
    (TeX-fold-buffer)                   ; ... and pre-fold entire buffer
    (local-set-key [(})] '(lambda () (interactive) (insert "}")
                            ;; (save-excursion (backward-char) (TeX-fold-macro))))
                            (TeX-fold-buffer)))
    ;; (outline-minor-mode 1)              ; foldable regions a-la-vim
    ;; (orgtbl-mode 1)                     ; support for org's tables
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bibliography
(add-hook
 'my-latex-mode-hook
 '(lambda ()
    (turn-on-reftex)                    ; activate RefTeX...
    (setq reftex-plug-into-AUCTeX 1     ; ...and integrate with AUCTex
          bib-cite-use-reftex-view-crossref t)
    (bib-cite-minor-mode 1)))           ; show citation info in minibuffer
(add-hook
 'bibtex-mode
 '(lambda ()
    (require 'bibtex-utils)))           ; insert keywords on entry (C-c k)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Preview
(add-hook
 'my-latex-mode-hook
 '(lambda ()
    (setq preview-LaTeX-command         ; command for starting a preview
          '("%T %`%l \"\\nonstopmode\\nofiles\\PassOptionsToPackage{"
            ("," . preview-required-option-list)
            "}{preview}\\AtBeginDocument{\\ifx\\ifPreview\\undefined"
            preview-default-preamble
            "\\fi}\"%' %t")
          preview-LaTeX-command-replacements ; replacements
          '(("%T" "TEXINPUTS=\".:./tex:./templates/tex:\""))
          preview-default-option-list   ; what to show in previews
          ;; Not used: section, footnotes, counters
          '("displaymath" "textmath" "floats" "graphics" "counters"))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Compilation
(add-hook
 'my-latex-mode-hook
 '(lambda ()
    (add-to-list 'TeX-command-list '("Makefile PDF" "make %s.pdf"
                                     TeX-run-compile nil t))
    (add-to-list 'TeX-command-list '("Makefile PS" "make %s.ps"
                                     TeX-run-compile nil t))
    (add-to-list 'TeX-command-list '("Makefile Clean" "make clean"
                                     TeX-run-compile nil t))
    (setq TeX-command-default "Makefile PDF")))


(provide 'my-writing-latex)
