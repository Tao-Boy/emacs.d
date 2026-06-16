;; -*- lexical-binding: t; -*-

(defun tau-org-inline-math ()
  (interactive)
  (insert "\\(\\)")
  (backward-char 2))

(defun tau-org-display-math ()
  (interactive)
  (insert "\\begin{equation}\n\n\\end{equation}")
  (forward-line -1)
  (indent-according-to-mode))

(defun cdlatex-setup ()
  (define-key org-mode-map (kbd "C-c m") #'tau-org-inline-math)
  (define-key org-mode-map (kbd "C-c d") #'tau-org-display-math)

  (with-eval-after-load 'cdlatex
    (define-key org-cdlatex-mode-map (kbd "`") nil)
    (define-key org-cdlatex-mode-map (kbd ";") #'cdlatex-math-symbol)

    (setq cdlatex-math-symbol-prefix ?\;)

    (setq cdlatex-math-symbol-alist
          '((?1 ("^{-1}"))
            (?2 ("^2"))
            (?3 ("^3"))
            (?+ ("^\\dagger" "\\cup"))))

    (setq cdlatex-command-alist
          '(("sum" "" "\\sum_{?}^{}" cdlatex-position-cursor nil nil t))))
  nil)



(provide 'init-cdlatex)
