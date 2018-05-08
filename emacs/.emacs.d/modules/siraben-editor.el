;;; siraben-editor.el --- make Emacs a great editor.
;;; Commentary:

;;; Code:

;; Don't use tabs to indent but maintain correct appearance.
(setq-default indent-tabs-mode nil)
(setq-default tab-width 8)

;; Newline at end of file
(setq require-final-newline t)

;; Delete the selection with a keypress.
(delete-selection-mode t)

;; Store all backup and autosave files in the tmp dir.
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(require 'undo-tree)
;; Auto-save the undo-tree history.
(setq undo-tree-history-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq undo-tree-auto-save-history t)

;; Revert buffers automatically when underlying files are changed
;; externally.  Disabled because of performance concerns.  (buffers
;; are checked every five seconds)

;; (global-auto-revert-mode t)

(setq tab-always-indent 'complete)

;; Blinking parens are ugly, remove that.
(setq blink-matching-paren nil)

;; Not a big fan of this package (needs some getting used to), but
;; necessary for many programming languages.
(use-package smartparens)

(defun siraben-enable-writing-modes ()
  "Enables writing modes for writing prose.
Enables auto-fill mode, spell checking and disables company mode."
  (interactive)
  (progn (auto-fill-mode 1)
	 (undo-tree-mode 1)
	 (flyspell-mode 1)

         ;; This is for situations like vertically split windows when
	 ;; Org mode headings don't wrap.
	 (visual-line-mode 1)
         
	 (company-mode -1)))

(defvar-local siraben-timed-writing-timer
  nil
  "The current writing timer object. Stop this timer with
`cancel-timer'.")

(defun siraben-timed-writing-mode (&optional length)
  "Begin a timed writing session for LENGTH minutes.
Default value of 5.

After X minutes, the user is prompted to make the buffer from
which the function was invoked read only."
  (interactive "p")
  (let ((working-buffer (current-buffer))
        (default-length 5))
    (setq-local siraben-timed-writing-timer
                (run-at-time (concat (int-to-string (or current-prefix-arg
                                                        length
                                                        default-length)) "min")
                             nil
                             `(lambda ()
                                (switch-to-buffer ,working-buffer)
                                (read-only-mode))))))

(add-hook 'markdown-mode-hook #'siraben-enable-writing-modes)
(add-hook 'org-mode-hook #'siraben-enable-writing-modes)
(setq auto-save-interval 100)

(require 'siraben-mdm)

(use-package mark-multiple)
(use-package multiple-cursors)

(require 'inline-string-rectangle)
(global-set-key (kbd "C-x r t") 'inline-string-rectangle)

(require 'mark-more-like-this)
(global-set-key (kbd "C-<") 'mark-previous-like-this)
(global-set-key (kbd "C->") 'mark-next-like-this)

;; Like the other two, but takes an argument (negative is previous)
(global-set-key (kbd "C-M-m") 'mark-more-like-this)
(global-set-key (kbd "s-G") 'mark-all-like-this)

(add-hook 'sgml-mode-hook
          #'(lambda ()
              (require 'rename-sgml-tag)
              (define-key sgml-mode-map (kbd "C-c C-r") 'rename-sgml-tag)))

(use-package emojify)
(use-package company-emoji)

(setq kill-do-not-save-duplicates t)
(setq save-interprogram-paste-before-kill t)

(provide 'siraben-editor)
;;; siraben-editor.el ends here
