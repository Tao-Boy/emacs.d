;;; early-init.el ---  -*- lexical-binding: t; -*-

(setq load-suffixes '(".elc" ".el")
      load-file-rep-suffixes '(""))

(setq site-run-file nil)

(setq package-enable-at-startup nil
      package-quickstart t)

(setq inhibit-startup-screen t
      initial-scratch-message nil
      frame-inhibit-implied-resize t)

(setq auto-save-default nil
      auto-save-list-file-prefix nil
      make-backup-files nil
      create-lockfiles nil)

(prefer-coding-system 'utf-8)

(setq read-process-output-max (* 4 1024 1024))
(setq process-adaptive-read-buffering nil)

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.8)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 64 1024 1024)
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

(when (eq system-type 'darwin)
  (setenv "PATH"
          (concat "/Library/TeX/texbin:/opt/homebrew/bin:/usr/local/bin:"
                  (getenv "PATH")))
  (add-to-list 'exec-path "/Library/TeX/texbin")
  (add-to-list 'exec-path "/opt/homebrew/bin"))

;;; early-init.el ends here
