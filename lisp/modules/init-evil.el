;;; init-evil.el --- Immediate modal editing -*- lexical-binding: t; -*-

(defvar evil-disable-insert-state-bindings)
(defvar evil-want-C-u-scroll)
(defvar evil-want-C-d-scroll)
(defvar evil-want-C-i-jump)
(defvar evil-want-C-h-delete)
(declare-function evil-mode "evil" (&optional arg))

;; Set these before Evil builds its keymaps.
(setq evil-disable-insert-state-bindings t
      evil-want-C-u-scroll nil
      evil-want-C-d-scroll nil
      evil-want-C-i-jump nil
      evil-want-C-h-delete nil)
;; Modal editing affects the first keystroke, so it intentionally stays eager.
;; A checkout without dependencies starts as ordinary Emacs.
(when (require 'evil nil t) (evil-mode 1))

(provide 'init-evil)
;;; init-evil.el ends here
