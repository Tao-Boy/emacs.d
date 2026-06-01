;;; init-tex-snippets.el --- LuaSnip LaTeX snippets ported to cdlatex -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; Port of the old Neovim LuaSnip math snippets (see tex/tex.lua) to cdlatex.
;; cdlatex has three relevant mechanisms, all active under `org-cdlatex-mode':
;;
;;   * KEYWORD + TAB   -> `cdlatex-command-alist'  (the bulk; this file)
;;                        TAB is wired to expansion via `tau--org-tab'.
;;   * ; + CHAR        -> `cdlatex-math-symbol-alist'   (Greek & many symbols)
;;   * ' + CHAR        -> `cdlatex-math-modify-alist'   (accents & font styles)
;;   * C-c {           -> `cdlatex-environment'         (environment templates)
;;
;; In a command-alist entry "?" marks where the cursor lands (via
;; `cdlatex-position-cursor'); the trailing two flags are TEXTFLAG and MATHFLAG.
;; Keywords MUST be word characters: `cdlatex-tab' grabs them with
;; `backward-word', so symbol triggers like //, !=, +-, c. cannot be commands.
;;
;; ---------------------------------------------------------------------------
;; ALREADY BUILT INTO cdlatex -- not redefined here, just use them:
;;   Greek:    ;a \alpha  ;b \beta  ;g \gamma  ;d \delta  ;e \epsilon (;ee var)
;;             ;q \theta  ;l \lambda  ;p \pi  ;s \sigma  ;w \omega ... and
;;             ;G \Gamma  ;D \Delta  ;Q \Theta  ;L \Lambda  ;P \Pi  ;S \Sigma
;;             ;F \Phi  ;Y \Psi  ;O \Omega  ;W \Xi  ;U \Upsilon
;;   Accents:  '- bar  '^ hat  '> vec  '. dot  ': ddot  '~ tilde  'v check
;;             'u breve  'o mathring  'T overline  '_ underline  '] overbrace
;;             '} underbrace  'H widehat  'N widetilde
;;   Fonts:    'b mathbf  'c mathcal  'r mathrm  'i mathit  'f mathsf
;;             'y mathtt  'F mathfrak     (added below: 'B mathbb, 's mathscr)
;;   Symbols:  ;. \cdot  ;* \times  ;~ \approx  ;8 \infty  ;+ \cup  ;0 \emptyset
;;             ;! \neg  ;& \wedge  ;^ \uparrow  ;_ \downarrow  ;/ \not
;;             ;\ \setminus  ;| \mapsto  ;= \Leftrightarrow  ;' \prime
;;             ;< / ;> arrows/min/max  ;[ / ;] Leftarrow/Rightarrow
;;             ;{ / ;} subset/supset  ;( / ;) langle/rangle
;;   Delim:    lr( lr[ lr{ lr< lr| + TAB  -> \left..\right pairs
;;   Templates:fr \frac{}{}   sq \sqrt{}   sn \section   ss \subsection
;;
;; ---------------------------------------------------------------------------
;; NOT CONVERTIBLE (cdlatex has no regex/auto/choice triggers) -- alternatives:
;;   * auto subscript  x2 -> x_2          : type `_' then char (cdlatex auto-
;;                                           braces; TAB simplifies a^{2}->a^2)
;;   * regex fractions 3/  a/  \pi/        : use `frac' / `fr' + TAB
;;   * bb(X) -> \mathbb{X}                 : `mbb' + TAB, or 'B
;;   * Xbar  -> \overline{X}               : 'T on the preceding char
;;   * X~    -> \tilde{X}                  : '~ on the preceding char
;;   * == &= , \leq= &\leq (alignment)     : type the & by hand
;;   * b| jk kj ** ++ -- (sub/superscript) : use cdlatex `_' / `^'
;;   * choice nodes (sqrt[n], \vb*, braket 3-arg, \section*) : primary form only
;;     (extra keyword `sqn' gives \sqrt[]{}; star/3-arg variants typed by hand)
;;   * \Alpha \Beta \Zeta \Eta \Iota \Kappa \Mu \Nu \Rho \Tau \Chi : invalid
;;     LaTeX (identical to Latin letters) -- dropped; use ;G etc. for real ones
;;
;; Many replacements assume the user preamble (physics, siunitx, custom macros:
;; \grad \curl \div \laplacian \vb \vu \bra \ket \braket \dyad \pdv \Aut \Gal
;; \rank \Vol \tr \SI \complexqty \cond \conv \mod \d \Sch \ed ...). Kept as-is.
;;
;; After editing this file in a running Emacs, run `M-x cdlatex-reset-mode'
;; (or restart) so cdlatex rebuilds its combined tables.

;;; Code:

(setq cdlatex-command-alist
      '(;; --- relations / binary operators ---
        ("neq"      "\\neq"        "\\neq"        nil nil nil t)
        ("approx"   "\\approx"     "\\approx"     nil nil nil t)
        ("sim"      "\\sim"        "\\sim"        nil nil nil t)
        ("geq"      "\\geq"        "\\geq"        nil nil nil t)
        ("leq"      "\\leq"        "\\leq"        nil nil nil t)
        ("gg"       "\\gg"         "\\gg"         nil nil nil t)
        ("ll"       "\\ll"         "\\ll"         nil nil nil t)
        ("eqv"      "\\equiv"      "\\equiv"      nil nil nil t)
        ("pm"       "\\pm"         "\\pm"         nil nil nil t)
        ("mp"       "\\mp"         "\\mp"         nil nil nil t)
        ("xx"       "\\times"      "\\times"      nil nil nil t)
        ("cir"      "\\circ"       "\\circ"       nil nil nil t)
        ("ot"       "\\otimes"     "\\otimes"     nil nil nil t)
        ("op"       "\\oplus"      "\\oplus"      nil nil nil t)
        ("cdot"     "\\cdot"       "\\cdot"       nil nil nil t)
        ("odot"     "\\odot"       "\\odot"       nil nil nil t)
        ("diamond"  "\\diamond"    "\\diamond"    nil nil nil t)
        ("setminus" "\\setminus"   "\\setminus"   nil nil nil t)
        ("dots"     "\\dots"       "\\dots"       nil nil nil t)
        ("cdots"    "\\cdots"      "\\cdots"      nil nil nil t)
        ("vdots"    "\\vdots"      "\\vdots"      nil nil nil t)
        ("vdot"     "\\vdot"       "\\vdot"       nil nil nil t)

        ;; --- logic / sets / arrows ---
        ("iff"      "\\iff"        "\\iff"        nil nil nil t)
        ("implies"  "\\implies"    "\\implies"    nil nil nil t)
        ("inn"      "\\in"         "\\in"         nil nil nil t)
        ("notin"    "\\notin"      "\\notin"      nil nil nil t)
        ("aa"       "\\forall"     "\\forall"     nil nil nil t)
        ("ee"       "\\exists"     "\\exists"     nil nil nil t)
        ("land"     "\\land"       "\\land"       nil nil nil t)
        ("lor"      "\\lor"        "\\lor"        nil nil nil t)
        ("to"       "\\to"         "\\to"         nil nil nil t)
        ("mto"      "\\mapsto"     "\\mapsto"     nil nil nil t)
        ("get"      "\\gets"       "\\gets"       nil nil nil t)
        ("up"       "\\uparrow"    "\\uparrow"    nil nil nil t)
        ("down"     "\\downarrow"  "\\downarrow"  nil nil nil t)
        ("mid"      "\\mid"        "\\mid"        nil nil nil t)
        ("cap"      "\\cap"        "\\cap"        nil nil nil t)
        ("cup"      "\\cup"        "\\cup"        nil nil nil t)
        ("sub"      "\\subset"     "\\subset"     nil nil nil t)
        ("emp"      "\\emptyset"   "\\emptyset"   nil nil nil t)

        ;; --- misc symbols ---
        ("oo"       "\\infty"      "\\infty"      nil nil nil t)
        ("perp"     "\\perp"       "\\perp"       nil nil nil t)
        ("hbar"     "\\hbar"       "\\hbar"       nil nil nil t)
        ("ell"      "\\ell"        "\\ell"        nil nil nil t)
        ("ns"       "\\unlhd"      "\\unlhd"      nil nil nil t)
        ("par"      "\\partial"    "\\partial"    nil nil nil t)
        ("nabla"    "\\nabla"      "\\nabla"      nil nil nil t)
        ("neg"      "\\neg"        "\\neg"        nil nil nil t)
        ("po"       "\\propto"     "\\propto"     nil nil nil t)

        ;; --- superscript shortcuts ---
        ("sr"       "^2"           "^2"           nil nil nil t)
        ("cb"       "^3"           "^3"           nil nil nil t)
        ("inv"      "^{-1}"        "^{-1}"        nil nil nil t)
        ("tp"       "^\\top"       "^\\top"       nil nil nil t)
        ("dr"       "^\\dagger"    "^\\dagger"    nil nil nil t)
        ("cc"       "^c"           "^c"           nil nil nil t)
        ("jk"       "_{}"          "_{?}"         cdlatex-position-cursor nil nil t)
        ("kj"       "^{}"          "^{?}"         cdlatex-position-cursor nil nil t)

        ;; --- math fonts (cursor inside) ---
        ("msf"      "\\mathsf{}"   "\\mathsf{?}"  cdlatex-position-cursor nil nil t)
        ("bm"       "\\bm{}"       "\\bm{?}"      cdlatex-position-cursor nil nil t)
        ("bf"       "\\mathbf{}"   "\\mathbf{?}"  cdlatex-position-cursor nil nil t)
        ("cal"      "\\mathcal{}"  "\\mathcal{?}" cdlatex-position-cursor nil nil t)
        ("scr"      "\\mathscr{}"  "\\mathscr{?}" cdlatex-position-cursor nil nil t)
        ("mbb"      "\\mathbb{}"   "\\mathbb{?}"  cdlatex-position-cursor nil nil t)
        ("mrm"      "\\mathrm{}"   "\\mathrm{?}"  cdlatex-position-cursor nil nil t)

        ;; --- text fonts (text mode) ---
        ("tit"      "\\textit{}"   "\\textit{?}"  cdlatex-position-cursor nil t nil)
        ("ttt"      "\\texttt{}"   "\\texttt{?}"  cdlatex-position-cursor nil t nil)
        ("tbf"      "\\textbf{}"   "\\textbf{?}"  cdlatex-position-cursor nil t nil)
        ("eph"      "\\emph{}"     "\\emph{?}"    cdlatex-position-cursor nil t nil)

        ;; --- calligraphic shortcuts ---
        ("PP"       "\\mathcal{P}"  "\\mathcal{P}"  nil nil nil t)
        ("SS"       "\\mathcal{S}"  "\\mathcal{S}"  nil nil nil t)
        ("LL"       "\\mathcal{L}"  "\\mathcal{L}"  nil nil nil t)
        ("FF"       "\\mathscr{F}"  "\\mathscr{F}"  nil nil nil t)
        ("IS"       "\\mathcal{IS}" "\\mathcal{IS}" nil nil nil t)

        ;; --- trig / functions / operators ---
        ("sin"  "\\sin" "\\sin" nil nil nil t) ("asin" "\\arcsin" "\\arcsin" nil nil nil t)
        ("cos"  "\\cos" "\\cos" nil nil nil t) ("acos" "\\arccos" "\\arccos" nil nil nil t)
        ("tan"  "\\tan" "\\tan" nil nil nil t) ("atan" "\\arctan" "\\arctan" nil nil nil t)
        ("cot"  "\\cot" "\\cot" nil nil nil t) ("acot" "\\arccot" "\\arccot" nil nil nil t)
        ("csc"  "\\csc" "\\csc" nil nil nil t) ("acsc" "\\arccsc" "\\arccsc" nil nil nil t)
        ("sec"  "\\sec" "\\sec" nil nil nil t) ("asec" "\\arcsec" "\\arcsec" nil nil nil t)
        ("log"  "\\log" "\\log" nil nil nil t)
        ("ln"   "\\ln"  "\\ln"  nil nil nil t)
        ("exp"  "\\exp" "\\exp" nil nil nil t)
        ("grad" "\\grad" "\\grad" nil nil nil t)
        ("curl" "\\curl" "\\curl" nil nil nil t)
        ("div"  "\\div"  "\\div"  nil nil nil t)
        ("lap"  "\\laplacian" "\\laplacian" nil nil nil t)
        ("min"  "\\min" "\\min" nil nil nil t)
        ("max"  "\\max" "\\max" nil nil nil t)
        ("sup"  "\\sup" "\\sup" nil nil nil t)
        ("inf"  "\\inf" "\\inf" nil nil nil t)
        ("det"  "\\operatorname{det}"  "\\operatorname{det}"  nil nil nil t)
        ("dim"  "\\operatorname{dim}"  "\\operatorname{dim}"  nil nil nil t)
        ("tr"   "\\tr"  "\\tr"  nil nil nil t)
        ("kk"   "\\operatorname{ker}"  "\\operatorname{ker}"  nil nil nil t)
        ("deg"  "\\operatorname{deg}"  "\\operatorname{deg}"  nil nil nil t)
        ("spp"  "\\operatorname{supp}" "\\operatorname{supp}" nil nil nil t)
        ("imm"  "\\operatorname{im}"   "\\operatorname{im}"   nil nil nil t)
        ("span" "\\operatorname{span}" "\\operatorname{span}" nil nil nil t)
        ("aut"  "\\Aut"  "\\Aut"  nil nil nil t)
        ("gal"  "\\Gal"  "\\Gal"  nil nil nil t)
        ("rank" "\\rank" "\\rank" nil nil nil t)
        ("vol"  "\\Vol"  "\\Vol"  nil nil nil t)
        ("pr"   "\\Pr"   "\\Pr"   nil nil nil t)
        ("sch"  "\\Sch"  "\\Sch"  nil nil nil t)

        ;; --- blackboard sets ---
        ("bbr" "\\mathbb{R}" "\\mathbb{R}" nil nil nil t)
        ("bbq" "\\mathbb{Q}" "\\mathbb{Q}" nil nil nil t)
        ("bbh" "\\mathbb{H}" "\\mathbb{H}" nil nil nil t)
        ("bbc" "\\mathbb{C}" "\\mathbb{C}" nil nil nil t)
        ("bbz" "\\mathbb{Z}" "\\mathbb{Z}" nil nil nil t)
        ("bbn" "\\mathbb{N}" "\\mathbb{N}" nil nil nil t)
        ("bbe" "\\mathbb{E}" "\\mathbb{E}" nil nil nil t)
        ("bb1" "\\mathbbm{1}" "\\mathbbm{1}" nil nil nil t)

        ;; --- accents (prefer ' modify; these are word-typed alternatives) ---
        ("bar"  "\\bar{}"       "\\bar{?}"        cdlatex-position-cursor nil nil t)
        ("hat"  "\\hat{}"       "\\hat{?}"        cdlatex-position-cursor nil nil t)
        ("vec"  "\\vec{}"       "\\vec{?}"        cdlatex-position-cursor nil nil t)
        ("dot"  "\\dot{}"       "\\dot{?}"        cdlatex-position-cursor nil nil t)
        ("doo"  "\\ddot{}"      "\\ddot{?}"       cdlatex-position-cursor nil nil t)
        ("td"   "\\tilde{}"     "\\tilde{?}"      cdlatex-position-cursor nil nil t)
        ("ring" "\\mathring{}"  "\\mathring{?}"   cdlatex-position-cursor nil nil t)
        ("ob"   "\\overbrace{}^{}"  "\\overbrace{?}^{}"  cdlatex-position-cursor nil nil t)
        ("ub"   "\\underbrace{}"    "\\underbrace{?}"    cdlatex-position-cursor nil nil t)

        ;; --- fractions / roots / big operators / integrals / limits ---
        ("frac" "\\frac{}{}"   "\\frac{?}{}"   cdlatex-position-cursor nil nil t)
        ("sqn"  "\\sqrt[]{}"   "\\sqrt[?]{}"   cdlatex-position-cursor nil nil t)
        ("sum"  "\\sum_{}^{}"  "\\sum_{?}^{}"  cdlatex-position-cursor nil nil t)
        ("pd"   "\\prod_{}^{}" "\\prod_{?}^{}" cdlatex-position-cursor nil nil t)
        ("lim"  "\\lim_{}"     "\\lim_{?}"     cdlatex-position-cursor nil nil t)
        ("lsup" "\\limsup_{}"  "\\limsup_{?}"  cdlatex-position-cursor nil nil t)
        ("linf" "\\liminf_{}"  "\\liminf_{?}"  cdlatex-position-cursor nil nil t)
        ("bot"  "\\bigotimes_{}^{}" "\\bigotimes_{?}^{}" cdlatex-position-cursor nil nil t)
        ("bcap" "\\bigcap_{}^{}"    "\\bigcap_{?}^{}"    cdlatex-position-cursor nil nil t)
        ("bcup" "\\bigcup_{}^{}"    "\\bigcup_{?}^{}"    cdlatex-position-cursor nil nil t)
        ("ii"   "\\int"  "\\int"  nil nil nil t)
        ("oii"  "\\oint" "\\oint" nil nil nil t)
        ("int"  "\\int_{}^{}"  "\\int_{?}^{}"  cdlatex-position-cursor nil nil t)
        ("oint" "\\oint_{}^{}" "\\oint_{?}^{}" cdlatex-position-cursor nil nil t)
        ("iint" "\\iint_{}^{}" "\\iint_{?}^{}" cdlatex-position-cursor nil nil t)
        ("lint" "\\int_{}"     "\\int_{?}"     cdlatex-position-cursor nil nil t)
        ("2int" "\\int_{}^{}\\int_{}^{}" "\\int_{?}^{}\\int_{}^{}" cdlatex-position-cursor nil nil t)
        ("dd"   "\\d "   "\\d "   nil nil nil t)

        ;; --- physics: bra-ket, vectors, derivatives, delimiters ---
        ("bra" "\\bra{}"       "\\bra{?}"       cdlatex-position-cursor nil nil t)
        ("ket" "\\ket{}"       "\\ket{?}"       cdlatex-position-cursor nil nil t)
        ("bk"  "\\braket{}{}"  "\\braket{?}{}"  cdlatex-position-cursor nil nil t)
        ("kb"  "\\dyad{}{}"    "\\dyad{?}{}"    cdlatex-position-cursor nil nil t)
        ("vb"  "\\vb{}"        "\\vb{?}"        cdlatex-position-cursor nil nil t)
        ("vu"  "\\vu{}"        "\\vu{?}"        cdlatex-position-cursor nil nil t)
        ("pv"  "\\pdv{}{}"     "\\pdv{?}{}"     cdlatex-position-cursor nil nil t)
        ("lrs" "{\\left( \\right)}"     "{\\left( ? \\right)}"     cdlatex-position-cursor nil nil t)
        ("lrb" "{\\left\\{ \\right\\}}" "{\\left\\{ ? \\right\\}}" cdlatex-position-cursor nil nil t)
        ("lrm" "{\\left[ \\right]}"     "{\\left[ ? \\right]}"     cdlatex-position-cursor nil nil t)
        ("lra" "\\left\\langle \\right\\rangle" "\\left\\langle ? \\right\\rangle" cdlatex-position-cursor nil nil t)
        ("vab" "\\|\\|"        "\\|?\\|"        cdlatex-position-cursor nil nil t)
        ("bv"  "\\bigg\\vert"  "\\bigg\\vert"   nil nil nil t)

        ;; --- modulo / units / misc macros ---
        ("mod"  "\\mod{}"  "\\mod{?}"  cdlatex-position-cursor nil nil t)
        ("bmod" "\\bmod{}" "\\bmod{?}" cdlatex-position-cursor nil nil t)
        ("nmod" "\\nmod{}" "\\nmod{?}" cdlatex-position-cursor nil nil t)
        ("pmod" "\\pmod{}" "\\pmod{?}" cdlatex-position-cursor nil nil t)
        ("SI"   "\\SI{}{}" "\\SI{?}{}" cdlatex-position-cursor nil nil t)
        ("cond" "\\cond()" "\\cond(?)" cdlatex-position-cursor nil nil t)
        ("cqty" "\\complexqty{}{}" "\\complexqty{?}{}" cdlatex-position-cursor nil nil t)
        ("cv"   "\\conv"   "\\conv"   nil nil nil t)
        ("ang"  "\\angle " "\\angle " nil nil nil t)
        ("ed"   "\\ed"     "\\ed"     nil nil nil t)
        ("lhs"  "\\mathrm{L.H.S}" "\\mathrm{L.H.S}" nil nil nil t)
        ("rhs"  "\\mathrm{R.H.S}" "\\mathrm{R.H.S}" nil nil nil t)

        ;; --- environment shortcuts (templates in cdlatex-env-alist below) ---
        ("bmat" "bmatrix"   "" cdlatex-environment ("bmatrix") nil t)
        ("Bmat" "Bmatrix"   "" cdlatex-environment ("Bmatrix") nil t)
        ("pmat" "pmatrix"   "" cdlatex-environment ("pmatrix") nil t)
        ("vmat" "vmatrix"   "" cdlatex-environment ("vmatrix") nil t)
        ("Vmat" "Vmatrix"   "" cdlatex-environment ("Vmatrix") nil t)
        ("case" "cases"     "" cdlatex-environment ("cases")   nil t)
        ("bal"  "align*"    "" cdlatex-environment ("align*")  t nil)
        ("bit"  "itemize"   "" cdlatex-environment ("itemize") t nil)
        ("ben"  "enumerate" "" cdlatex-environment ("enumerate") t nil)
        ("bcr"  "center"    "" cdlatex-environment ("center")  t nil)
        ("im"   "\\item"    "\\item " nil nil t nil)
        ("cha"  "\\chapter{}" "\\chapter{?}" cdlatex-position-cursor nil t nil)

        ;; --- identity matrices (fixed templates) ---
        ("II3" "3x3 identity"
         "\\begin{bmatrix}\n1 & & \\\\\n & 1 & \\\\\n & & 1\n\\end{bmatrix}"
         nil nil nil t)
        ("II4" "4x4 identity"
         "\\begin{bmatrix}\n1 & & & \\\\\n & 1 & & \\\\\n & & 1 & \\\\\n & & & 1\n\\end{bmatrix}"
         nil nil nil t)
        ("II5" "5x5 identity"
         "\\begin{bmatrix}\n1 & & & & \\\\\n & 1 & & & \\\\\n & & 1 & & \\\\\n & & & 1 & \\\\\n & & & & 1\n\\end{bmatrix}"
         nil nil nil t)
        ("II6" "6x6 identity"
         "\\begin{bmatrix}\n1 & & & & & \\\\\n & 1 & & & & \\\\\n & & 1 & & & \\\\\n & & & 1 & & \\\\\n & & & & 1 & \\\\\n & & & & & 1\n\\end{bmatrix}"
         nil nil nil t)))

;; Accents/fonts missing from cdlatex defaults, on the ' prefix.
(setq cdlatex-math-modify-alist
      '((?B "\\mathbb"  nil t nil nil)
        (?s "\\mathscr" nil t nil nil)))

;; Environment templates used by the *mat / case / bal ... command shortcuts
;; and by C-c {.  "?" is the cursor; the third element is the \item template.
(setq cdlatex-env-alist
      '(("bmatrix" "\\begin{bmatrix}\n?\n\\end{bmatrix}" nil)
        ("Bmatrix" "\\begin{Bmatrix}\n?\n\\end{Bmatrix}" nil)
        ("pmatrix" "\\begin{pmatrix}\n?\n\\end{pmatrix}" nil)
        ("vmatrix" "\\begin{vmatrix}\n?\n\\end{vmatrix}" nil)
        ("Vmatrix" "\\begin{Vmatrix}\n?\n\\end{Vmatrix}" nil)
        ("cases"   "\\begin{cases}\n?\n\\end{cases}" nil)
        ("align*"  "\\begin{align*}\n?\n\\end{align*}" nil)
        ("itemize" "\\begin{itemize}\n\\item ?\n\\end{itemize}" "\\item ?")))

(provide 'init-tex-snippets)
;;; init-tex-snippets.el ends here
