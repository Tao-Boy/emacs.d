;; -*- lexical-binding: t; -*-

(blink-cursor-mode -1)
(add-hook 'prog-mode-hook #'electric-pair-mode)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

(load-theme 'wombat)

(setq read-process-output-max (* 4 1024 1024))
(setq process-adaptive-read-buffering nil)

(provide 'init-generic)
