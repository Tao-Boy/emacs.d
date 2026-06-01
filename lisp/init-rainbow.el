;; -*- lexical-binding: t; -*-

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

(provide 'init-rainbow)
