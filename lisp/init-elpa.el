;; -*- lexical-binding: t; -*-

(require 'package)
(package-initialize)
(setq package-install-upgrade-built-in nil)
(setq package-check-signature nil)
(setq package-archives '(("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
                         ("melpa" . "https://mirrors.ustc.edu.cn/elpa/melpa/")
                         ("nongnu" . "https://mirrors.ustc.edu.cn/elpa/nongnu/")))
(setq package-archive-priorities
      '(("gnu" . 3)
	("melpa" . 2)
	("nongnu" . 1)))

(add-hook 'package-menu-mode-hook #'hl-line-mode)

(defmacro tau-emacs-install (&rest packages)
  "Install PACKAGES unless they are installed."
  `(progn
     ,@(mapcar
        (lambda (package)
          `(unless (package-installed-p ',package)
             (condition-case-unless-debug nil
                 (progn
                   (unless package-archive-contents
                     (package-refresh-contents))
                   (package-install ',package))
               (error
                (message
                 "Cannot install `%s'; try `M-x package-refresh-contents' first"
                 ',package)))))
        packages)))

(tau-emacs-install
 evil
 vertico
 orderless
 marginalia
 corfu
 aas
 tempel
 auctex
 doom-themes
 rainbow-delimiters)

(when (and package-quickstart
           (not (file-readable-p package-quickstart-file)))
  (ignore-errors (package-quickstart-refresh)))

(provide 'init-elpa)
