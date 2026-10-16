;;; init-snippet.el --- Templates and auto-expanding snippets -*- lexical-binding: t; -*-

;;; Commentary:

;; Tempel templates, plus AAS snippets that expand LaTeX math as you
;; type in Org buffers.  Both load with the first Org buffer.

;;; Code:

(use-package tempel
  :ensure t
  :defer t
  :bind (:map tempel-map
              ("TAB" . tempel-next)
              ("<tab>" . tempel-next)
              ("<backtab>" . tempel-previous)
              ("S-TAB" . tempel-previous)))

(defun tau-org-in-math-p ()
  "Non-nil if point is inside LaTeX math in an Org buffer.
Uses `org-ratex-in-math-p' when org-ratex is available: Org's own
`org-inside-LaTeX-fragment-p' fails in a whole \\[...\\] once one of its
lines starts with \"- \", \"+ \" or \"1. \", which Org reads as a list item."
  (if (fboundp 'org-ratex-in-math-p)
      (org-ratex-in-math-p)
    (org-inside-LaTeX-fragment-p)))

(use-package aas
  :ensure t
  :hook (org-mode . aas-activate-for-major-mode)
  :config
  (require 'org-ratex nil t)
  (aas-set-snippets 'org-mode
    :cond (lambda () (not (tau-org-in-math-p)))
    "mk" '(tempel "\\(" p "\\)" q)
    "dm" '(tempel
           "\\[" n>
           p
           n "\\]" q)

    :cond #'tau-org-in-math-p
    ";a" "\\alpha"
    ";b" "\\beta"
    ";g" "\\gamma"
    ";d" "\\delta"
    ";e" "\\epsilon"
    ":e" "\\varepsilon"
    ";z" "\\zeta"
    ";h" "\\eta"
    ";t" "\\theta"
    ";i" "\\iota"
    ";k" "\\kappa"
    ";l" "\\lambda"
    ";m" "\\mu"
    ";n" "\\nu"
    ";x" "\\xi"
    ";p" "\\pi"
    ";r" "\\rho"
    ";s" "\\sigma"
    ";u" "\\tau"
    ";f" "\\phi"
    ":f" "\\varphi"
    ";c" "\\chi"
    ";y" "\\psi"
    ";o" "\\omega"

    ";G" "\\Gamma"
    ";D" "\\Delta"
    ";T" "\\Theta"
    ";L" "\\Lambda"
    ";X" "\\Xi"
    ";P" "\\Pi"
    ";S" "\\Sigma"
    ";F" "\\Phi"
    ";Y" "\\Psi"
    ";O" "\\Omega"

    ;; "->" "\\to"
    ;; "<-" "\\leftarrow"
    ;; "=>" "\\implies"
    ;; "=<" "\\impliedby"
    ;; "<=>" "\\iff"

    "<=" "\\leq"
    ">=" "\\geq"
    "!=" "\\neq"
    "~=" "\\approx"
    "+-" "\\pm"
    "-+" "\\mp"
    "xx" "\\times"
    "**" "\\cdot"

    "inn" "\\in"
    "nin" "\\notin"

    "AA" "\\forall"
    "EE" "\\exists"

    "oo" "\\infty"
    "pd" "\\partial"
    "nbl" "\\nabla"

    "sin" "\\sin"
    "cos" "\\cos"
    "tan" "\\tan"
    "log" "\\log"
    "ln" "\\ln"
    "exp" "\\exp"

    "ff" '(tempel
           "\\frac{" p "}{" p "}" q)
    "sq" '(tempel
           "\\sqrt{" p "}" q)

    "sr" "^{2}"
    "cb" "^{3}"

    "sum" '(tempel
            "\\sum_{" (p "i=1") "}^{"
            (p "n") "} " q)

    "prod" '(tempel
             "\\prod_{" (p "i=1") "}^{"
             (p "n") "} " q)

    "int" '(tempel
            "\\int_{" (p "a") "}^{"
            (p "b") "} "
            p
            "\\, d" (p "x") q)

    "lim" '(tempel
            "\\lim_{"
            (p "n") " \\to "
            (p "\\infty")
            "} " q)

    "lr(" '(tempel
            "\\left(" p "\\right)" q)

    "lr[" '(tempel
            "\\left[" p "\\right]" q)

    "lr{" '(tempel
            "\\left\\{" p "\\right\\}" q)

    "lr|" '(tempel
            "\\left|" p "\\right|" q)

    "jk" '(tempel "_{" p "}" q)
    "kj" '(tempel "^{" p "}" q)))

(provide 'init-snippet)
;;; init-snippet.el ends here
