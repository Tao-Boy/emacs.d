;;; init-evil.el --- Vim emulation -*- lexical-binding: t; -*-

;;; Commentary:

;; Evil has to be active before the first key press, so it is loaded
;; eagerly.  All `evil-want-*' options are read while Evil builds its
;; keymaps, i.e. when the library loads, so they go in `:init'.

;;; Code:

(use-package evil
  :ensure t
  :demand t
  :init
  (setq evil-disable-insert-state-bindings t
        evil-want-C-u-scroll nil
        evil-want-C-d-scroll nil
        evil-want-C-i-jump nil
        evil-want-C-h-delete nil
        ;; Built-in linear undo/redo, so that `C-r' redoes.
        evil-undo-system 'undo-redo)
  :config
  (evil-mode 1))

(provide 'init-evil)
;;; init-evil.el ends here
