;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Preview LaTeX document with `doc-view-mode'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defconst ecb-latex-preview-buffer-name " *ECB LaTeX preview*")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Convenience functions for the user

(defun ecb-maximize-latex-preview-window ()
  "Maximize the LaTeX preview window.
   I.e. delete all other ECB-windows, so only one ECB-window and the
   edit-window\(s) are visible \(and maybe a compile-window). Works
   also if the ECB-analyse-window is not visible in current layout."
  (interactive)
  (ecb-maximize-ecb-buffer ecb-latex-preview-buffer-name))

(defun ecb-goto-latex-preview-window ()
  "Make the LaTeX preview window the current window."
  (interactive)
  (ecb-goto-ecb-window ecb-latex-preview-buffer-name))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Declare dedicated window

(defecb-window-dedicator-to-ecb-buffer ecb-set-latex-preview-buffer
    ecb-latex-preview-buffer-name nil
  "Display the LaTeX preview buffer in current window and make window dedicated."
  (switch-to-buffer (get-buffer-create ecb-latex-preview-buffer-name))
  ;; (switch-to-buffer ecb-latex-preview-buffer-name)
  (setq buffer-read-only t)
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Content Synchronization

(defcustom ecb-latex-preview-buffer-sync 'always
  "*Synchronize the LaTeX preview buffer automatically with current edit buffer.

   If 'always then the synchronization takes place always a buffer changes in the
   edit window, if nil then never. If a list of major-modes then only if the
   `major-mode' of the new buffer belongs NOT to this list.

   If the special value 'basic is set then ECB uses the setting of the option
   `ecb-basic-buffer-sync'.

   IMPORTANT NOTE: Every time the synchronization is done the hook
   `ecb-latex-preview-buffer-sync-hook' is evaluated."
  :group 'ecb-latex-preview
  :type '(radio :tag "Synchronize ECBs LaTeX preview buffer"
                (const :tag "use basic value" :value basic)
                (const :tag "Always" :value always)
                (const :tag "Never" nil)
                (repeat :tag "Not with these modes"
                        (symbol :tag "mode"))))

