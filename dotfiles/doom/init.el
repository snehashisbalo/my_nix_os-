;;; init.el -*- lexical-binding: t; -*-

(doom! :completion
       (vertico +icons)

       :ui
       doom
       modeline
       ophints
       (popup +defaults)
       vc-gutter
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       snippets
       word-wrap

       :emacs
       dired
       electric
       undo
       vc

       :checkers
       syntax

       :tools
       (eval +overlay)
       lookup
       magit

       :lang
       emacs-lisp
       markdown
       nix
       org
       sh

       :config
       (default +bindings +smartparens))
