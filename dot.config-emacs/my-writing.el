;;; my-writing.el --- Text editing preferences.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup activation hooks (`my-writing-mode-hook')
(my-define-hook 'my-writing-mode-hook '(text-mode-hook))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General settings

(my-add-hook
 'my-writing-mode-hook
 '(lambda ()
    (setq fill-column 1000000000)       ; (hopefully) virtually infinite
    (visual-line-mode 1)                ; do not break lines in file (better VC)

    (setq paragraph-start (concat "\\(" paragraph-start "\\|^[ \\t]*\\*\\)"))

    ;; ECB
    (my-define-ecb-layouts '("my-writing"))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spelling

(setq ispell-program-name "aspell"
      ispell-extra-args '("--sug-mode=ultra"))

;; `flyspell'
;; (add-hook 'my-writing-mode-hook
;;           '(lambda ()
;;              (flyspell-mode 1)
;;              ;; (flyspell-buffer)
;;              ))
(add-hook 'flyspell-mode-hook
          '(lambda ()
             (auto-dictionary-mode 1)
             (adict-guess-dictionary)))

;; `wordnet'
(autoload 'wordnet-search "wordnet")
(my-add-hook 'my-writing-mode-hook
          '(lambda ()
             (local-set-key [(control c) (w)] 'wordnet-search)))
(my-add-helper-buffer "*WordNet*")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; `predictive': Predictive text completion
;; http://www.emacswiki.org/emacs/PredictiveMode

;; Auto-create personal dictionary
(let* ((my-dicts-dir    (path my-data-dir "predictive"))
       (my-dict-english (path my-dicts-dir "my-dict-english")))
  (add-to-list 'load-path my-dicts-dir)
  (unless (file-exists-p (concat my-dict-english ".el"))
    (make-directory my-dicts-dir t)
    (predictive-create-dict 'my-dict-english my-dict-english nil nil)
    (predictive-save-dict my-dict-english)))

(setq-default predictive-auto-add-to-dict t) ; add new words to first dict
(setq predictive-main-dict '(my-dict-english dict-english)
      predictive-auto-learn t           ; update frequency counts
      predictive-add-to-dict-ask t      ; ask for new words
      predictive-which-dict t
      auto-completion-syntax-alist '(accept . word) ; non-word char accepts
      completion-auto-show nil)         ; no auto completion-ui


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous

(add-hook 'doc-view-mode-hook 'auto-revert-mode) ; refresh doc-view on changes
(setq doc-view-continuous t)            ; change page when hitting page bounds


(require 'my-writing-latex)


(provide 'my-writing)
