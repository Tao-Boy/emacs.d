;;; init-completion.el --- Minibuffer and in-buffer completion -*- lexical-binding: t; -*-

;;; Commentary:

;; Vertico + Orderless + Marginalia in the minibuffer, Corfu in
;; buffers.  The minibuffer UI is enabled right before the first
;; command instead of during startup.

;;; Code:

(setq completion-ignore-case t
      read-file-name-completion-ignore-case t
      read-buffer-completion-ignore-case t
      ;; Emacs 30: don't offer dictionary words in `text-mode' buffers.
      text-mode-ispell-word-completion nil)

;;;; Minibuffer

(use-package vertico
  :ensure t
  :hook (tau-first-input . vertico-mode)
  :custom
  (vertico-cycle t)
  (vertico-count 8))

;; The `orderless' style is registered by the package autoloads, so
;; the library itself loads on the first completion.
(use-package orderless
  :ensure t
  :defer t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion))))
  ;; Emacs 31: let `partial-completion' match substrings as well.
  (completion-pcm-leading-wildcard t))

(use-package marginalia
  :ensure t
  :hook (tau-first-input . marginalia-mode))

;;;; In-buffer completion

;; On Emacs 31 Corfu also pops up in terminals, using TTY child frames.
(use-package corfu
  :ensure t
  :hook (prog-mode . corfu-mode)
  :custom
  (corfu-auto t)
  ;; A small delay and a two-character prefix avoid running every
  ;; completion backend on each keystroke.
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 2)
  (corfu-quit-no-match 'separator)
  :bind (:map corfu-map
              ("TAB" . nil)            ; Keep TAB for indentation.
              ("RET" . corfu-insert)))

(provide 'init-completion)
;;; init-completion.el ends here
