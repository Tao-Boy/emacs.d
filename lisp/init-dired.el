;; -*- lexical-binding: t; -*-

(require 'dired)
(require 'dired-x)

(setq dired-recursive-copies 'always
      dired-recursive-deletes 'always
      dired-dwim-target t
      delete-by-moving-to-trash t
      dired-auto-revert-buffer t)

(put 'dired-find-alternate-file 'disabled nil)

(add-hook 'dired-mode-hook #'dired-omit-mode)

(setq dired-omit-files
      (concat dired-omit-files
              "\\|^\\.DS_Store$"
              "\\|^\\.git$"))

(provide 'init-dired)
