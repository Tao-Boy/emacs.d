;;; compile.el --- Compile configuration with warnings treated as errors -*- lexical-binding: t; -*-

(require 'bytecomp)
(defconst tau-compile-root
  (file-name-directory (directory-file-name (file-name-directory load-file-name))))
(defconst tau-compile-temp (make-temp-file "tau-compile-" t))
(setq user-emacs-directory (file-name-as-directory tau-compile-temp)
      load-prefer-newer t
      package-user-dir (or (getenv "TAU_PACKAGE_DIR")
                           (expand-file-name "elpa/" tau-compile-root)))
(dolist (directory '("lisp" "lisp/modules" "lisp/org"))
  (add-to-list 'load-path (expand-file-name directory tau-compile-root)))
(require 'package)
(package-initialize)
(require 'tau-core)
(setq byte-compile-error-on-warn t)
(let ((success t))
  (unwind-protect
      (dolist (file (append (list (expand-file-name "early-init.el" tau-compile-root)
                                  (expand-file-name "init.el" tau-compile-root))
                            (directory-files-recursively
                             (expand-file-name "lisp/" tau-compile-root) "\\.el\\'")))
        (unless (byte-compile-file file) (setq success nil)))
    (delete-directory tau-compile-temp t))
  (kill-emacs (if success 0 1)))

;;; compile.el ends here
