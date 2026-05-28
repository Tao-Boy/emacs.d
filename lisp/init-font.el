;; -*- lexical-binding: t; -*-

(add-hook 'after-init-hook
          (lambda ()
            (set-cursor-color "yellow")
            (set-face-attribute 'default nil :height 150 :font "Maple Mono NF CN")))

(provide 'init-font)
