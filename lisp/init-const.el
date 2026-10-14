;;; init-const.el --- Constants -*- lexical-binding: t; -*-

;;; Commentary:

;; Platform predicates used by the other modules.

;;; Code:

(defconst sys/win32p (eq system-type 'windows-nt)
  "Non-nil on Microsoft Windows.")

(defconst sys/linuxp (eq system-type 'gnu/linux)
  "Non-nil on GNU/Linux.")

(defconst sys/macp (eq system-type 'darwin)
  "Non-nil on macOS.")

(provide 'init-const)
;;; init-const.el ends here
