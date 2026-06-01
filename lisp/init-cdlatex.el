;; -*- lexical-binding: t; -*-

(defun tau-org-inline-math ()
  (interactive)
  (insert "\\(\\)")
  (backward-char 2))

(defun tau-org-display-math ()
  (interactive)
  (insert "\\[\n\n\\]")
  (forward-line -1)
  (indent-according-to-mode))

(defun cdlatex-setup ()

  (define-key org-mode-map (kbd "C-c m") #'tau-org-inline-math)
  (define-key org-mode-map (kbd "C-c d") #'tau-org-display-math)

  (define-key org-cdlatex-mode-map (kbd "`") nil)
  (define-key org-cdlatex-mode-map (kbd ";") #'cdlatex-math-symbol)

  (setq cdlatex-math-symbol-prefix ?\;))

(provide 'init-cdlatex)
