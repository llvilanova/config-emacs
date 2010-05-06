;; -*-mode: Emacs-Lisp; folded-file:t-*-
;; Time-stamp: <2010-03-29 15:29:45 (lluis)>

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ General text editing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup activation hooks (`my-writing-mode-hook')
(setq my-writing-mode-hook nil)
(add-hook 'text-mode-hook '(lambda () (run-hooks 'my-writing-mode-hook)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General settings
;; TODO: `speedbar' does not show correctly when put on the right side
(defvar my-writing-ecb-layouts '("my-writing")
  "ECB layout for writing tasks.")

(defvar my-writing-tggl-refill [(control c) (q)])
(defvar my-writing-wordnet [(control c) (w)])

(add-hook
 'my-writing-mode-hook
 '(lambda ()
    ;; (set-fill-column 80)                 ; text width

    ;; (longlines-mode 1)                   ; show virtual line breaks
    (auto-fill-mode 1)                   ; auto-wrap lines
    ;; (refill-mode 1)                      ; keep paragraph filled
    (local-set-key my-writing-tggl-refill; toggle `refill-mode'
                   'refill-mode)

    ;; Nice tables (two flavours)
    (orgtbl-mode 1)
    ;; (require 'table)

    (require 'wordnet)                   ; worndet integration
    (local-set-key my-writing-wordnet 'wordnet)

    (setq paragraph-start (concat "\\(" paragraph-start "\\|^[ \\t]*\\*\\)"))

    ;; ECB
    (my-define-ecb-layouts my-writing-ecb-layouts)
    ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spelling
(setq ispell-program-name "aspell"
      ispell-extra-args '("--sug-mode=ultra"))
;; (add-hook 'my-writing-mode-hook
;;           '(lambda ()
;;              (flyspell-mode 1)
;;              ;; (flyspell-buffer)
;;              ))
;;
;; auto-dictionary
(add-hook 'flyspell-mode-hook
          '(lambda ()
             (auto-dictionary-mode 1)
             (adict-guess-dictionary)
             ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Predictive text completion
;; http://www.emacswiki.org/emacs/PredictiveMode
(add-hook
 'my-writing-mode-hook
 '(lambda ()
    (add-to-list 'load-path (path my-code-dir "predictive"))
    (add-to-list 'load-path (path my-code-dir "predictive" "latex"))
    (add-to-list 'load-path (path my-code-dir "predictive" "texinfo"))
    (add-to-list 'load-path (path my-code-dir "predictive" "html"))
    ;; Create new dictionaries with: `predictive-create-dict'
    (add-to-list 'load-path (path my-data-dir "predictive"))

    (require 'predictive)

    (set-default 'predictive-auto-add-to-dict t)
    (setq predictive-main-dict 'my-english
          predictive-auto-learn t
          predictive-add-to-dict-ask t ;; nil
          predictive-use-auto-learn-cache nil ;; t
          ;; predictive-which-dict t
          auto-completion-syntax-alist '(accept . word) ; non-word char accepts
          completion-auto-show nil                      ; no auto completion-ui
          )
    ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous
(add-hook 'doc-view-mode-hook 'auto-revert-mode) ; refresh doc-view on changes
(setq doc-view-continuous t)            ; change page when hitting page bounds
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;}}} [END] General text editing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ LaTeX editing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TODO: integrate with `iTe'
;; TODO: integrate `plotter' in a sweave-like fashion
;; http://www.statistik.lmu.de/~leisch/Sweave/
;; TODO: `TeX-view' (C-c C-v) should use `doc-view-mode' instead of launching
;; an external command

(defvar my-latex-width 100
  "Text width when editing LaTeX documents.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup activation hooks (`my-latex-mode-hook')
(setq my-latex-mode-hook nil)
(add-hook 'LaTeX-mode-hook              ; AUCTeX's mode
          '(lambda ()
             (run-hooks
              'my-writing-mode-hook
              'my-latex-mode-hook
              )))
;; (add-hook 'latex-mode-hook              ; Emacs's mode
;;           '(lambda ()
;;              (run-hooks
;;               'my-writing-mode-hook
;;               'my-latex-mode-hook
;;               )))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General settings
(add-hook
 'my-latex-mode-hook
 '(lambda ()
    ;; AUCTeX file parsing
    (setq TeX-parse-self t
          TeX-auto-save t
          TeX-style-local (path ".style" "")
          TeX-auto-local (path ".auto" "")
          )
    (setq-default TeX-master nil)      ; query for master file

    (predictive-mode 1)                ; predictive text
    (LaTeX-math-mode 1)                ; nice math insertion menu
    (TeX-fold-mode 1)                  ; nicely foldable environments...
    (TeX-fold-buffer)                  ; ... and pre-fold entire buffer
    (outline-minor-mode 1)             ; foldable regions a-la-vim
    (set-fill-column my-latex-width)   ; text width
    ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bibliography
(add-hook
 'my-latex-mode-hook
 '(lambda ()
    (turn-on-reftex)                   ; activate RefTeX...
    (setq reftex-plug-into-AUCTeX 1)   ; ...and integrate with AUCTex
    (setq bib-cite-use-reftex-view-crossref t)
    (bib-cite-minor-mode 1)            ; show citation info in minibuffer
    ;; (add-to-list 'load-path            ; alternate bibliography editing
    ;;              (path my-code-dir "ebib" "src"))
    ;; (require 'ebib)
    ))
(add-hook
 'bibtex-mode
 '(lambda ()
    (require 'bibtex-utils)            ; insert keywords on entry (C-c k)
    ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Preview
(defvar my-preview-default-option-list
  ;; Not used: section, footnotes, counters
  '("displaymath" "textmath" "floats" "graphics" "counters")
  "What to show in previews.")

(add-hook
 'my-latex-mode-hook
 '(lambda ()
    (setq preview-LaTeX-command              ; command for starting a preview
          '("%T %`%l \"\\nonstopmode\\nofiles\\PassOptionsToPackage{"
            ("," . preview-required-option-list)
            "}{preview}\\AtBeginDocument{\\ifx\\ifPreview\\undefined"
            preview-default-preamble
            "\\fi}\"%' %t")
          preview-LaTeX-command-replacements ; replacements
          '(("%T" "TEXINPUTS=\".:./tex:./templates/tex:\""))
          preview-default-option-list        ; what to show in previews
          my-preview-default-option-list)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous
(add-hook
 'my-latex-mode-hook
 '(lambda ()
    (smart-dnd-setup                   ; drag'n'drop
     '(
       ("\\.tex\\'" . "\\input{%r}\n")
       ("\\.cls\\'" . "\\documentclass{%f}\n")
       ("\\.sty\\'" . "\\usepackage{%f}\n")
       ("\\.eps\\'" . "\\includegraphics[]{%r}\n")
       ("\\.ps\\'"  . "\\includegraphics[]{%r}\n")
       ("\\.pdf\\'" . "\\includegraphics[]{%r}\n")
       ("\\.jpg\\'" . "\\includegraphics[]{%r}\n")
       ("\\.png\\'" . "\\includegraphics[]{%n}\n")
       ("\\.mov\\'" .
        "\\includemovie[\n\tposter,\n\trepeat=1,\n\ttext=(%r)\n\t]{}{}{%r}\n")
       ("\\.avi\\'" .
        "\\includemovie[\n\tposter,\n\trepeat=1,\n\ttext=(%r)\n\t]{}{}{%r}\n")))
    ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;}}} [END] LaTeX editing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
