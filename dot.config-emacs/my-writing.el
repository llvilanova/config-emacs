;;; my-writing.el --- Text editing preferences.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Packages

(defun my-writing-setup ()
  (my-add-packages
   '(
     ;; predictive
     wn-org
     )))
(my-add-init-hook 'text-mode-hook #'my-writing-setup)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; * General settings

(add-hook
 'text-mode-hook
 (lambda ()
   (setq fill-column 100000)           ; (hopefully) virtually infinite
   (visual-line-mode 1)                ; do not break lines in file (better VC)

   (setq paragraph-start (concat "\\(" paragraph-start "\\|^[ \\t]*\\*\\)"))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; * Spelling

(setq ispell-program-name "aspell"
      ispell-extra-args '("--sug-mode=ultra"))

;; `auto-dictionary'
(use-package auto-dictionary
  :ensure t
  :defer t
  :init (add-hook 'text-mode-hook #'auto-dictionary-mode))

;; `flyspell'
(use-package flyspell
  :diminish flyspell-mode
  :init
  (progn
    (defvar my-flyspell-mode-maybe-enabled t)
    (defun my-flyspell-mode-maybe (&optional arg)
      (when my-flyspell-mode-maybe-enabled
        (flyspell-mode arg)))
    (add-hook 'text-mode-hook #'my-flyspell-mode-maybe)))

;; `wn-org'
(use-package wn-org
  :commands wn-org-search
  :bind ("C-x w" . wn-org-search))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; * `predictive': Predictive text completion

(use-package predictive
  :disabled t
  :defer t
  :init (add-hook 'text-mode-hook #'predictive-mode)
  :config
  (progn
    (message "blah!")
    ;; Auto-create personal dictionary
    (let* ((my-dicts-dir    (path my-data-dir "predictive"))
           (my-dict-english (path my-dicts-dir "my-dict-english")))
      (add-to-list 'load-path my-dicts-dir)
      (unless (file-exists-p (concat my-dict-english ".el"))
        (make-directory my-dicts-dir t)
        (predictive-create-dict 'my-dict-english my-dict-english nil nil)
        (predictive-save-dict my-dict-english)))

    (setq predictive-main-dict '(my-dict-english dict-english)
          predictive-auto-learn t         ; update frequency counts
          predictive-auto-add-to-dict nil ; should add new words to 1st dict ...
          predictive-add-to-dict-ask t    ; ... but ask before adding
          predictive-which-dict-mode t    ; show current dict in mode line
          auto-completion-syntax-alist '(accept . word) ; non-word char accepts
          completion-auto-show nil)))     ; no auto completion-ui


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; * Miscellaneous

(add-hook 'doc-view-mode-hook 'auto-revert-mode) ; refresh doc-view on changes
(setq doc-view-continuous t)            ; change page when hitting page bounds


(require 'my-writing-latex)


(provide 'my-writing)
