;; -*- lexical-binding: t; -*-

(package-initialize)

(setq package-archives '(("gnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))

(defvar my/package--refreshed nil)

(defun require-package (package &optional min-version)
  (unless (package-installed-p package min-version)
    (unless (or my/package--refreshed
                (assoc package package-archive-contents))
      (package-refresh-contents)
      (setq my/package--refreshed t))
    (package-install package)))

(setq package-install-upgrade-built-in t)

(require-package 'org '(9 8 4))
(require-package 'htmlize)
(require-package 'rime)
(require-package 'corfu)
(require-package 'auctex)
(require-package 'tempel)
(require-package 'aas)
(require-package 'org-fragtog)
(require-package 'rainbow-delimiters)

(provide 'init-elpa)
