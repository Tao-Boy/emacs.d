;;; init-rime.el --- Chinese input with Tao-Boy/rimel -*- lexical-binding: t; -*-

;;; Commentary:

;; Install Tao-Boy/rimel from GitHub, rather than the unrelated MELPA
;; package with the same name.  Its own C module is compiled on first
;; activation; librime development files and Rime schemas are required.
;; The input method and candidate UI remain lazy until first use.

;;; Code:

(use-package posframe
  :ensure t
  :defer t)

(use-package rimel
  :vc (:url "https://github.com/Tao-Boy/rimel.git" :rev :newest)
  :defer t
  :bind (("C-c r s" . rimel-select-schema)
         ("C-c r a" . rimel-toggle-ascii-mode)
         ("C-c r f" . rimel-force-rime)
         ("C-c r d" . rimel-deploy))
  :init
  (setq default-input-method "rimel")
  :custom
  ;; The library falls back to the minibuffer on terminals.
  (rimel-candidate-style 'posframe)
  ;; Keep English in Evil command states, code, after Latin letters or
  ;; digits, for capitals, in Org source blocks and in math.
  (rimel-probes '(rimel-probe-evil-non-insert
                  rimel-probe-program
                  rimel-probe-after-alphanumeric
                  rimel-probe-uppercase
                  rimel-probe-org
                  rimel-probe-tex-math)))

(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements "C-c r" "rime"))

(provide 'init-rime)
;;; init-rime.el ends here
