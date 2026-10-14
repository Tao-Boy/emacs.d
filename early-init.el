;;; early-init.el --- Early initialization -*- lexical-binding: t; no-byte-compile: t; -*-

;;; Commentary:

;; Loaded before the package system and the first GUI frame are
;; initialized.  Only settings that must take effect that early live
;; here: garbage collection, startup-only I/O shortcuts, the package
;; activation strategy, native compilation and frame parameters.
;;
;; Targets Emacs 31.1.  Ideas taken from minimal-emacs.d, Doom Emacs,
;; Centaur Emacs and Purcell's emacs.d.

;;; Code:

;;;; Garbage collection

;; Postpone GC for the whole of startup; `init-basic' installs the
;; run-time policy afterwards.  Batch jobs (byte-compilation, scripts)
;; run before `emacs-startup-hook', so they get a large but finite
;; threshold instead of an unbounded one.
(setq gc-cons-threshold (if noninteractive
                            (* 128 1024 1024)
                          most-positive-fixnum)
      gc-cons-percentage 1.0)

;;;; Startup-only I/O shortcuts

;; Every `load' and `require' consults `file-name-handler-alist' for
;; each candidate file name.  Skip it while the init files load.  The
;; gzip handler is kept when Emacs's own Lisp is installed compressed.
;;
;; The handlers are restored in `after-init-hook', which runs before
;; the files named on the command line are visited, so `emacs foo.gz'
;; and `emacs /ssh:host:file' keep working.
(unless (or (daemonp) noninteractive init-file-debug)
  (let ((saved file-name-handler-alist))
    (setq file-name-handler-alist
          (unless (locate-file-internal "calc-loaddefs.el" load-path)
            (list (rassq 'jka-compr-handler saved))))
    (add-hook 'after-init-hook
              (lambda ()
                (setq file-name-handler-alist
                      (delete-dups (append file-name-handler-alist saved))))
              101)))

;; Emacs 31: cache the contents of `load-path' directories so that each
;; `require' looks only at directories that actually contain the file.
;; The filter calls `regexp-opt', which is not preloaded: load it first,
;; or autoloading it from inside the filter recurses until
;; `max-lisp-eval-depth' is exceeded.
(require 'regexp-opt)
(setq load-path-filter-function #'load-path-filter-cache-directory-files)

;;;; Packages

;; Let Emacs activate packages before `init.el' through a single
;; precomputed autoloads file (`package-quickstart-file') instead of
;; scanning every package directory.  `package-install' and
;; `package-upgrade' refresh that file automatically.
(setq package-enable-at-startup t
      package-quickstart t)

;;;; Native compilation

(when (featurep 'native-compile)
  ;; Compile packages to native code when they are installed rather
  ;; than on first use.  JIT compilation (the default) stays on for
  ;; built-in libraries such as Org.
  (setq package-native-compile t
        native-comp-async-report-warnings-errors 'silent
        native-comp-warning-on-missing-source nil))

;;;; Frames

;; Disable GUI chrome through frame parameters, before the first frame
;; is created: cheaper than calling the minor modes and no flicker.
;; The mode variables are set too, so toggling them later works.
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(horizontal-scroll-bars) default-frame-alist)
(setq menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil)

;; Paint the first frame with the theme's colors (doom-tokyo-night) so
;; there is no white flash before `init-ui' loads the theme.
(push '(background-color . "#1a1b26") default-frame-alist)
(push '(foreground-color . "#a9b1d6") default-frame-alist)

(setq frame-inhibit-implied-resize t      ; Don't resize frames on font changes.
      frame-resize-pixelwise t
      inhibit-startup-screen t
      inhibit-x-resources t               ; Skip the X resource database.
      inhibit-compacting-font-caches t)   ; Large CJK fonts stay cached.

;;; early-init.el ends here
