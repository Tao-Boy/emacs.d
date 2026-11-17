;;; init-keybindings.el --- Native Emacs bindings -*- lexical-binding: t; -*-

;;; Code:

(use-package repeat
  :hook (tau-first-input . repeat-mode))

(use-package delsel
  :hook (tau-first-input . delete-selection-mode))

(use-package emacs
  :bind (("M-o" . other-window)
         ("C-x k" . kill-current-buffer)
         ("C-x C-b" . ibuffer)
         ("C-x C-r" . recentf-open)
         ("C-c d" . duplicate-dwim)
         :prefix-map tau-file-map
         :prefix "C-c f"
         ("f" . find-file)
         ("r" . recentf-open)
         ("R" . rename-visited-file)
         :prefix-map tau-toggle-map
         :prefix "C-c t"
         ("l" . display-line-numbers-mode)
         ("w" . visual-line-mode)
         ("t" . toggle-truncate-lines)
         ("s" . whitespace-mode)
         ("f" . toggle-frame-fullscreen)))

(use-package which-key
  :config
  (which-key-add-key-based-replacements
    "C-c f" "file"
    "C-c t" "toggle"))

(provide 'init-keybindings)
;;; init-keybindings.el ends here
