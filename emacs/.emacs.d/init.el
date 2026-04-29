;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Performance Tweaks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Suppress annoying message while opening init.el
(with-eval-after-load 'flycheck
  (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc)))

;; Measure startup time
(defconst emacs-start-time (current-time))

;; Suppress all messages during startup
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      inhibit-default-init t
      inhibit-startup-screen t)

;; Suppress native compilation warnings during startup only
(setq native-comp-async-report-warnings-errors nil)
(setq byte-compile-warnings '(not obsolete free-vars unresolved cl-functions))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Package Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/") t)
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t
      use-package-always-defer t        ; Defer by default for performance
      use-package-compute-statistics t  ; Track loading times
      use-package-verbose nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Performance Optimization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq idle-update-delay 1.0)
(setq read-process-output-max (* 4 1024 1024))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Basic UI and Editor Behavior
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; UI cleanup
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode 1)
(size-indication-mode 1)

;; Editor behavior
(setq-default indent-tabs-mode nil
              tab-width 4
              show-trailing-whitespace t)
(setq scroll-conservatively 100
      scroll-margin 3)

;; Encoding
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; Hooks
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'hl-line-mode)
(add-hook 'before-save-hook #'delete-trailing-whitespace)

;; Parentheses
(show-paren-mode 1)
(setq show-paren-delay 0)
(electric-pair-mode 1)

;; Auto-revert
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)

