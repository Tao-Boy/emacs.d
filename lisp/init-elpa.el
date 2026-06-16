;; -*- lexical-binding: t; -*-

(require 'package)

(setq package-archives '(("gnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(setq package-install-upgrade-built-in t
      package-quickstart t)

(package-initialize)

(defconst tau-package-list
  '(rime
    corfu
    auctex
    cdlatex
    rainbow-delimiters
    org-roam))

(defvar tau--package-refreshed nil)

(defun tau-package-quickstart-refresh-maybe (&optional force)
  (when (and package-quickstart
             (or force
                 (not (file-exists-p package-quickstart-file))))
    (package-quickstart-refresh)))

(defun tau-package-ensure (package &optional min-version)
  (unless (package-installed-p package min-version)
    (unless (or tau--package-refreshed
                (assoc package package-archive-contents))
      (package-refresh-contents)
      (setq tau--package-refreshed t))
    (package-install package)
    t))

(defun tau-package-ensure-all ()
  (let ((installed nil))
    (dolist (package tau-package-list)
      (when (tau-package-ensure package)
        (setq installed t)))
    (tau-package-quickstart-refresh-maybe installed)))

(tau-package-ensure-all)

(provide 'init-elpa)
