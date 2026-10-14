;;; init-latex.el --- LaTeX -*- lexical-binding: t; -*-

;;; Commentary:

;; AUCTeX replaces the built-in TeX modes through its autoloads, so
;; nothing is loaded until a .tex file is visited.

;;; Code:

(use-package auctex
  :ensure t
  :defer t)

(provide 'init-latex)
;;; init-latex.el ends here
