;;; init-rime.el --- Upstream liberime and Rimel -*- lexical-binding: t; -*-

;;; Code:

(use-package liberime
  :ensure t
  :defer t
  :custom
  (liberime-auto-build t)
  (liberime-user-data-dir (locate-user-emacs-file "rime/")))

(use-package rimel
  :ensure t
  :defer t
  :bind (("C-c r s" . rimel-select-schema)
         ("C-c r d" . rimel-deploy))
  :init
  (setq default-input-method "rimel")
  :custom
  (rimel-show-candidate 'prompt)
  (rimel-disable-predicates
   '(rimel-predicate-evil-mode-p
     rimel-predicate-prog-in-code-p
     rimel-predicate-after-alphabet-char-p
     rimel-predicate-current-uppercase-letter-p
     rimel-predicate-org-in-src-block-p
     rimel-predicate-org-latex-mode-p
     rimel-predicate-tex-math-or-command-p)))

(use-package which-key
  :config
  (which-key-add-key-based-replacements "C-c r" "rime"))

(provide 'init-rime)
;;; init-rime.el ends here
