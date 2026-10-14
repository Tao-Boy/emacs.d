;;; init-org.el --- Org -*- lexical-binding: t; -*-

;;; Commentary:

;; Org loads on first use: visiting an Org file, capture, agenda or one
;; of the knowledge-base commands.  Those commands live in `tau-org.el'
;; and are autoloaded through the `C-c n' bindings below.

;;; Code:

;;;; Knowledge-base locations

(defgroup tau-org nil
  "Personal Org-mode knowledge-management configuration."
  :group 'org)

(defcustom tau-org-root (expand-file-name "~/org/")
  "Root directory of the Org knowledge base."
  :type 'directory)

(defcustom tau-org-notes-directory (expand-file-name "notes/" tau-org-root)
  "Directory containing permanent knowledge notes."
  :type 'directory)

(defcustom tau-org-areas '("math" "physics" "methods" "references")
  "Subdirectories of `tau-org-notes-directory', one per area."
  :type '(repeat string))

(defcustom tau-org-inbox-file (expand-file-name "inbox.org" tau-org-root)
  "Inbox file."
  :type 'file)

(defcustom tau-org-tasks-file (expand-file-name "tasks.org" tau-org-root)
  "Task file."
  :type 'file)

(defcustom tau-org-index-file (expand-file-name "index.org" tau-org-root)
  "Top-level index file."
  :type 'file)

(defcustom tau-org-attachments-directory
  (expand-file-name "attachments/" tau-org-root)
  "Directory for manually managed attachments."
  :type 'directory)

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
         ("C-c a" . org-agenda)
         :map org-mode-map
         ("C-c n I" . org-id-get-create))
  :hook (org-mode . tau-org-mode-setup)
  :custom
  (org-directory tau-org-root)
  ;; Only the inbox and the task list: keeping the (potentially
  ;; thousands of) knowledge notes out of the agenda keeps it fast.
  (org-agenda-files (list tau-org-inbox-file tau-org-tasks-file))
  (org-capture-templates
   `(("i" "Inbox" entry (file ,tau-org-inbox-file)
      "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")
     ("t" "Task" entry (file ,tau-org-tasks-file)
      "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")))

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

  ;; Mathematics.  `org-use-sub-superscripts' set to {} means only
  ;; x_{i} is a subscript, so identifiers such as wave_function or R_s
  ;; stay ordinary text.
  (org-highlight-latex-and-related '(latex script entities))
  (org-pretty-entities t)
  (org-pretty-entities-include-sub-superscripts t)
  (org-use-sub-superscripts '{})

  ;; IDs: link to headings as [[id:UUID][Title]], one UUID per heading.
  (org-id-link-to-org-use-id t)
  (org-id-link-consider-parent-id nil)
  (org-id-method 'uuid)
  (org-id-track-globally t)
  :config
  ;; `org-store-link' only creates ID links once org-id is loaded.
  (require 'org-id)
  (setq org-format-latex-options
        (plist-put org-format-latex-options :scale 1.4))
  ;; SVG previews stay sharp on HiDPI displays.
  (when (executable-find "dvisvgm")
    (setq org-preview-latex-default-process 'dvisvgm)))

;;;; Knowledge-base commands

(use-package tau-org
  :commands tau-org-initialize-directories
  :bind (:prefix-map tau-org-note-map
         :prefix "C-c n"
         :prefix-docstring "Prefix keymap for Org knowledge-base commands."
         ("n" . tau-org-new-note)
         ("f" . tau-org-find-file)
         ("j" . tau-org-find-node)
         ("i" . tau-org-insert-node-link)
         ("b" . tau-org-backlinks)
         ("s" . tau-org-rg-search)
         ("R" . tau-org-refresh-id-db)))

(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements "C-c n" "notes"))

(provide 'init-org)
;;; init-org.el ends here
