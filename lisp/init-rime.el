;;; init-rime.el --- -*- lexical-binding: t; -*-

;; Code:

(setq default-input-method "rime")
(cond
 ((eq system-type 'gnu/linux)
  (setq rime-share-data-dir "~/.local/share/rime"))
 
 ((eq system-type 'darwin)
  (setq rime-librime-root "/opt/homebrew"
	rime-emacs-module-header-root "/Applications/Emacs.app/Contents/Resources/include/"
        rime-share-data-dir "~/.config/rime")))

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
