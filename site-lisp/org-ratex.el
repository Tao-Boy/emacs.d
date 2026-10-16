;;; org-ratex.el --- Preview Org LaTeX fragments with RaTeX render-svg -*- lexical-binding: t; -*-

;; Version: 0.12
;; Package-Requires: ((emacs "29.1") (org "9.6"))
;; Keywords: tex, outlines, multimedia

;;; Commentary:

;; LaTeX preview for Org mode using the `render-svg' CLI from RaTeX
;; (https://github.com/Tao-Boy/RaTeX); no TeX installation is needed.
;; Inline math is written \(...\), display math \[...\] or an environment
;; \begin{NAME}...\end{NAME} starting a line; $...$ is not previewed.
;;
;;   M-x org-ratex-mode         preview the whole buffer and edit formulas
;;                              in place (see below)
;;   M-x org-ratex-preview      preview the fragment at point, the active
;;                              region, or the whole buffer
;;   C-u M-x org-ratex-preview  remove previews
;;
;; In `org-ratex-mode' a formula is shown as source while it is edited:
;;  - Moving onto an inline formula from either side (C-f, C-b, C-n,
;;    C-p) or clicking its image puts point in its content, right after \\( or
;;    right before \\).  Motion steps over the delimiters, so C-f at the
;;    end of the content leaves the formula and renders it.
;;  - A display formula or environment on lines of its own is edited
;;    while point is anywhere on those lines; C-n enters it on its first
;;    line, C-p on its last.
;;  - Typing never moves point; a formula is rendered as soon as its
;;    closing delimiter is typed.
;;
;; `org-ratex-in-math-p' tells whether point is inside a formula, for
;; math snippets; unlike `org-inside-LaTeX-fragment-p' it is not fooled
;; by a line in \\[...\\] that starts like a list item, such as "- x".
;;
;; Rendering runs asynchronously in batches, several `render-svg' processes
;; at a time, fragments nearest to point first.  SVGs are read from the
;; process' stdout and kept only in memory.
;;
;; Formulas take their size and color from the text around them, at
;; display time: images are sized in `em' of the face at their position, so
;; they follow headings, `text-scale-adjust' and `global-text-scale-adjust';
;; and every element of the SVG gets an explicit fill="currentColor", which
;; Emacs draws with that face's foreground, so a theme switch needs no
;; re-rendering.  (Emacs 31 no longer adds a default fill to SVG images, so
;; the explicit attribute is what makes this work there.)
;; Colors set in the formula, such as \color{red}, are kept.
;;
;; Inline formulas sit on the text baseline.  `render-svg' does not report
;; the baseline, so every formula is rendered a second time followed by an
;; invisible strut of known depth: the height of that second image minus the
;; strut depth is the formula's height above the baseline.
;;
;; Display formulas on lines of their own are laid out like KaTeX's display
;; mode: display style, the same 1.21 size, a line at least 1.2 formula em
;; tall, 1em margins above and below (left out next to a blank line,
;; where the web would collapse them with the paragraph's), centered in
;; the window.  Wide ones are scaled down to fit; both follow resizes.


;;; Code:

(require 'cl-lib)
(require 'seq)
(require 'org)
(require 'org-element)

(defgroup org-ratex nil
  "Preview Org LaTeX fragments with RaTeX."
  :group 'org)

(defcustom org-ratex-executable "render-svg"
  "Path to RaTeX's `render-svg' executable."
  :type 'file)

