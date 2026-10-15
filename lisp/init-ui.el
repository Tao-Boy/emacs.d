;;; init-ui.el --- Appearance -*- lexical-binding: t; -*-

;;; Commentary:

;; Theme, fonts, mode line, cursor, parentheses and scrolling.

;;; Code:

;;;; Theme

(use-package doom-themes
  :ensure t
  :demand t
  :config
  (load-theme 'doom-tokyo-night t))

;;;; Fonts

(defvar tau-font-families '("IosevkaTerm NFM" "Ioskeley Mono" "monospace")
  "Default font candidates, in order of preference.")

(defvar tau-font-height 150
  "Height of the default face, in 1/10 pt.")

(defvar tau-cjk-font-families '("LXGW WenKai Mono")
  "CJK font candidates, in order of preference.")

(defvar tau-emoji-font-families
  '("Noto Color Emoji" "Apple Color Emoji" "Segoe UI Emoji")
  "Emoji font candidates, in order of preference.")

(defun tau--first-font (families)
  "Return the first font family in FAMILIES that is installed."
  (catch 'found
    (dolist (family families)
      (when (find-font (font-spec :family family))
        (throw 'found family)))))

(defun tau-setup-fonts ()
  "Set up fonts on a graphical display.
Return non-nil if the display is graphical."
  (when (display-graphic-p)
    (when-let* ((family (tau--first-font tau-font-families)))
      (set-face-attribute 'default nil :family family :height tau-font-height))
    (when-let* ((family (tau--first-font tau-cjk-font-families)))
      (dolist (charset '(han cjk-misc kana bopomofo))
        (set-fontset-font t charset (font-spec :family family))))
    (when-let* ((family (tau--first-font tau-emoji-font-families)))
      (set-fontset-font t 'emoji (font-spec :family family) nil 'prepend))
    t))

(defun tau--setup-fonts-in-first-gui-frame ()
  "Set up fonts once the daemon creates its first graphical frame."
  (when (tau-setup-fonts)
    (remove-hook 'server-after-make-frame-hook
                 #'tau--setup-fonts-in-first-gui-frame)))

(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'tau--setup-fonts-in-first-gui-frame)
  (tau-setup-fonts))

;;;; Mode line

;; Emacs 31: fold minor-mode lighters into a single button.
(setq mode-line-collapse-minor-modes t)

;;;; Cursor

(blink-cursor-mode -1)

(setq visible-cursor nil
      xterm-update-cursor t)               ; Emacs 31: cursor shape on TTYs.

;;;; Parentheses

;; `show-paren-mode' is on by default.
(setq show-paren-delay 0
      show-paren-context-when-offscreen 'overlay)

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode)
  :config
  ;; Override specs take precedence over the theme and, unlike
  ;; `custom-set-faces', are never written to `custom-file'.
  (dolist (spec '((rainbow-delimiters-depth-1-face :foreground "#FFD700")
                  (rainbow-delimiters-depth-2-face :foreground "#DA70D6")
                  (rainbow-delimiters-depth-3-face :foreground "#179FFF")
                  (rainbow-delimiters-depth-4-face :foreground "#00E5A8")
                  (rainbow-delimiters-depth-5-face :foreground "#FF8C00")
                  (rainbow-delimiters-depth-6-face :foreground "#B56DFF")
                  (rainbow-delimiters-depth-7-face :foreground "#FFD700")
                  (rainbow-delimiters-depth-8-face :foreground "#DA70D6")
                  (rainbow-delimiters-depth-9-face :foreground "#179FFF")
                  (rainbow-delimiters-unmatched-face
                   :foreground "#F44747" :weight bold)
                  (rainbow-delimiters-mismatched-face
                   :foreground "#F44747" :weight bold :underline t)))
    (face-spec-set (car spec) `((t ,(cdr spec))))))

;;;; Scrolling

(setq scroll-margin 0
      scroll-conservatively 101
      scroll-preserve-screen-position t
      auto-window-vscroll nil)

(add-hook 'tau-first-input-hook
          (lambda ()
            (when (or (display-graphic-p) (daemonp))
              (pixel-scroll-precision-mode 1))))

;;;; Terminal

(unless (display-graphic-p)
  ;; The menu bar of the initial terminal frame is created before
  ;; early-init.el can disable it.
  (menu-bar-mode -1)
  ;; Emacs 31 draws child frames (Corfu popups) on TTYs; give them
  ;; Unicode borders.
  (add-hook 'tau-first-input-hook #'standard-display-unicode-special-glyphs))

(provide 'init-ui)
;;; init-ui.el ends here
