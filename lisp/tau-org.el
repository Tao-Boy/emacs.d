;;; tau-org.el --- Org knowledge-base commands -*- lexical-binding: t; -*-

;;; Commentary:

;; A small, database-free knowledge base on top of Org IDs:
;;
;;   - every note is a file under `tau-org-notes-directory' whose first
;;     heading carries a globally unique :ID:;
;;   - links between notes are [[id:UUID][Title]] links;
;;   - files are listed with fd, ID'd headings and backlinks are found
;;     with ripgrep, so nothing has to be indexed in advance.
;;
;; Settings (`tau-org-root' and friends) are defined in init-org.el.
;; This file is loaded on demand through the `C-c n' key bindings.

;;; Code:

(require 'org)
(require 'org-id)

(defvar tau-org-root)
(defvar tau-org-notes-directory)
(defvar tau-org-areas)
(defvar tau-org-inbox-file)
(defvar tau-org-tasks-file)
(defvar tau-org-index-file)
(defvar tau-org-attachments-directory)

;;;; External programs

(defun tau-org--fd-program ()
  "Return the fd executable, which some distributions call fdfind."
  (or (executable-find "fd")
      (executable-find "fdfind")))

(defun tau-org--rg-program ()
  "Return the ripgrep executable, or signal a `user-error'."
  (or (executable-find "rg")
      (user-error "ripgrep executable `rg' was not found")))

