;;; my-writing-latex.el --- (La)TeX editing preferences.

;; * General settings

(use-package auctex
  :ensure t
  :mode ("\\.tex" . TeX-latex-mode)
  ;; :commands (latex-mode LaTeX-mode plain-tex-mode)
  :init
  (setq-default TeX-parse-self t                 ; parse file on load
                TeX-auto-save t                  ; store parsed information...
                TeX-auto-local (path ".auto" "") ; ...here
                TeX-save-query t                 ; ask saving before compilation
                TeX-style-local (path ".style" "")
                TeX-fold-auto t                  ; auto-fold new macros
                TeX-PDF-mode 1
                TeX-master nil)                  ; query for master file
  (setq-default font-latex-user-keyword-classes  ; user-defined keyword highlighting
                '(("my-latex-todo" (("TODO" "{")) font-latex-warning-face command)))

  ;; foldable regions
  (use-package outline
    :defer t
    :init (add-hook 'LaTeX-mode-hook #'outline-minor-mode))
  ;; support for org's tables
  (use-package org-table
    :defer t
    :commands orgtbl-mode
    :init (add-hook 'LaTeX-mode-hook #'orgtbl-mode)))

(use-package tex
  :ensure auctex
  :defer t
  :init
  (add-hook 'LaTeX-mode-hook #'TeX-source-correlate-mode)
  :config
  ;; do not ask when running the viewer
  (setq TeX-command-list
        (mapcar
         (lambda (elem)
           (if (string= "View" (car elem))
               (list (nth 0 elem)
                     (nth 1 elem)
                     (nth 2 elem)
                     nil
                     (nth 4 elem)
                     (nthcdr 5 elem))
             elem))
         TeX-command-list)))

(use-package latex
  :ensure auctex
  :defer t
  :commands (LaTeX-math-mode)
  :init
  ;; nice math insertion menu
  (add-hook 'LaTeX-mode-hook #'LaTeX-math-mode))

(use-package tex-fold
  :ensure auctex
  :defer t
  :commands (TeX-fold-buffer)
  :init
  ;; ... and pre-fold entire buffer
  (add-hook 'LaTeX-mode-hook #'TeX-fold-buffer)
  ;; nicely foldable environments ...
  (add-hook 'LaTeX-mode-hook #'TeX-fold-mode)
  ;; auto-fold on closing brace
  (add-hook
   'LaTeX-mode-hook
   (lambda ()
     (local-set-key [(})] (lambda ()
                            (interactive)
                            (insert "}")
                            (when TeX-fold-mode
                              (TeX-fold-buffer)))))))


;; * Bibliography

(use-package reftex
  :ensure auctex
  :defer t
  :init
  (setq reftex-plug-into-AUCTeX t)
  (add-hook 'LaTeX-mode-hook  #'turn-on-reftex))

;; `bibtex-utils': insert keywords on entry (C-c k) & manage search results
(use-package bibtex
  :defer t
  :config
  (use-package bibtex-utils
    :ensure t
    :commands (bu-make-field-keywords
               bibtex-search-minor-mode)
    :bind (:map bibtex-mode-map
                ("C-c k" . bu-make-field-keywords))
    :init (add-hook 'bibtex-mode-hook #'bibtex-search-minor-mode)))

;; `bib-cite': show citation info in minibuffer
(use-package bib-cite
  :defer t
  :init
  (setq-default bib-cite-use-reftex-view-crossref t)
  (add-hook 'LaTeX-mode-hook #'turn-on-bib-cite))

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
