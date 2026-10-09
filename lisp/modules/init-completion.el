;;; init-completion.el --- Completion on first use -*- lexical-binding: t; -*-

;; Declarations let this module compile without eagerly loading its UI libraries.
(defvar corfu-auto)
(defvar corfu-auto-delay)
(defvar corfu-auto-prefix)
(defvar corfu-quit-no-match)
(defvar corfu-map)
(defvar vertico-cycle)
(defvar vertico-count)
(defvar savehist-file)
(declare-function corfu-insert "corfu")
(declare-function corfu-mode "corfu" (&optional arg))
(declare-function vertico-mode "vertico" (&optional arg))
(declare-function marginalia-mode "marginalia" (&optional arg))

(require 'tau-core)
(setq corfu-auto t
      corfu-auto-delay 0
      corfu-auto-prefix 1
      corfu-quit-no-match 'separator
      vertico-cycle t
      vertico-count 8
      completion-ignore-case t
      read-file-name-completion-ignore-case t)

(defvar tau-completion-ready nil
  "Non-nil after minibuffer completion has been initialized.")

(defun tau-completion-enable (&rest _)
  "Initialize completion before the first interactive command or read."
  (unless tau-completion-ready
    (when (require 'orderless nil t)
      (setq completion-styles '(orderless basic)
            completion-category-defaults nil
            completion-category-overrides '((file (styles partial-completion)))))
    (if (require 'vertico nil t)
        (progn
          (when (bound-and-true-p fido-vertical-mode) (fido-vertical-mode -1))
          (when (bound-and-true-p fido-mode) (fido-mode -1))
          (when (bound-and-true-p icomplete-mode) (icomplete-mode -1))
          (vertico-mode 1))
      (fido-vertical-mode 1))
    (when (require 'marginalia nil t) (marginalia-mode 1))
    (make-directory tau-state-directory t)
    (setq savehist-file (tau-state-file "history"))
    (tau-state-migrate-file "history" savehist-file)
    (savehist-mode 1)
    (setq tau-completion-ready t)
    (remove-hook 'pre-command-hook #'tau-completion-enable)
    (dolist (function '(completing-read read-file-name read-buffer))
      (advice-remove function #'tau-completion-enable))))

;; Runs before M-x or other commands enter a minibuffer.  Public read entry
;; points also cover Lisp calls outside the interactive command loop.
(add-hook 'pre-command-hook #'tau-completion-enable)
(dolist (function '(completing-read read-file-name read-buffer))
  (advice-add function :before #'tau-completion-enable))

(defun tau-corfu-enable ()
  "Enable in-buffer completion when Corfu is installed."
  (when (fboundp 'corfu-mode) (corfu-mode 1)))
(add-hook 'prog-mode-hook #'tau-corfu-enable)
(with-eval-after-load 'corfu
  (define-key corfu-map (kbd "TAB") nil)
  (define-key corfu-map (kbd "RET") #'corfu-insert))

(provide 'init-completion)
;;; init-completion.el ends here
