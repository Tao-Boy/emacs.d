;; -*- lexical-binding: t; -*-

(defconst sys/win32p
  (eq system-type 'windows-nt)
  "Is running on a WinTel system?")

(defconst sys/linuxp
  (eq system-type 'gnu/linux)
  "Is running on a GNU/Linux system?")

(defconst sys/macp
  (eq system-type 'darwin)
  "Is running on a Mac system?")

(provide 'init-const)
