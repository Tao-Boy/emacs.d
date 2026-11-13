;;; init-completion.el --- Built-in completion -*- lexical-binding: t; -*-

;;; Commentary:

;; Fido provides a vertical minibuffer with flex matching.  TAB indents
;; first, then uses the major mode's completion-at-point backends,
;; including Eglot.  Completion Preview is not enabled.

;;; Code:

(setq completion-ignore-case t
      read-file-name-completion-ignore-case t
      read-buffer-completion-ignore-case t
      completion-styles '(flex basic)
      completion-category-overrides '((file (styles partial-completion)))
      completion-pcm-leading-wildcard t     ; Emacs 31: substring file matching.
      text-mode-ispell-word-completion nil
      tab-always-indent 'complete
      completion-auto-help 'always)

;;;; Minibuffer

(use-package icomplete
  :hook (tau-first-input . fido-vertical-mode)
  :custom
  (icomplete-compute-delay 0)
  (icomplete-prospects-height 8))

(provide 'init-completion)
;;; init-completion.el ends here
