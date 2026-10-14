;;; init.el --- Main configuration entry point -*- lexical-binding: t; -*-

;;; Commentary:

;; Loads the modules under `lisp/' in dependency order.  Each module is
;; a plain feature (`init-*'), so a single module can be reloaded with
;; `M-x load-library'.  See README.md for the layout and for the
;; startup performance techniques in use.

;;; Code:

(when (version< emacs-version "31.1")
  (display-warning 'init (format "This configuration targets Emacs 31.1; \
running %s, some features will be missing or broken." emacs-version)))

;;;; Load path

(dolist (dir '("lisp" "site-lisp"))
  (let ((path (expand-file-name dir user-emacs-directory)))
    (when (file-directory-p path)
      (push path load-path))))

;;;; Modules

(require 'init-const)
(require 'init-package)      ; package.el + use-package
(require 'init-basic)        ; Better defaults, GC policy, session state
(require 'init-ui)           ; Theme, fonts, mode line, scrolling
(require 'init-evil)
(require 'init-completion)   ; Vertico, Orderless, Marginalia, Corfu
(require 'init-snippet)      ; Tempel, AAS
(require 'init-dired)
(require 'init-prog)         ; Tree-sitter, Eglot, programming defaults
(require 'init-latex)        ; AUCTeX
(require 'init-org)          ; Org and Denote

;;;; Customize

;; Loaded last so that settings saved through Customize win.
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror 'nomessage)

;;;; Startup report

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs ready in %s with %d garbage collections."
                     (emacs-init-time "%.3fs") gcs-done)))

;;; init.el ends here
