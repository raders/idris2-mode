# idris2-mode
Emacs mode for Idris2.

Add the following lines to your init.el file:

```
(add-to-list 'load-path "directory where idris2-mode.el resides")
(autoload 'idris2-mode "idris2-mode" "Idris2 Mode." t)
(add-to-list 'auto-mode-alist '("\\.idr\\'" . idris2-mode))
```
You will also need to turn on auto-revert-mode, since the Idris interactive editing commands
update the files on disk.
## Commands
* `C-c C-r` Reload File
* `C-c C-t` Show Type
* `C-c C-a` Create an initial clause for a type declaration
* `C-c C-c` Case Split
* `C-c C-m` Make Case
* `C-c C-l` Make Lemma
* `C-c C-s` Proof Search
* `C-c C-d` Show docs
