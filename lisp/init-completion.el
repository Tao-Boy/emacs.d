;;; init-completion.el --- Vertico, Orderless and Consult -*- lexical-binding: t; -*-

;;; Commentary:

;; Vertico displays minibuffer candidates, Orderless matches them, and
;; Consult provides navigation commands and the completion-at-point UI.
;; TAB indents first, then offers major-mode/Eglot completions through
;; the minibuffer.  Completion Preview is not enabled.

;;; Code:

(setq completion-ignore-case t
      read-file-name-completion-ignore-case t
      read-buffer-completion-ignore-case t
      text-mode-ispell-word-completion nil
      tab-always-indent 'complete)

;;;; Minibuffer

(use-package vertico
  :ensure t
  :hook (tau-first-input . vertico-mode)
  :custom
  (vertico-cycle t)
  (vertico-count 8))

(use-package orderless
  :ensure t
  :defer t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-pcm-leading-wildcard t))       ; Emacs 31: substring file matching.

;;;; Navigation and in-buffer completion

(use-package consult
  :ensure t
  :defer t
  :commands consult-completion-in-region
  :bind (([remap switch-to-buffer] . consult-buffer)
         ([remap recentf-open] . consult-recent-file)
         ([remap yank-pop] . consult-yank-pop)
         ([remap goto-line] . consult-goto-line)
         ("M-g l" . consult-line)
         ("C-c s" . consult-ripgrep))
  :init
  (setq completion-in-region-function #'consult-completion-in-region))

(provide 'init-completion)
;;; init-completion.el ends here
