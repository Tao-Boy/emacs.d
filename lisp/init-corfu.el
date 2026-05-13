;; -*- lexical-binding: t; -*-

(setq corfu-auto t
      corfu-auto-delay 0
      corfu-auto-prefix 1
      corfu-quit-no-match 'separator)

(add-hook 'prog-mode-hook #'corfu-mode)

(with-eval-after-load 'corfu
  (define-key corfu-map (kbd "TAB") nil)
  (define-key corfu-map (kbd "RET") 'corfu-insert))

(provide 'init-corfu)
