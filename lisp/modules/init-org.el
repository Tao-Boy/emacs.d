;;; init-org.el --- Org entry points without loading Org -*- lexical-binding: t; -*-

(declare-function org-store-link "ol" (&optional arg interactive?))

(with-eval-after-load 'org (require 'tau-org-settings))
(autoload 'tau-org-files "tau-org-notes")
(autoload 'tau-org-current-node "tau-org-notes")
(autoload 'tau-org-node-index "tau-org-search")
(autoload 'tau-org-read-node "tau-org-search")
(dolist (command '(tau-org-find-file tau-org-new-note tau-org-initialize-directories))
  (autoload command "tau-org-notes" nil t))
(dolist (command '(tau-org-find-node
                  tau-org-insert-node-link tau-org-backlinks tau-org-rg-search
                                      tau-org-refresh-id-db))
  (autoload command "tau-org-search" nil t))
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "C-c a") #'org-agenda)
(defvar tau-org-note-map (make-sparse-keymap)
  "Prefix map for Org knowledge-base commands.")
(define-key global-map (kbd "C-c n") tau-org-note-map)
(dolist (binding '(("n" . tau-org-new-note) ("f" . tau-org-find-file)
                   ("j" . tau-org-find-node) ("i" . tau-org-insert-node-link)
                   ("b" . tau-org-backlinks) ("s" . tau-org-rg-search)
                   ("R" . tau-org-refresh-id-db)))
  (define-key tau-org-note-map (kbd (car binding)) (cdr binding)))

(provide 'init-org)
;;; init-org.el ends here
