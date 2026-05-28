;;; init-rime.el --- -*- lexical-binding: t; -*-

;; Code:

(defvar-local emacs-header-path
  (cond
   ((= emacs-major-version 30)
    (concat user-emacs-directory "emacs-header/30"))
   ((= emacs-major-version 31)
    (concat user-emacs-directory "emacs-header/31")))
  (t nil))

(setq default-input-method "rime")

(setq rime-librime-root (concat user-emacs-directory "librime")
      rime-emacs-module-header-root emacs-header-path
      rime-share-data-dir (concat user-emacs-directory "rime-data"))
 
(when (display-graphic-p)
  (setq rime-show-candidate 'posframe
	rime-posframe-style 'vertical))

(setq rime-disable-predicates
      '(texmathp
	rime-predicate-space-after-cc-p
	rime-predicate-after-ascii-char-p
	rime-predicate-punctuation-line-begin-p))

(provide 'init-rime)
;; init-rime.el ends here