(defcustom ecb-latex-preview-buffer-sync-delay 'basic
  "*Time Emacs must be idle before the LaTeX preview buffer is synchronized.
   Synchronizing is done with the current source displayed in the edit window. If
   nil then there is no delay, means synchronization takes place immediately. A
   small value of about 0.25 seconds saves CPU resources and you get even though
   almost the same effect as if you set no delay.

   If the special value 'basic is set then ECB uses the setting of the option
   `ecb-basic-buffer-sync-delay'"
  :group 'ecb-analyse
  :type '(radio (const :tag "use basic value" :value basic)
                (const :tag "No synchronizing delay" :value nil)
                (number :tag "Idle time before synchronizing" :value 2))
  :set (function (lambda (symbol value)
                   (set symbol value)
                   (if (and (boundp 'ecb-minor-mode)
                            (featurep 'ecb-examples)
                            ecb-minor-mode)
                       (ecb-activate-ecb-autocontrol-function
                        value 'ecb-latex-preview-buffer-sync))))
  :initialize 'custom-initialize-default)

(defcustom ecb-latex-preview-buffer-sync-hook nil
  "Hook run at the end of `ecb-latex-preview-buffer-sync'.
   See documentation of `ecb-latex-preview-buffer-sync' for conditions when
   synchronization takes place and so in turn these hooks are evaluated.

   ..."
  :group 'ecb-analyse
  :type 'hook)


(defun ecb-latex-preview-get-document-name ()
  "Get name of document to preview."
  (let ((master (TeX-master-file)))
    (if (file-readable-p (concat master ".pdf"))
        (concat master ".pdf")
      nil
      )
    )
  )

(defvar ecb-latex-preview-last-document nil)

(defecb-autocontrol/sync-function ecb-latex-preview-buffer-sync
    ecb-latex-preview-buffer-name ecb-latex-preview-buffer-sync t
  "Synchronizes the LaTeX preview buffer with current source if changed.
   Can be called interactively but normally this should not be necessary because
   it will be called autom. by the internal synchronizing mechanism of ECB."
  ;; synchronize only when point stays in one of the edit-window.
  (when (ecb-point-in-edit-window-number)
    (let ((document (ecb-latex-preview-get-document-name)))
      (when (or force
                (not (string-equal document ecb-latex-preview-last-document)))
        (setq ecb-latex-preview-last-document document)
        (if document
            (ecb-with-readonly-buffer visible-buffer
              (fundamental-mode)
              (erase-buffer)
              (insert-file-contents document)
              (set-visited-file-name document t t)
              (set-buffer-modified-p nil)
              (doc-view-mode)
              )
          (ecb-with-readonly-buffer visible-buffer
            (fundamental-mode)
            (erase-buffer)
            (insert "There is no document to preview.")
            (set-buffer-modified-p nil)
            )
          )
        ))
    ;; Now lets run the hooks in `ecb-latex-preview-buffer-sync-hook'
    (run-hooks 'ecb-latex-preview-buffer-sync-hook)
    ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The layout itself
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(ecb-layout-define "LaTeX" right
                   "A layout specialized on LaTeX editing"
                   (let ((edit-window (previous-window (selected-window) 0)))
                     (ecb-set-latex-preview-buffer)
                     (ecb-split-ver 0.7)
                     (ecb-set-speedbar-buffer)
                     (select-window edit-window)
                   ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (De)Activation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (defun ecb-examples-preactivation-state(action)
;;   (cond ((equal action 'save)
;;          ;; code for saving the state
;;          )
;;         ((equal action 'restore)
;;          ;; code for restoring the state
;;          )))

;; (defun ecb-examples-activate ()
;;   "Activate the new layout \"example-layout1\".
;;    Acivates the function `ecb-examples-bufferinfo-buffer-sync', set
;;    `ecb-compile-window-height' to 5 and `ecb-windows-height' to 6. The
;;    preactivation-state is saved and will be restored by
;;    `ecb-examples-deactivate'."
;;   (interactive)

;;   (assert (featurep 'ecb) nil
;;           "ECB must be loaded!")
;;   (assert ecb-minor-mode nil
;;           "ECB must be activated!")
;;   (assert (equal (selected-frame) ecb-frame) nil
;;           "The ECB-frame must be selected!")
;;   (assert (not (ecb-string= ecb-layout-name "example-layout1")) nil
;;           "The examples-layout1 is already active!")

;;   ;; saving the state
;;   (ecb-examples-preactivation-state 'save)

;;   ;; switch to our prefered layout
;;   (setq ecb-windows-height 6)
;;   (setq ecb-compile-window-height 8)
;;   (let ((ecb-change-layout-preserves-compwin-state nil))
;;     ;; activating the synchronization of the bufferinfo-window is done in the
;;     ;; dedicator-function (see `ecb-examples-set-bufferinfo-buffer' for the
;;     ;; reason). So the synchronizing will be activated implicitly with the
;;     ;; layout-switch because this redraws the layout and this calls all
;;     ;; dedicator-functions.
;;     (ecb-layout-switch "example-layout1")))

;; (defun ecb-examples-deactivate ()
;;   "Deactivate the new layout \"example-layout1\".
;;    Stops `ecb-examples-bufferinfo-buffer-sync' and restore the state
;;    as before activation."
;;   (interactive)

;;   (assert (featurep 'ecb) nil
;;           "ECB must be loaded!")
;;   (assert ecb-minor-mode nil
;;           "ECB must be activated!")
;;   (assert (equal (selected-frame) ecb-frame) nil
;;           "The ECB-frame must be selected!")
;;   (assert (ecb-string= ecb-layout-name "example-layout1") nil
;;           "The example-layout1 is not active!")

;;   ;; we stop here the synchronization.
;;   (ecb-stop-autocontrol/sync-function 'ecb-examples-bufferinfo-buffer-sync)

;;   (ecb-examples-preactivation-state 'restore)

;;   (ecb-layout-switch ecb-layout-name))
