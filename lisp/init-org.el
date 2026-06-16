;; -*- lexical-binding: t; -*-

(with-eval-after-load 'org
  
  (cdlatex-setup)
  (setq org-highlight-latex-and-related '(native script entities)
	org-src-fontify-natively t)
  (setq org-preview-latex-default-process 'dvisvgm)
  (setq org-preview-latex-image-directory (expand-file-name "~/.cache/org-ltximg/"))
  (setq org-format-latex-header
	"\\documentclass{article}
         \\usepackage[usenames]{color}
         \\usepackage{amsmath}
         \\usepackage{physics}
         \\usepackage{amssymb}
         \\pagestyle{empty}")

  (setq org-format-latex-options
	(plist-put org-format-latex-options :scale 1.3))

  (setq org-link-file-path-type 'relative)

  (setq org-roam-directory (expand-file-name "~/org/roam/")
	org-roam-completion-everywhere t)

  (with-eval-after-load 'org-roam
    (org-roam-db-autosync-mode))

  (global-set-key (kbd "C-c n f") #'org-roam-node-find)
  (global-set-key (kbd "C-c n i") #'org-roam-node-insert)
  (global-set-key (kbd "C-c n c") #'org-roam-capture)
  (global-set-key (kbd "C-c n b") #'org-roam-buffer-toggle)

  (add-to-list 'org-src-lang-modes '("python" . python-ts))
  (add-to-list 'org-src-lang-modes '("bash" . bash-ts))
  (add-to-list 'org-src-lang-modes '("sh" . bash-ts))
  (add-to-list 'org-src-lang-modes '("c" . c-ts))
  (add-to-list 'org-src-lang-modes '("cpp" . c++-ts))
  (add-to-list 'org-src-lang-modes '("rust" . rust-ts))

  (require 'org-tempo)

  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("rs" . "src rust")))

(add-hook 'org-mode-hook 'org-cdlatex-mode)
(add-hook 'org-mode-hook 'rainbow-delimiters-mode)
(add-hook 'org-mode-hook 'corfu-mode)
(add-hook 'org-mode-hook 'visual-line-mode)

(add-hook 'org-mode-hook (lambda ()
			   (electric-pair-local-mode -1)))

(provide 'init-org)
