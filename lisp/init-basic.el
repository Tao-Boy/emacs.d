;;; init-basic.el --- Better defaults -*- lexical-binding: t; -*-

;;; Commentary:

;; Built-in settings: run-time GC policy, deferred-loading hooks,
;; encoding, files, minibuffer, editing and session persistence.

;;; Code:

;;;; Garbage collection

(defvar tau-gc-cons-threshold (* 64 1024 1024)
  "Value of `gc-cons-threshold' after startup.")

(defun tau--gc-defer ()
  "Don't collect garbage until `tau--gc-restore'."
  (setq gc-cons-threshold most-positive-fixnum))

(defun tau--gc-restore ()
  "Restore the run-time GC threshold, unless a minibuffer is still open.
`minibuffer-exit-hook' runs while the exited minibuffer still counts
towards `minibuffer-depth', so with recursive minibuffers the threshold
stays raised until the outermost one exits."
  (when (<= (minibuffer-depth) 1)
    (setq gc-cons-threshold tau-gc-cons-threshold)))

(defun tau--gc-when-unfocused ()
  "Collect garbage when Emacs loses focus, when a pause goes unnoticed."
  (unless (frame-focus-state)
    (garbage-collect)))

;; The minibuffer hooks are installed only after startup, so that a
;; prompt shown while the init files load cannot end the startup GC
;; pause early.  Completion UIs allocate a lot; don't GC while the
;; minibuffer is open.
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold tau-gc-cons-threshold
                  gc-cons-percentage 0.1)
            (add-hook 'minibuffer-setup-hook #'tau--gc-defer)
            (add-hook 'minibuffer-exit-hook #'tau--gc-restore)
            (add-function :after after-focus-change-function
                          #'tau--gc-when-unfocused)))

;;;; Deferred loading

(defvar tau-first-input-hook nil
  "Transient hook run once, before the first interactive command.
Global modes that are not needed to draw the first frame are enabled
here instead of during startup.")

(defun tau--run-first-input-hook ()
  "Run and clear `tau-first-input-hook'."
  (remove-hook 'pre-command-hook #'tau--run-first-input-hook)
  (run-hooks 'tau-first-input-hook)
  (setq tau-first-input-hook nil))

(add-hook 'pre-command-hook #'tau--run-first-input-hook -100)

;;;; Startup

(setq initial-scratch-message nil
      ;; `lisp-interaction-mode' would run `prog-mode-hook' (and load
      ;; Corfu, rainbow-delimiters, ...) for *scratch* during startup.
      initial-major-mode 'fundamental-mode)

;;;; Performance

(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right
              cursor-in-non-selected-windows nil)

(setq bidi-inhibit-bpa t
      highlight-nonselected-windows nil
      fast-but-imprecise-scrolling t
      redisplay-skip-fontification-on-input t
      read-process-output-max (* 1024 1024)  ; LSP servers send large replies.
      process-adaptive-read-buffering nil
      ffap-machine-p-known 'reject           ; Don't ping hostnames at point.
      auto-mode-case-fold nil)

;;;; Encoding

(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)

;;;; Files

(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      require-final-newline t
      vc-follow-symlinks t
      delete-by-moving-to-trash t)

;; Revert buffers whose files changed on disk.
(use-package autorevert
  :hook (tau-first-input . global-auto-revert-mode)
  :custom
  (auto-revert-avoid-polling t)             ; Use file notifications.
  (auto-revert-check-vc-info nil)
  (global-auto-revert-non-file-buffers t)
  (auto-revert-verbose nil))

;; Disable expensive modes in buffers with very long lines.
(use-package so-long
  :hook (tau-first-input . global-so-long-mode))

;;;; Interaction

(setq use-short-answers t
      y-or-n-p-use-read-key t
      use-dialog-box nil
      ring-bell-function #'ignore
      enable-recursive-minibuffers t
      ;; Hide commands that don't apply to the current mode from M-x.
      read-extended-command-predicate #'command-completion-default-include-p
      ;; Keep the cursor out of the minibuffer prompt.
      minibuffer-prompt-properties '(read-only t cursor-intangible t
                                     face minibuffer-prompt)
      help-window-select t)

(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

(use-package which-key
  :hook (tau-first-input . which-key-mode)
  :custom (which-key-idle-delay 0.5))

;;;; Editing

(setq-default indent-tabs-mode nil
              tab-width 4)

(setq kill-do-not-save-duplicates t
      save-interprogram-paste-before-kill t
      sentence-end-double-space nil)

;;;; Session state

(use-package savehist
  :hook (tau-first-input . savehist-mode)
  :custom
  (history-length 1000)
  (history-delete-duplicates t))

(use-package recentf
  :hook (tau-first-input . recentf-mode)
  :custom
  (recentf-max-saved-items 300)
  (recentf-auto-cleanup 'never)            ; Don't stat every entry on start.
  (recentf-autosave-interval 300)          ; Emacs 31.
  (recentf-show-messages nil)              ; Emacs 31.
  (recentf-exclude `(,(regexp-quote (locate-user-emacs-file "elpa/"))
                     "/tmp/" "\\`/[^/]+:" "COMMIT_EDITMSG\\'")))

;; Cheap at startup (the places file is read lazily), and it has to be
;; active before the first file is visited.
(use-package saveplace
  :demand t
  :custom (save-place-autosave-interval 300) ; Emacs 31.
  :config (save-place-mode 1))

(provide 'init-basic)
;;; init-basic.el ends here
