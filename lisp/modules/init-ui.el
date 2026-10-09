;;; init-ui.el --- Theme and frame appearance -*- lexical-binding: t; -*-

(declare-function set-fontset-font "fontset.c" (name target font-spec &optional frame add))

(require 'tau-core)
(defcustom tau-theme 'doom-tokyo-night
  "Preferred theme; use a built-in theme if it is unavailable."
  :type 'symbol :group 'tau)
(defcustom tau-fonts '("IosevkaTerm NFM" "Ioskeley Mono" "monospace")
  "Default font families in preference order."
  :type '(repeat string) :group 'tau)
(defcustom tau-zh-fonts '("LXGW WenKai Mono")
  "Han font families in preference order."
  :type '(repeat string) :group 'tau)
(defcustom tau-font-height 150
  "Default font height in tenths of a point."
  :type 'integer :group 'tau)

(defun tau-set-font (&rest fonts)
  "Set the first available member of FONTS on the selected GUI frame."
  (when (display-graphic-p)
    (catch 'found
      (dolist (font fonts)
        (when (find-font (font-spec :family font))
          (set-face-attribute 'default (selected-frame)
                              :family font :height tau-font-height)
          (throw 'found font))))))

(defun tau-set-zh-font (&rest fonts)
  "Set the first available Han font from FONTS on the selected GUI frame."
  (when (display-graphic-p)
    (catch 'found
      (dolist (font fonts)
        (when (find-font (font-spec :family font))
          (set-fontset-font t 'han (font-spec :family font) (selected-frame))
          (throw 'found font))))))

(defun tau-ui-setup-frame (&optional frame)
  "Set fonts for FRAME, including frames created by emacsclient."
  (with-selected-frame (or frame (selected-frame))
    (apply #'tau-set-font tau-fonts)
    (apply #'tau-set-zh-font tau-zh-fonts)
    (when (and (display-graphic-p) (fboundp 'pixel-scroll-precision-mode))
      (pixel-scroll-precision-mode 1))))
(add-hook 'after-init-hook #'tau-ui-setup-frame)
(add-hook 'after-make-frame-functions #'tau-ui-setup-frame)

(with-eval-after-load 'rainbow-delimiters
  (let ((colors '("#FFD700" "#DA70D6" "#179FFF" "#00E5A8" "#FF8C00"
                  "#B56DFF" "#FFD700" "#DA70D6" "#179FFF"))
        (depth 0))
    (dolist (color colors)
      (setq depth (1+ depth))
      (set-face-attribute (intern (format "rainbow-delimiters-depth-%d-face" depth))
                          nil :foreground color)))
  (set-face-attribute 'rainbow-delimiters-unmatched-face nil
                      :foreground "#F44747" :weight 'bold)
  (set-face-attribute 'rainbow-delimiters-mismatched-face nil
                      :foreground "#F44747" :weight 'bold :underline t))

(setq scroll-margin 0
      scroll-conservatively 101
      scroll-preserve-screen-position t)
(when (and (display-graphic-p) (fboundp 'pixel-scroll-precision-mode))
  (pixel-scroll-precision-mode 1))

;; Load before displaying the first frame, avoiding a later theme flash.
(load-theme (if (memq tau-theme (custom-available-themes)) tau-theme 'modus-vivendi) t)

(provide 'init-ui)
;;; init-ui.el ends here
