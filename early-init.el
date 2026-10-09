;;; early-init.el --- Startup policy -*- lexical-binding: t; -*-

;; Activate packages once, under our control, in `tau-packages'.
(setq package-enable-at-startup nil
      package-quickstart t
      load-prefer-newer t)

;; Bound startup memory.  Keep file handlers intact for TRAMP and compressed
;; Lisp, including files supplied on the command line.
(setq gc-cons-threshold (* 128 1024 1024)
      gc-cons-percentage 0.6)

(defun tau-startup-restore-gc ()
  "Restore steady-state garbage collection."
  (setq gc-cons-threshold (* 16 1024 1024)
        gc-cons-percentage 0.1))

(add-hook 'emacs-startup-hook #'tau-startup-restore-gc)
(setq frame-inhibit-implied-resize t)
(dolist (setting '((menu-bar-lines . 0)
                   (tool-bar-lines . 0)
                   (vertical-scroll-bars . nil)))
  (add-to-list 'default-frame-alist setting))

;;; early-init.el ends here
