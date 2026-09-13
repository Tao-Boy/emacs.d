;; -*- lexical-binding: t; -*-

(setq inhibit-startup-screen t
      inhibit-startup-message t
      initial-scratch-message nil
      use-short-answers t
      y-or-n-p-use-read-key t)

(setq ring-bell-function #'ignore)

(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)

(setq auto-save-default nil
      make-backup-files nil
      create-lockfiles nil
      auto-mode-case-fold nil)

(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror)


(when (native-comp-available-p)
  (setq native-comp-async-report-warnings-errors 'silent))

(setq xterm-update-cursor t)
(blink-cursor-mode -1)
(setq visible-cursor nil)
(xterm-mouse-mode t)

(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook
          (lambda ()
            (electric-pair-local-mode 1)
            (display-line-numbers-mode 1)))

(provide 'init-basic)
