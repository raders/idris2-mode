# idris2-mode
Emacs mode for Idris2

Add the following lines to your init.el file:

```
(add-to-list 'load-path "~/dev/idris2-mode/")
(autoload 'idris2-mode "idris2-mode" "Idris2 Mode." t)
(add-to-list 'auto-mode-alist '("\\.idr\\'" . idris2-mode))
```
