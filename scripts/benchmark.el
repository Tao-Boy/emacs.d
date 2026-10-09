;;; benchmark.el --- Init and first-use measurements -*- lexical-binding: t; -*-

(defconst tau-benchmark-root
  (file-name-as-directory
   (or (getenv "TAU_BENCH_ROOT")
       (file-name-directory (directory-file-name (file-name-directory load-file-name))))))
(defconst tau-benchmark-temp (make-temp-file "tau-benchmark-" t))
(setq user-emacs-directory tau-benchmark-root
      package-user-dir (or (getenv "TAU_PACKAGE_DIR")
                           (expand-file-name "elpa/" tau-benchmark-root))
      tau-org-root (expand-file-name "org/" tau-benchmark-temp)
      org-id-locations-file (expand-file-name "ids" tau-benchmark-temp))
(when-let* ((setup (getenv "TAU_TEST_SETUP"))) (load setup nil t))
;; The original Emacs 31 config's load-path filter requires this to be loaded
;; before early-init.  Keep it identical for before/after comparisons.
(require 'regexp-opt)

(let* ((start (current-time)) (gcs gcs-done) (libraries (length load-history))
       startup completion org-buffer prog-buffer startup-gcs startup-libraries)
  (unwind-protect
      (progn
        (load (expand-file-name "early-init.el" tau-benchmark-root) nil t)
        (load (expand-file-name "init.el" tau-benchmark-root) nil t)
        (run-hooks 'after-init-hook 'emacs-startup-hook)
        (setq startup (float-time (time-subtract (current-time) start))
              startup-gcs (- gcs-done gcs)
              startup-libraries (- (length load-history) libraries))
        (setq start (current-time))
        (when (fboundp 'tau-completion-enable) (tau-completion-enable))
        (setq completion (float-time (time-subtract (current-time) start))
              start (current-time))
        (with-temp-buffer (org-mode))
        (setq org-buffer (float-time (time-subtract (current-time) start))
              start (current-time))
        (with-temp-buffer (emacs-lisp-mode))
        (setq prog-buffer (float-time (time-subtract (current-time) start))))
    (when (bound-and-true-p savehist-mode) (savehist-mode -1))
    (delete-directory tau-benchmark-temp t))
  (require 'json)
  (princ (json-encode `((emacs . ,emacs-version)
                        (startup_seconds . ,startup)
                        (startup_gcs . ,startup-gcs)
                        (startup_libraries . ,startup-libraries)
                        (completion_activation_seconds . ,completion)
                        (first_org_buffer_seconds . ,org-buffer)
                        (first_prog_buffer_seconds . ,prog-buffer))))
  (princ "\n"))

;;; benchmark.el ends here
