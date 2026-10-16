;;; init-keybindings.el --- Native key bindings and additions -*- lexical-binding: t; -*-

;;; Commentary:

;; Standard Emacs key bindings, plus a few commands and remaps that make
;; them more convenient.  Nothing here replaces a default binding with
;; something unrelated: the remapped keys do what they did before, only
;; more of it (`C-a' also goes to the indentation, `M-w' copies the line
;; when there is no region, ...).  See README.md for the full list.

;;; Code:

;;;; Global modes

;; `repeat-mode': repeat `C-x o', `C-x {', `C-x u', `M-g n', ... with
;; their last key.  `delete-selection-mode': typed text replaces the
;; active region, as in other editors.
(add-hook 'tau-first-input-hook #'repeat-mode)
(add-hook 'tau-first-input-hook #'delete-selection-mode)

;;;; Editing commands

(defun tau-beginning-of-line (arg)
  "Move to the indentation, or to the beginning of the line if already there.
With ARG not nil or 1, move forward ARG - 1 lines first."
  (interactive "^p")
  (unless (= arg 1)
    (forward-line (1- arg)))
  (let ((start (point)))
    (back-to-indentation)
    (when (= start (point))
      (move-beginning-of-line 1))))

(defun tau-kill-region-or-line (arg)
  "Kill the active region, or the current line (ARG lines) without one."
  (interactive "p")
  (if (region-active-p)
      (kill-region (region-beginning) (region-end))
    (kill-whole-line arg)))

(defun tau-copy-region-or-line (arg)
  "Copy the active region, or the current line (ARG lines) without one."
  (interactive "p")
  (if (region-active-p)
      (kill-ring-save (region-beginning) (region-end))
    (kill-ring-save (line-beginning-position) (line-beginning-position (1+ arg)))
    (message "Copied %d line%s" arg (if (= arg 1) "" "s"))))

(defun tau--move-lines (n)
  "Move the current line, or the lines of the active region, N lines down.
Point and mark keep their place within the moved lines."
  (let* ((region (region-active-p))
         (beg (save-excursion
                (goto-char (if region (region-beginning) (point)))
                (line-beginning-position)))
         (end (save-excursion
                (goto-char (if region (region-end) (point)))
                ;; A region that ends at a line start doesn't include it.
                (when (and region (bolp) (> (point) beg))
                  (backward-char))
                (line-beginning-position 2)))
         (point-offset (- (point) beg))
         (mark-offset (and region (- (mark) beg))))
    ;; The last line of the buffer may lack a newline to move along.
    (when (and (= end (point-max)) (> end beg) (/= (char-before end) ?\n))
      (save-excursion
        (goto-char end)
        (insert "\n")
        (setq end (point))))
    (let ((text (delete-and-extract-region beg end)))
      (goto-char beg)
      (forward-line n)
      (unless (bolp) (insert "\n"))
      (let ((new-beg (point)))
        (insert text)
        (goto-char (+ new-beg point-offset))
        (when region
          (set-mark (+ new-beg mark-offset))
          (setq deactivate-mark nil))))))

(defun tau-move-lines-up (arg)
  "Move the current line or the lines of the region ARG lines up."
  (interactive "p")
  (tau--move-lines (- arg)))

(defun tau-move-lines-down (arg)
  "Move the current line or the lines of the region ARG lines down."
  (interactive "p")
  (tau--move-lines arg))

(defun tau-keyboard-quit-dwim ()
  "Like `keyboard-quit', but also leave a minibuffer from another window.
Deactivate the region if it is active, close the *Completions* window
if it is shown, abort the minibuffer if it is active but not selected,
and otherwise call `keyboard-quit'."
  (interactive)
  (cond
   ((region-active-p) (keyboard-quit))
   ((derived-mode-p 'completion-list-mode) (delete-completion-window))
   ((> (minibuffer-depth) 0) (abort-recursive-edit))
   (t (keyboard-quit))))

;;;; Windows

(defun tau-split-window-below ()
  "Split the selected window in two and select the new, lower window."
  (interactive)
  (select-window (split-window-below)))

(defun tau-split-window-right ()
  "Split the selected window in two and select the new, right window."
  (interactive)
  (select-window (split-window-right)))

;;;; Files

(declare-function dired-current-directory "dired")

(defun tau-copy-file-name (&optional directory)
  "Copy the visited file's name, or the Dired directory, to the kill ring.
With prefix argument DIRECTORY, copy its directory instead."
  (interactive "P")
  (let ((name (or (if (derived-mode-p 'dired-mode)
                      (dired-current-directory)
                    buffer-file-name)
                  (user-error "Buffer is not visiting a file"))))
    (when directory
      (setq name (file-name-directory name)))
    (kill-new (abbreviate-file-name name))
    (message "Copied %s" (abbreviate-file-name name))))

(defun tau-sudo-edit (&optional file)
  "Edit FILE (by default the visited file) as root through TRAMP."
  (interactive
   (list (if (or current-prefix-arg (not buffer-file-name))
             (read-file-name "Find file as root: ")
           buffer-file-name)))
  (when (file-remote-p file)
    (user-error "%s is a remote file" file))
  (let ((point (and (equal file buffer-file-name) (point))))
    (find-file (concat "/sudo::" (expand-file-name file)))
    (when point
      (goto-char point))))

(defvar-keymap tau-file-map
  :doc "Prefix keymap for file commands."
  "r" #'recentf-open                        ; Emacs 29.
  "R" #'rename-visited-file                 ; Emacs 29.
  "y" #'tau-copy-file-name
  "s" #'tau-sudo-edit)

(defvar-keymap tau-toggle-map
  :doc "Prefix keymap for toggling minor modes."
  "l" #'display-line-numbers-mode
  "w" #'visual-line-mode
  "t" #'toggle-truncate-lines
  "s" #'whitespace-mode
  "f" #'toggle-frame-fullscreen)

;;;; Bindings

(dolist (binding
         `(;; Movement and editing.
           ("C-a"       . tau-beginning-of-line)
           ("C-w"       . tau-kill-region-or-line)
           ("M-w"       . tau-copy-region-or-line)
           ("M-z"       . zap-up-to-char)
           ("M-/"       . hippie-expand)
           ("M-<up>"    . tau-move-lines-up)
           ("M-<down>"  . tau-move-lines-down)
           ("C-c d"     . duplicate-dwim)          ; Emacs 29.
           ("C-g"       . tau-keyboard-quit-dwim)
           ;; Buffers, windows and files.
           ("M-o"       . other-window)
           ("C-x 2"     . tau-split-window-below)
           ("C-x 3"     . tau-split-window-right)
           ("C-x k"     . kill-current-buffer)
           ("C-x C-b"   . ibuffer)
           ("C-x C-r"   . recentf-open)
           ("C-c f"     . ,tau-file-map)
           ("C-c t"     . ,tau-toggle-map)))
  (keymap-global-set (car binding) (cdr binding)))

;; `C-z' minimizes graphical frames (and suspends terminal ones) when
;; mistyped for `C-x'; `C-x C-z' still does that.
(keymap-global-unset "C-z")

(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    "C-c f" "file"
    "C-c t" "toggle"))

;;;; Expand region

;; `C-=' selects ever larger syntactic units (tree-sitter nodes when
;; available), `C--' shrinks the selection again.  Negative arguments
;; remain on `M--' and `C-M--'.
(use-package expreg
  :ensure t
  :bind (("C-=" . expreg-expand)
         ("C--" . expreg-contract)))

(provide 'init-keybindings)
;;; init-keybindings.el ends here
