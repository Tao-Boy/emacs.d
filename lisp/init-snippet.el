;; -*- lexical-binding: t; -*-

(add-hook 'org-mode-hook #'aas-activate-for-major-mode)

(with-eval-after-load 'tempel
  (define-key tempel-map (kbd "TAB") #'tempel-next)
  (define-key tempel-map (kbd "<tab>") #'tempel-next)
  (define-key tempel-map (kbd "<backtab>") #'tempel-previous)
  (define-key tempel-map (kbd "S-TAB") #'tempel-previous))

(with-eval-after-load 'aas
  (aas-set-snippets 'org-mode
    :cond (lambda () (not (org-inside-LaTeX-fragment-p)))
    "mk" '(tempel "\\(" p "\\)" q)
    "dm" '(tempel
           "\\[" n>
           p
           n "\\]" q)

    :cond #'org-inside-LaTeX-fragment-p
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

					;    "->" "\\to"
					;    "<-" "\\leftarrow"
					;    "=>" "\\implies"
					;    "=<" "\\impliedby"
					;    "<=>" "\\iff"

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
    "kj" '(tempel "^{" p "}" q)
    ))

(provide 'init-snippet)
