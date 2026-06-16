;;; early-init.el ---  -*- lexical-binding: t; -*-

(setq gc-cons-threshold most-positive-fixnum)

(defvar tau--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist
                  (delete-dups (append file-name-handler-alist
                                       tau--file-name-handler-alist)))))

;; Native compilation runs asynchronously in the background; silence its
;; warnings/errors popup so it doesn't interrupt.
(setq native-comp-async-report-warnings-errors 'silent)

(setq package-enable-at-startup nil
      package-quickstart t
      package-quickstart-file (expand-file-name "package-quickstart.el" user-emacs-directory)
      warning-suppress-types '((files)))

(prefer-coding-system 'utf-8)

(setq inhibit-startup-screen t
      initial-scratch-message nil
      frame-inhibit-implied-resize t)

(setq auto-save-default nil
      auto-save-list-file-prefix nil
      make-backup-files nil
      create-lockfiles nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 128 1024 1024)
                  gc-cons-percentage 0.1)))

(setq default-frame-alist
      '((menu-bar-lines . 0)
        (tool-bar-lines . 0)
        (right-fringe . 0)
        (left-fringe . 0)
        (vertical-scroll-bars . nil)))

(when (featurep 'ns)
  (push '(ns-transparent-titlebar . t) default-frame-alist)
  (push '(ns-appearance . dark) default-frame-alist))

(let ((env-file (expand-file-name "env.el" user-emacs-directory)))
  (when (file-exists-p env-file)
    (load env-file 'noerror)))

;;; early-init.el ends here
