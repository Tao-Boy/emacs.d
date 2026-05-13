;; -*- lexical-binding: t; -*-

(with-eval-after-load 'org
  (setq org-highlight-latex-and-related '(native script entities)
	org-src-fontify-natively t)
  (setq org-preview-latex-default-process 'dvipng)
  (setq org-preview-latex-image-directory "~/.temp")
  (setq org-format-latex-header
	"\\documentclass{article}
       \\usepackage[usenames]{color}
       \\usepackage{amsmath}
       \\usepackage{physics}
       \\usepackage{amssymb}
       \\pagestyle{empty}")

  (setq org-format-latex-options
	(plist-put org-format-latex-options :scale 1.4)))

(add-hook 'org-mode-hook 'org-fragtog-mode)
(add-hook 'org-mode-hook 'rainbow-delimiters-mode)
(add-hook 'org-mode-hook 'corfu-mode)

(provide 'init-org)
