;; -*- lexical-binding: t; -*-

(defgroup texsuit nil
  "Minimal TeX expander: TAB expansion + field jumping + sub/superscript helpers."
  :group 'org
  :prefix "texsuit-")

(defcustom texsuit-templates
  '(("fr"  . "\\frac{<>}{<>}")
    ("sr"  . "^{<>}")
    ("sb"  . "_{<>}")
    ("dm"  . "\\[\n<>\n\\]")
    ("eq"  . "\\begin{equation}\n<>\n\\end{equation}")
    ("ali" . "\\begin{align}\n<>\n\\end{align}")
    ("it"  . "\\item <>"))
  "Trigger -> template alist."
  :type '(alist :key-type string :value-type string))

(defcustom simple-tex-expand-placeholder "<>"
  "Placeholder used inside templates."
  :type 'string)

(defvar-local simple-tex-expand--fields nil
  "Remaining field markers for the current template expansion.")

(defun simple-tex-expand--trigger-bounds ()
  "Return bounds of trigger before point, or nil."
  (save-excursion
    (let ((end (point)))
      (skip-syntax-backward "w_")
      (when (< (point) end)
        (cons (point) end)))))

(defun simple-tex-expand--trigger-at-point ()
  "Return trigger before point, or nil."
  (let ((bds (simple-tex-expand--trigger-bounds)))
    (when bds
      (buffer-substring-no-properties (car bds) (cdr bds)))))

(defun simple-tex-expand--collect-fields (beg end)
  "Delete placeholders between BEG and END and return markers."
  (let (fields)
    (save-excursion
      (goto-char beg)
      (while (search-forward simple-tex-expand-placeholder end t)
        (let ((pos (match-beginning 0)))
          (replace-match "")
          (push (copy-marker pos t) fields)
          (setq end (- end (length simple-tex-expand-placeholder))))))
    (nreverse fields)))

(defun simple-tex-expand--insert-template (template)
  "Insert TEMPLATE, record fields, and jump to first field."
  (let ((beg (point)))
    (insert template)
    (let ((fields (simple-tex-expand--collect-fields beg (point))))
      (setq simple-tex-expand--fields (cdr fields))
      (when fields
        (goto-char (marker-position (car fields)))))
    t))

(defun simple-tex-expand-next-field ()
  "Jump to next placeholder field."
  (interactive)
  (while (and simple-tex-expand--fields
              (not (marker-buffer (car simple-tex-expand--fields))))
    (pop simple-tex-expand--fields))
  (when simple-tex-expand--fields
    (goto-char (marker-position (pop simple-tex-expand--fields)))
    t))

(defun simple-tex-expand-at-point ()
  "Expand trigger before point."
  (interactive)
  (let* ((bds (simple-tex-expand--trigger-bounds))
         (key (and bds
                   (buffer-substring-no-properties (car bds) (cdr bds))))
         (tpl (and key (cdr (assoc key simple-tex-expand-templates)))))
    (when tpl
      (delete-region (car bds) (cdr bds))
      (simple-tex-expand--insert-template tpl))))

(defun simple-tex-expand-tab ()
  "Jump field, else expand trigger, else fallback to normal TAB behavior."
  (interactive)
  (or (simple-tex-expand-next-field)
      (simple-tex-expand-at-point)
      (indent-for-tab-command)))

(defun simple-tex-expand-insert-superscript ()
  "Insert ^{...} and put point inside braces."
  (interactive)
  (simple-tex-expand--insert-template "^{<>}"))

(defun simple-tex-expand-insert-subscript ()
  "Insert _{...} and put point inside braces."
  (interactive)
  (simple-tex-expand--insert-template "_{<>}"))

(defvar simple-tex-expand-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "TAB")   #'simple-tex-expand-tab)
    (define-key map (kbd "<tab>") #'simple-tex-expand-tab)
    ;; 保守绑定：不直接抢占 ^ 和 _
    (define-key map (kbd "C-c ^") #'simple-tex-expand-insert-superscript)
    (define-key map (kbd "C-c _") #'simple-tex-expand-insert-subscript)
    map)
  "Keymap for `simple-tex-expand-mode'.")

(define-minor-mode simple-tex-expand-mode
  "Tiny TeX expander mode."
  :lighter " sTeX"
  :keymap simple-tex-expand-mode-map)

;; 仅在 LaTeX 中启用
(add-hook 'LaTeX-mode-hook #'simple-tex-expand-mode)
(add-hook 'latex-mode-hook #'simple-tex-expand-mode)

;; 若你也想在 Org 中使用，可打开下一行：
;; (add-hook 'org-mode-hook #'simple-tex-expand-mode)

(provide 'simple-tex-expand)
