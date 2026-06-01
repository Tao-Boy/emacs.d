;; -*- lexical-binding: t; -*-

(when (eq system-type 'darwin)
  (setenv "PATH"
          (concat "/Library/TeX/texbin:/opt/homebrew/bin:"
                  (getenv "PATH")))
  (add-to-list 'exec-path "/Library/TeX/texbin")
  (add-to-list 'exec-path "/opt/homebrew/bin"))
