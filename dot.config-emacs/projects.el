;; -*-mode: Emacs-Lisp; outline-minor-mode:t-*-
;; Time-stamp: <2010-01-21 22:13:29 (lluis)>

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Project management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enable EDE (Project Management) features
(global-ede-mode 1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; [END] Project management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Project-specific options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (setq semanticdb-project-roots
;;       (list
;;        "~/Projects/oss1/code/branches/foo/src"

;;        "~/Projects/oss1/code/branches/foo/src/include"

;;        "~/Projects/oss1/code/branches/foo/src/trace/libtrace"
;;        "~/Projects/oss1/code/branches/foo/src/trace/utils/libspecial"
;;        "~/Projects/oss1/code/branches/foo/src/support/paraver/src/libparaver"

;;        "~/Projects/oss1/code/branches/foo/src/trace/tools/trace2paraver"

;;        "~/Projects/oss1/code/branches/foo/src/sim/libcycle"
;;        ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; OSS / 1
(setq oss1-physmemshare-file
      (path my-home-dir "Projects" "oss1" "code" "branches" "memobjmodel"
            "configure.ac"))
(if (file-exists-p oss1-physmemshare-file)
    (ede-cpp-root-project "oss1-memobjmodel"
                          :name "OSS / 1 -- memobjmodel"
                          :file oss1-physmemshare-file
                          :include-path '(
                                          "/build/src/include"
                                          "/src/include"

                                          "/src/trace/libtrace"
                                          "/src/trace/utils/libspecial"
                                          "/src/support/paraver/src/libparaver"

                                          "/src/trace/tools/trace2paraver"

                                          "/src/sim/libcycle"
                                          )
                          )
  )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; [END] Project-specific options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
