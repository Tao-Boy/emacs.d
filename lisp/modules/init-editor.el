;;; init-editor.el --- Buffer-local editing behavior -*- lexical-binding: t; -*-

(defvar xterm-update-cursor)
(defvar display-line-numbers-type)

(setq xterm-update-cursor t
      visible-cursor nil
      display-line-numbers-type 'relative
      show-paren-delay 0)
(blink-cursor-mode -1)
(show-paren-mode 1)
(unless noninteractive (xterm-mouse-mode 1))

(defun tau-prog-mode-setup ()
  "Enable programming conveniences in the current buffer."
  (electric-pair-local-mode 1)
  (display-line-numbers-mode 1)
  (when (fboundp 'rainbow-delimiters-mode)
    (rainbow-delimiters-mode 1)))
(add-hook 'prog-mode-hook #'tau-prog-mode-setup)

(provide 'init-editor)
;;; init-editor.el ends here
