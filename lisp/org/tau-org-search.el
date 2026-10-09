;;; tau-org-search.el --- Node lookup, backlinks and search -*- lexical-binding: t; -*-

(require 'tau-org-notes)
(require 'grep)
(require 'json)

(defun tau-org--rg-program ()
  "Return ripgrep or report the missing executable."
  (or (executable-find "rg")
      (user-error "ripgrep executable rg was not found")))

(defun tau-org--shell-command (program args)
  "Construct a safely shell-quoted command from PROGRAM and ARGS."
  (mapconcat #'shell-quote-argument (cons program args) " "))

(defun tau-org-node-index ()
  "Return ID-bearing headings as (:title TITLE :id ID :file FILE :line LINE).
Scan on demand with ripgrep; no database or startup scan is needed."
  (let ((rg (tau-org--rg-program))
        (default-directory tau-org-root)
        (last-heading (make-hash-table :test #'equal))
        nodes)
    (dolist (json-line
             (tau-org--process-lines
              rg "--json" "--hidden" "--no-ignore" "--glob" "!.git/**"
              "--glob" "*.org" "--regexp"
              "^(\\*+ .+|[ \t]*:ID:[ \t]+\\S+[ \t]*)$" "."))
      (let ((object (json-parse-string json-line)))
        (when (equal (gethash "type" object) "match")
          (let* ((data (gethash "data" object))
                 (file (expand-file-name (gethash "text" (gethash "path" data))
                                         tau-org-root))
                 (line (gethash "line_number" data))
                 (text (string-trim-right (gethash "text" (gethash "lines" data)))))
            (cond
             ((string-match "\\`\\*+[ \t]+\\(.+\\)\\'" text)
              (puthash file (list :title (string-trim (match-string 1 text)) :line line)
                       last-heading))
             ((string-match "\\`[ \t]*:ID:[ \t]+\\([^[:space:]]+\\)" text)
              (let ((heading (gethash file last-heading)))
                (when heading
                  (push (list :title (plist-get heading :title)
                              :id (match-string 1 text) :file file
                              :line (plist-get heading :line))
                        nodes)))))))))
    (sort nodes (lambda (a b)
                  (string-lessp (downcase (plist-get a :title))
                                (downcase (plist-get b :title)))))))

(defun tau-org-read-node ()
  "Select an Org ID node and return its plist."
  (let ((nodes (tau-org-node-index)))
    (unless nodes (user-error "No headings with :ID: properties were found"))
    (let* ((table (mapcar
                   (lambda (node)
                     (cons (format "%s  —  %s:%d" (plist-get node :title)
                                   (file-relative-name (plist-get node :file) tau-org-root)
                                   (plist-get node :line))
                           node))
                   nodes))
           (choice (completing-read "Node: " table nil t)))
      (cdr (assoc choice table)))))

(defun tau-org-find-node ()
  "Select a knowledge node and jump to its heading."
  (interactive)
  (let ((node (tau-org-read-node)))
    (find-file (plist-get node :file))
    (widen)
    (goto-char (point-min))
    (forward-line (1- (plist-get node :line)))
    (with-suppressed-warnings ((obsolete org-show-context))
      (if (fboundp 'org-fold-show-context)
          (org-fold-show-context)
        (org-show-context)))
    (recenter)))

(defun tau-org-insert-node-link ()
  "Select a knowledge node and insert [[id:UUID][Node title]]."
  (interactive)
  (unless (derived-mode-p 'org-mode)
    (user-error "Current buffer is not an Org buffer"))
  (let ((node (tau-org-read-node)))
    (insert (org-link-make-string (concat "id:" (plist-get node :id))
                                  (plist-get node :title)))))

(defun tau-org-rg-search (query &optional literal case-sensitive)
  "Search for regexp QUERY, or literal text with prefix argument LITERAL.
Non-nil CASE-SENSITIVE preserves exact ID matching for backlinks."
  (interactive
   (list (read-string (if current-prefix-arg "Org literal search: " "Org regexp search: ")
                      (thing-at-point 'symbol t))
         current-prefix-arg))
  (let ((default-directory tau-org-root))
    (grep (tau-org--shell-command
           (tau-org--rg-program)
           (append '("--line-number" "--no-heading" "--with-filename" "--color=never"
                                    "--hidden" "--no-ignore" "--glob" "!.git/**"
                     "--glob" "*.org")
                   (list (if case-sensitive "--case-sensitive" "--smart-case"))
                   (when literal '("--fixed-strings"))
                   (list "--" query "."))))))

(defun tau-org-backlinks ()
  "Show links to the current node in a navigable grep buffer."
  (interactive)
  (tau-org-rg-search (concat "id:" (plist-get (tau-org-current-node) :id)) t t))

(defun tau-org-refresh-id-db ()
  "Rebuild Org's ID locations after importing or moving notes."
  (interactive)
  (let ((files (tau-org-files)))
    (unless files (user-error "No Org files found under %s" tau-org-root))
    (setq org-id-extra-files files)
    (org-id-update-id-locations files)
    (message "Org ID database refreshed: %d files" (length files))))

(provide 'tau-org-search)
;;; tau-org-search.el ends here