(defun tau-org--process-lines (program &rest args)
  "Run PROGRAM with ARGS in `tau-org-root' and return its output lines.
Standard error is discarded.  Exit status 1 is accepted because
ripgrep uses it to mean that nothing matched."
  (let ((default-directory tau-org-root))
    (with-temp-buffer
      (let ((status (apply #'process-file program nil '(t nil) nil args)))
        (unless (memql status '(0 1))
          (error "%s failed with exit status %s" program status))
        (split-string (buffer-string) "\n" t)))))

(defun tau-org--grep (&rest args)
  "Run ripgrep with ARGS in `tau-org-root', showing matches in `grep-mode'.
RET on a match jumps to its location."
  (require 'grep)
  (let ((default-directory tau-org-root))
    (compilation-start
     (mapconcat #'shell-quote-argument (cons (tau-org--rg-program) args) " ")
     #'grep-mode)))

(defconst tau-org--rg-common-args
  '("--line-number" "--no-heading" "--with-filename" "--color=never"
    "--hidden" "--no-ignore" "--glob" "!.git/**" "--glob" "*.org")
  "Arguments shared by every ripgrep search over the knowledge base.")

;;;; Files

(defun tau-org-files ()
  "Return all Org files below `tau-org-root'.
Use fd when available and fall back to Lisp directory traversal."
  (if-let* ((fd (tau-org--fd-program)))
      (mapcar (lambda (file) (expand-file-name file tau-org-root))
              (tau-org--process-lines fd "--hidden" "--no-ignore"
                                      "--exclude" ".git" "--type" "f"
                                      "--extension" "org" "."))
    (directory-files-recursively tau-org-root "\\.org\\'")))

;;;###autoload
(defun tau-org-find-file ()
  "Select and visit an Org file of the knowledge base."
  (interactive)
  (let* ((table (mapcar (lambda (file)
                          (cons (file-relative-name file tau-org-root) file))
                        (tau-org-files)))
         (choice (completing-read "Org file: " table nil t)))
    (find-file (cdr (assoc choice table)))))

;;;; New notes

(defun tau-org--slugify (title)
  "Turn TITLE into a file-name slug.
Unicode letters, including Chinese characters, are preserved."
  (let* ((slug (downcase (string-trim title)))
         (slug (replace-regexp-in-string "[[:space:]]+" "-" slug))
         ;; Characters that are invalid on common file systems.
         (slug (replace-regexp-in-string "[/\\\\:*?\"<>|]" "-" slug))
         (slug (replace-regexp-in-string "-+" "-" slug))
         (slug (string-trim slug "-+" "-+")))
    (if (string-empty-p slug) "note" slug)))

;;;###autoload
(defun tau-org-new-note (title area)
  "Create a permanent note called TITLE in AREA.
The note's root heading gets a globally unique Org ID."
  (interactive
   (list (read-string "Title: ")
         (completing-read "Area: " tau-org-areas nil t nil nil "physics")))
  (let* ((directory (file-name-as-directory
                     (expand-file-name area tau-org-notes-directory)))
         (file (expand-file-name
                (format "%s--%s.org"
                        (format-time-string "%Y%m%dT%H%M%S")
                        (tau-org--slugify title))
                directory)))
    (when (file-exists-p file)
      (user-error "File already exists: %s" file))
    (make-directory directory t)
    (find-file file)
    (insert (format "#+title: %s\n#+filetags: :%s:\n#+startup: content\n\n* %s\n"
                    title area title))
    (forward-line -1)                   ; Back onto the root heading.
    (org-id-get-create)
    (org-entry-put nil "CREATED" (format-time-string "[%Y-%m-%d %a %H:%M]"))
    (goto-char (point-max))
    (insert "\n")
    (save-buffer)))

;;;; Node index

(defun tau-org-node-index ()
  "Return all headings of the knowledge base that carry an ID.
Each node is a plist (:title TITLE :id ID :file FILE :line LINE),
sorted by title.  One ripgrep pass finds every heading and :ID: line;
ripgrep prints the matches of each file together and in order, so an
:ID: line belongs to the last heading seen in the same file."
  (let ((rg (tau-org--rg-program))
        (last-heading (make-hash-table :test #'equal))
        nodes)
    (dolist (line (apply #'tau-org--process-lines rg "--null"
                         (append tau-org--rg-common-args
                                 '("--regexp" "^(\\*+ .+|[ \t]*:ID:[ \t]+\\S+[ \t]*)$"
                                   "."))))
      ;; With --null, each line is FILE\0LINE:TEXT.
      (when (string-match "\\`\\([^\0]+\\)\0\\([0-9]+\\):\\(.*\\)\\'" line)
        (let ((file (expand-file-name (match-string 1 line) tau-org-root))
              (line-number (string-to-number (match-string 2 line)))
              (text (string-trim-right (match-string 3 line))))
          (cond
           ((string-match "\\`\\*+[ \t]+\\(.+\\)\\'" text)
            (puthash file (cons (string-trim (match-string 1 text)) line-number)
                     last-heading))
           ((string-match "\\`[ \t]*:ID:[ \t]+\\([^[:space:]]+\\)" text)
            (when-let* ((heading (gethash file last-heading)))
              (push (list :title (car heading)
                          :id (match-string 1 text)
                          :file file
                          :line (cdr heading))
                    nodes)))))))
    (sort nodes :key (lambda (node) (downcase (plist-get node :title)))
          :in-place t)))

(defun tau-org-read-node ()
  "Select an ID'd heading in the minibuffer and return its node plist."
  (let* ((nodes (or (tau-org-node-index)
                    (user-error "No headings with :ID: properties were found")))
         (table (mapcar (lambda (node)
                          (cons (format "%s  —  %s:%d"
                                        (plist-get node :title)
                                        (file-relative-name (plist-get node :file)
                                                            tau-org-root)
                                        (plist-get node :line))
                                node))
                        nodes)))
    (cdr (assoc (completing-read "Node: " table nil t) table))))

;;;###autoload
(defun tau-org-find-node ()
  "Select a knowledge node and jump to it."
  (interactive)
  (let ((node (tau-org-read-node)))
    (find-file (plist-get node :file))
    (widen)
    (goto-char (point-min))
    (forward-line (1- (plist-get node :line)))
    (org-fold-show-context)
    (recenter)))

;;;###autoload
(defun tau-org-insert-node-link ()
  "Select a knowledge node and insert an [[id:UUID][Title]] link to it."
  (interactive)
  (unless (derived-mode-p 'org-mode)
    (user-error "Current buffer is not an Org buffer"))
  (let ((node (tau-org-read-node)))
    (insert (org-link-make-string (concat "id:" (plist-get node :id))
                                  (plist-get node :title)))))

;;;; Backlinks and search

(defun tau-org-current-node ()
  "Return (:id ID :title TITLE) for the heading at point.
Create an ID for the heading if it has none."
  (unless (derived-mode-p 'org-mode)
    (user-error "Current buffer is not an Org buffer"))
  (save-excursion
    (when (org-before-first-heading-p)
      (user-error "Point is before the first Org heading"))
    (org-back-to-heading t)
    (list :id (org-id-get-create)
          :title (org-get-heading t t t t))))

;;;###autoload
(defun tau-org-backlinks ()
  "List all links to the current node in a `grep-mode' buffer."
  (interactive)
  ;; "id:UUID" does not match the :ID: property line itself.
  (let ((needle (concat "id:" (plist-get (tau-org-current-node) :id))))
    (apply #'tau-org--grep
           (append tau-org--rg-common-args
                   (list "--fixed-strings" "--regexp" needle ".")))))

;;;###autoload
(defun tau-org-rg-search (query &optional literal)
  "Search all Org notes for the regular expression QUERY with ripgrep.
With prefix argument LITERAL, search for QUERY literally."
  (interactive
   (list (read-string (if current-prefix-arg
                          "Org literal search: "
                        "Org regexp search: ")
                      (thing-at-point 'symbol t))
         current-prefix-arg))
  (apply #'tau-org--grep
         (append tau-org--rg-common-args
                 '("--smart-case")
                 (and literal '("--fixed-strings"))
                 (list "--regexp" query "."))))

;;;; Maintenance

;;;###autoload
(defun tau-org-refresh-id-db ()
  "Rebuild the global Org ID location database from the knowledge base.
Useful after importing notes or moving or pulling files outside Emacs."
  (interactive)
  (let ((files (or (tau-org-files)
                   (user-error "No Org files found under %s" tau-org-root))))
    (setq org-id-extra-files files)
    (org-id-update-id-locations files)
    (message "Org ID database refreshed: %d files" (length files))))

;;;###autoload
(defun tau-org-initialize-directories ()
  "Create the directory structure and main files of the knowledge base."
  (interactive)
  (dolist (directory (append (list tau-org-root tau-org-notes-directory
                                   tau-org-attachments-directory)
                             (mapcar (lambda (area)
                                       (expand-file-name area tau-org-notes-directory))
                                     tau-org-areas)))
    (make-directory directory t))
  (dolist (file (list tau-org-inbox-file tau-org-tasks-file tau-org-index-file))
    (unless (file-exists-p file)
      (write-region "" nil file)))
  (message "Initialized Org directory: %s" tau-org-root))

(provide 'tau-org)
;;; tau-org.el ends here
