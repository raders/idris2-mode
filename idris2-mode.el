;;; -*- lexical-binding: t; -*-
(require 'thingatpt)

;;(setq words-include-escapes t)


;; from idris-hackers/idris-mode (https://github.com/idris-hackers/idris-mode)
(defconst idris2-syntax-table
  (let ((st (make-syntax-table)))

    ;; Matching parens
    (modify-syntax-entry ?\( "()" st)
    (modify-syntax-entry ?\) ")(" st)
    (modify-syntax-entry ?\[ "(]" st)
    (modify-syntax-entry ?\] ")[" st)

    ;; Matching {}, but with nested comments
    (modify-syntax-entry ?\{ "(} 1bn" st)
    (modify-syntax-entry ?\} "){ 4bn" st)
    (modify-syntax-entry ?\n ">" st)

    ;; ' and _ can be part of names, so give them symbol constituent syntax
    (modify-syntax-entry ?' "/" st)
    (modify-syntax-entry ?_ "_" st)

    ;; Idris operator chars get punctuation syntax
    (mapc #'(lambda (ch) (modify-syntax-entry ch "." st))
	  "!#$%&*+./<=>@^|~:")
    ;; - is an operator char but may also be 1st or 2nd char of comment starter
    ;; -- and the 1st char of comment end -}
    (modify-syntax-entry ?\- ". 123" st)

    ;; Whitespace is whitespace
    (modify-syntax-entry ?\  " " st)
    (modify-syntax-entry ?\t " " st)

    ;; ;; Strings
    (modify-syntax-entry ?\" "\"" st)
    (modify-syntax-entry ?\\ "/" st)

    st))


(setq idris2-highlights
      '(("import" . font-lock-function-name-face)
        ("^record" . font-lock-keyword-face)
        ("^data" . font-lock-keyword-face)
        ("^[a-zA-Z][a-zA-z0-9_']* +:\\( +.*\n\\)+" . font-lock-function-name-face)))
      

(define-derived-mode idris2-mode prog-mode "Idris2"
  :syntax-table idris2-syntax-table
  (setq font-lock-multiline t)
  (setq font-lock-defaults '(idris2-highlights)))



(defun idris2-setup ()
  ;;(setq whitespace-line-column 70)
  (make-local-variable 'tab-stop-list)
  (setq tab-stop-list (number-sequence 2 80 2))
  (setq indent-line-function 'indent-relative)
  (make-local-variable 'auto-revert-verbose)
  (setq auto-revert-verbose nil)
  (make-local-variable 'auto-revert-interval)
  (setq auto-revert-interval 0.2)

  (define-key idris2-mode-map (kbd "C-c C-r") 'idris2-load-file)
  (define-key idris2-mode-map (kbd "C-c C-t") 'idris2-type-at-point)
  (define-key idris2-mode-map (kbd "C-c C-d") 'idris2-doc)
  (define-key idris2-mode-map (kbd "C-c C-c") 'idris2-case-split)
  (define-key idris2-mode-map (kbd "C-c C-a") 'idris2-add-clause)
  (define-key idris2-mode-map (kbd "C-c C-l") 'idris2-make-lemma)
  (define-key idris2-mode-map (kbd "C-c C-s") 'idris2-proof-search)
  (define-key idris2-mode-map (kbd "C-c C-m") 'idris2-make-cases-from-hole))


(defun idris2-load-file ()
  (interactive)
  (save-buffer)
  (message (idris2-send (concat ":l " (file-name-nondirectory buffer-file-name)))))

(defun idris2-make-lemma ()
  (interactive)
  (let* ((n (current-word))
         (l (line-number-at-pos)))
    (message (idris2-send (format ":ml! %d %s" l n)))))

(defun idris2-add-clause ()
  (interactive)
  (let* ((n (current-word))
         (l (line-number-at-pos)))
    (message (idris2-send (format ":ac! %d %s" l n)))))


(defun idris2-case-split ()
  (interactive)
  (let* ((n (current-word))
         (l (line-number-at-pos))
         (col (current-column)))
    (message (idris2-send (format ":cs! %d %d %s" l col n)))))

(defun idris2-proof-search ()
  (interactive)
  (let* ((n (current-word))
         (l (line-number-at-pos)))
    (message (idris2-send (format ":ps! %d %s" l n)))))

(defun idris2-make-cases-from-hole ()
  (interactive)
  (let* ((n (current-word))
         (l (line-number-at-pos)))
    (message (idris2-send (format ":mc! %d %s" l n)))))

(defun idris2-type-at-point ()
  (interactive)
  (let* ((n (current-word))
         (l (line-number-at-pos))
         (col (current-column))
         (ret (idris2-send (format ":t %s" n))))
    (if (equal (string-match "Undefined name" ret) nil)
        (message ret)
        (message (idris2-send (format ":typeat %d %d %s" l (1+ col) n))))))

(defun idris2-doc ()
  (interactive)
  (let* ((thing (current-word)))
    (message (idris2-send (format ":doc %s" thing )))))

(defun idris2-send1 (sexp)
  (let* ((cmd (concat "idris2 "
                      (file-name-nondirectory buffer-file-name)
                      " --client '" sexp "'"))
         (ret (shell-command-to-string cmd)))
    ;;(message "send: %s" cmd)
    (message "%s" ret)))

(defun idris2-send (sexp)
  (call-process "touch" nil standard-output nil (file-name-nondirectory buffer-file-name))
  (let* ((cmd (concat (file-name-nondirectory buffer-file-name)
                      " --client '" sexp "'"))
         (ret (with-output-to-string
                (call-process "idris2" nil standard-output nil
                              (file-name-nondirectory buffer-file-name)
                              "--client"
                              sexp))))
    ret))

(add-hook 'idris2-mode-hook 'idris2-setup)

