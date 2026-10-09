;;; init.el --- Configuration entry point -*- lexical-binding: t; -*-

(when (version< emacs-version "29.1")
  (error "This configuration requires Emacs 29.1 or newer"))

(defconst tau-config-directory
  (file-name-directory (or load-file-name buffer-file-name))
  "Directory containing this configuration's source files.")

(dolist (directory '("lisp" "lisp/modules" "lisp/org" "site-lisp"))
  (add-to-list 'load-path (expand-file-name directory tau-config-directory)))

(unwind-protect
    (progn
      (require 'tau-core)
      ;; Machine-specific options must precede package/module initialization.
      (load (expand-file-name "local.el" tau-config-directory) 'noerror 'nomessage)
      (tau-core-setup-state)
      (require 'tau-packages)
      (dolist (module tau-modules)
        (require module))
      ;; Custom is a final override, rather than another source of defaults.
      (load custom-file 'noerror 'nomessage))
  ;; Also restore GC on init errors and in batch, which omits startup hooks.
  (when (fboundp 'tau-startup-restore-gc)
    (tau-startup-restore-gc)))

;;; init.el ends here
