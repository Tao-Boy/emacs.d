;; -*- lexical-binding: t; -*-

(defconst my/emacs-d user-emacs-directory)
(defconst my/lisp-dir (concat my/emacs-d "lisp/"))
(defconst my/site-lisp-dir (concat my/emacs-d "site-lisp/"))

(defun require-init (pkg &optional maybe-disabled)
  (unless maybe-disabled
    (load (file-truename (format "%s/%s" my/lisp-dir pkg)) t t)))

(setq custom-file (concat my/emacs-d "custom.el"))
(load custom-file 'noerror)

(let ((file-name-handler-alist nil))
  (require-init 'init-autoload)
  (require-init 'init-keymaps)
  (require-init 'init-elpa)
  (require-init 'init-corfu)
  (require-init 'init-org)
  (require-init 'init-aas)
  (require-init 'init-rime)
  (require-init 'init-ui))
