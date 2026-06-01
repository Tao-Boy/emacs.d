;; -*- lexical-binding: t; -*-

(require 'package)
(setq package-selected-packages nil)

(setq package-archives '(("gnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))

(defvar tau--package--refreshed nil)

(defun require-package (package &optional min-version)
  (unless (package-installed-p package min-version)
    (unless (or tau--package--refreshed
                (assoc package package-archive-contents))
      (package-refresh-contents))
      (setq tau--package--refreshed t)
    (package-install package)))

(setq package-install-upgrade-built-in t)

(require-package 'rime)
(require-package 'corfu)
(require-package 'auctex)
(require-package 'cdlatex)
(require-package 'rainbow-delimiters)

(package-activate-all)

(provide 'init-elpa)
