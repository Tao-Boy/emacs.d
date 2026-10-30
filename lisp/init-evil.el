;;; init-evil.el --- Vim editing with Evil -*- lexical-binding: t; -*-

;;; Commentary:

;; Enable Evil before the first key is read.  Options that affect its
;; keymaps must be set before loading Evil, rather than in :config.
;; Keep TAB available for indentation and completion, and leave the
;; minibuffer on its usual Emacs bindings (Vertico).

;;; Code:

(use-package evil
  :ensure t
  :demand t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil          ; Use evil-collection below.
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil             ; C-i and TAB share a key on TTYs.
        evil-undo-system 'undo-redo)       ; Built-in undo, no extra package.
  :bind (:map tau-toggle-map
              ("e" . evil-mode))
  :config
  (evil-mode 1))

(use-package evil-collection
  :ensure t
  :after evil
  :demand t
  :init
  ;; Only adapt the selected buffers; keep global bracket motions as-is.
  (setq evil-collection-want-unimpaired-p nil)
  :config
  (evil-collection-init '(dired ibuffer help)))

(provide 'init-evil)
;;; init-evil.el ends here