;; Cursor Style
(setq-default cursor-type 'bar)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Font Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (seq-filter (lambda (f) (string-match-p "Caskaydia" f)) (font-family-list))

(when (member "CaskaydiaCove Nerd Font" (font-family-list))
  ;; Base monospace font
  (set-face-attribute 'default nil
                      :font "CaskaydiaCove Nerd Font"
                      :height 140
                      :weight 'regular)

  ;; Fixed Pitch
  (set-face-attribute 'fixed-pitch nil
                      :font "CaskaydiaCove Nerd Font"
                      :height 140
                      :weight 'regular)

  ;; Varible Pitch
  (set-face-attribute 'variable-pitch nil
                    :font "CaskaydiaCove Nerd Font"
                    :height 140
                    :weight 'regular)

  ;; Bold
  (set-face-attribute 'bold nil
                      :font "CaskaydiaCove Nerd Font"
                      :weight 'bold)

  ;; Italic
  (set-face-attribute 'italic nil
                      :font "CaskaydiaCove Nerd Font"
                      :slant 'italic)

  ;; Bold italic
  (set-face-attribute 'bold-italic nil
                      :font "CaskaydiaCove Nerd Font"
                      :weight 'bold
                      :slant 'italic))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Icons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package nerd-icons
  :ensure t
  :init
  (setq nerd-icons-scale-factor 1.2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Dashboard
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package dashboard
  :demand t
  :after nerd-icons
  :config
  (setq dashboard-startup-banner 'logo
        dashboard-center-content t
        dashboard-vertically-center-content t
        dashboard-display-icons-p t
        dashboard-icon-type 'nerd-icons
        dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-path-max-length 30
        dashboard-items-default-length 20)
  (dashboard-setup-startup-hook))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Doom-Themes and Doom-Modeline Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package doom-themes
  :demand t
  :init
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  :config
  (load-theme 'doom-one :no-confirm)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(use-package doom-modeline
  :demand t
  :hook (after-init . doom-modeline-mode)
  :config
  (setq doom-modeline-height 25
        doom-modeline-bar-width 4
        doom-modeline-icon t
        doom-modeline-major-mode-icon t
        doom-modeline-major-mode-color-icon t
        doom-modeline-buffer-file-name-style 'truncate-upto-project))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Eldoc Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package eldoc
  :preface
   (add-to-list 'display-buffer-alist
               '("^\\*eldoc for" display-buffer-at-bottom
                 (window-height . 4)))
   (setq eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)
  :config
   (eldoc-add-command-completions "paredit-")
   (eldoc-add-command-completions "combobulate-"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Syntax Checking using Flycheck
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package flycheck
  :preface

  (defun mp-flycheck-eldoc (callback &rest _ignored)
    "Print flycheck messages at point by calling CALLBACK."
    (when-let ((flycheck-errors (and flycheck-mode (flycheck-overlay-errors-at (point)))))
      (mapc
       (lambda (err)
         (funcall callback
           (format "%s: %s"
                   (let ((level (flycheck-error-level err)))
                     (pcase level
                       ('info (propertize "I" 'face 'flycheck-error-list-info))
                       ('error (propertize "E" 'face 'flycheck-error-list-error))
                       ('warning (propertize "W" 'face 'flycheck-error-list-warning))
                       (_ level)))
                   (flycheck-error-message err))
           :thing (or (flycheck-error-id err)
                      (flycheck-error-group err))
           :face 'font-lock-doc-face))
       flycheck-errors)))

  (defun mp-flycheck-prefer-eldoc ()
    (add-hook 'eldoc-documentation-functions #'mp-flycheck-eldoc nil t)
    (setq eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)
    (setq flycheck-display-errors-function nil)
    (setq flycheck-help-echo-function nil))

  :hook ((flycheck-mode . mp-flycheck-prefer-eldoc)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; File Explorer & Dired
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; dired-subtree — expand subdirectories inline with TAB / S-TAB
(use-package dired-subtree
  :after dired
  :bind (:map dired-mode-map
         ("<tab>"     . dired-subtree-toggle)
         ("<backtab>" . dired-subtree-cycle))
  :config
  (setq dired-subtree-use-backgrounds nil)) ; cleaner look in a narrow sidebar

(use-package dired-toggle
  :defer t
  :bind (("<f3>" . #'dired-toggle)
         :map dired-mode-map
         ("q" . #'dired-toggle-quit)
         ([remap dired-find-file] . #'dired-toggle-find-file)
         ([remap dired-up-directory] . #'dired-toggle-up-directory)
         ("C-c C-u" . #'dired-toggle-up-directory))
  :config
  (setq dired-toggle-window-size 32)
  (setq dired-toggle-window-side 'left)

  ;; Optional, enable =visual-line-mode= for our narrow dired buffer:
  (add-hook 'dired-toggle-mode-hook
            (lambda () (interactive)
              (visual-line-mode 1)
              (setq-local visual-line-fringe-indicators '(nil right-curly-arrow))
              (setq-local word-wrap nil))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Project Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package project
  :ensure nil
  :bind-keymap ("C-c P" . project-prefix-map))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Centaur Tabs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package centaur-tabs
  :demand t
  :init
  (setq centaur-tabs-style             "bar"
        centaur-tabs-height            30
        centaur-tabs-set-icons         t
        centaur-tabs-icon-type         'nerd-icons
        centaur-tabs-set-bar           'over
        centaur-tabs-set-modified-marker t
        centaur-tabs-modified-marker   "●"
        centaur-tabs-cycle-scope       'tabs)
  :config
  (centaur-tabs-mode 1)
  (centaur-tabs-group-by-projectile-project)
  (defun my/centaur-tabs-hide-buffer-p (buffer)
    (with-current-buffer buffer
      (or (string-prefix-p "*" (buffer-name))
          (derived-mode-p 'dired-mode))))
  (setq centaur-tabs-hide-tab-function #'my/centaur-tabs-hide-buffer-p)
  :bind
  (("C-<prior>" . centaur-tabs-backward)
   ("C-<next>"  . centaur-tabs-forward)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Which-Key
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package which-key
  :demand t
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.5))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Eglot and Corfu configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package eglot
  :ensure nil
  :hook ((c-mode      . eglot-ensure)
         (c++-mode    . eglot-ensure)
         (python-mode . eglot-ensure)
         (verilog-mode . eglot-ensure))
  :custom
  (eglot-autoshutdown t)
  (eglot-sync-connect 1)
  (eglot-ignored-server-capabilities '(:documentHighlightProvider))
  :config
  (add-to-list 'eglot-server-programs
               '((verilog-mode) . ("verible-verilog-ls"))))

(use-package corfu
  :ensure t
  :demand t
  :init
  (setq corfu-auto t
        corfu-auto-delay 0.1
        corfu-auto-prefix 2
        corfu-cycle t
        corfu-quit-no-match t)
  :config
  (global-corfu-mode))

(use-package cape
  :ensure t
  :demand t
  :bind ("C-c p" . cape-prefix-map)
  :config
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file))

(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet
  :config
  (yas-reload-all))

(use-package yasnippet-capf
  :ensure t
  :after (yasnippet cape))

;; Merge all LSP-buffer sources into one simultaneous query
(defun my/eglot-capf-setup ()
  (setq-local completion-at-point-functions
              (list
               (cape-capf-super
                #'eglot-completion-at-point
                #'yasnippet-capf
                #'cape-dabbrev
                #'cape-file))))

(with-eval-after-load 'eglot
  (add-hook 'eglot-managed-mode-hook #'my/eglot-capf-setup))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Magit - Git Interface
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package transient
  :demand t)

(use-package magit
  :after transient
  :bind (("C-x g" . magit-status)
         ("C-x M-g" . magit-dispatch)
         ("C-c g" . magit-file-dispatch)
         ("C-c M-g" . magit-blame-addition))
  :config
  (setq magit-diff-refine-hunk 'all
        magit-refresh-status-buffer t
        magit-commit-show-diff t
        magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package diff-hl
  :demand t
  :hook ((magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (global-diff-hl-mode)
  (diff-hl-flydiff-mode)
  (diff-hl-margin-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Emacs Lisp Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package elisp-mode
  :ensure nil
  :bind (:map emacs-lisp-mode-map
              ("C-c C-e" . eval-last-sexp)
              ("C-c C-b" . eval-buffer)
              ("C-c C-r" . eval-region)
              ("C-c C-d" . describe-function)
              ("C-c C-v" . describe-variable))
  :hook (emacs-lisp-mode . eldoc-mode)
  :config
  (setq eldoc-idle-delay 0.1))

;; Enhanced elisp-refs for finding definitions
(use-package elisp-refs
  :bind (:map emacs-lisp-mode-map
              ("C-c C-f" . elisp-refs-function)))

;; Macrostep for macro expansion
(use-package macrostep
  :bind (:map emacs-lisp-mode-map
              ("C-c e" . macrostep-expand)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Verilog / SystemVerilog
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package verilog-ext
  :ensure t
  :demand t
  :hook (verilog-mode . verilog-ext-mode)
  :init
  (setq verilog-ext-feature-list
        '(font-lock
          eglot
          flycheck
          navigation
          template
          compilation
          imenu
          ports
          which-func
          beautify))
  :config
  (verilog-ext-mode-setup)
  (setq verilog-ext-flycheck-default-linter 'verilog-ext-verible)

  (setq verilog-indent-level             3
        verilog-indent-level-module      3
        verilog-indent-level-declaration 3
        verilog-indent-level-behavioral  3
        verilog-case-indent              2
        verilog-auto-newline             nil
        verilog-auto-indent-on-newline   t
        verilog-auto-endcomments         t
        verilog-tab-always-indent        t
        verilog-highlight-p1800-keywords t)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; C / C++ Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package cc-mode
  :ensure nil
  :hook ((c-mode   . (lambda () (c-set-style "bsd")))
         (c++-mode . (lambda () (c-set-style "bsd"))))
  :config
  (setq c-basic-offset 4
        c-tab-always-indent t))

;; clang-format: auto-format C/C++ on save or manually
(use-package clang-format
  :bind (:map c-mode-base-map
              ("C-c f"   . clang-format-buffer)
              ("C-c C-f" . clang-format-region))
  :config
  ;; Use a .clang-format file in your project root if present, otherwise Google style
  (setq clang-format-style "file"
        clang-format-fallback-style "Google"))

;; CMake support for CMakeLists.txt and .cmake files
(use-package cmake-mode
  :mode (("CMakeLists\\.txt\\'" . cmake-mode)
         ("\\.cmake\\'" . cmake-mode)))

;; Grand Unified Debugger
(use-package gud
  :ensure nil
  :bind (("<f5>"    . gdb)
         ("<f9>"    . gud-break)
         ("<f10>"   . gud-next)
         ("<f11>"   . gud-step)
         ("<S-f11>" . gud-finish)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Org Mode Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package org
  :ensure t
  :pin gnu
  :bind (("C-c l" . org-store-link)
         ("C-c c" . org-capture))
  :hook ((org-mode . org-indent-mode)
         (org-mode . visual-line-mode)
         (org-mode . variable-pitch-mode))
  :config

  (dolist (face '((org-level-1 . 1.5)
                  (org-level-2 . 1.3)
                  (org-level-3 . 1.2)
                  (org-level-4 . 1.1)))
    (set-face-attribute (car face) nil :weight 'bold :height (cdr face)))

  (set-face-attribute 'org-document-title nil :weight 'bold :height 1.6 :underline nil)

  ;; Code execution
  (require 'org-tempo)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (C          . t)
     (python     . t)))
  (setq org-babel-python-command  "python3"
        org-confirm-babel-evaluate nil)

  ;; Source block indentation
  (setq org-src-fontify-natively        t   ; syntax-highlight blocks in-buffer
        org-src-tab-acts-natively       t
        org-src-preserve-indentation    t
        org-edit-src-content-indentation 0)

  ;; Display
  (setq org-return-follows-link    t
        org-hide-emphasis-markers  t
        org-hide-leading-stars     t
        org-pretty-entities        t
        org-ellipsis               " ·" ; collapsed heading indicator
        org-startup-folded         'content)

  (setq org-capture-templates
        '(("n" "Note" entry (file "~/org/notes.org")
           "* %?\n  %i\n  %a")))

  (require 'org-indent)
  (set-face-attribute 'org-indent          nil :inherit '(org-hide fixed-pitch))
  (set-face-attribute 'org-block           nil :inherit 'fixed-pitch :height 0.85)
  (set-face-attribute 'org-code            nil :inherit '(shadow fixed-pitch) :height 0.85)
  (set-face-attribute 'org-verbatim        nil :inherit '(shadow fixed-pitch) :height 0.85)
  (set-face-attribute 'org-meta-line       nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox        nil :inherit 'fixed-pitch))

(use-package org-modern
  :hook (org-mode . org-modern-mode)
  :config
  (setq org-modern-tag      nil   ; don't restyle tags
        org-modern-priority nil   ; no priority indicators
        org-modern-todo     nil)) ; no TODO keywords

(use-package olivetti
  :hook (org-mode . olivetti-mode)
  :config
  (setq olivetti-body-width 100)
  (setq olivetti-style nil)) ; characters wide; adjust to your screen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; File Backup & Cleanup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq backup-directory-alist '(("." . "~/.emacs.d/backups"))
      make-backup-files t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      delete-auto-save-files t
      create-lockfiles nil
      recentf-max-saved-items 50
      recentf-max-menu-items 15
      message-log-max 1000)

(let ((eln-dir (list (expand-file-name "eln-cache" user-emacs-directory))))
  (if (boundp 'native-comp-eln-load-path)
      (setq native-comp-eln-load-path eln-dir)   ; Emacs 29
    (setq comp-eln-load-path eln-dir)))          ; Emacs 30 (in case Emacs is updated)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Restore Performance After Startup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-hook 'emacs-startup-hook
          (lambda ()
            ;; Restore normal GC settings
            (setq gc-cons-threshold (* 20 1000 1000)
                  gc-cons-percentage 0.1)

            ;; Re-enable warnings
            (setq native-comp-async-report-warnings-errors 'silent)

            ;; Display startup time
            (message "Emacs loaded in %.2f seconds with %d garbage collections."
                     (float-time (time-subtract after-init-time before-init-time))
                     gcs-done)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Configuration Analysis & Warnings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun check-init-redundancies ()
  "Check for redundant or unnecessary configuration in init.el."
  (interactive)
  (with-output-to-temp-buffer "*Init Analysis*"
    (princ "Emacs Configuration Analysis\n\n")

    ;; Check for required executables
    (princ "External Tool Dependencies\n")
    (dolist (tool '(("verilator"          "Verilog linting/simulation")
                    ("verible-verilog-ls" "Verilog LSP server")
                    ("clangd"             "C/C++ LSP server")
                    ("clang-format"       "C/C++ formatter")
                    ("gdb"                "C/C++ debugger")
                    ("cmake"              "CMake build system")
                    ("pyright"            "Python LSP server")
                    ("python3"            "Python interpreter")))
      (if (executable-find (car tool))
          (princ (format "%s: Found\n" (car tool)))
        (princ (format "%s: NOT FOUND%s\n" (car tool) (cadr tool)))))

    (princ "\nPerformance Statistics\n")
    (when (fboundp 'use-package-report)
      (princ "  Run M-x use-package-report for loading times\n"))

    (princ (format "  GC threshold: %s\n" gc-cons-threshold))
    (princ (format "  Read process max: %s bytes\n" read-process-output-max))

    ;; Check font availability
    (princ "\nFont Configuration\n")
    (if (member "JetBrainsMono Nerd Font" (font-family-list))
        (princ "JetBrainsMono Nerd Font: Found\n")
      (princ "JetBrainsMono Nerd Font: NOT FOUND\n"))

    (princ "\nAnalysis Complete\n")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; End of Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(olivetti org-modern elisp-refs macrostep diff-hl transient magit which-key corfu verilog-ext cape dired-toggle dired-subtree flycheck yasnippet yasnippet-snippets yasnippet-capf clang-format cmake-mode doom-modeline doom-themes nerd-icons dashboard gud centaur-tabs)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
