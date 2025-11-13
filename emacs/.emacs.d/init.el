;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Performance Tweaks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Measure startup time
(defconst emacs-start-time (current-time))

;; Maximize GC threshold during startup
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Suppress all messages during startup
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      inhibit-default-init t
      inhibit-startup-screen t)

;; Don't resize frame
(setq frame-inhibit-implied-resize t)

;; Package initialization will happen later
(setq package-enable-at-startup nil)

;; Suppress native compilation warnings during startup only
(setq native-comp-async-report-warnings-errors nil)
(setq byte-compile-warnings '(not obsolete free-vars unresolved cl-functions))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Package Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t
      use-package-always-defer t  ; Defer by default for performance
      use-package-compute-statistics t  ; Track loading times
      use-package-verbose nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Performance Optimization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq idle-update-delay 1.0)
(setq read-process-output-max (* 1024 1024)) ; 1 MB

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

;; Auto-revert
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Font Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(when (member "JetBrainsMono Nerd Font" (font-family-list))
  (set-face-attribute 'default nil
                      :font "JetBrainsMono Nerd Font"
                      :height 140)
  (set-face-attribute 'fixed-pitch nil
                      :font "JetBrainsMono Nerd Font"
                      :height 140))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Icons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package all-the-icons
  :if (display-graphic-p)
  :demand t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Dashboard - Welcome Screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package dashboard
  :demand t
  :after all-the-icons
  :config
  (setq dashboard-banner-logo-title "Welcome to Emacs!"
        dashboard-startup-banner 'logo
        dashboard-center-content t
        dashboard-vertically-center-content t
        dashboard-display-icons-p t
        dashboard-icon-type 'all-the-icons
        dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-items '((recents . 8) (agenda . 5))
        dashboard-path-max-length 50
        dashboard-items-default-length 20
        dashboard-set-init-info t)
  (dashboard-setup-startup-hook))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Theme Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package catppuccin-theme
  :demand t
  :config
  (setq catppuccin-flavor 'mocha)
  (load-theme 'catppuccin :no-confirm))

(use-package doom-modeline
  :demand t
  :config
  (setq doom-modeline-height 25
        doom-modeline-bar-width 3
        doom-modeline-icon t
        doom-modeline-major-mode-icon t
        doom-modeline-major-mode-color-icon t
        doom-modeline-buffer-file-name-style 'truncate-upto-project)
  (doom-modeline-mode 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Auto-completion (Company)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package company
  :hook (prog-mode . company-mode)
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection)
              ("TAB" . company-complete-selection)
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous))
  :config
  (setq company-idle-delay 0.1
        company-minimum-prefix-length 2
        company-show-quick-access t
        company-selection-wrap-around t
        company-dabbrev-downcase nil
        company-backends '((company-capf company-files company-keywords))
        company-transformers '(company-sort-by-occurrence)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Syntax Checking (Flycheck)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package flycheck
  :hook (prog-mode . flycheck-mode)
  :config
  (setq flycheck-check-syntax-automatically '(save idle-change mode-enabled)
        flycheck-idle-change-delay 0.5
        flycheck-display-errors-delay 0.3))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Language Server Protocol (LSP)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((c-mode c++-mode python-mode verilog-mode) . lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (setq lsp-idle-delay 0.5
        lsp-log-io nil
        lsp-file-watch-threshold 2000
        lsp-enable-symbol-highlighting t
        lsp-enable-on-type-formatting nil
        lsp-headerline-breadcrumb-enable t
        lsp-modeline-diagnostics-enable t
        lsp-auto-guess-root t
        lsp-auto-configure t
        lsp-lens-enable t
        lsp-signature-auto-activate t
        lsp-signature-render-documentation t)

  ;; Clangd for C/C++
  (setq lsp-clients-clangd-args
        '("--header-insertion=never"
          "--clang-tidy"
          "--completion-style=detailed"
          "--background-index"
          "--pch-storage=memory"))

  ;; Verible for Verilog/SystemVerilog
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection "verible-verilog-ls")
    :major-modes '(verilog-mode)
    :server-id 'verible-ls
    :priority 1)))

