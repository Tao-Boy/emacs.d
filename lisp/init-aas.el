;; -*- lexical-binding: t; -*-

(with-eval-after-load 'tempel
  (define-key tempel-map (kbd "TAB") #'tempel-next)
  (define-key tempel-map (kbd "<backtab>") #'tempel-previous))

(with-eval-after-load 'org
  (require 'aas)
  (aas-set-snippets 'org-mode
    ",," '(tempel "\\(" p "\\)")
    ";;" '(tempel "\\[" n> r> n "\\]")
    :cond #'texmathp
    ";A" "\\Alpha"
    ";a" "\\alpha"
    ";b" "\\beta"
    ";B" "\\Beta"
    ";g" "\\gamma"
    ";G" "\\Gamma"
    ";d" "\\delta"
    ";D" "\\Delta"
    "eps" "\\epsilon"
    "vps" "\\varepsilon"
    "Eps" "\\Epsilon"
    "eta" "\\eta"
    "Eta" "\\Eta"
    ";z" "\\zeta"
    ";Z" "\\Zeta"
    ";t" "\\theta"
    ";T" "\\Theta"
    "iot" "\\iota"
    "Iot" "\\Iota"
    "kap" "\\kappa"
    "Kap" "\\Kappa"
    "lam" "\\lambda"
    "Lam" "\\Lambda"
    "mu" "\\mu"
    "Mu" "\\Mu"
    "nu" "\\nu"
    "Nu" "\\Nu"
    "pi" "\\pi"
    "Pi" "\\Pi"
    "rho" "\\rho"
    "Rho" "\\Rho"
    ";s" "\\sigma"
    ";S" "\\Sigma"
    "tau" "\\tau"
    "Tau" "\\Tau"
    "ups" "\\ups"
    "Ups" "\\Ups"
    "phi" "\\phi"
    "Phi" "\\Phi"
    "vhi" "\\varphi"
    "Vhi" "\\Varphi"
    "chi" "\\chi"
    "Chi" "\\Chi"
    "psi" "\\psi"
    "Psi" "\\Psi"
    ";o" "\\omega"
    ";O" "\\Omega"
    "sin" "\\sin"
    "asin" "\\arcsin"
    "cos" "\\cos"
    "acos" "\\arccos"
    "tan" "\\tan"
    "atan" "\\arctan"
    "cot" "\\cot"
    "acot" "\\arccot"
    "csc" "\\csc"
    "acsc" "\\arccsc"
    "sec" "\\sec"
    "asec" "\\arcsec"
    "log" "\\log"
    "ln" "\\ln"
    "exp" "\\exp"
    "min" "\\min"
    "max" "\\max"
    "dd" "\\d"
    "tr" "\\tr"
    "bar" '(tempel "\\bar{" p "}")
    "td" '(tempel "\\tilde{" p "}")
    "dot" '(tempel "\\dot{" p "}")
    "doo" '(tempel "\\ddot{" p "}")
    "hat" '(tempel "\\hat{" p "}")
    "vec" '(tempel "\\vec{" p "}")
    "ob" '(tempel "\\overbrace{" p "}^{" p "}")
    "ub" '(tempel "\\underbrace{" p "}_{" p "}")
    "sq" '(tempel "\\sqrt{" p "}")
    "bra" '(tempel "\\bra{" p "}")
    "ket" '(tempel "\\ket{" p "}")
    "lrs" '(tempel "{\\left( " p " \\right)}")
    "lrb" '(tempel "{\\left\\{ " p " \\right\\}}")
    "lrm" '(tempel "{\\left[ " p " \\right]}")
    "lr<" '(tempel "\\left\\langle " p " \\right\\rangle")
    "lr|" '(tempel "\\left|" p "\\right|")
    "sup" "\\sup"
    "inf" "\\inf"
    "oo" "\\infity"
    "RR" "\\mathbb{R}"
    "lim" '(tempel "\\lim_{" p "}")
    "lsup" '(tempel "\\limsup_{" p "}")
    "linf" '(tempel "\\liminf_{" p "}")
    "sum" '(tempel "\\sum_{" p "}^{" p "}")
    "pd" '(tempel "\\prod_{" p "}")
    "bot" '(tempel "\\bigotimes_{" p "}^{" p "}")
    "bcap" '(tempel "\\bigcap_{" p "}^{" p "}")
    "bcup" '(tempel "\\bigcup_{" p "}^{" p "}")
    "int" '(tempel "\\int_{" p "}^{" p "} " p " \\d " p "")
    "oint" '(tempel "\\oint_{" p "}^{" p "} " p " \\d " p "")
    "2int" '(tempel "\\int_{" p "}^{" p "}\\int_{" p "}^{" p "} " p " \\d " p "\\d " p "")
    "aa" "\\forall"
    "inn" "\\in"
    "ee" "\\exists"
    "ell" "\\ell"
    "sr" "^2"
    "cb" "^3"
    "ivs" "^{-1}"
    "//" '(tempel "\\frac{" p "}{" p "}")
    "jk" '(tempel "_{" p "}")
    "kj" '(tempel "^{" p "}")
    "lrs" '(tempel "\\left(" p "\\right)")
    "dag" "^{\\dagger}"
    "ket" '(tempel "\\ket{" p "}")
    "bra" '(tempel "\\bra{" p "}")))

(add-hook 'org-mode-hook #'aas-activate-for-major-mode)

(provide 'init-aas)
;; init-aas.el ends here
