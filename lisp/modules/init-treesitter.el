;;; init-treesitter.el --- Built-in language grammars -*- lexical-binding: t; -*-

(declare-function treesit-ready-p "treesit" (language &optional quiet))

;; No grammar download or compilation occurs during startup.
(defvar treesit-language-source-alist
  '((bash . ("https://github.com/tree-sitter/tree-sitter-bash"))
    (c . ("https://github.com/tree-sitter/tree-sitter-c"))
    (cpp . ("https://github.com/tree-sitter/tree-sitter-cpp"))
    (python . ("https://github.com/tree-sitter/tree-sitter-python"))
    (rust . ("https://github.com/tree-sitter/tree-sitter-rust"))))

;; Only install a remap when both its grammar and target mode are usable.
(when (and (fboundp 'treesit-available-p) (treesit-available-p)
           (require 'treesit nil t))
  (dolist (entry '((python python-mode python-ts-mode)
                   (c c-mode c-ts-mode) (cpp c++-mode c++-ts-mode)
                   (bash sh-mode bash-ts-mode) (rust rust-mode rust-ts-mode)))
    (when (and (fboundp (nth 2 entry)) (treesit-ready-p (car entry) t))
      (add-to-list 'major-mode-remap-alist (cons (nth 1 entry) (nth 2 entry))))))

(provide 'init-treesitter)
;;; init-treesitter.el ends here