(use-package lsp-ui
  :after lsp-mode
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)
  :bind (:map lsp-ui-mode-map
              ("C-c l d" . lsp-ui-doc-show)
              ("C-c l p" . lsp-ui-peek-find-definitions)
              ("C-c l r" . lsp-ui-peek-find-references)
              ("C-c l i" . lsp-ui-imenu))
  :config
  (setq lsp-ui-sideline-enable t
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-show-code-actions t
        lsp-ui-peek-enable t
        lsp-ui-doc-enable t
        lsp-ui-doc-position 'at-point
        lsp-ui-doc-delay 0.5))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Verilog/SystemVerilog Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package verilog-mode
  :ensure nil
  :mode (("\\.v\\'" . verilog-mode)
         ("\\.vh\\'" . verilog-mode)
         ("\\.sv\\'" . verilog-mode)
         ("\\.svh\\'" . verilog-mode))
  :bind (:map verilog-mode-map
              ("C-c C-a" . verilog-auto)
              ("C-c C-s" . verilog-sk-begin)
              ("C-c C-m" . verilog-sk-module)
              ("C-c v l" . verilog-verilator-lint)
              ("C-c v c" . verilog-verilator-compile)
              ("C-c v r" . verilog-verilator-run)
              ("C-c v w" . verilog-verilator-view-waveform))
  :config
  ;; Indentation settings
  (setq verilog-indent-level 3
        verilog-indent-level-module 3
        verilog-indent-level-declaration 3
        verilog-indent-level-behavioral 3
        verilog-case-indent 2
        verilog-auto-newline nil
        verilog-auto-indent-on-newline t
        verilog-auto-endcomments t
        verilog-tab-always-indent t
        verilog-highlight-p1800-keywords t
        verilog-linter "verilator --lint-only -Wall")

  ;; Auto-save AUTOs
  (add-hook 'verilog-mode-hook
            (lambda ()
              (add-hook 'before-save-hook 'verilog-auto nil t)))

  ;; Verilator integration functions
  (defun verilog-verilator-lint ()
    "Lint current Verilog file with Verilator."
    (interactive)
    (compile (format "verilator --lint-only -Wall %s" (buffer-file-name))))

  (defun verilog-verilator-compile ()
    "Compile current Verilog module with Verilator."
    (interactive)
    (let ((module-name (read-string "Top module name: ")))
      (compile (format "verilator --cc --exe --build -j 0 -Wall %s sim_main.cpp"
                       (buffer-file-name)))))

  (defun verilog-verilator-run ()
    "Run Verilator simulation."
    (interactive)
    (let ((default-directory (locate-dominating-file default-directory "obj_dir")))
      (if default-directory
          (compile "obj_dir/Vtop")
        (message "No obj_dir found. Compile first with C-c v c"))))

  (defun verilog-verilator-view-waveform ()
    "View VCD waveform with GTKWave."
    (interactive)
    (let ((vcd-file (read-file-name "VCD file: " nil nil t "*.vcd")))
      (start-process "gtkwave" nil "gtkwave" vcd-file))))

;; Flycheck integration for Verilator
(with-eval-after-load 'flycheck
  (flycheck-define-checker verilog-verilator
    "A Verilog syntax checker using Verilator."
    :command ("verilator" "--lint-only" "-Wall" source)
    :error-patterns
    ((warning line-start "%Warning" (? "-" (id (+ (any alpha)))) ": "
              (file-name) ":" line ":" column ": " (message) line-end)
     (error line-start "%Error" (? "-" (id (+ (any alpha)))) ": "
            (file-name) ":" line ":" column ": " (message) line-end))
    :modes verilog-mode)
  (add-to-list 'flycheck-checkers 'verilog-verilator))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; C/C++ Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq c-default-style "linux"
      c-basic-offset 4)

(add-hook 'c++-mode-hook
          (lambda ()
            (setq flycheck-gcc-language-standard "c++17"
                  flycheck-clang-language-standard "c++17"
                  c-basic-offset 4)))

(add-hook 'c-mode-hook
          (lambda ()
            (setq flycheck-gcc-language-standard "c11"
                  flycheck-clang-language-standard "c11")))

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
  :hook ((emacs-lisp-mode . eldoc-mode)
         (emacs-lisp-mode . company-mode))
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
;;; File Explorer & Dired
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package neotree
  :bind ("<f8>" . neotree-toggle)
  :config
  (setq neo-show-hidden-files t
        neo-smart-open t
        neo-theme (if (display-graphic-p) 'icons 'arrow)
        neo-autorefresh t
        neo-window-width 30
        neo-window-fixed-size nil))

