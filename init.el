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

(with-temp-message ""
  (require 'init-autoload)
  (require 'init-generic)
  (require 'init-keymaps)
  (require 'init-treesitter)
  (require 'init-elpa)
  (require 'init-rime)
  (require 'init-corfu)
  (require 'init-cdlatex)
  (require 'init-org)
  (require 'init-rainbow)
  (require 'init-font)
  )
