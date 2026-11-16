;;; init-package.el --- package.el and use-package -*- lexical-binding: t; -*-

;;; Code:

(setq use-package-always-ensure nil
      use-package-compute-statistics init-file-debug
      use-package-enable-imenu-support t)

(require 'use-package)

(defvar tau-elpa-mirror "https://mirrors.ustc.edu.cn/elpa/"
  "URL under which the gnu, nongnu and melpa archives are mirrored.")

(defvar tau-github-mirror "https://gh-proxy.com/github.com/"
  "URL prefix replacing https://github.com/ for tree-sitter downloads.")

(use-package package
  :custom
  (package-archives
   (mapcar (lambda (archive)
             (cons archive (concat tau-elpa-mirror archive "/")))
           '("gnu" "nongnu" "melpa")))
  (package-archive-priorities '(("gnu" . 3) ("melpa" . 2) ("nongnu" . 1)))
  (package-install-upgrade-built-in nil)
  (package-check-signature nil)
  :hook (package-menu-mode . hl-line-mode))

(provide 'init-package)
;;; init-package.el ends here
