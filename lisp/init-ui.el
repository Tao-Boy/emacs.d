;; -*- lexical-binding: t; -*-

(require 'cl-lib)

(defun tau-set-font (&rest fonts)
  "Set the first available font in FONTS as the default font."
  (when (display-graphic-p)
    (cl-loop
     for font in fonts
     when (find-font (font-spec :family font))
     return
     (set-face-attribute 'default nil
                         :family font
                         :height 150))))

(defun tau-set-zh-font (&rest fonts)
  "Set the first available font in FONTS as the default font."
  (when (display-graphic-p)
    (cl-loop
     for font in fonts
     when (find-font (font-spec :family font))
     return
     (set-fontset-font t 'han
                         (font-spec :family font)))))

(add-hook 'after-init-hook
          (lambda ()
            (tau-set-font
             "IosevkaTerm NFM"
             "Ioskeley Mono"
             "monospace")
	    (tau-set-zh-font
	     "LXGW WenKai Mono")))

(with-eval-after-load 'rainbow-delimiters
  (custom-set-faces
   '(rainbow-delimiters-depth-1-face ((t (:foreground "#FFD700"))))
   '(rainbow-delimiters-depth-2-face ((t (:foreground "#DA70D6"))))
   '(rainbow-delimiters-depth-3-face ((t (:foreground "#179FFF"))))
   '(rainbow-delimiters-depth-4-face ((t (:foreground "#00E5A8"))))
   '(rainbow-delimiters-depth-5-face ((t (:foreground "#FF8C00"))))
   '(rainbow-delimiters-depth-6-face ((t (:foreground "#B56DFF"))))
   '(rainbow-delimiters-depth-7-face ((t (:foreground "#FFD700"))))
   '(rainbow-delimiters-depth-8-face ((t (:foreground "#DA70D6"))))
   '(rainbow-delimiters-depth-9-face ((t (:foreground "#179FFF"))))
   '(rainbow-delimiters-unmatched-face
     ((t (:foreground "#F44747" :weight bold))))
   '(rainbow-delimiters-mismatched-face
     ((t (:foreground "#F44747" :weight bold :underline t))))))

;; The package provides no global mode, so enable it per buffer.  The
;; faces configured above are only visible once the mode is active.
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)


(when (fboundp 'pixel-scroll-precision-mode)
  (setq scroll-margin 0
	scroll-conservatively 101
	scroll-preserve-screen-position t)
  (pixel-scroll-precision-mode 1))


(show-paren-mode 1)
(setq show-paren-delay 0)



(load-theme 'doom-tokyo-night t)

(provide 'init-ui)
