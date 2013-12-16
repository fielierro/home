;; some setup
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(display-time)

(setq frame-title-format (list "%b - " (getenv "USERNAME") "@" system-name))
(setq user-mail-address "neil.swinton@simplivt.com")
(put 'narrow-to-region 'disabled nil)
(global-unset-key "\C-z")               ;minimize screws with Unity mode
(global-set-key (kbd "M-C-f") 'grep-find)
;; (setq grep-find-command "find . -type f -name '*~' -prune -o -print0 | "xargs" -0 -e grep -nH -e ")
(server-start)

;; Libraries
(setq load-path (append (list nil "~/elisp") load-path))
(load-library "google-c-style")
(load-library "git")
(load-library "git-blame")
(load-library "ssh.el")

;; Templates
(require 'template)
(template-initialize)

;; Copyright
(require 'copyright)
(add-hook 'before-save-hook 'copyright-update)

;; Auto-fill
(setq-default fill-column 80)
(setq auto-fill-mode 1)

;; C Style
(setq-default indent-tabs-mode nil)
(setq standard-indent 2)
(setq indent-tabs-mode nil)
(add-hook 'c-mode-common-hook 'google-set-c-style)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)
(add-hook 'c-mode-common-hook '(lambda () (c-toggle-auto-state 1)))
(show-paren-mode 1)

;; Desktop
(require 'desktop)
(setq desktop-path '("~/.emacs.d/"))
(setq desktop-buffers-not-to-save
      (concat "\\("
	      "^nn\\.a[0-9]+\\|\\.log\\|(ftp)\\|^tags\\|^TAGS"
	      "\\|\\.emacs.*\\|\\.diary\\|\\.newsrc-dribble\\|\\.bbdb"
	      "\\)$"))
(add-to-list 'desktop-modes-not-to-save 'dired-mode)
(add-to-list 'desktop-modes-not-to-save 'Info-mode)
(add-to-list 'desktop-modes-not-to-save 'info-lookup-mode)
(add-to-list 'desktop-modes-not-to-save 'fundamental-mode)

(desktop-save-mode 1)

(defun my-current-directory (text)
  (if (string-match "[a-z0-9@\-]*:\([^$]+\)" text)
      (setq cur-dir (substring text (match-beginning 1) (match-end 1)))
    (cd cur-dir)
    (message "dir tracking %s" cur-dir)))
(defun my-shell-setup ()
  "Track current directory"
  (add-hook 'comint-output-filter-functions 'my-current-directory nil t))

;; (setq shell-mode-hook 'my-shell-setup)
(add-hook 'shell-mode-hook
          (lambda()
            (setq dirtrack-list '("^[0-9]+:[0-9][0-9]:[0-9][0-9]^.*[^ ]+:\\(.*\\)[\$\#] " 1 nil))
            (shell-dirtrack-mode )))

(defun unix-line-endings()
  "Change to Unix endings."
  (interactive)
  (set-buffer-file-coding-system 'iso-latin-1-unix t)
)

(defun dos-line-endings()
  "Change to DOS line endings."
  (interactive)
  (set-buffer-file-coding-system 'iso-latin-1-dos t)
)

(defun mac-line-endings()
  "Change to Mac line endings."
  (interactive)
  (set-buffer-file-coding-system 'iso-latin-1-mac t)
)

(defun new-shell(name)
  "Create a new, named, shell buffer"
  (interactive "sName: ")
  (shell (get-buffer-create name))
  (switch-to-buffer name)
  )


(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(c-auto-align-backslashes t)
 '(safe-local-variable-values (quote ((c-default-style . "bsd"))))
 '(sort-fold-case t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

(defun errno()
  "Open the base errno file on ubuntu"
  (interactive)
  (find-file-read-only "/usr/include/asm-generic/errno-base.h")
)
