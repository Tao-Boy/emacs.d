;;; init-rime.el --- -*- lexical-binding: t; -*-

;; Code:

(defvar emacs-header-path
  (concat user-emacs-directory "emacs-header/"
          (number-to-string emacs-major-version)))

(setq default-input-method "rime")

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

(defun my/rime-predicate-org-latex-mode-p ()
  "Return non-nil when point is strictly inside an Org LaTeX element."
  (and (derived-mode-p 'org-mode)
       (fboundp 'org-element-context)
       (let* ((context (org-element-context))
              (type (org-element-type context)))
         (and (memq type '(latex-fragment latex-environment))
              (let* ((begin (org-element-property :begin context))
                     (end (org-element-property :end context))
                     (post-blank (or (org-element-property :post-blank context) 0))
                     (strict-end (and end (- end post-blank))))
                (and begin strict-end
                     (>= (point) begin)
                     (< (point) strict-end)))))))

(setq rime-disable-predicates
      '(my/rime-predicate-org-latex-mode-p
	rime-predicate-space-after-cc-p
	rime-predicate-after-ascii-char-p
	rime-predicate-punctuation-line-begin-p))

(provide 'init-rime)
;; init-rime.el ends here
