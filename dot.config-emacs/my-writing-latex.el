;;; my-writing-latex.el --- (La)TeX editing preferences.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Packages

(defun my-writing-latex-setup ()
  (my-add-packages
   '(
     (:name auctex                :type apt-get)
     )))
(my-hook-once 'LaTeX-mode-hook #'my-writing-latex-setup)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; * General settings
(setq font-latex-user-keyword-classes   ; user-defined keyword highlighting
      '(("my-latex-todo" (("TODO" "{")) font-latex-warning-face command))
      TeX-parse-self t                  ; parse file on load
      TeX-auto-save t                   ; store parsed information...
      TeX-auto-local (path ".auto" "")  ; ...here
      TeX-style-local (path ".style" "")
      TeX-fold-auto t)                  ; auto-fold new macros
(setq-default TeX-master nil)           ; query for master file

(add-hook
 'LaTeX-mode-hook
 (lambda ()
   (TeX-PDF-mode 1)
   (TeX-source-correlate-mode 1)
   (LaTeX-math-mode 1)                 ; nice math insertion menu
   (TeX-fold-mode 1)                   ; nicely foldable environments...
   (TeX-fold-buffer)                   ; ... and pre-fold entire buffer
   (local-set-key [(})] (lambda ()
                          (interactive)
                          (insert "}")
                          (when TeX-fold-mode
                            (TeX-fold-buffer))))
   ;; (outline-minor-mode 1)              ; foldable regions a-la-vim
   (orgtbl-mode 1)                      ; support for org's tables
   (after 'smartparens-global-mode
     (require 'smartparens-latex))
   (sp-local-pair 'latex-mode "\"" nil :actions nil)))

;; Do not ask when running the viewer
(after 'tex
  (setq TeX-command-list
        (mapcar
         (lambda (elem)
           (if (string= "View" (car elem))
               (list (nth 0 elem)
                     (nth 1 elem)
                     (nth 2 elem)
                     nil
                     (nthcdr 4 elem))
             elem))
         TeX-command-list)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; * Bibliography
(add-hook
 'LaTeX-mode-hook
 (lambda ()
   (turn-on-reftex)                     ; activate RefTeX...
   (setq reftex-plug-into-AUCTeX 1)))   ; ...and integrate with AUCTex
(add-hook
 'bibtex-mode
 (lambda ()
   (require 'bibtex-utils)))            ; insert keywords on entry (C-c k)

;; `bib-cite': show citation info in minibuffer
(use-package bib-cite
  :defer t
  :diminish bib-cite-minor-mode
  :init
  (add-hook 'LateX-mode-hook #'bib-cite-minor-mode)
  :config
  (setq reftex-plug-into-AUCTeX bib-cite-use-reftex-view-crossref t))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; * Preview
(add-hook
 'LaTeX-mode-hook
 (lambda ()
   (setq preview-LaTeX-command          ; command for starting a preview
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
;; * Compilation
(add-hook
 'LaTeX-mode-hook
 (lambda ()
   (add-to-list 'TeX-command-list '("Makefile PDF" "make %s.pdf"
                                    TeX-run-compile nil t))
   (add-to-list 'TeX-command-list '("Makefile PS" "make %s.ps"
                                    TeX-run-compile nil t))
   (add-to-list 'TeX-command-list '("Makefile Clean" "make clean"
                                    TeX-run-compile nil t))
   (setq TeX-command-default "Makefile PDF")))


(provide 'my-writing-latex)