(defcustom org-ratex-scale 1.21
  "Formula font size relative to the surrounding text's font size.
1.21 is what KaTeX uses on the web (.katex { font-size: 1.21em }), as
KaTeX's fonts look small next to most text fonts at the same size."
  :type 'number)

(defcustom org-ratex-inline-margin 0.1
  "Horizontal space, in em, on each side of an inline formula.
It is part of the image, so it scales with the formula."
  :type 'number)

(defcustom org-ratex-display-margin 1.0
  "Space, in em of the text, above and below a display formula.
1.0 is KaTeX's (.katex-display { margin: 1em 0 }).  As on the web, where
this margin collapses with the paragraph's, it is left out on a side
where the formula is next to a blank line or the buffer's edge.  It is
part of the image, so it scales with the text."
  :type 'number)

(defcustom org-ratex-center-display t
  "Non-nil means center display formulas that are on a line of their own."
  :type 'boolean)

(defcustom org-ratex-foreground 'face
  "Formula color.
`face' uses the foreground of the text around the formula, which follows
the current theme; otherwise a color string such as \"#268bd2\"."
  :type '(choice (const face) color))

(defcustom org-ratex-batch-size 40
  "Maximum number of formulas sent to one `render-svg' process."
  :type 'natnum)

(defcustom org-ratex-max-processes 4
  "Maximum number of `render-svg' processes running at the same time."
  :type 'natnum)

(defface org-ratex-error '((t :underline (:style wave :color "red")))
  "Face for fragments RaTeX could not render.")

(defconst org-ratex--strut-depth 100
  "Depth, in em, of the strut used to measure the baseline.")

(defconst org-ratex--strut
  (format " \\rule[-%dem]{0pt}{0pt}" org-ratex--strut-depth))

(defconst org-ratex--display-strut '(0.914 . 0.286)
  "Least height and depth, in formula em, of KaTeX's display line.
KaTeX sets display math with line-height 1.2 in KaTeX_Main, so even a
short formula such as x takes this much room around its baseline.")

(defconst org-ratex--render-size 100
  "Font size passed to `render-svg'; images are rescaled when displayed.")

(defconst org-ratex--placeholder-color "#010203"
  "Color passed to `render-svg', replaced by currentColor in its output.")

(defconst org-ratex--placeholder-paint "rgba(1,2,3,1)"
  "How `render-svg' writes `org-ratex--placeholder-color'.")

;;;; State

(defvar org-ratex--cache (make-hash-table :test #'equal)
  "Rendered formulas: KEY -> (:data SVG :height EM :ascent PERCENT)
or (:error MSG).  KEY is (FORMULA INLINE-P).")

(defvar org-ratex--waiting (make-hash-table :test #'equal)
  "KEY -> list of fragments waiting for KEY to be rendered.")

(defvar org-ratex--queue nil
  "Batches not started yet, as (INLINE KEYS).")

(defvar org-ratex--running 0
  "Number of running `render-svg' processes.")

(defvar-local org-ratex--generation 0
  "Bumped when previews are cleared, so late results are dropped.")

(defvar org-ratex-mode)

(defvar-local org-ratex--active nil
  "(BEG . END) markers of the fragment point is in, shown as source.")

(defun org-ratex-clear-cache ()
  "Forget all rendered formulas."
  (interactive)
  (clrhash org-ratex--cache))

;;;; Fragments

(defconst org-ratex--skipped-elements
  '(src-block example-block export-block fixed-width comment comment-block
              keyword babel-call node-property)
  "Org elements whose text is never math.")

(defun org-ratex--one-line (formula)
  "Join FORMULA into one line, since `render-svg' expects one per line."
  (let* ((s (replace-regexp-in-string "\\(^\\|[^\\]\\)%.*$" "\\1" formula))
         (s (string-trim (replace-regexp-in-string "[ \t]*\n[ \t]*" " " s))))
    ;; render-svg skips lines starting with # or %, which would shift
    ;; the numbering of its results.
    (if (string-match-p "\\`[#%]" s) (concat "{}" s) s)))

(defun org-ratex--own-line-p (beg end)
  "Non-nil if only blanks surround BEG..END on their lines."
  (save-excursion
    (and (progn (goto-char beg) (skip-chars-backward " \t") (bolp))
         (progn (goto-char end) (skip-chars-forward " \t") (eolp)))))

(defun org-ratex--paragraph (beg end)
  "Return (START . STOP) of the blank-line delimited text around BEG..END."
  (save-excursion
    (cons (progn (goto-char beg)
                 (if (re-search-backward "^[ \t]*$" nil t) (point) (point-min)))
          (progn (goto-char end)
                 (if (re-search-forward "^[ \t]*$" nil t) (point) (point-max))))))

(defconst org-ratex--open-re
  "\\\\\\([([]\\)\\|^[ \t]*\\(\\\\begin{\\([A-Za-z0-9*]+\\)}\\)"
  "Opening \\( or \\[, or \\begin{NAME} at the start of a line.")

(defun org-ratex--env-end (name limit)
  "Move past the \\end{NAME} closing the environment before point.
Nested environments of the same NAME are skipped.  Return nil, leaving
point unchanged, if there is none before LIMIT."
  (let ((start (point))
        (re (concat "\\\\\\(begin\\|end\\){" (regexp-quote name) "}"))
        (depth 1))
    (while (and (> depth 0) (re-search-forward re limit t))
      (setq depth (if (equal (match-string 1) "begin") (1+ depth) (1- depth))))
    (or (= depth 0) (progn (goto-char start) nil))))

(defun org-ratex--scan (beg end)
  "Return formulas opening between BEG and END.
Each item is (B E KIND OB CB): B is at the opening backslash, E just
after the closing delimiter, OB just after the opening delimiter and CB
at the closing one, so OB..CB is the formula's content.  KIND is
`inline' for \\(...\\), `display' for \\[...\\] and `env' for
\\begin{NAME}...\\end{NAME}.  A formula cannot span
a blank line, so an unclosed delimiter does not swallow the rest of the
buffer."
  (let (result)
    (save-excursion
      (goto-char beg)
      ;; A closing delimiter may lie past END; stop there.
      (while (and (< (point) end) (re-search-forward org-ratex--open-re end t))
        (let* ((env (match-string 3))
               (b (if env (match-beginning 2) (match-beginning 0)))
               (ob (match-end 0))
               (kind (cond (env 'env) ((equal (match-string 1) "(") 'inline) (t 'display)))
               (escaped (and (not env)
                             (save-excursion
                               (goto-char b)
                               (cl-oddp (- (point) (progn (skip-chars-backward "\\\\")
                                                          (point)))))))
               (limit (save-excursion
                        (if (re-search-forward "^[ \t]*$" nil t) (point) (point-max)))))
          (when (and (not escaped)
                     (if env
                         (org-ratex--env-end env limit)
                       (search-forward (if (eq kind 'inline) "\\)" "\\]") limit t)))
            ;; Point is now past the formula, so an environment inside
            ;; \[...\] or a \(...\) inside an environment is not seen again.
            (push (list b (point) kind ob
                        (- (point) (if env (+ 6 (length env)) 2)))
                  result)))))
    (nreverse result)))

(defun org-ratex--math-p (beg)
  "Non-nil if a formula starting at BEG is in text Org treats as markup."
  (save-excursion
    (not (memq (org-element-type (org-element-at-point beg))
               org-ratex--skipped-elements))))

(defun org-ratex--fragments (beg end)
  "Return math between BEG and END.
Each item is (BEG END FORMULA INLINE-P CENTER-P BLOCK-P); BLOCK-P means a
display formula on lines of its own."
  (cl-loop for (b e kind) in (org-ratex--scan beg end)
           for inline = (eq kind 'inline)
           ;; render-svg takes an environment whole, delimiters inside.
           for line = (org-ratex--one-line
                       (if (eq kind 'env)
                           (buffer-substring-no-properties b e)
                         (buffer-substring-no-properties (+ b 2) (- e 2))))
           for block = (and (not inline) (org-ratex--own-line-p b e))
           when (and (<= e end) (not (string-empty-p line)) (org-ratex--math-p b))
           collect (list b e line inline (and org-ratex-center-display block) block)))

(defun org-ratex--lines (beg end)
  "Return (START . STOP), the whole lines holding BEG..END."
  (save-excursion
    (cons (progn (goto-char beg) (line-beginning-position))
          (progn (goto-char end) (line-end-position)))))

(defun org-ratex--editing-p (beg end block &optional pos)
  "Non-nil if POS (default point) puts the formula BEG..END in edit state.
That is POS strictly between the delimiters, or, for a BLOCK formula,
anywhere on its lines.  At BEG or END of an inline formula point is
outside, so the formula is shown as soon as it is typed or left."
  (let ((pos (or pos (point))))
    (if block
        (let ((lines (org-ratex--lines beg end)))
          (<= (car lines) pos (cdr lines)))
      (< beg pos end))))

(defun org-ratex--formula-at (pos)
  "Return the formula touching POS as (B E KIND OB CB BLOCK), or nil.
Touching means B <= POS <= E, or for a block formula POS on its lines."
  (save-excursion
    (goto-char pos)
    (let ((para (org-ratex--paragraph pos pos)))
      ;; Scan to the end of the line, so that POS inside an opening
      ;; delimiter, such as within \\begin{align}, is found too.
      (cl-loop for (b e kind ob cb) in (org-ratex--scan (car para) (line-end-position))
               for block = (and (not (eq kind 'inline)) (org-ratex--own-line-p b e))
               when (and (if block
                             (org-ratex--editing-p b e t pos)
                           (<= b pos e))
                         (org-ratex--math-p b))
               return (list b e kind ob cb block)))))

(defun org-ratex-in-math-p (&optional pos)
  "Non-nil if POS (default point) is in the content of a formula.
That is between the delimiters of \\(...\\), \\[...\\] or
\\begin{NAME}...\\end{NAME}, with POS right after the opening or
right before the closing delimiter included, so that it can serve as
a condition for math snippets.

Unlike `org-inside-LaTeX-fragment-p' this does not rely on Org's
paragraph parser, which reads a line starting with \"- \", \"+ \" or
\"1. \" inside \\[...\\] as a list item and then no longer sees the
formula around it.  It works without `org-ratex-mode'."
  (let* ((pos (or pos (point)))
         (f (org-ratex--formula-at pos)))
    (and f (<= (nth 3 f) pos (nth 4 f)))))

(defun org-ratex--fragment-at-point ()
  "Return (BEG . END) of the formula at point, or nil."
  (when-let* ((f (org-ratex--formula-at (point))))
    (cons (nth 0 f) (nth 1 f))))

;;;; Rendering processes

(defun org-ratex--svg-size (svg)
  "Return (WIDTH . HEIGHT) from SVG's viewBox, as floats.
Floats matter: an integral size such as 92 would otherwise make the
divisions below integer divisions."
  (when (string-match "viewBox=\"0 0 \\([0-9.]+\\) \\([0-9.]+\\)\"" svg)
    (cons (float (string-to-number (match-string 1 svg)))
          (float (string-to-number (match-string 2 svg))))))

(defun org-ratex--entry (svg strut-svg)
  "Make a cache entry from SVG and its STRUT-SVG twin."
  (let* ((size org-ratex--render-size)
         (h (cdr (org-ratex--svg-size svg)))
         (hs (and strut-svg (cdr (org-ratex--svg-size strut-svg))))
         (above (and hs (- hs (* org-ratex--strut-depth size)))))
    (list :data (string-replace org-ratex--placeholder-paint "currentColor" svg)
          :height (/ h size)
          :above (and above (/ above size))
          :ascent (and above (> h 0)
                       (max 0 (min 100 (round (* 100 (/ above h)))))))))

(defun org-ratex--start-next ()
  "Start queued batches while fewer than `org-ratex-max-processes' run."
  (while (and org-ratex--queue (< org-ratex--running org-ratex-max-processes))
    (pcase-let ((`(,inline ,keys) (pop org-ratex--queue)))
      (let ((proc (make-process
                   :name "org-ratex"
                   :buffer (generate-new-buffer " *org-ratex*" t)
                   :command `(,org-ratex-executable
                              "--stdout" "--padding" "0"
                              "--font-size" ,(number-to-string org-ratex--render-size)
                              "--color" ,org-ratex--placeholder-color
                              ,@(and inline '("--inline")))
                   ;; stderr shares the pipe, so each "OK n" line directly
                   ;; follows the SVG of formula n.
                   :connection-type 'pipe
                   :coding 'utf-8-unix
                   :noquery t
                   :sentinel #'org-ratex--sentinel)))
        (process-put proc 'org-ratex-keys keys)
        (cl-incf org-ratex--running)
        (process-send-string
         proc (mapconcat (lambda (k) (concat (car k) "\n" (car k) org-ratex--strut "\n"))
                         keys ""))
        (process-send-eof proc)))))

(defun org-ratex--parse-output ()
  "Return a hash table: formula number -> SVG string or (error . MSG)."
  (let ((results (make-hash-table)) svg)
    (goto-char (point-min))
    (while (not (eobp))
      (let ((line (buffer-substring-no-properties (point) (line-end-position))))
        (cond ((string-prefix-p "<svg" line) (setq svg line))
              ((string-match "\\`OK +\\([0-9]+\\) " line)
               (puthash (string-to-number (match-string 1 line)) svg results)
               (setq svg nil))
              ((string-match "\\`ERR +\\([0-9]+\\) .* — \\(.*\\)" line)
               (puthash (string-to-number (match-string 1 line))
                        (cons 'error (match-string 2 line)) results))))
      (forward-line 1))
    results))

(defun org-ratex--sentinel (proc _event)
  "When PROC exits, cache its results and show waiting fragments."
  (when (memq (process-status proc) '(exit signal))
    (cl-decf org-ratex--running)
    (let ((keys (process-get proc 'org-ratex-keys))
          (results (with-current-buffer (process-buffer proc)
                     (org-ratex--parse-output)))
          (i 0))
      (kill-buffer (process-buffer proc))
      (dolist (key keys)
        (let ((svg (gethash (1+ (* 2 i)) results))
              (strut (gethash (+ 2 (* 2 i)) results)))
          (setq i (1+ i))
          (puthash key
                   (if (stringp svg)
                       (org-ratex--entry svg (and (stringp strut) strut))
                     (list :error (if (consp svg) (cdr svg) "render-svg failed")))
                   org-ratex--cache)
          (dolist (frag (gethash key org-ratex--waiting))
            (org-ratex--place frag))
          (remhash key org-ratex--waiting))))
    (org-ratex--start-next)))

;;;; Overlays

(defun org-ratex-edit-at-mouse (event)
  "Edit the formula whose image was clicked with EVENT.
Point goes to the start of the formula's content."
  (interactive "e")
  (let ((posn (event-start event)))
    (select-window (posn-window posn))
    (when-let* ((f (org-ratex--formula-at (posn-point posn))))
      (goto-char (nth 3 f)))))

(defvar org-ratex-image-map
  (let ((map (make-sparse-keymap)))
    ;; The press does nothing, so the image stays until the release,
    ;; which then lands on it too and runs `org-ratex-edit-at-mouse'.
    (define-key map [down-mouse-1] #'ignore)
    (define-key map [mouse-1] #'org-ratex-edit-at-mouse)
    map)
  "Keymap active on rendered formula images.")

(defun org-ratex--remove-on-edit (ov after &rest _)
  "Delete OV once its text has been modified (AFTER is non-nil)."
  (when after (delete-overlay ov)))

(defun org-ratex--pad (svg left right top bottom)
  "Return SVG with LEFT, RIGHT, TOP and BOTTOM em of blank space added.
The space is added to the viewBox, so it scales with the image (Emacs'
:margin is in pixels only)."
  (let ((k org-ratex--render-size))
    (if (string-match "viewBox=\"0 0 \\([0-9.]+\\) \\([0-9.]+\\)\" width=\"[0-9.]+pt\" height=\"[0-9.]+pt\""
                      svg)
        (let ((w (+ (string-to-number (match-string 1 svg)) (* k (+ left right))))
              (h (+ (string-to-number (match-string 2 svg)) (* k (+ top bottom)))))
          (replace-match (format "viewBox=\"%.4f %.4f %.4f %.4f\" width=\"%.4fpt\" height=\"%.4fpt\""
                                 (* k (- left)) (* k (- top)) w h w h)
                         t t svg))
      svg)))

(defun org-ratex--next-to-blank-p (pos direction)
  "Non-nil if the line DIRECTION (-1 or 1) lines from POS is blank or absent."
  (save-excursion
    (goto-char pos)
    (or (/= 0 (forward-line direction))
        (and (> direction 0) (eobp))
        (looking-at-p "[ \t]*$"))))

(defun org-ratex--display-padding (ov entry)
  "Return (TOP . BOTTOM), in formula em, around block formula OV.
ENTRY is its cache entry.  This reproduces KaTeX's display layout:
the formula sits in a line at least `org-ratex--display-strut' high
and deep, with `org-ratex-display-margin' above and below."
  (let* ((h (or (plist-get entry :above) (/ (plist-get entry :height) 2)))
         (d (- (plist-get entry :height) h))
         (m (/ org-ratex-display-margin org-ratex-scale)))
    (cons (+ (max 0 (- (car org-ratex--display-strut) h))
             (if (org-ratex--next-to-blank-p (overlay-start ov) -1) 0 m))
          (+ (max 0 (- (cdr org-ratex--display-strut) d))
             (if (org-ratex--next-to-blank-p (overlay-end ov) 1) 0 m)))))

(defun org-ratex--put-image (ov &optional window)
  "Show OV's formula as an image, sized and centered for WINDOW."
  (let* ((entry (overlay-get ov 'org-ratex-entry))
         (inline (overlay-get ov 'org-ratex-inline))
         (block (overlay-get ov 'org-ratex-block))
         (win (or window (get-buffer-window (overlay-buffer ov) t)))
         ;; Padding in the formula's own em, before scaling to the text.
         (dx (if inline (/ org-ratex-inline-margin org-ratex-scale) 0))
         (dy (if block (org-ratex--display-padding ov entry) '(0 . 0)))
         (data (encode-coding-string
                (org-ratex--pad (plist-get entry :data) dx dx (car dy) (cdr dy))
                'utf-8))
         (img (apply #'create-image data 'svg t
                     ;; In em of the face at the formula, resolved at display
                     ;; time: follows headings and text scaling.
                     :height (cons (* org-ratex-scale
                                      (+ (plist-get entry :height) (car dy) (cdr dy)))
                                   'em)
                     ;; The `em' above is the pixel size of the face's font.
                     ;; The default :scale would multiply it by
                     ;; `image-scaling-factor', which for `auto' depends on
                     ;; the frame's column width, not on this text.
                     :scale 1.0
                     ;; A block formula's image is its whole line; anything
                     ;; else sits on the text baseline (padding is only
                     ;; horizontal there, so the measured ascent holds).
                     :ascent (if block 'center (or (plist-get entry :ascent) 'center))
                     (append
                      (and (stringp org-ratex-foreground)
                           (list :foreground org-ratex-foreground))
                      (and win block
                           (list :max-width (window-body-width win t)))))))
    (overlay-put ov 'display img)
    (when (overlay-get ov 'org-ratex-center)
      ;; :align-to is recomputed on every redisplay, so this follows resizes.
      (overlay-put ov 'before-string
                   (propertize " " 'display
                               `(space :align-to (- center (0.5 . ,img))))))))

(defun org-ratex--place (frag)
  "Put the preview overlay for FRAG if its text is unchanged."
  (pcase-let ((`(,buf ,gen ,bm ,em ,text ,key ,center ,block) frag))
    (when (buffer-live-p buf)
      (with-current-buffer buf
        (let ((b (marker-position bm)) (e (marker-position em))
              (entry (gethash key org-ratex--cache)))
          (set-marker bm nil)
          (set-marker em nil)
          (when (and entry b (= gen org-ratex--generation)
                     (<= e (point-max))
                     (equal (buffer-substring-no-properties b e) text)
                     (not (and org-ratex-mode (org-ratex--editing-p b e block)))
                     (not (seq-some (lambda (o) (overlay-get o 'org-ratex))
                                    (overlays-in b e))))
            (let ((ov (make-overlay b e nil t nil)))
              (overlay-put ov 'org-ratex t)
              (overlay-put ov 'org-overlay-type 'org-latex-overlay)
              (overlay-put ov 'evaporate t)
              (overlay-put ov 'modification-hooks '(org-ratex--remove-on-edit))
              (if (plist-get entry :error)
                  (progn (overlay-put ov 'face 'org-ratex-error)
                         (overlay-put ov 'help-echo (plist-get entry :error)))
                (overlay-put ov 'org-ratex-entry entry)
                (overlay-put ov 'org-ratex-inline (nth 1 key))
                (overlay-put ov 'org-ratex-center center)
                (overlay-put ov 'org-ratex-block block)
                (overlay-put ov 'keymap org-ratex-image-map)
                (overlay-put ov 'help-echo "mouse-1: edit formula")
                (org-ratex--put-image ov)))))))))

(defun org-ratex-clear (&optional beg end)
  "Remove RaTeX previews between BEG and END (default: whole buffer)."
  (interactive)
  (remove-overlays (or beg (point-min)) (or end (point-max)) 'org-ratex t))

(defun org-ratex-preview-region (beg end)
  "Render math between BEG and END asynchronously.
In `org-ratex-mode', the fragment at point is left as source."
  (interactive "r")
  (unless (executable-find org-ratex-executable)
    (user-error "Cannot find RaTeX executable %S" org-ratex-executable))
  (org-ratex-clear beg end)
  (let* ((pt (point))
         (frags (sort (org-ratex--fragments beg end)
                      (lambda (a b) (< (abs (- (car a) pt)) (abs (- (car b) pt))))))
         (new (list (list t) (list nil))))   ; inline -> new keys
    (pcase-dolist (`(,b ,e ,formula ,inline ,center ,block) frags)
      (unless (and org-ratex-mode (org-ratex--editing-p b e block))
        (let* ((key (list formula inline))
               (frag (list (current-buffer) org-ratex--generation
                           (copy-marker b) (copy-marker e)
                           (buffer-substring-no-properties b e) key center block)))
          (cond ((gethash key org-ratex--cache) (org-ratex--place frag))
                ((gethash key org-ratex--waiting)
                 (push frag (gethash key org-ratex--waiting)))
                (t (puthash key (list frag) org-ratex--waiting)
                   (push key (cdr (assq inline new))))))))
    (pcase-dolist (`(,inline . ,keys) new)
      (setq keys (nreverse keys))
      (while keys
        (let ((n (min org-ratex-batch-size (length keys))))
          (setq org-ratex--queue
                (append org-ratex--queue
                        (list (list inline (seq-take keys n)))))
          (setq keys (nthcdr n keys)))))
    (org-ratex--start-next)))

;;;; Commands and minor mode

;;;###autoload
(defun org-ratex-preview (&optional arg)
  "Preview LaTeX with RaTeX.
Without ARG: toggle the fragment at point, or preview the active region or
the whole buffer.  With \\[universal-argument]: remove previews."
  (interactive "P")
  (let* ((frag (org-ratex--fragment-at-point))
         (beg (cond ((use-region-p) (region-beginning)) (frag (car frag)) (t (point-min))))
         (end (cond ((use-region-p) (region-end)) (frag (cdr frag)) (t (point-max)))))
    (cond (arg (org-ratex-clear beg end)
               (unless (or frag (use-region-p)) (cl-incf org-ratex--generation)))
          ((and frag (seq-some (lambda (o) (overlay-get o 'org-ratex))
                               (overlays-in beg end)))
           (org-ratex-clear beg end))
          (t (org-ratex-preview-region beg end)))))

(defun org-ratex--refresh ()
  "Preview the whole buffer."
  (org-ratex-preview-region (point-min) (point-max)))

(defvar-local org-ratex--changed nil
  "(BEG . END) covering buffer changes since the last command.")

(defun org-ratex--after-change (beg end _len)
  "Record that BEG..END changed."
  (setq org-ratex--changed
        (if org-ratex--changed
            (cons (min beg (car org-ratex--changed)) (max end (cdr org-ratex--changed)))
          (cons beg end))))

(defvar-local org-ratex--prev-point nil
  "Point before the current command.")

(defun org-ratex--pre-command ()
  "Remember point before the command."
  (setq org-ratex--prev-point (point)))

(defun org-ratex--adjust-point (f prev)
  "Move point to where editing formula F should start, coming from PREV.
Called only for commands that moved point without changing the buffer."
  (pcase-let* ((`(,b ,e ,_kind ,ob ,cb ,block) f)
               (p (point))
               (step (= 1 (abs (- p prev))))
               (prev-in (org-ratex--editing-p b e block prev)))
    (cond
     ;; Moved onto a block formula from another line, as by C-n or C-p:
     ;; its image is one line, so land on its first line when coming from
     ;; above and on its last line when coming from below.
     ((and block (not prev-in) (not step))
      (let ((col (save-excursion (goto-char prev) (current-column))))
        (goto-char (if (< prev b) b e))
        (move-to-column col)))
     ;; Reached the start of an inline formula from outside, whether
     ;; by C-f or C-n, onto the image: edit right after \\(.
     ((and (not block) (= p b) (not prev-in))
      (goto-char ob))
     ;; Stepped into the opening delimiter: forward into the content, or
     ;; backward out of the formula.
     ((and step (< b p ob))
      (goto-char (if (< prev p) ob b)))
     ;; Stepped into the closing delimiter: backward into the content, or
     ;; forward out of the formula.
     ((and step (< cb p e))
      (goto-char (if (> prev p) cb e))))))

(defun org-ratex--post-command ()
  "Show the formula being edited as source; render what point left or edits made."
  (let ((prev org-ratex--prev-point)
        (changed org-ratex--changed))
    (setq org-ratex--changed nil org-ratex--prev-point nil)
    ;; Delimiters are not stops for motion commands; typing is left alone.
    (when (and prev (not changed) (/= prev (point)))
      (when-let* ((f (org-ratex--formula-at (point))))
        (org-ratex--adjust-point f prev)))
    (let* ((f (org-ratex--formula-at (point)))
           (frag (and f (org-ratex--editing-p (nth 0 f) (nth 1 f) (nth 5 f))
                      (cons (nth 0 f) (nth 1 f))))
           (active (and org-ratex--active
                        (cons (marker-position (car org-ratex--active))
                              (marker-position (cdr org-ratex--active)))))
           (same (and frag active (= (car frag) (car active))))
           (todo nil))
      ;; Point left the formula it was in: render it (it may have been edited).
      (when (and active (not same))
        (push active todo)
        (set-marker (car org-ratex--active) nil)
        (set-marker (cdr org-ratex--active) nil)
        (setq org-ratex--active nil))
      ;; Edits outside the formula at point may add, remove or change formulas.
      (when (and changed
                 (not (and same (<= (car frag) (car changed))
                           (<= (cdr changed) (cdr frag)))))
        ;; One line further each way: a formula next to a line that just
        ;; became blank, or stopped being blank, needs new margins.
        (push (save-excursion
                (cons (progn (goto-char (max (point-min) (car changed)))
                             (forward-line -1) (point))
                      (progn (goto-char (min (point-max) (cdr changed)))
                             (forward-line 1) (line-end-position))))
              todo))
      (dolist (r todo)
        (let ((para (org-ratex--paragraph (car r) (cdr r))))
          (org-ratex-preview-region (car para) (cdr para))))
      (when (and frag (not same))
        (org-ratex-clear (car frag) (cdr frag))
        (setq org-ratex--active (cons (copy-marker (car frag))
                                      (copy-marker (cdr frag) t)))))))

(defun org-ratex--window-resized (window)
  "Fit display formulas to WINDOW's new width."
  (dolist (ov (overlays-in (point-min) (point-max)))
    (when (and (overlay-get ov 'org-ratex-entry)
               (overlay-get ov 'org-ratex-block))
      (org-ratex--put-image ov window))))

;;;###autoload
(define-minor-mode org-ratex-mode
  "Preview LaTeX in this Org buffer with RaTeX.
The fragment at point is shown as source and rendered when point leaves it."
  :lighter " RaTeX"
  (if org-ratex-mode
      (progn
        (add-hook 'pre-command-hook #'org-ratex--pre-command nil t)
        (add-hook 'post-command-hook #'org-ratex--post-command nil t)
        (add-hook 'after-change-functions #'org-ratex--after-change nil t)
        (add-hook 'after-save-hook #'org-ratex--refresh nil t)
        (add-hook 'window-size-change-functions #'org-ratex--window-resized nil t)
        (org-ratex--refresh)
        (org-ratex--post-command))
    (remove-hook 'pre-command-hook #'org-ratex--pre-command t)
    (remove-hook 'post-command-hook #'org-ratex--post-command t)
    (remove-hook 'after-change-functions #'org-ratex--after-change t)
    (remove-hook 'after-save-hook #'org-ratex--refresh t)
    (remove-hook 'window-size-change-functions #'org-ratex--window-resized t)
    (setq org-ratex--active nil org-ratex--changed nil)
    (cl-incf org-ratex--generation)
    (org-ratex-clear)))

(provide 'org-ratex)
;;; org-ratex.el ends here
