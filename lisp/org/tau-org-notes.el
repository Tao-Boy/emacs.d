;;; tau-org-notes.el --- Files, note creation and stable identities -*- lexical-binding: t; -*-

;; Requiring Org first lets the init-org after-load registration finish before
;; we require its settings, avoiding a recursive settings load.
(require 'org)
(require 'tau-org-settings)
(require 'subr-x)

(defun tau-org--fd-program ()
  "Return fd, including its Debian executable name fdfind."
  (or (executable-find "fd") (executable-find "fdfind")))

(defun tau-org--process-lines (program &rest args)
  "Run PROGRAM with ARGS and return output lines.
Accept status 1 for ripgrep's no-match result; report other failures."
  (with-temp-buffer
    (let ((status (apply #'process-file program nil t nil args)))
      (unless (member status '(0 1))
        (error "%s failed with exit status %s" program status))
      (split-string (buffer-string) "\n" t))))

(defun tau-org-files ()
  "Return all Org files below `tau-org-root', using fd when available."
  (unless (file-directory-p tau-org-root)
    (user-error "Initialize %s with M-x tau-org-initialize-directories" tau-org-root))
  (let ((fd (tau-org--fd-program)))
    (if fd
        (let ((default-directory tau-org-root))
          (mapcar (lambda (file) (expand-file-name file tau-org-root))
                  (tau-org--process-lines fd "--hidden" "--no-ignore" "--exclude"
                                          ".git" "--type" "f" "--extension" "org" ".")))
      (directory-files-recursively tau-org-root "\\.org\\'"))))

(defun tau-org-find-file ()
  "Select and visit a file in the knowledge base."
  (interactive)
  (let* ((table (mapcar (lambda (file)
                          (cons (file-relative-name file tau-org-root) file))
                        (tau-org-files)))
         (choice (completing-read "Org file: " table nil t)))
    (find-file (cdr (assoc choice table)))))

(defun tau-org--slugify (title)
  "Convert TITLE into a filename slug, preserving Chinese and other Unicode."
  (let ((slug (downcase (string-trim title))))
    (setq slug (replace-regexp-in-string "[[:space:]]+" "-" slug)
          slug (replace-regexp-in-string "[/\\\\:*?\"<>|]" "-" slug)
          slug (replace-regexp-in-string "-+" "-" slug)
          slug (string-trim slug "-" "-"))
    (if (string-empty-p slug) "note" slug)))

(defun tau-org-new-note (title area)
  "Create a permanent note named TITLE under AREA, with a stable Org ID."
  (interactive
   (list (read-string "Title: ")
         (completing-read "Area: " '("math" "physics" "methods" "references")
                          nil t nil nil "physics")))
  (let* ((directory (expand-file-name (concat area "/") tau-org-notes-directory))
         (filename (format "%s--%s.org" (format-time-string "%Y%m%dT%H%M%S")
                           (tau-org--slugify title)))
         (file (expand-file-name filename directory)))
    (make-directory directory t)
    (when (file-exists-p file)
      (user-error "File already exists: %s" file))
    (find-file file)
    (insert (format "#+title: %s\n#+filetags: :%s:\n#+startup: content\n\n* %s\n"
                    title area title))
    (forward-line -1)
    (org-id-get-create)
    (org-entry-put nil "CREATED" (format-time-string "[%Y-%m-%d %a %H:%M]"))
    (goto-char (point-max))
    (insert "\n")
    (save-buffer)))

(defun tau-org-current-node ()
  "Return (:id ID :title TITLE) for the current heading, creating its ID if needed."
  (unless (derived-mode-p 'org-mode)
    (user-error "Current buffer is not an Org buffer"))
  (save-excursion
    (when (org-before-first-heading-p)
      (user-error "Point is before the first Org heading"))
    (org-back-to-heading t)
    (list :id (org-id-get-create) :title (org-get-heading t t t t))))

(defun tau-org-initialize-directories ()
  "Create the knowledge-base structure without overwriting existing files."
  (interactive)
  (dolist (directory (append (list tau-org-root tau-org-notes-directory
                                   tau-org-attachments-directory)
                             (mapcar (lambda (area)
                                       (expand-file-name area tau-org-notes-directory))
                                     '("math/" "physics/" "methods/" "references/"))))
    (make-directory directory t))
  (dolist (file (list tau-org-inbox-file tau-org-tasks-file tau-org-index-file))
    (unless (file-exists-p file)
      (write-region "" nil file)))
  (message "Initialized Org directory: %s" tau-org-root))

(provide 'tau-org-notes)
;;; tau-org-notes.el ends here
