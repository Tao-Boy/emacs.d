;;; init-keybindings.el --- Evil and shared bindings -*- lexical-binding: t; -*-

;;; Code:

(use-package evil
  :ensure t
  :demand t
  :init
  (setq evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil
        evil-undo-system 'undo-redo)
  :config
  (evil-mode 1))

(use-package evil-collection
  :ensure t
  :after evil
  :demand t
  :custom (evil-collection-want-unimpaired-p nil)
  :config
  (evil-collection-init '(dired ibuffer help)))

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
         ("e" . evil-mode)
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
