;;; init-snippet.el --- CDLaTeX math input -*- lexical-binding: t; -*-

;;; Code:

(use-package cdlatex
  :ensure t
  :hook ((org-mode . turn-on-org-cdlatex)
         ((latex-mode LaTeX-mode) . turn-on-cdlatex))
  :bind (:map cdlatex-mode-map
              ("C-c TAB" . cdlatex-tab))
  :custom
  (cdlatex-math-symbol-prefix ?\;)
  (cdlatex-simplify-sub-super-scripts nil)
  ;; Keep the previous Greek-letter keys and common operator mnemonics.
  (cdlatex-math-symbol-alist
   '((?i ("\\iota" "\\imath"))
     (?t ("\\theta" "\\vartheta" "\\tan"))
     (?T ("\\Theta" "" "\\arctan"))
     (?u ("\\tau"))
     (?x ("\\xi"))
     (?X ("\\Xi"))
     (?c ("\\chi" "" "\\cos"))
     (?< ("\\leq" "\\leftarrow"))
     (?> ("\\geq" "\\rightarrow"))
     (?! ("\\neq" "\\neg"))
     (?+ ("\\pm" "\\cup"))
     (?- ("\\mp" "\\leftrightarrow"))))
  ;; Keywords expand with TAB.  A question mark marks the initial cursor.
  (cdlatex-command-alist
   '(("mk" "Inline math" "\\(?\\)" cdlatex-position-cursor nil t nil)
     ("dm" "Display math" "\\[\n?\n\\]" cdlatex-position-cursor nil t nil)
     ("ff" "Fraction" "\\frac{?}{}" cdlatex-position-cursor nil nil t)
     ("sr" "Square" "^{2}" nil nil nil t)
     ("cb" "Cube" "^{3}" nil nil nil t)
     ("sum" "Sum" "\\sum_{?}^{n} " cdlatex-position-cursor nil nil t)
     ("prod" "Product" "\\prod_{?}^{n} " cdlatex-position-cursor nil nil t)
     ("int" "Integral" "\\int_{?}^{b} \\, dx" cdlatex-position-cursor nil nil t)
     ("lim" "Limit" "\\lim_{? \\to \\infty} " cdlatex-position-cursor nil nil t)
     ("jk" "Subscript" "_{?}" cdlatex-position-cursor nil nil t)
     ("kj" "Superscript" "^{?}" cdlatex-position-cursor nil nil t)
     ("xx" "Times" "\\times" nil nil nil t)
     ("inn" "In" "\\in" nil nil nil t)
     ("nin" "Not in" "\\notin" nil nil nil t)
     ("AA" "For all" "\\forall" nil nil nil t)
     ("EE" "Exists" "\\exists" nil nil nil t)
     ("oo" "Infinity" "\\infty" nil nil nil t)
     ("pd" "Partial" "\\partial" nil nil nil t)
     ("nbl" "Nabla" "\\nabla" nil nil nil t)
     ("sin" "Sine" "\\sin" nil nil nil t)
     ("cos" "Cosine" "\\cos" nil nil nil t)
     ("tan" "Tangent" "\\tan" nil nil nil t)
     ("log" "Logarithm" "\\log" nil nil nil t)
     ("ln" "Natural logarithm" "\\ln" nil nil nil t)
     ("exp" "Exponential" "\\exp" nil nil nil t))))

(provide 'init-snippet)
;;; init-snippet.el ends here
