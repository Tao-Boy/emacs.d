;; -*- lexical-binding: t; -*-

(defun cdlatex-setup ()

  (define-abbrev-table 'org-mode-abbrev-table
    '(("mk" "\\(\\)" (lambda ()
		       (backward-char 2))
       :system t)
      ("dm" "\\[\n\n\\]" (lambda ()
			   (forward-line -1)
			   (indent-according-to-mode))
       :system t)))

  (defun tau--org-tab ()
    (interactive)
    (unless (expand-abbrev)
      (call-interactively #'org-cycle)))
  
  (define-key org-mode-map (kbd "TAB") #'tau--org-tab)
  (define-key org-mode-map (kbd "<tab>") #'tau--org-tab)

  (define-key org-cdlatex-mode-map (kbd "`") nil)
  (define-key org-cdlatex-mode-map (kbd ";") #'cdlatex-math-symbol)
  
  (setq cdlatex-math-symbol-prefix ?\;)
  (setq cdlatex-command-alist
	'(
	  ("sum" "" "\\sum_{?}^{}" cdlatex-position-cursor nil nil t)
	  ("int" "" "\\int_{?}^{}" cdlatex-position-cursor nil nil t)
	  ("pm" "" "\\pm" nil nil nil t)
	  )
	))

(provide 'init-cdlatex)
