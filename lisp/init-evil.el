;; -*- lexical-binding: t; -*-

;; All `evil-want-*' variables are consulted while Evil builds its
;; keymaps, i.e. while the library is loaded.  They therefore have to
;; be set *before* `(require 'evil)' -- setting them afterwards has no
;; effect on the resulting key bindings.
(setq evil-disable-insert-state-bindings t
      evil-want-C-u-scroll nil
      evil-want-C-d-scroll nil
      evil-want-C-i-jump nil
      evil-want-C-h-delete nil)

(require 'evil)

(evil-mode 1)

(provide 'init-evil)