(require 'dired-x)
(setq dired-listing-switches "-alh"
      dired-dwim-target t)
(add-hook 'dired-mode-hook 'dired-hide-details-mode)

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Terminal Emulator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package vterm
  :bind ("C-c t" . vterm)
  :config
  (setq vterm-max-scrollback 10000
        vterm-shell "/bin/bash"
        vterm-term-environment-variable "xterm-256color"))

(use-package multi-term
  :bind ("C-c T" . multi-term)
  :config
  (setq multi-term-program "/bin/bash"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Debugger - Enhanced
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; GDB configuration
(setq gdb-many-windows t
      gdb-show-main t
      gdb-use-separate-io-buffer t)

(use-package realgud
  :commands (realgud:gdb realgud:pdb))

;; DAP Mode for modern debugging
(use-package dap-mode
  :after lsp-mode
  :commands dap-debug
  :config
  (dap-auto-configure-mode)
  (require 'dap-gdb-lldb)
  (require 'dap-python)

  ;; GDB/LLDB configuration
  (setq dap-gdb-lldb-path "lldb-vscode")

  ;; Python debugging
  (setq dap-python-debugger 'debugpy))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Project Management - Projectile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package projectile
  :demand t
  :bind-keymap ("C-c p" . projectile-command-map)
  :config
  (projectile-mode +1)
  (setq projectile-completion-system 'default
        projectile-enable-caching t
        projectile-indexing-method 'alien
        projectile-cache-file (expand-file-name "projectile.cache" user-emacs-directory)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Which-Key
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package which-key
  :demand t
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.5))

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
;;; Org Mode Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package org
  :ensure t
  :pin gnu
  :bind (("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c c" . org-capture)
         :map org-mode-map
         ("C-c <up>" . org-priority-up)
         ("C-c <down>" . org-priority-down))
  :hook ((org-mode . org-indent-mode)
         (org-mode . visual-line-mode))
  :config
  ;; Agenda files
  (setq org-agenda-files '("~/org"))

  ;; Logging
  (setq org-log-done 'time
        org-log-into-drawer t)

  ;; Display
  (setq org-return-follows-link t
        org-hide-emphasis-markers t
        org-startup-indented t
        org-startup-folded 'content)

  ;; TODO keywords
  (setq org-todo-keywords
        '((sequence "TODO(t)" "IN-PROGRESS(i)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))

  ;; Capture templates
  (setq org-capture-templates
        '(("t" "Todo" entry (file+headline "~/org/tasks.org" "Tasks")
           "* TODO %?\n  %i\n  %a")
          ("j" "Journal" entry (file+datetree "~/org/journal.org")
           "* %?\nEntered on %U\n  %i\n  %a")
          ("n" "Note" entry (file+headline "~/org/notes.org" "Notes")
           "* %?\n  %i\n  %a")))

  ;; Agenda view customization
  (setq org-agenda-custom-commands
        '(("d" "Dashboard"
           ((agenda "" ((org-agenda-span 7)))
            (todo "IN-PROGRESS" ((org-agenda-overriding-header "In Progress")))
            (todo "TODO" ((org-agenda-overriding-header "To Do")))))
          ("n" "Next Actions"
           ((todo "IN-PROGRESS")
            (todo "TODO"
                  ((org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'scheduled 'deadline))))))))

  ;; Refile targets
  (setq org-refile-targets '((org-agenda-files :maxlevel . 3))
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil))

;; Beautiful org headings
(let* ((variable-tuple '(:font "JetBrainsMono Nerd Font"))
       (base-font-color (face-foreground 'default nil 'default))
       (headline `(:inherit default :weight bold :foreground ,base-font-color)))
  (custom-theme-set-faces
   'user
   `(org-level-8 ((t (,@headline ,@variable-tuple))))
   `(org-level-7 ((t (,@headline ,@variable-tuple))))
   `(org-level-6 ((t (,@headline ,@variable-tuple))))
   `(org-level-5 ((t (,@headline ,@variable-tuple))))
   `(org-level-4 ((t (,@headline ,@variable-tuple :height 1.1))))
   `(org-level-3 ((t (,@headline ,@variable-tuple :height 1.2))))
   `(org-level-2 ((t (,@headline ,@variable-tuple :height 1.3))))
   `(org-level-1 ((t (,@headline ,@variable-tuple :height 1.5))))
   `(org-document-title ((t (,@headline ,@variable-tuple :height 1.6 :underline nil))))))

;; Org Babel for code execution
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)
   (C . t)))

(setq org-confirm-babel-evaluate nil)

;; Org bullets for better visuals
(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :config
  (setq org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

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
      native-comp-eln-load-path (list (expand-file-name "eln-cache" user-emacs-directory))
      message-log-max 1000)

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
    (princ "=== Emacs Configuration Analysis ===\n\n")

    ;; Check for required executables
    (princ "--- External Tool Dependencies ---\n")
    (dolist (tool '(("verilator" "Verilog linting/simulation")
                    ("verible-verilog-ls" "Verilog LSP server")
                    ("clangd" "C/C++ LSP server")
                    ("pyright" "Python LSP server")
                    ("gtkwave" "Waveform viewer")))
      (if (executable-find (car tool))
          (princ (format "  ✓ %s: Found\n" (car tool)))
        (princ (format "  ✗ %s: NOT FOUND - %s\n" (car tool) (cadr tool)))))

    (princ "\n--- Performance Statistics ---\n")
    (when (fboundp 'use-package-report)
      (princ "  Run M-x use-package-report for loading times\n"))

    (princ (format "  GC threshold: %s\n" gc-cons-threshold))
    (princ (format "  Read process max: %s bytes\n" read-process-output-max))

    ;; Check font availability
    (princ "\n--- Font Configuration ---\n")
    (if (member "JetBrainsMono Nerd Font" (font-family-list))
        (princ "  ✓ JetBrainsMono Nerd Font: Found\n")
      (princ "  ✗ JetBrainsMono Nerd Font: NOT FOUND\n"))

    (princ "\n--- Removed Configurations ---\n")
    (princ "  • mu4e (email client) - Removed\n")
    (princ "  • w3m (HTML rendering for email) - Removed\n")
    (princ "  • org-mime (org-mode email integration) - Removed\n")
    (princ "  • platformio-mode (embedded development) - Removed\n")
    (princ "  • company-arduino (Arduino completions) - Removed\n")

    (princ "\n=== Analysis Complete ===\n")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; End of Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files nil)
 '(package-selected-packages
   '(org-bullets elisp-refs macrostep dap-mode diff-hl transient magit which-key projectile realgud multi-term vterm all-the-icons-dired neotree lsp-ui lsp-mode flycheck company doom-modeline catppuccin-theme all-the-icons dashboard)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-document-title ((t (:inherit default :weight bold :foreground "#cdd6f4" :font "JetBrainsMono Nerd Font" :height 1.6 :underline nil))))
 '(org-level-1 ((t (:inherit default :weight bold :foreground "#cdd6f4" :font "JetBrainsMono Nerd Font" :height 1.5))))
 '(org-level-2 ((t (:inherit default :weight bold :foreground "#cdd6f4" :font "JetBrainsMono Nerd Font" :height 1.3))))
 '(org-level-3 ((t (:inherit default :weight bold :foreground "#cdd6f4" :font "JetBrainsMono Nerd Font" :height 1.2))))
 '(org-level-4 ((t (:inherit default :weight bold :foreground "#cdd6f4" :font "JetBrainsMono Nerd Font" :height 1.1))))
 '(org-level-5 ((t (:inherit default :weight bold :foreground "#cdd6f4" :font "JetBrainsMono Nerd Font"))))
 '(org-level-6 ((t (:inherit default :weight bold :foreground "#cdd6f4" :font "JetBrainsMono Nerd Font"))))
 '(org-level-7 ((t (:inherit default :weight bold :foreground "#cdd6f4" :font "JetBrainsMono Nerd Font"))))
 '(org-level-8 ((t (:inherit default :weight bold :foreground "#cdd6f4" :font "JetBrainsMono Nerd Font")))))
