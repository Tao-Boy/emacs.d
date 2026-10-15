;;; init-ai.el --- AI pair programming with ECA -*- lexical-binding: t; -*-

;;; Commentary:

;; ECA (Editor Code Assistant) talks to the `eca' server, which
;; `M-x eca' downloads on first use unless an `eca' executable is on
;; PATH or `eca-custom-command' is set.  Models, providers and API keys
;; are configured on the server side: `M-x eca-open-global-config'.

;;; Code:

(use-package eca
  :ensure t
  :defer t
  :bind (:prefix-map tau-eca-map
         :prefix "C-c e"
         :prefix-docstring "Prefix keymap for ECA commands."
         ("e" . eca)                                 ; Start, or open the chat.
         ("t" . eca-chat-toggle-window)
         ("i" . eca-chat-inline-prompt)              ; Ask from any buffer.
         ("a" . eca-chat-add-context-to-user-prompt) ; File or region as context.
         ("n" . eca-chat-new)
         ("s" . eca-switch-to-chat)
         ("w" . eca-workspaces)
         ("m" . eca-chat-select-model)
         ("," . eca-settings)
         ("q" . eca-stop))
  :custom
  (eca-chat-window-side 'right)
  ;; `url-retrieve' downloads the server asynchronously; curl can block
  ;; Emacs on some builds.
  (eca-server-download-method 'url-retrieve))

(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements "C-c e" "eca"))

(provide 'init-ai)
;;; init-ai.el ends here
