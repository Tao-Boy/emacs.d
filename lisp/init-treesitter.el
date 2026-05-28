;; -*- lexical-binding: t; -*-

(setq treesit-language-source-alist
      '((bash   . ("https://gh-proxy.com/github.com/tree-sitter/tree-sitter-bash"))
        (c      . ("https://gh-proxy.com/github.com/tree-sitter/tree-sitter-c"))
        (cpp    . ("https://gh-proxy.com/github.com/tree-sitter/tree-sitter-cpp"))
        (python . ("https://gh-proxy.com/github.com/tree-sitter/tree-sitter-python"))
        (rust   . ("https://gh-proxy.com/github.com/tree-sitter/tree-sitter-rust"))))

(dolist (mapping
         '((python-mode     . python-ts-mode)
           (c-mode          . c-ts-mode)
           (c++-mode        . c++-ts-mode)
           (sh-mode         . bash-ts-mode)))
  (add-to-list 'major-mode-remap-alist mapping))

(provide 'init-treesitter)
