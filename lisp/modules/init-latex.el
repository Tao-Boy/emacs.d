;;; init-latex.el --- LaTeX editor on first use -*- lexical-binding: t; -*-

(defun tau-latex-mode ()
  "Use AUCTeX when installed, otherwise use the built-in LaTeX mode."
  (interactive)
  (if (require 'tex-site nil t)
      (LaTeX-mode)
    (latex-mode)))

(add-to-list 'auto-mode-alist '("\\.\\(?:tex\\|ltx\\)\\'" . tau-latex-mode))

(provide 'init-latex)
;;; init-latex.el ends here
