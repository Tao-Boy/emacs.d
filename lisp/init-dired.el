;;; init-dired.el --- Directory editor -*- lexical-binding: t; -*-

;;; Commentary:

;; Dired and Dired-X are configured lazily; nothing loads until the
;; first Dired buffer.

;;; Code:

(use-package dired
  :defer t
  :custom
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'always)
  (dired-dwim-target t)
  (dired-auto-revert-buffer t)
  (dired-listing-switches (if sys/linuxp
                              "-alh --group-directories-first"
                            "-alh"))
  :config
  (put 'dired-find-alternate-file 'disabled nil))

(use-package dired-x
  :hook (dired-mode . dired-omit-mode)
  :config
  (setq dired-omit-files
        (concat dired-omit-files "\\|^\\.DS_Store\\'\\|^\\.git\\'")))

(provide 'init-dired)
;;; init-dired.el ends here
