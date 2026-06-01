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

  (add-to-list 'org-src-lang-modes '("python" . python-ts))
  (add-to-list 'org-src-lang-modes '("bash" . bash-ts))
  (add-to-list 'org-src-lang-modes '("sh" . bash-ts))
  (add-to-list 'org-src-lang-modes '("c" . c-ts))
  (add-to-list 'org-src-lang-modes '("cpp" . c++-ts))
  (add-to-list 'org-src-lang-modes '("rust" . rust-ts))

  (require 'org-tempo)

  (tempo-define-template
   "org-html-theme"
   '("#+SETUPFILE: https://fniessen.github.io/org-html-themes/org/html-theme-readtheorg.setup" n)
   "<set"
   "Insert org-html-themes setupfile"
   'org-tempo-tags)
  
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
