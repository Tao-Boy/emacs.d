;; -*- lexical-binding: t; -*-

(add-hook 'after-init-hook
          (lambda ()
            (set-cursor-color "yellow")
            (set-face-attribute 'default nil :height 150)
            (when (find-font (font-spec :name "Maple Mono NF CN"))
              (set-face-attribute 'default nil :font "Maple Mono NF CN"))))

(provide 'init-font)
