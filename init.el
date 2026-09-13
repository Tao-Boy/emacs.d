;; -*- lexical-binding: t; -*-

(mapc
 (lambda (string)
   (add-to-list 'load-path (locate-user-emacs-file string)))
 '("lisp" "site-lisp"))

(require 'init-const)
(require 'init-basic)
(require 'init-elpa)
(require 'init-dired)
(require 'init-treesitter)
(require 'init-org)
(require 'init-snippet)
(require 'init-completion)
(require 'init-evil)
(require 'init-ui)
