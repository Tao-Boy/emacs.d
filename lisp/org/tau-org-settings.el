;;; tau-org-settings.el --- Org editing, capture and agenda -*- lexical-binding: t; -*-

(require 'tau-core)
(defvar org-id-locations-file)
(tau-core-setup-state)
(require 'org)

;; Migrate the ID cache on first Org use, rather than scanning notes at startup.
(when (equal org-id-locations-file (tau-state-file "org-id-locations"))
  (tau-state-migrate-file ".org-id-locations" org-id-locations-file))
(require 'org-id)

(defgroup tau-org nil
  "Personal Org knowledge management."
  :group 'org)
(defcustom tau-org-root (expand-file-name "~/org/")
  "Root of the knowledge base.  Set in local.el before loading Org."
  :type 'directory :group 'tau-org)
(defcustom tau-org-notes-directory (expand-file-name "notes/" tau-org-root)
  "Directory containing permanent notes."
  :type 'directory :group 'tau-org)
(defcustom tau-org-inbox-file (expand-file-name "inbox.org" tau-org-root)
  "Inbox file."
  :type 'file :group 'tau-org)
(defcustom tau-org-tasks-file (expand-file-name "tasks.org" tau-org-root)
  "Task file."
  :type 'file :group 'tau-org)
(defcustom tau-org-index-file (expand-file-name "index.org" tau-org-root)
  "Top-level index file."
  :type 'file :group 'tau-org)
(defcustom tau-org-attachments-directory (expand-file-name "attachments/" tau-org-root)
  "Directory for manually managed attachments."
  :type 'directory :group 'tau-org)

;; Permanent knowledge notes stay out of the agenda so thousands of notes
;; do not slow down task generation.  No note directories are created here.
(setq org-directory tau-org-root
      org-agenda-files (list tau-org-inbox-file tau-org-tasks-file)
      org-startup-folded 'content
      org-startup-with-latex-preview nil
      org-startup-with-inline-images t
      org-ellipsis " …"
      org-hide-emphasis-markers nil
      org-cycle-separator-lines 2
      org-special-ctrl-a/e t
      org-special-ctrl-k t
      org-return-follows-link t
      org-src-fontify-natively t
      org-src-tab-acts-natively t
      org-src-preserve-indentation t
      org-log-done 'time
      org-log-into-drawer t)

;; Org 9.8 renamed this option.  The older built-in Org in Emacs 29/30
;; still needs the previous name.
(with-suppressed-warnings ((obsolete org-edit-src-content-indentation))
  (if (boundp 'org-src-content-indentation)
      (setq org-src-content-indentation 0)
    (setq org-edit-src-content-indentation 0)))

(defun tau-org-mode-setup ()
  "Configure the current Org buffer for technical notes."
  (visual-line-mode 1)
  (org-indent-mode 1)
  (setq-local fill-column 88)
  (display-line-numbers-mode -1))
(add-hook 'org-mode-hook #'tau-org-mode-setup)

;; Braced subscripts are rendered; identifiers such as wave_function are not.
(setq org-highlight-latex-and-related '(latex script entities)
      org-pretty-entities t
      org-pretty-entities-include-sub-superscripts t
      org-use-sub-superscripts '{}
      org-format-latex-options (plist-put org-format-latex-options :scale 1.4))
(when (executable-find "dvisvgm")
  (setq org-preview-latex-default-process 'dvisvgm))

(setq org-id-link-to-org-use-id t
      org-id-link-consider-parent-id nil
      org-id-method 'uuid
      org-id-track-globally t)

(setq org-capture-templates
      `(("i" "Inbox" entry (file ,tau-org-inbox-file)
         "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")
        ("t" "Task" entry (file ,tau-org-tasks-file)
         "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")))
(define-key org-mode-map (kbd "C-c n I") #'org-id-get-create)

(provide 'tau-org-settings)
;;; tau-org-settings.el ends here
