;; early-init.el

;; Prevent double package-initialize
(setq package-enable-at-startup nil)

;; Maximize GC during startup (move here from init.el)
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Don't resize frame during startup
(setq frame-inhibit-implied-resize t)
