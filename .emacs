;; Sample load command for top-level .emacs: (load "~/git/home/.emacs")

;; preable, require up the emacs built in package manager.
(require 'package)

;; configure package to use melpa, org, and melpa-stable
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")))

;; and finaglly initialize package manager
(package-initialize)

;; the rest of this uses use-package to manage loading and configuring
;; packagess. if use-package isn't installed go fetch and install
;; it. this is super easy because our just configured package manager
;; can fetch use package for us.
(when
    (not package-archive-contents)
  (package-refresh-contents)
  (package-install 'use-package))

;; make use-package download all referenced but uninstalled
;; packages.
(setq use-package-always-ensure t)


;; Add this directory to the load path
(setq load-path (append (list nil (concat (file-name-directory (or load-file-name buffer-file-name)) "elisp")) load-path))

;; Setup window appearance
(tool-bar-mode   -1)                    ; no toolbar
(menu-bar-mode   -1)                    ; no menubar
(scroll-bar-mode -1)                    ; no scrollbar
(display-time)                          ; show time in the status bar

;; Don't split horizontally unless I do it explicitly
;; (setq split-height-threshold 1200)
(setq split-width-threshold 2000)

(setq frame-title-format (list "%b - " (getenv "USER") "@" system-name)) ; window frame has buffer, username, and system name

;; Allow find-file to open urls
(url-handler-mode 1)

;; Require final newlines by default
(setq require-final-newline t)

;----------------------------------------------------------------------------------
;;;
;;; time-stamp: Useful for timestamping files when you save them
;;;
;; jpm: DO NOT modify a read only buffer (ie, VM buffers!! ie, if I've emailed myself a script...)
;; jpm was:     (if (and (stringp time-stamp-start)
;    (if (and (not buffer-read-only) (stringp time-stamp-start)
;
; jpm: Also had to blow away time-stamp.elc, for some reason wasnt auto-recompiling...
; see /usr/local/lib/xemacs/xemacs-packages/lisp/xemacs-base/time-stamp.el for formats:
; (add-hook 'write-file-hooks 'time-stamp)
; jpmfix was 12/08: (setq time-stamp-format "%02d-%3b-%y %02H:%02M:%02S %u@%s")
; jpmfix 12/08: (setq time-stamp-start "Last modified on:[ \t]+\\\\?[.]*")
(setq time-stamp-format "%02d-%3b-%:y %02H:%02M:%02S %u/%s")
; jpmfix was this 8/20/08: (setq time-stamp-start "Last modified on:[ \t]+\\\\?[.]*")
; Change it to allow string to have Last modified on: <09-Nov-2017 08:59:22 neil/dnx-swarm-manager.jqb1nsbpafmetnlegmr14s1iig.bx.internal.cloudapp.net"
; searc for spaces/tabs
(setq time-stamp-start "Last modified on:[ \t]+\\\\?[\"<]*" )
(setq time-stamp-line-limit 9999)
(setq time-stamp-end "\\\\?[\";]*$")

;; after copy Ctrl+c in Linux X11, you can paste by `yank' in emacs
(setq x-select-enable-clipboard t)

;; after mouse selection in X11, you can paste by `yank' in emacs
(setq x-select-enable-primary t)

;; Show trialing whitespace
(setq show-trailing-whitespace t)

;; Ruby
(add-to-list 'auto-mode-alist
             '("\\.\\(?:cap\\|gemspec\\|irbrc\\|gemrc\\|rake\\|rb\\|ru\\|thor\\)\\'" . ruby-mode))
(add-to-list 'auto-mode-alist
             '("\\(?:Brewfile\\|Capfile\\|Gemfile\\(?:\\.[a-zA-Z0-9._-]+\\)?\\|[rR]akefile\\)\\'" . ruby-mode))
(add-hook 'ruby-mode-hook
          (lambda () (add-hook 'before-save-hook 'whitespace-cleanup nil t)))

;; Python Hook
(add-hook 'python-mode-hook
          (function (lambda ()
                      (add-hook 'before-save-hook 'whitespace-cleanup nil t)
                      (setq indent-tabs-mode nil tab-width 2))))

;; Terraform Hook
(add-hook 'terraform-mode-hook
          (function (lambda ()
                      (add-hook 'before-save-hook 'whitespace-cleanup nil t)
                      )))


;; Customize keys
(put 'narrow-to-region 'disabled nil)   ; Enable narrow-to-region
(global-unset-key "\C-z")               ; Disable minimizing via keystroke -- it screws with VMware Unity mode
(global-set-key (kbd "M-C-f") 'grep-find) ;Use ESC-ctrl-f for grep-find
;; (setq grep-find-command "find . -type f -name '*~' -prune -o -print0 | "xargs" -0 -e grep -nH -e ")

;; Run server so other shells can use this session via emacsclient
(server-start)

;; Use yaml mode for SaltStack sls files
(add-to-list 'auto-mode-alist '("\\.sls$" . yaml-mode))

;; Libraries -- all relative to this .emacs file

(load-library "google-c-style")
(load-library "ssh")
(load-library "shell-procfs-dirtrack")

;; Git is installed via package manager now, but we've got a copy just in case
;(load-library "git") ;; Install via package manager
;(load-library "git-blame")  ;; Install via package manager
(require 'git)

;; Use the template package
(require 'template)
(template-initialize)

;; Copyright
(require 'copyright)
(add-hook 'before-save-hook 'copyright-update)

;; Auto-fill
(setq-default fill-column 80)
(setq auto-fill-mode 1)
(add-hook 'vc-log-mode-hook 'turn-on-auto-fill) ; wrap commit messages

;; Color comint output in older Emacsen
(ansi-color-for-comint-mode-on)

;; Indentation
(setq-default indent-tabs-mode nil)
(setq standard-indent 2)
(setq indent-tabs-mode nil)
(setq show-trailing-whitespace 't)

;; C Style
(add-hook 'c-mode-common-hook 'google-set-c-style)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)
(add-hook 'c-mode-common-hook '(lambda () (c-toggle-auto-state 1)))

;; Emacs Lisp
(add-hook 'emacs-lisp-mode-hook
          (lambda ()

           ;; Use spaces, not tabs.
           (setq indent-tabs-mode nil)
           (setq standard-indent 2)

           ;; Pretty-print eval'd expressions.
           (define-key emacs-lisp-mode-map
            "\C-x\C-e" 'pp-eval-last-sexp)

           ;; Recompile if .elc exists.
           (add-hook (make-local-variable 'after-save-hook)
                     (lambda ()
                      (byte-force-recompile default-directory)))

           (add-hook 'before-save-hook 'whitespace-cleanup nil t)

           (define-key emacs-lisp-mode-map
            "\r" 'reindent-then-newline-and-indent)))


(show-paren-mode 1)

;; Desktop
(require 'desktop)
(unless (file-directory-p "~/.emacs.d/")
 (make-directory "~/.emacs.d"))

;; use only one desktop
(setq desktop-path '("~/.emacs.d/"))
(setq desktop-dirname "~/.emacs.d/")
(setq desktop-base-file-name "emacs-desktop")
(setq desktop-auto-save-timeout 30)

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
(defun my-desktop-save ()
  (interactive)
  ;; Don't call desktop-save-in-desktop-dir, as it prints a message.
  (if (eq (desktop-owner) (emacs-pid))
      (desktop-save desktop-dirname)))
(add-hook 'auto-save-hook 'my-desktop-save)

(defun resize-frame()
  "On windowing system, set frame size based on screen size"
  (interactive)
  (when (display-graphic-p)
    (let* ((screen-height (/ (x-display-pixel-height) (frame-char-height)))
           (screen-width (/ (x-display-pixel-width) (frame-char-width)))
           (height-percent 90)
           (width-percent 65)
           (width-max 140)
           (new-frame-height (/ (* screen-height height-percent) 100))
           (new-frame-width (/ (* screen-width width-percent) 100))
           (new-offset-index (random 5))
           )
      (if (> new-frame-width width-max)
          (setq new-frame-width width-max))
      (set-frame-position (selected-frame)
                          (* new-offset-index (/ (x-display-pixel-height) 100))
                          (* new-offset-index (/ (x-display-pixel-width) 100)))
      (set-frame-size (selected-frame) new-frame-width new-frame-height)
      )
    )
  )

(resize-frame)

(defun retitle(name)
  "Set the frame title"
  (interactive "sName: ")
  (setq frame-title-format (list "%b - " (getenv "USER") "@" name))
  )


(defun ssh-host(id host)
  "Insert entry in ssh-config"
  (interactive "sId: \nsHost: ")
  (save-excursion
    (set-buffer (find-file-noselect "~/.ssh/config"))
    (goto-char (point-max))
    (insert (format "\nHost %s\n     Hostname %s\n     User dcuser\n     ForwardAgent yes\n     ForwardX11 yes\n     ForwardX11Trusted yes\n\n" id host))
    (kill-new id)
    (basic-save-buffer)
    ))


;; dirtrack-mode settings
(defun my-current-directory (text)
  (if (string-match "[a-z0-9@\-]*:\([^$]+\)" text)
      (setq cur-dir (substring text (match-beginning 1) (match-end 1)))
    (cd cur-dir)
    (message "dir tracking %s" cur-dir)))
(defun my-shell-setup ()
  "Track current directory"
  (add-hook 'comint-output-filter-functions 'my-current-directory nil t))

;; (setq shell-mode-hook 'my-shell-setup)
(if (file-accessible-directory-p (format "/proc/%s/cwd" (emacs-pid)))
    (add-hook 'shell-mode-hook 'shell-procfs-dirtrack-mode))

;;(Add-hook 'shell-mode-hook
;;          (lambda()
;;            (setq dirtrack-list '("^[0-9]+:[0-9][0-9]:[0-9][0-9]^.*[^ ]+:\\(.*\\)[\$\#] " 1 nil))
;;            (shell-dirtrack-mode 't)))

;;
;; Utility functions
;;
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

(defun errno()
  "Open the base errno file on ubuntu"
  (interactive)
  (find-file-read-only "/usr/include/asm-generic/errno-base.h")
)

;; Customize
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(c-auto-align-backslashes t)
 '(display-time-world-list (quote (("EST5EDT" "New York") ("UTC" "Universal"))))
 '(safe-local-variable-values (quote ((c-default-style . "bsd"))))
 '(sort-fold-case t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
