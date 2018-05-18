;;; siraben-ui.el -- configure Emacs' visual appearance.

;;; Commentary:
;; This file configures the visual appearance of Emacs, loads
;; my favorite theme, and adds a smart mode line.

;;; Code:

;; Remove the annoying blinking cursor and bell ring.
(blink-cursor-mode -1)
(setq ring-bell-function 'ignore)

;; Disable startup screen.
(setq inhibit-startup-screen t)

;; Nice scrolling.
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

;; Warn when opening files bigger than 100MB.
(setq large-file-warning-threshold 100000000)

;; Mode line settings.
(line-number-mode t)
(column-number-mode t)
(size-indication-mode t)

;; Enable short answers
(fset 'yes-or-no-p 'y-or-n-p)

;; Extra mode line modes.
(display-battery-mode t)
(display-time-mode t)
(global-company-mode t)

;;(ido-mode t)

(setq frame-title-format
      '(""
	(:eval (if (buffer-file-name)
		   (abbreviate-file-name (buffer-file-name))
		 "%b"))))

;; Enable my favorite color scheme.
(use-package color-theme-sanityinc-tomorrow
  :demand
  :config (load-theme 'sanityinc-tomorrow-bright t))

;; Improve the mode line.
(use-package smart-mode-line
  :config (progn (setq sml/no-confirm-load-theme t)
	         (setq sml/theme nil)
                 (add-to-list 'sml/replacer-regexp-list
                              '("^~/dotfiles/emacs/.emacs.d/" ":Emacs Config:") t)))


;; Remove the auto-revert mode-line
(diminish 'auto-revert-mode)
(diminish 'flyspell-mode)
(diminish 'auto-fill-function " ->|")
(diminish 'helm-mode)
(diminish 'emacs-lisp-mode "Elisp")
(add-hook 'after-init-hook #'sml/setup)

(provide 'siraben-ui)
;;; siraben-ui.el ends here
