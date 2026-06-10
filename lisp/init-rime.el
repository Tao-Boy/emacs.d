;;; init-rime.el --- -*- lexical-binding: t; -*-

;; Code:

(defvar emacs-header-path
  (concat user-emacs-directory "emacs-header/"
          (number-to-string emacs-major-version)))

(setq default-input-method "rime")

(when (eq system-type 'windows-nt)
  (setq rime-librime-root (concat user-emacs-directory "librime")))

(when (eq system-type 'darwin)
  (setq rime-librime-root "/opt/homebrew"))

(cond
 ((eq system-type 'windows-nt)
  (setq rime-librime-root (concat user-emacs-directory "librime")))
 ((eq system-type 'darwin)
  (setq rime-librime-root "/opt/homebrew")))

(setq rime-emacs-module-header-root emacs-header-path
      rime-share-data-dir (concat user-emacs-directory "rime-data"))
 
(when (display-graphic-p)
  (setq rime-show-candidate 'posframe
	rime-posframe-style 'vertical))

(setq rime-disable-predicates
      '(rime-predicate-org-latex-mode-p
	rime-predicate-space-after-cc-p
	rime-predicate-after-ascii-char-p
	rime-predicate-punctuation-line-begin-p))

(provide 'init-rime)
;; init-rime.el ends here
