;;; tau-packages.el --- Activation and explicit provisioning -*- lexical-binding: t; -*-

(require 'tau-core)
(defcustom tau-packages
  '(evil vertico orderless marginalia corfu aas tempel auctex
         doom-themes rainbow-delimiters)
  "Direct dependencies.  Install only on explicit request."
  :type '(repeat symbol)
  :group 'tau)

;; Keep the existing mirror choice; local.el can override it.
(defvar package-archives
  '(("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
    ("melpa" . "https://mirrors.ustc.edu.cn/elpa/melpa/")
    ("nongnu" . "https://mirrors.ustc.edu.cn/elpa/nongnu/")))
(setq package-archive-priorities '(("gnu" . 3) ("melpa" . 2) ("nongnu" . 1))
      package-install-upgrade-built-in nil
      package-quickstart t
      package-quickstart-file (tau-state-file "package-quickstart.el"))

(make-directory tau-state-directory t)

;; Use the quickstart autoload cache without parsing all descriptors/archives.
;; The uncached fallback is also entirely local.
(package-activate-all)

(defun tau-packages-install ()
  "Install missing dependencies and rebuild the autoload cache.
This is the only configuration command that refreshes package archives."
  (interactive)
  (require 'package)
  (require 'seq)
  (unless package--initialized (package-initialize))
  (let ((missing (seq-remove #'package-installed-p tau-packages)))
    (when missing
      (package-refresh-contents)
      (dolist (package missing) (package-install package)))
    (tau-packages-refresh)
    (message "Dependencies ready; restart Emacs to activate new features")))

(defun tau-packages-refresh ()
  "Rebuild the local package autoload cache without using the network."
  (interactive)
  (require 'package)
  (make-directory tau-state-directory t)
  (package-quickstart-refresh))

(provide 'tau-packages)
;;; tau-packages.el ends here
