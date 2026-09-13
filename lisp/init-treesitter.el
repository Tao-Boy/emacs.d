;; -*- lexical-binding: t; -*-

(setq treesit-language-source-alist
      '((bash   . ("https://gh-proxy.com/github.com/tree-sitter/tree-sitter-bash"))
        (c      . ("https://gh-proxy.com/github.com/tree-sitter/tree-sitter-c"))
        (cpp    . ("https://gh-proxy.com/github.com/tree-sitter/tree-sitter-cpp"))
        (python . ("https://gh-proxy.com/github.com/tree-sitter/tree-sitter-python"))
        (rust   . ("https://gh-proxy.com/github.com/tree-sitter/tree-sitter-rust"))))

(when (require 'treesit nil t)
  (dolist (entry '((python . (python-mode . python-ts-mode))
                   (c      . (c-mode      . c-ts-mode))
                   (cpp    . (c++-mode    . c++-ts-mode))
                   (bash   . (sh-mode     . bash-ts-mode))
                   (rust   . (rust-mode   . rust-ts-mode))))
    (when (treesit-ready-p (car entry) t)
      (add-to-list 'major-mode-remap-alist (cdr entry)))))

(provide 'init-treesitter)
