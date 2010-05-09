;;; my-writing.el --- Text editing preferences.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup activation hooks (`my-writing-mode-hook')
(setq my-writing-mode-hook nil)
(add-hook 'text-mode-hook '(lambda () (run-hooks 'my-writing-mode-hook)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General settings

(add-hook
 'my-writing-mode-hook
 '(lambda ()
    ;; (longlines-mode 1)                  ; show virtual line breaks
    (auto-fill-mode 1)                  ; auto-wrap lines
    ;; (refill-mode 1)                     ; keep paragraph filled
    (local-set-key [(control c) (q)] 'refill-mode)

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
(add-hook 'my-writing-mode-hook
          '(lambda ()
             (local-set-key [(control c) (w)] 'wordnet-search)))
(add-hook 'ecb-activate-hook
          '(lambda ()
             (add-to-list 'ecb-compilation-buffer-names '("*WordNet*" . nil))))


;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; `predictive': Predictive text completion
;; ;; http://www.emacswiki.org/emacs/PredictiveMode

;; (add-to-list 'my-recompile-cmds (path my-code-dir "predictive"))
;; (autoload 'predictive-mode "predictive"
;;   "Turn on Predictive Completion Mode." t)

;; (add-to-list 'load-path (path my-code-dir "predictive"))
;; (add-to-list 'load-path (path my-code-dir "predictive" "latex"))
;; (add-to-list 'load-path (path my-code-dir "predictive" "texinfo"))
;; (add-to-list 'load-path (path my-code-dir "predictive" "html"))
;; ;; Create new dictionaries with: `predictive-create-dict'
;; (add-to-list 'load-path (path my-data-dir "predictive"))

;; (add-hook
;;  'my-writing-mode-hook
;;  '(lambda ()
;;     (set-default 'predictive-auto-add-to-dict t)
;;     (setq predictive-main-dict 'my-english
;;           predictive-auto-learn t
;;           predictive-add-to-dict-ask t ;; nil
;;           predictive-use-auto-learn-cache nil ;; t
;;           ;; predictive-which-dict t
;;           auto-completion-syntax-alist '(accept . word) ; non-word char accepts
;;           completion-auto-show nil)))                   ; no auto completion-ui


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous

(add-hook 'doc-view-mode-hook 'auto-revert-mode) ; refresh doc-view on changes
(setq doc-view-continuous t)            ; change page when hitting page bounds


(require 'my-writing-latex)


(provide 'my-writing)
