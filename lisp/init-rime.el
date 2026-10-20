;;; init-rime.el --- Chinese input with Rime -*- lexical-binding: t; -*-

;;; Commentary:

;; Rimel is a small Rime front end built on the liberime dynamic
;; module.  `C-\' toggles it; nothing is loaded before that.
;;
;; Instead of compiling liberime, its prebuilt release is downloaded
;; into `tau-liberime-directory' on first use.  On Windows the
;; "-with-deps" archive also brings librime, its DLLs and the Rime
;; schemas, so no MSYS2 or compiler is needed.  On GNU/Linux and macOS
;; the prebuilt module links against the system librime (for example
;; `apt install librime1 librime-data' or `brew install librime').

;;; Code:

;;;; Prebuilt liberime

(defvar tau-liberime-version "v0.0.11"
  "Release of liberime to download.")

(defvar tau-liberime-directory (locate-user-emacs-file "liberime/")
  "Directory into which the prebuilt liberime archive is unpacked.")

(defun tau-liberime--emacs-ucrt-p ()
  "Return non-nil if this Emacs is linked against the Windows UCRT.
UCRT builds import the api-ms-win-crt-* DLLs, MSVCRT builds do not."
  (when-let* ((exe (locate-file invocation-name (list invocation-directory)
                                exec-suffixes)))
    (with-temp-buffer
      (set-buffer-multibyte nil)
      (insert-file-contents-literally exe)
      (search-forward "api-ms-win-crt-" nil t))))

(defun tau-liberime--archive ()
  "Return (ARCHIVE . MODULE) for this system, or nil if unsupported.
ARCHIVE is the release file name, MODULE the module's path inside it."
  (let ((arm (string-prefix-p "aarch64" system-configuration)))
    (pcase system-type
      ('windows-nt
       ;; The archive ships librime and its libraries but takes the GCC
       ;; runtime DLLs from Emacs's own directory, so the C runtime of
       ;; the archive has to match the one Emacs was built with.
       (cons (format "liberime-%s-windows-%s-with-deps.zip" tau-liberime-version
                     (cond (arm "clang-arm64")
                           ((tau-liberime--emacs-ucrt-p) "ucrt-x86_64")
                           (t "x86_64")))
             "bin/liberime-core.dll"))
      ('gnu/linux
       (cons (format "liberime-%s-linux-%s.tar.gz" tau-liberime-version
                     (if arm "aarch64" "x86_64"))
             "lib/liberime-core.so"))
      ('darwin
       (cons (format "liberime-%s-macos-%s.tar.gz" tau-liberime-version
                     (if arm "arm64" "x86_64"))
             "lib/liberime-core.dylib")))))

(defun tau-liberime--module-file ()
  "Return where the prebuilt liberime module is, or would be, installed."
  (when-let* ((archive (tau-liberime--archive)))
    (expand-file-name (cdr archive) tau-liberime-directory)))

(defun tau-liberime--extract (archive directory)
  "Unpack ARCHIVE into DIRECTORY, signalling an error on failure."
  (let* ((windows-tar (and (eq system-type 'windows-nt)
                           (expand-file-name "System32/tar.exe"
                                             (getenv "SystemRoot"))))
         (status
          (cond
           ;; Windows 10+ ships bsdtar, which also reads zip files.
           ((and windows-tar (file-executable-p windows-tar))
            (call-process windows-tar nil nil nil "-xf" archive "-C" directory))
           ((eq system-type 'windows-nt)
            (call-process "powershell" nil nil nil "-NoProfile" "-Command"
                          (format "Expand-Archive -Force -LiteralPath '%s' -DestinationPath '%s'"
                                  archive directory)))
           ;; Unlike the zip files, the tarballs have a top-level directory.
           (t (call-process "tar" nil nil nil "-xzf" archive "-C" directory
                            "--strip-components=1")))))
    (unless (eq status 0)
      (error "Could not unpack %s (exit status %s)" archive status))))

(defvar tau-github-mirror)

(defun tau-liberime-install ()
  "Download and unpack the prebuilt liberime into `tau-liberime-directory'."
  (interactive)
  (let* ((archive (or (car (tau-liberime--archive))
                      (user-error "No prebuilt liberime for %s" system-configuration)))
         (url (format "%semacs-rime/liberime/releases/download/%s/%s"
                      (or tau-github-mirror "https://github.com/")
                      tau-liberime-version archive))
         (file (expand-file-name archive temporary-file-directory)))
    (make-directory tau-liberime-directory t)
    (message "Downloading %s..." url)
    (url-copy-file url file t)
    (unwind-protect
        (tau-liberime--extract file tau-liberime-directory)
      (delete-file file))
    (message "liberime installed in %s" tau-liberime-directory)))

(defun tau-liberime--preload-dlls (directory)
  "Load the DLLs in DIRECTORY that liberime-core.dll depends on.
Windows looks for a module's dependencies next to emacs.exe and on
the process PATH, not next to the module, and `setenv' only changes
the environment of subprocesses.  A DLL that is already loaded is
reused by name, so the dependencies are loaded first: `module-load'
keeps a DLL loaded even when it rejects it for not being an Emacs
module.  DLLs whose own dependencies are not loaded yet fail and are
retried until no more progress is made.  Return the DLLs that could
not be loaded."
  (let ((pending (seq-remove (lambda (file)
                               (string-suffix-p "liberime-core.dll" file))
                             (directory-files directory t "\\.dll\\'")))
        (progress t))
    (while (and pending progress)
      (setq progress nil)
      (dolist (dll pending)
        (condition-case nil
            (module-load dll)
          (module-not-gpl-compatible
           (setq pending (delete dll pending)
                 progress t))
          (module-open-failed nil))))
    pending))

(declare-function liberime-get-library-directory "liberime")
(defvar liberime-module-file)
(defvar liberime-shared-data-dir)

(defun tau-liberime--prepare (&rest _)
  "Point liberime at the prebuilt module, downloading it if necessary.
Nothing is downloaded when liberime finds a module of its own, for
example one built with `liberime-build'."
  (when-let* (((not (featurep 'liberime-core)))
              (module (tau-liberime--module-file)))
    (unless (or (file-exists-p module)
                (and liberime-module-file (file-exists-p liberime-module-file))
                (let ((dir (liberime-get-library-directory)))
                  (locate-file "liberime-core"
                               (list dir (expand-file-name "src" dir)
                                     (expand-file-name "build" dir))
                               (list module-file-suffix)))
                (not (y-or-n-p "Download the prebuilt liberime module? ")))
      (tau-liberime-install))
    (when (file-exists-p module)
      (setq liberime-module-file module)
      (let ((data (expand-file-name "share/rime-data/" tau-liberime-directory)))
        (when (and (not liberime-shared-data-dir) (file-directory-p data))
          (setq liberime-shared-data-dir data)))
      (when (eq system-type 'windows-nt)
        (tau-liberime--preload-dlls (file-name-directory module))))))

(defvar liberime-load-on-require)

;; Don't start Rime when the library loads, but when `liberime-load'
;; is called (by rimel), after `tau-liberime--prepare'.  Also at compile
;; time: when this file is byte-compiled, use-package loads liberime
;; before any of its keywords (even `:preface') is evaluated.
(eval-and-compile
  (setq liberime-load-on-require nil))

(use-package liberime
  :ensure t
  :defer t
  :config
  (advice-add 'liberime-load :before #'tau-liberime--prepare))

;;;; Rimel

;; Candidates in a child frame, also on terminals with Emacs 31.
(use-package posframe
  :ensure t
  :defer t)

(use-package rimel
  :ensure t
  :defer t
  :bind ("M-i" . rimel-convert-string-at-point) ; Pinyin before point -> 汉字.
  :init
  (setq default-input-method "rimel")
  :custom
  (rimel-schema "luna_pinyin_simp")
  (rimel-show-candidate 'posframe)
  ;; Type English without toggling: in code, after Latin letters, for
  ;; capitals, in source blocks and in math.
  (rimel-disable-predicates '(rimel-predicate-prog-in-code-p
                              rimel-predicate-after-alphabet-char-p
                              rimel-predicate-current-uppercase-letter-p
                              rimel-predicate-org-in-src-block-p
                              rimel-predicate-org-latex-mode-p
                              rimel-predicate-tex-math-or-command-p)))

(provide 'init-rime)
;;; init-rime.el ends here
