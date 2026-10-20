;;; init-org.el --- Org and Denote -*- lexical-binding: t; -*-

;;; Commentary:

;; Org loads on first use: visiting an Org file, capture or agenda.
;;
;; Permanent notes are managed by Denote: one Org file per note under
;; `denote-directory', named IDENTIFIER--TITLE__KEYWORDS.org and linked
;; with [[denote:IDENTIFIER]] links.  Denote itself loads with the
;; first `C-c n' command.

;;; Code:

;;;; Org

(declare-function org-indent-mode "org-indent")

(defun tau-org-mode-setup ()
  "Configure an Org buffer for technical note taking."
  (visual-line-mode 1)
  (org-indent-mode 1)
  (setq-local fill-column 88))

(use-package org
  :defer t
  :bind (("C-c l" . org-store-link)
         ("C-c c" . org-capture)
         ("C-c a" . org-agenda))
  :hook (org-mode . tau-org-mode-setup)
  :custom
  (org-directory "~/org/")
  ;; Relative file names below are resolved against `org-directory'.
  ;; Only the inbox and the task list are in the agenda: scanning the
  ;; (potentially thousands of) notes would make it slow.
  (org-agenda-files '("inbox.org" "tasks.org"))
  (org-capture-templates
   '(("i" "Inbox" entry (file "inbox.org")
      "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")
     ("t" "Task" entry (file "tasks.org")
      "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")
     ("n" "Note (Denote)" plain (file denote-last-path)
      #'denote-org-capture
      :no-save t :immediate-finish nil :kill-buffer t :jump-to-captured t)))

  ;; Startup.  LaTeX previews are not rendered on open: large math
  ;; notes would take seconds to display.
  (org-startup-folded 'content)
  (org-startup-with-latex-preview nil)
  (org-startup-with-link-previews t)        ; Org 9.8 name of inline images.

  ;; Appearance.  Emphasis markers stay visible for plain-text editing.
  (org-ellipsis " …")
  (org-hide-emphasis-markers nil)
  (org-cycle-separator-lines 2)

  ;; Editing.
  (org-special-ctrl-a/e t)
  (org-special-ctrl-k t)
  (org-return-follows-link t)

  ;; Source blocks.
  (org-src-fontify-natively t)
  (org-src-tab-acts-natively t)
  (org-src-preserve-indentation t)
  (org-src-content-indentation 0)          ; Org 9.8 name.

  ;; Logging.
  (org-log-done 'time)
  (org-log-into-drawer t)

  ;; Mathematics.  LaTeX stays plain text: \alpha is not displayed as α
  ;; and x_{i} is not raised; fragments and scripts are only colored.
  ;; `org-use-sub-superscripts' set to {} means only x_{i} is a
  ;; subscript on export, so identifiers such as wave_function or R_s
  ;; stay ordinary text.
  (org-highlight-latex-and-related '(latex script entities))
  (org-pretty-entities nil)
  (org-use-sub-superscripts '{})
  :config
  ;; Notes written before the switch to Denote link to each other with
  ;; [[id:UUID]] links, which only resolve once org-id is loaded.
  (require 'org-id)
  (setq org-format-latex-options
        (plist-put org-format-latex-options :scale 1.4))
  ;; SVG previews stay sharp on HiDPI displays.
  (when (executable-find "dvisvgm")
    (setq org-preview-latex-default-process 'dvisvgm)))

;;;; Denote

(use-package denote
  :ensure t
  :hook (dired-mode . denote-dired-mode-in-directories)
  :bind (:prefix-map tau-denote-map
         :prefix "C-c n"
         :prefix-docstring "Prefix keymap for Denote commands."
         ("n" . denote)
         ("f" . denote-open-or-create)
         ("i" . denote-link-or-create)
         ("l" . denote-find-link)
         ("b" . denote-backlinks)
         ("B" . denote-find-backlink)
         ("s" . denote-grep)
         ("r" . denote-rename-file)
         ("R" . denote-rename-file-using-front-matter)
         ("d" . denote-sort-dired))
  :custom
  (denote-directory (expand-file-name "notes/" org-directory))
  ;; One subdirectory per area, as before the switch to Denote.
  (denote-prompts '(subdirectory title keywords))
  (denote-known-keywords '("math" "physics" "methods" "references"))
  (denote-dired-directories-include-subdirectories t))

;; Denote's backlinks and `denote-grep' search through xref.
(use-package xref
  :defer t
  :config
  (when (executable-find "rg")
    (setq xref-search-program 'ripgrep)))

(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements "C-c n" "notes"))

(provide 'init-org)
;;; init-org.el ends here
