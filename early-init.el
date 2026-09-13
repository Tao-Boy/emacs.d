;;; -*- lexical-binding: t; -*-

(setq gc-cons-percentage 1.0)
(if noninteractive
    (setq gc-cons-threshold (* 128 1024 1024))
  (setq gc-cons-threshold most-positive-fixnum))

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

(setq read-process-output-max (* 64 1024))

(let ((default-file-name-handler-alist file-name-handler-alist)
      (default-load-suffixes load-suffixes)
      (default-load-file-rep-suffixes load-file-rep-suffixes))
  (setq file-name-handler-alist nil
        load-suffixes '(".elc" ".el")
        load-file-rep-suffixes '(""))
  (add-hook 'emacs-startup-hook
            (lambda ()
              (setq load-suffixes default-load-suffixes
                    load-file-rep-suffixes default-load-file-rep-suffixes
                    file-name-handler-alist default-file-name-handler-alist))
            101))

(when (boundp 'load-path-filter-function)
  (setq load-path-filter-function #'load-path-filter-cache-directory-files))

;; `native-comp-deferred-compilation' is an obsolete name (Emacs 29.1+),
;; and `native-comp-jit-compilation' is the variable that is consulted.
(setq native-comp-jit-compilation nil)

(setq load-prefer-newer noninteractive)

(setq package-enable-at-startup nil)

(setq frame-inhibit-implied-resize t)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
