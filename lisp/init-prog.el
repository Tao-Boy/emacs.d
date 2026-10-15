;;; init-prog.el --- Programming -*- lexical-binding: t; -*-

;;; Commentary:

;; Common `prog-mode' setup, tree-sitter major modes and Eglot.

;;; Code:

;;;; prog-mode

(use-package display-line-numbers
  :hook (prog-mode . display-line-numbers-mode)
  :custom (display-line-numbers-type 'relative))

(add-hook 'prog-mode-hook #'electric-pair-local-mode)

;;;; Tree-sitter

(defvar tau-github-mirror "https://gh-proxy.com/github.com/"
  "URL prefix that replaces \"https://github.com/\", or nil for none.
Used when downloading tree-sitter grammars and prebuilt liberime.")

(defun tau--call-with-github-mirror (fn &rest args)
  "Call FN with ARGS while git fetches GitHub through `tau-github-mirror'.
The URL rewrite is passed to git through its environment (git 2.31+),
so the pinned grammar recipes that Emacs 31 ships are kept as is and
no global git configuration is touched."
  (if (not tau-github-mirror)
      (apply fn args)
    (let* ((n (string-to-number (or (getenv "GIT_CONFIG_COUNT") "0")))
           (process-environment
            (append (list (format "GIT_CONFIG_COUNT=%d" (1+ n))
                          (format "GIT_CONFIG_KEY_%d=url.%s.insteadOf"
                                  n tau-github-mirror)
                          (format "GIT_CONFIG_VALUE_%d=https://github.com/" n))
                    process-environment)))
      (apply fn args))))

(advice-add 'treesit-install-language-grammar
            :around #'tau--call-with-github-mirror)

;; Emacs 31: the built-in tree-sitter modes register themselves in
;; `treesit-major-mode-remap-alist', together with grammar recipes
;; pinned to versions they are known to work with.  Opening a file in
;; one of these modes offers to install a missing grammar
;; (`treesit-auto-install-grammar' is `ask' by default).
(setq treesit-enabled-modes '(python-ts-mode
                              c-ts-mode c++-ts-mode c-or-c++-ts-mode
                              bash-ts-mode
                              rust-ts-mode))

;; What the option's `:set' function does.  `setopt' would also load
;; treesit.el, cus-edit and the widget library during startup (~15 ms).
(dolist (remap treesit-major-mode-remap-alist)
  (when (memq (cdr remap) treesit-enabled-modes)
    (add-to-list 'major-mode-remap-alist remap)))

(defun tau--treesit-fallback ()
  "Switch to the classic major mode if the tree-sitter mode did not start.
That happens when the grammar is missing (its installation was declined
or failed) or the buffer is too large for tree-sitter."
  (unless (treesit-parser-list)
    (let ((classic (car (rassq major-mode treesit-major-mode-remap-alist))))
      (when (fboundp classic)
        (funcall classic)))))

(dolist (mode treesit-enabled-modes)
  (add-hook (intern (format "%s-hook" mode)) #'tau--treesit-fallback))

;;;; Eglot

(use-package eglot
  :defer t
  :custom
  (eglot-autoshutdown t)                    ; Stop servers with their last buffer.
  (eglot-events-buffer-config '(:size 0)))  ; Logging every message is slow.

(provide 'init-prog)
;;; init-prog.el ends here
