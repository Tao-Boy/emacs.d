;; -*- lexical-binding: t; -*-

(setq corfu-auto t
      corfu-auto-delay 0
      corfu-auto-prefix 1
      corfu-quit-no-match 'separator)

(add-hook 'prog-mode-hook #'corfu-mode)

(with-eval-after-load 'corfu
  (define-key corfu-map (kbd "TAB") nil)
  (define-key corfu-map (kbd "RET") 'corfu-insert))

(require 'vertico)

;; Fido/icomplete and Vertico are mutually exclusive: both install
;; themselves into the minibuffer, which results in duplicated
;; candidates and broken completion.  `init-org.el' may have enabled
;; Fido as a fallback, so make sure the built-in UI is off again before
;; activating Vertico.
(when (fboundp 'fido-mode)
  (fido-mode -1))
(when (fboundp 'fido-vertical-mode)
  (fido-vertical-mode -1))
(when (bound-and-true-p icomplete-mode)
  (icomplete-mode -1))

(vertico-mode 1)
(setq vertico-cycle t)
(setq vertico-count 8)

(require 'orderless)
(setq completion-styles '(orderless basic)
      completion-category-defaults nil
      completion-category-overrides
      '((file (styles partial-completion))))

(require 'marginalia)
(marginalia-mode 1)

(provide 'init-completion)
