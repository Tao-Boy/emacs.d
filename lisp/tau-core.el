;;; tau-core.el --- Shared paths and editor defaults -*- lexical-binding: t; -*-

(defgroup tau nil
  "Tau's Emacs configuration."
  :group 'convenience)

(defcustom tau-modules
  '(init-editor init-completion init-dired init-treesitter init-latex
                init-org init-snippet init-evil init-ui)
  "Modules to load in order.  Override in local.el to select features."
  :type '(repeat symbol)
  :group 'tau)

(defcustom tau-state-directory (locate-user-emacs-file "var/")
  "Directory for generated state.  Source files never belong here."
  :type 'directory
  :group 'tau)

(defun tau-state-file (name)
  "Return the path for NAME under `tau-state-directory'."
  (expand-file-name name tau-state-directory))

(defun tau-state-migrate-file (legacy-name target)
  "Copy LEGACY-NAME from the old state location to TARGET once.
Preserve both the original file and any existing target."
  (let ((legacy (locate-user-emacs-file legacy-name)))
    (when (and (file-readable-p legacy) (not (file-exists-p target)))
      (make-directory (file-name-directory target) t)
      (copy-file legacy target))))

;; Preserve an existing user-selected Custom location, including legacy files.
(setq custom-file (or custom-file (locate-user-emacs-file "custom.el")))

;; Declared without values so external startup/local.el paths take precedence.
(defvar org-id-locations-file)
(defvar org-persist-directory)

(defun tau-core-setup-state ()
  "Route generated Org state after local.el has selected its paths."
  (unless (boundp 'org-id-locations-file)
    (setq org-id-locations-file (tau-state-file "org-id-locations")))
  (unless (boundp 'org-persist-directory)
    (setq org-persist-directory (tau-state-file "org-persist/"))))
(setq inhibit-startup-screen t
      inhibit-startup-message t
      initial-scratch-message nil
      use-short-answers t
      y-or-n-p-use-read-key t
      ring-bell-function #'ignore)

(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)

;; Preserve the original editing policy.
(setq auto-save-default nil
      make-backup-files nil
      create-lockfiles nil
      auto-mode-case-fold nil
      read-process-output-max (* 64 1024))

(provide 'tau-core)
;;; tau-core.el ends here
