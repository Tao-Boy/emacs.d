;; -*- lexical-binding: t; -*-

(setq auto-mode-case-fold nil)

(defun tau--add-load-path ()
  (dolist (dir '("site-lisp" "lisp"))
    (let ((path (expand-file-name dir user-emacs-directory)))
      (when (file-directory-p path)
        (push path load-path)))))

(tau--add-load-path)

(defconst my/emacs-d user-emacs-directory)
(defconst my/lisp-dir (concat my/emacs-d "lisp/"))
(defconst my/site-lisp-dir (concat my/emacs-d "site-lisp/"))

(setq custom-file
      (expand-file-name "custom.el" user-emacs-directory))

(defun tau-require-modules (&rest modules)
  (dolist (module modules)
    (require module)))

(with-temp-message ""
  ;; Core startup and package activation.
  (tau-require-modules
   'init-elpa
   'init-generic
   'init-font)

  ;; Language and feature configuration.  These modules avoid eager package
  ;; loads and install hooks/autoload-friendly settings only.
  (tau-require-modules
   'init-treesitter
   'init-rime
   'init-corfu
   'init-cdlatex
   'init-org
   'init-rainbow))
