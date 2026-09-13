;;-*- lexical-binding: t; -*-

(require 'org)
(require 'org-id)
(require 'grep)
(require 'json)
(require 'seq)
(require 'subr-x)


(defgroup tau-org nil
  "Personal Org-mode knowledge-management configuration."
  :group 'org)


(defcustom tau-org-root
  (expand-file-name "~/org/")
  "Root directory of the Org knowledge base."
  :type 'directory
  :group 'tau-org)


(defcustom tau-org-notes-directory
  (expand-file-name "notes/" tau-org-root)
  "Directory containing permanent knowledge notes."
  :type 'directory
  :group 'tau-org)


(defcustom tau-org-inbox-file
  (expand-file-name "inbox.org" tau-org-root)
  "Inbox file."
  :type 'file
  :group 'tau-org)


(defcustom tau-org-tasks-file
  (expand-file-name "tasks.org" tau-org-root)
  "Task file."
  :type 'file
  :group 'tau-org)


(defcustom tau-org-index-file
  (expand-file-name "index.org" tau-org-root)
  "Top-level index file."
  :type 'file
  :group 'tau-org)


(defcustom tau-org-attachments-directory
  (expand-file-name "attachments/" tau-org-root)
  "Directory for manually managed attachments."
  :type 'directory
  :group 'tau-org)


(setq org-directory tau-org-root)


;;;; ================================================================
;;;; Agenda
;;;; ================================================================

;; Knowledge notes are deliberately NOT placed in `org-agenda-files'.
;;
;; This keeps agenda generation fast even when the permanent knowledge
;; base contains thousands of files.

(setq org-agenda-files
      (list tau-org-inbox-file
            tau-org-tasks-file))


;;;; ================================================================
;;;; Basic Org behaviour
;;;; ================================================================

(setq
 ;; ------------------------------------------------------------
 ;; Startup
 ;; ------------------------------------------------------------

 org-startup-folded 'content

 ;; Do not automatically render every LaTeX fragment when opening
 ;; potentially large mathematical notes.
 org-startup-with-latex-preview nil

 ;; Display inline images automatically.
 org-startup-with-inline-images t


 ;; ------------------------------------------------------------
 ;; Appearance
 ;; ------------------------------------------------------------

 org-ellipsis " …"

 ;; Keep markup delimiters visible while editing.
 ;;
 ;; Example:
 ;;
 ;;     *bold*
 ;;     /italic/
 ;;
 ;; This is preferable for technical plain-text documents.
 org-hide-emphasis-markers nil

 org-cycle-separator-lines 2


 ;; ------------------------------------------------------------
 ;; Editing
 ;; ------------------------------------------------------------

 org-special-ctrl-a/e t
 org-special-ctrl-k t

 ;; RET on a link follows the link.
 org-return-follows-link t


 ;; ------------------------------------------------------------
 ;; Source blocks
 ;; ------------------------------------------------------------

 org-src-fontify-natively t
 org-src-tab-acts-natively t
 org-src-preserve-indentation t


 ;; ------------------------------------------------------------
 ;; Logging
 ;; ------------------------------------------------------------

 org-log-done 'time
 org-log-into-drawer t)

;; Org 9.8 renamed `org-edit-src-content-indentation' to
;; `org-src-content-indentation'; the old name is obsolete and setting
;; it has no effect any more.  The old name is kept as a fallback for
;; older Org versions.
(with-suppressed-warnings ((obsolete org-edit-src-content-indentation))
  (if (boundp 'org-src-content-indentation)
      (setq org-src-content-indentation 0)
    (setq org-edit-src-content-indentation 0)))


;;;; ================================================================
;;;; Org-mode buffer setup
;;;; ================================================================

(defun tau-org-mode-setup ()
  "Configure an Org buffer for technical note taking."
  (visual-line-mode 1)
  (org-indent-mode 1)

  ;; Good prose width for mathematical notes.
  (setq-local fill-column 88)

  ;; Line numbers usually add little value to prose-heavy Org notes.
  (when (fboundp 'display-line-numbers-mode)
    (display-line-numbers-mode -1)))


(add-hook 'org-mode-hook #'tau-org-mode-setup)


;;;; ================================================================
;;;; Mathematics and LaTeX
;;;; ================================================================

(setq
 ;; Highlight LaTeX fragments.
 org-highlight-latex-and-related
 '(latex script entities)

 ;; Display entities such as \alpha as α where appropriate.
 org-pretty-entities t

 ;; Pretty-print explicit braced subscripts and superscripts.
 org-pretty-entities-include-sub-superscripts t

 ;; Very important for technical notes.
 ;;
 ;;     x_i       -> ordinary text
 ;;     x_{i}     -> subscript
 ;;
 ;; This prevents accidental interpretation of identifiers such as:
 ;;
 ;;     wave_function
 ;;     metric_tensor
 ;;     R_s
 ;;
 org-use-sub-superscripts '{})


;; Increase preview size slightly.
(setq org-format-latex-options
      (plist-put org-format-latex-options :scale 1.4))


;; SVG gives excellent results on HiDPI displays.
(when (executable-find "dvisvgm")
  (setq org-preview-latex-default-process 'dvisvgm))


;;;; ================================================================
;;;; org-id -- stable knowledge graph
;;;; ================================================================

(setq
 ;; Prefer globally stable ID links.
 ;;
 ;; Instead of:
 ;;
 ;;     [[file:foo.org::*Noether theorem]]
 ;;
 ;; use:
 ;;
 ;;     [[id:UUID][Noether theorem]]
 ;;
 org-id-link-to-org-use-id t

 ;; Give each linked heading its own ID rather than reusing the ID of
 ;; an ancestor heading.
 org-id-link-consider-parent-id nil

 ;; UUIDs are appropriate for long-lived knowledge nodes.
 org-id-method 'uuid

 ;; Maintain the global ID location database.
 org-id-track-globally t)


;;;; ================================================================
;;;; Native Org global commands
;;;; ================================================================

(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "C-c a") #'org-agenda)


;;;; ================================================================
;;;; Native minibuffer completion
;;;; ================================================================

;; Persist minibuffer history between Emacs sessions.
(savehist-mode 1)


;; Emacs' built-in Fido/icomplete is only used as a fallback when no
;; other completion UI is available.  Vertico (see
;; `init-completion.el') is this configuration's UI of choice, and the
;; two are mutually exclusive: they both install themselves into the
;; minibuffer, which results in duplicated candidates and broken
;; completion when both are active.  `init-completion.el' therefore
;; turns Fido/icomplete off again before enabling Vertico.
(when (and (fboundp 'fido-vertical-mode)
           (not (fboundp 'vertico-mode)))
  (fido-mode 1)
  (fido-vertical-mode 1))


(setq completion-ignore-case t
      read-file-name-completion-ignore-case t)


;;;; ================================================================
;;;; Capture
;;;; ================================================================

(setq org-capture-templates
      `(("i"
         "Inbox"
         entry
         (file ,tau-org-inbox-file)
         "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")

        ("t"
         "Task"
         entry
         (file ,tau-org-tasks-file)
         "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")))


;;;; ================================================================
;;;; External executable helpers
;;;; ================================================================

(defun tau-org--fd-program ()
  "Return the executable used for fd.

Some Linux distributions install fd under the name `fdfind'."
  (or (executable-find "fd")
      (executable-find "fdfind")))


(defun tau-org--rg-program ()
  "Return the ripgrep executable."
  (executable-find "rg"))


(defun tau-org--process-lines (program &rest args)
  "Run PROGRAM with ARGS and return its output as a list of lines.

Exit status 0 means matches/results were found.

Exit status 1 is also accepted because ripgrep uses status 1 to mean
that no matching lines were found."
  (with-temp-buffer
    (let ((status
           (apply #'process-file
                  program
                  nil
                  t
                  nil
                  args)))

      (unless (or (= status 0)
                  (= status 1))
        (error "%s failed with exit status %s"
               program
               status))

      (split-string
       (buffer-string)
       "\n"
       t))))


(defun tau-org--shell-command (program args)
  "Construct a safely shell-quoted command from PROGRAM and ARGS."
  (mapconcat
   #'shell-quote-argument
   (cons program args)
   " "))


;;;; ================================================================
;;;; Find all Org files
;;;; ================================================================

(defun tau-org-files ()
  "Return all Org files below `tau-org-root'.

Use fd when available.  Fall back to pure Emacs directory traversal
otherwise."
  (let ((fd (tau-org--fd-program)))

    (if fd

        (let ((default-directory tau-org-root))
          (mapcar
           (lambda (file)
             (expand-file-name file tau-org-root))

           (tau-org--process-lines
            fd
            "--hidden"
            "--no-ignore"
            "--exclude"
            ".git"
            "--type"
            "f"
            "--extension"
            "org"
            ".")))

      ;; Pure Emacs fallback.
      (directory-files-recursively
       tau-org-root
       "\\.org\\'"))))


;;;; ================================================================
;;;; Find Org file
;;;; ================================================================

(defun tau-org-find-file ()
  "Interactively select and visit an Org file in the knowledge base."
  (interactive)

  (let* ((files
          (tau-org-files))

         (table
          (mapcar
           (lambda (file)
             (cons
              (file-relative-name
               file
               tau-org-root)
              file))
           files))

         (choice
          (completing-read
           "Org file: "
           table
           nil
           t)))

    (find-file
     (cdr
      (assoc choice table)))))


;;;; ================================================================
;;;; Note filename generation
;;;; ================================================================

(defun tau-org--slugify (title)
  "Convert TITLE into a reasonably filesystem-friendly filename slug.

Unicode characters, including Chinese characters, are preserved."
  (let ((slug
         (downcase
          (string-trim title))))

    ;; Whitespace -> hyphen.
    (setq slug
          (replace-regexp-in-string
           "[[:space:]]+"
           "-"
           slug))

    ;; Remove characters that cause problems on common filesystems.
    (setq slug
          (replace-regexp-in-string
           "[/\\\\:*?\"<>|]"
           "-"
           slug))

    ;; Collapse repeated hyphens.
    (setq slug
          (replace-regexp-in-string
           "-+"
           "-"
           slug))

    ;; Remove leading/trailing hyphens.
    (setq slug
          (string-trim slug "-" "-"))

    (if (string-empty-p slug)
        "note"
      slug)))


;;;; ================================================================
;;;; Create atomic note
;;;; ================================================================

(defun tau-org-new-note (title area)
  "Create a new permanent note named TITLE under AREA.

The first headline receives a globally unique Org ID."
  (interactive
   (list
    (read-string "Title: ")

    (completing-read
     "Area: "
     '("math"
       "physics"
       "methods"
       "references")
     nil
     t
     nil
     nil
     "physics")))

  (let* ((directory
          (expand-file-name
           (concat area "/")
           tau-org-notes-directory))

         (filename
          (format
           "%s--%s.org"
           (format-time-string
            "%Y%m%dT%H%M%S")
           (tau-org--slugify title)))

         (file
          (expand-file-name
           filename
           directory)))

    (make-directory directory t)

    (when (file-exists-p file)
      (user-error "File already exists: %s" file))

    (find-file file)

    (insert
     (format
      "#+title: %s\n#+filetags: :%s:\n#+startup: content\n\n* %s\n"
      title
      area
      title))

    ;; Move back onto the root headline.
    (forward-line -1)

    ;; Create stable node identity.
    (org-id-get-create)

    (org-entry-put
     nil
     "CREATED"
     (format-time-string
      "[%Y-%m-%d %a %H:%M]"))

    ;; Continue writing below the headline.
    (goto-char (point-max))
    (insert "\n")

    (save-buffer)))


;;;; ================================================================
;;;; Knowledge-node index
;;;; ================================================================

(defun tau-org-node-index ()
  "Return all Org headings in the knowledge base carrying an ID.

Each result has the form:

  (:title TITLE
   :id    ID
   :file  FILE
   :line  LINE)

ripgrep is used to locate relevant lines quickly.  No external
database or third-party Emacs package is required."
  (let ((rg (tau-org--rg-program)))

    (unless rg
      (user-error "ripgrep executable `rg' was not found"))

    (let ((default-directory tau-org-root)

          ;; Remember most recently encountered headline per file.
          (last-heading
           (make-hash-table :test #'equal))

          nodes)

      (dolist
          (json-line
           (tau-org--process-lines
            rg
            "--json"
            "--hidden"
            "--no-ignore"
            "--glob"
            "!.git/**"
            "--glob"
            "*.org"
            "--regexp"
            "^(\\*+ .+|[ \t]*:ID:[ \t]+\\S+[ \t]*)$"
            "."))

        (let ((object
               (ignore-errors
                 (json-parse-string json-line))))

          (when
              (and object
                   (equal
                    (gethash "type" object)
                    "match"))

            (let* ((data
                    (gethash "data" object))

                   (path-data
                    (gethash "path" data))

                   (lines-data
                    (gethash "lines" data))

                   (relative-file
                    (gethash "text" path-data))

                   (file
                    (expand-file-name
                     relative-file
                     tau-org-root))

                   (line-number
                    (gethash "line_number" data))

                   (text
                    (string-trim-right
                     (gethash "text" lines-data))))

              (cond

               ;; -------------------------------------------------
               ;; Headline
               ;; -------------------------------------------------

               ((string-match
                 "\\`\\(\\*+\\)[ \t]+\\(.+\\)\\'"
                 text)

                (puthash
                 file
                 (list
                  :title
                  (string-trim
                   (match-string 2 text))

                  :line
                  line-number)
                 last-heading))


               ;; -------------------------------------------------
               ;; ID property
               ;; -------------------------------------------------

               ((string-match
                 "\\`[ \t]*:ID:[ \t]+\\([^[:space:]]+\\)"
                 text)

                (let ((heading
                       (gethash
                        file
                        last-heading)))

                  (when heading
                    (push
                     (list
                      :title
                      (plist-get
                       heading
                       :title)

                      :id
                      (match-string
                       1
                       text)

                      :file
                      file

                      :line
                      (plist-get
                       heading
                       :line))

                     nodes)))))))))

      ;; Alphabetical ordering gives predictable native minibuffer
      ;; completion.
      (sort
       nodes
       (lambda (a b)
         (string-lessp
          (downcase
           (plist-get a :title))
          (downcase
           (plist-get b :title))))))))


;;;; ================================================================
;;;; Read/select knowledge node
;;;; ================================================================

(defun tau-org-read-node ()
  "Interactively select an Org ID node and return its node plist."
  (let ((nodes
         (tau-org-node-index)))

    (unless nodes
      (user-error
       "No headings with :ID: properties were found"))

    (let* ((table
            (mapcar
             (lambda (node)
               (cons
                (format
                 "%s  —  %s:%d"
                 (plist-get
                  node
                  :title)

                 (file-relative-name
                  (plist-get
                   node
                   :file)
                  tau-org-root)

                 (plist-get
                  node
                  :line))
                node))
             nodes))

           (choice
            (completing-read
             "Node: "
             table
             nil
             t)))

      (cdr
       (assoc choice table)))))


;;;; ================================================================
;;;; Jump to node
;;;; ================================================================

(defun tau-org-find-node ()
  "Select an Org ID node and jump to it."
  (interactive)

  (let* ((node
          (tau-org-read-node))

         (file
          (plist-get
           node
           :file))

         (line
          (plist-get
           node
           :line)))

    (find-file file)

    (widen)

    (goto-char
     (point-min))

    (forward-line
     (1- line))

    ;; `org-show-context' is obsolete since Org 9.6 and is only kept as a
    ;; fallback for older Org versions.
    (with-suppressed-warnings ((obsolete org-show-context))
      (if (fboundp 'org-fold-show-context)
          (org-fold-show-context)
        (org-show-context)))

    (recenter)))


;;;; ================================================================
;;;; Insert node link
;;;; ================================================================

(defun tau-org-insert-node-link ()
  "Select a knowledge node and insert a stable Org ID link.

The inserted form is conceptually:

  [[id:UUID][Node title]]"
  (interactive)

  (unless (derived-mode-p 'org-mode)
    (user-error
     "Current buffer is not an Org buffer"))

  (let* ((node
          (tau-org-read-node))

         (id
          (plist-get
           node
           :id))

         (title
          (plist-get
           node
           :title)))

    (insert
     (org-link-make-string
      (concat
       "id:"
       id)
      title))))


;;;; ================================================================
;;;; Current knowledge node
;;;; ================================================================

(defun tau-org-current-node ()
  "Return the current Org node.

If the current heading has no ID, create one.

The result is a plist:

  (:id ID :title TITLE)"
  (unless (derived-mode-p 'org-mode)
    (user-error
     "Current buffer is not an Org buffer"))

  (save-excursion

    (when (org-before-first-heading-p)
      (user-error
       "Point is before the first Org heading"))

    (org-back-to-heading t)

    (let ((id
           (org-id-get-create))

          (title
           (org-get-heading
            t
            t
            t
            t)))

      (list
       :id
       id

       :title
       title))))


;;;; ================================================================
;;;; Backlinks
;;;; ================================================================

(defun tau-org-backlinks ()
  "Show all Org links pointing to the current node.

Backlinks are found dynamically with ripgrep.

Results are displayed in `grep-mode', so RET can be used to jump
directly to the source location."
  (interactive)

  (let ((rg
         (tau-org--rg-program)))

    (unless rg
      (user-error
       "ripgrep executable `rg' was not found"))

    (let* ((node
            (tau-org-current-node))

           (id
            (plist-get
             node
             :id))

           ;; Searching for "id:UUID" deliberately does not match the
           ;; :ID: property itself.
           (needle
            (concat
             "id:"
             id))

           (default-directory
            tau-org-root)

           (command
            (tau-org--shell-command
             rg
             (list
              "--line-number"
              "--no-heading"
              "--with-filename"
              "--color=never"
              "--hidden"
              "--no-ignore"
              "--fixed-strings"
              "--glob"
              "!.git/**"
              "--glob"
              "*.org"
              needle
              "."))))

      (grep command))))


;;;; ================================================================
;;;; Full-text search
;;;; ================================================================

(defun tau-org-rg-search (query &optional literal)
  "Search all Org notes using ripgrep.

QUERY is interpreted as a regular expression by default.

With prefix argument LITERAL, QUERY is searched literally using
ripgrep's `--fixed-strings' mode.

Examples:

    C-c n s
        regexp search

    C-u C-c n s
        literal search"
  (interactive
   (list
    (read-string
     (if current-prefix-arg
         "Org literal search: "
       "Org regexp search: ")
     (thing-at-point
      'symbol
      t))

    current-prefix-arg))

  (let ((rg
         (tau-org--rg-program)))

    (unless rg
      (user-error
       "ripgrep executable `rg' was not found"))

    (let* ((default-directory
            tau-org-root)

           (args
            (append
             (list
              "--line-number"
              "--no-heading"
              "--with-filename"
              "--color=never"
              "--smart-case"
              "--hidden"
              "--no-ignore"
              "--glob"
              "!.git/**"
              "--glob"
              "*.org")

             (when literal
               (list
                "--fixed-strings"))

             (list
              query
              "."))))

      (grep
       (tau-org--shell-command
        rg
        args)))))


;;;; ================================================================
;;;; Refresh org-id database
;;;; ================================================================

(defun tau-org-refresh-id-db ()
  "Rebuild the global Org ID location database.

This is particularly useful after:

  - importing an existing collection of Org files;
  - moving many files outside Emacs;
  - changing the directory hierarchy from the shell;
  - pulling many changed notes from Git."
  (interactive)

  (let ((files
         (tau-org-files)))

    (unless files
      (user-error
       "No Org files found under %s"
       tau-org-root))

    ;; Make the entire knowledge base known to org-id.
    (setq org-id-extra-files files)

    (org-id-update-id-locations
     files)

    (message
     "Org ID database refreshed: %d files"
     (length files))))


;;;; ================================================================
;;;; Create required directory structure
;;;; ================================================================

(defun tau-org-initialize-directories ()
  "Create the standard directory structure for the knowledge base."
  (interactive)

  (dolist
      (directory
       (list
        tau-org-root

        tau-org-notes-directory

        (expand-file-name
         "math/"
         tau-org-notes-directory)

        (expand-file-name
         "physics/"
         tau-org-notes-directory)

        (expand-file-name
         "methods/"
         tau-org-notes-directory)

        (expand-file-name
         "references/"
         tau-org-notes-directory)

        tau-org-attachments-directory))

    (make-directory
     directory
     t))

  ;; Ensure principal files exist.
  (dolist
      (file
       (list
        tau-org-inbox-file
        tau-org-tasks-file
        tau-org-index-file))

    (unless
        (file-exists-p file)
      (write-region
       ""
       nil
       file)))

  (message
   "Initialized Org directory: %s"
   tau-org-root))


;;;; ================================================================
;;;; Prefix keymap
;;;; ================================================================

(defvar tau-org-note-map
  (make-sparse-keymap)
  "Prefix keymap for Tau Org knowledge-base commands.")


;; Main prefix:
;;
;;     C-c n
;;
(define-key
 global-map
 (kbd "C-c n")
 tau-org-note-map)


;; Create new permanent note.
(define-key
 tau-org-note-map
 (kbd "n")
 #'tau-org-new-note)


;; Find Org file.
(define-key
 tau-org-note-map
 (kbd "f")
 #'tau-org-find-file)


;; Jump to knowledge node.
(define-key
 tau-org-note-map
 (kbd "j")
 #'tau-org-find-node)


;; Insert ID link to another knowledge node.
(define-key
 tau-org-note-map
 (kbd "i")
 #'tau-org-insert-node-link)


;; Show backlinks to current node.
(define-key
 tau-org-note-map
 (kbd "b")
 #'tau-org-backlinks)


;; Full-text ripgrep search.
(define-key
 tau-org-note-map
 (kbd "s")
 #'tau-org-rg-search)


;; Rebuild org-id location database.
(define-key
 tau-org-note-map
 (kbd "R")
 #'tau-org-refresh-id-db)


;;;; ================================================================
;;;; Convenience keybindings inside Org
;;;; ================================================================

(with-eval-after-load 'org

  ;; Explicitly create an ID for current heading.
  (define-key
   org-mode-map
   (kbd "C-c n I")
   #'org-id-get-create))


;;;; ================================================================
;;;; Finalization
;;;; ================================================================

(provide 'init-org)
