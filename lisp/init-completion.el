;;; init-completion.el --- Built-in completion -*- lexical-binding: t; -*-

;;; Commentary:

;; Fido provides a vertical minibuffer with flex matching.  Completion
;; Preview shows in-buffer suggestions from the usual completion-at-point
;; backends, including Eglot.  Both are part of Emacs.

;;; Code:

(setq completion-ignore-case t
      read-file-name-completion-ignore-case t
      read-buffer-completion-ignore-case t
      completion-styles '(flex basic)
      completion-category-overrides '((file (styles partial-completion)))
      completion-pcm-leading-wildcard t     ; Emacs 31: substring file matching.
      text-mode-ispell-word-completion nil)

;;;; Minibuffer

(use-package icomplete
  :hook (tau-first-input . fido-vertical-mode)
  :custom
  (icomplete-compute-delay 0)
  (icomplete-prospects-height 8))

;;;; In-buffer completion

(use-package completion-preview
  :hook (prog-mode . completion-preview-mode)
  :custom
  (completion-preview-minimum-symbol-length 2)
  (completion-preview-idle-delay 0.1)
  :bind (:map completion-preview-active-mode-map
              ("M-n" . completion-preview-next-candidate)
              ("M-p" . completion-preview-prev-candidate)))

(provide 'init-completion)
;;; init-completion.el ends here
