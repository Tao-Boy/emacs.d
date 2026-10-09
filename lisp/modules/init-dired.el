;;; init-dired.el --- Dired configuration on first visit -*- lexical-binding: t; -*-

(defvar dired-recursive-copies)
(defvar dired-recursive-deletes)
(defvar dired-dwim-target)
(defvar dired-auto-revert-buffer)
(defvar dired-omit-files)
(declare-function dired-omit-mode "dired-x" (&optional arg))

(setq dired-recursive-copies 'always
      dired-recursive-deletes 'always
      dired-dwim-target t
      delete-by-moving-to-trash t
      dired-auto-revert-buffer t)
(put 'dired-find-alternate-file 'disabled nil)
(with-eval-after-load 'dired
  (require 'dired-x)
  (setq dired-omit-files
        (concat dired-omit-files "\\|^\\.DS_Store$\\|^\\.git$"))
  (add-hook 'dired-mode-hook #'dired-omit-mode))

(provide 'init-dired)
;;; init-dired.el ends here
