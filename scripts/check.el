;;; check.el --- Isolated offline regression runner -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(defconst tau-check-root
  (file-name-directory (directory-file-name (file-name-directory load-file-name))))
(defconst tau-check-temp (make-temp-file "tau-check-" t))
(setq user-emacs-directory (file-name-as-directory tau-check-temp)
      package-user-dir (or (getenv "TAU_PACKAGE_DIR")
                           (expand-file-name "elpa/" tau-check-root))
      tau-org-root (expand-file-name "org/" tau-check-temp)
      custom-file (expand-file-name "custom.el" tau-check-temp))

;; Optional non-secret paths for distribution-specific package installations.
(when-let* ((setup (getenv "TAU_TEST_SETUP")))
  (load setup nil t))

(defun tau-check-no-network (&rest _)
  "Fail immediately if initialization attempts a network operation."
  (error "Configuration attempted network access"))
;; Advice on autoloaded functions also applies when their library is loaded.
(dolist (function '(package-refresh-contents package-install
                                             url-retrieve url-retrieve-synchronously))
  (advice-add function :override #'tau-check-no-network))

(load (expand-file-name "early-init.el" tau-check-root) nil t)
(load (expand-file-name "init.el" tau-check-root) nil t)
(run-hooks 'after-init-hook 'emacs-startup-hook)
(defconst tau-check-eager-features (copy-sequence features))
(defconst tau-check-initial-commands
  (mapcar (lambda (symbol) (cons symbol (commandp symbol)))
          '(tau-org-files tau-org-current-node tau-org-node-index tau-org-read-node
            tau-org-new-note tau-org-find-node)))
(load (expand-file-name "tests/config-tests.el" tau-check-root) nil t)

(let ((stats (ert-run-tests-batch "^tau-test-")))
  (savehist-mode -1)
  (dolist (buffer (buffer-list))
    (when (and (buffer-file-name buffer)
               (file-in-directory-p (buffer-file-name buffer) tau-check-temp))
      (with-current-buffer buffer (set-buffer-modified-p nil))
      (kill-buffer buffer)))
  (delete-directory tau-check-temp t)
  (kill-emacs (if (zerop (ert-stats-completed-unexpected stats)) 0 1)))

;;; check.el ends here
