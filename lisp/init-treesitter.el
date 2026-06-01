;; -*- lexical-binding: t; -*-

(setq treesit-language-source-alist
      '((bash   . ("https://gh-proxy.com/github.com/tree-sitter/tree-sitter-bash"))
        (c      . ("https://gh-proxy.com/github.com/tree-sitter/tree-sitter-c"))
        (cpp    . ("https://gh-proxy.com/github.com/tree-sitter/tree-sitter-cpp"))
        (python . ("https://gh-proxy.com/github.com/tree-sitter/tree-sitter-python"))
        (rust   . ("https://gh-proxy.com/github.com/tree-sitter/tree-sitter-rust"))))

;; Only remap to tree-sitter modes when the grammar is actually installed,
;; otherwise opening a file would error. Install grammars with
;; `M-x treesit-install-language-grammar'.
(when (require 'treesit nil t)
  (dolist (entry '((python . (python-mode . python-ts-mode))
                   (c      . (c-mode      . c-ts-mode))
                   (cpp    . (c++-mode    . c++-ts-mode))
                   (bash   . (sh-mode     . bash-ts-mode))))
    (when (treesit-ready-p (car entry) t)
      (add-to-list 'major-mode-remap-alist (cdr entry)))))

(provide 'init-treesitter)
