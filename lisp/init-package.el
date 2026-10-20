;;; init-package.el --- package.el and use-package -*- lexical-binding: t; -*-

;;; Commentary:

;; Package archive and GitHub mirrors, package.el and use-package.
;;
;; Packages are activated before init.el by `package-quickstart' (see
;; early-init.el), so package.el itself is not needed at startup.  The
;; only thing that would load it is `use-package's `:ensure', which
;; requires package.el unconditionally; `tau-package-ensure' skips that
;; when the package is already installed, so package.el is only loaded
;; when something actually has to be installed.

;;; Code:

;;;; Mirrors

(defvar tau-elpa-mirror "https://mirrors.ustc.edu.cn/elpa/"
  "URL under which the gnu, nongnu and melpa archives are mirrored.")

(defvar tau-github-mirror "https://gh-proxy.com/github.com/"
  "URL prefix that replaces \"https://github.com/\", or nil for none.
Used when downloading tree-sitter grammars and prebuilt liberime.")

;;;; Archives

(setq package-archives
      (mapcar (lambda (archive)
                (cons archive (concat tau-elpa-mirror archive "/")))
              '("gnu" "nongnu" "melpa"))
      package-archive-priorities '(("gnu" . 3) ("melpa" . 2) ("nongnu" . 1))
      package-install-upgrade-built-in nil
      package-check-signature nil)

(with-eval-after-load 'package
  (add-hook 'package-menu-mode-hook #'hl-line-mode))

;;;; use-package

;; Must be set before use-package is loaded.
(setq use-package-enable-imenu-support t)

(setq use-package-expand-minimally t        ; Leaner macro expansion.
      use-package-always-ensure nil         ; Opt in per package.
      use-package-compute-statistics init-file-debug)

(require 'use-package)

(defun tau-package-ensure (name args state &optional no-refresh)
  "Fast path for `use-package-ensure-elpa'.
NAME, ARGS, STATE and NO-REFRESH are as for that function.  With
`package-quickstart', `package-installed-p' answers from
`package-activated-list' without loading package.el, so packages that
are already installed cost nothing."
  (unless (catch 'missing
            (dolist (ensure args t)
              (let ((package (cond ((eq ensure t) (use-package-as-symbol name))
                                   ((consp ensure) (car ensure))
                                   (t ensure))))
                (unless (or (null package) (package-installed-p package))
                  (throw 'missing nil)))))
    (use-package-ensure-elpa name args state no-refresh)))

(setq use-package-ensure-function #'tau-package-ensure)

;; Installing a package during init regenerates the quickstart file,
;; and `package-quickstart-refresh' calls `package-initialize', which
;; then warns about an "unnecessary call" that this file never made.
(with-eval-after-load 'warnings
  (add-to-list 'warning-suppress-log-types '(package reinitialization)))

(provide 'init-package)
;;; init-package.el ends here
