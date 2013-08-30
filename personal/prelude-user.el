(load-theme 'monokai t)
(setq prelude-whitespace nil)
(setq visible-bell t)
(define-key global-map (kbd "RET") 'newline-and-indent)

; Add more packages
(require 'package)
(add-to-list 'package-archives 
    '("marmalade" .
      "http://marmalade-repo.org/packages/"))
(package-initialize)

; start the emacsserver that listens to emacsclient
(server-start)
(remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function)

(require 'ruby-end)
(electric-pair-mode 0)

(require 'ruby-block)
(ruby-block-mode t)
(setq ruby-block-highlight-toggle t)

(require 'flymake-ruby)
(add-hook 'ruby-mode-hook 'flymake-ruby-load)

; Kill ring search!
(autoload 'kill-ring-search "kill-ring-search"
  "Search the kill ring in the minibuffer."
  (interactive))
(global-set-key "\M-\C-y" 'kill-ring-search)

; Evil mode overrode C-n and C-p, so these are replacements
(global-set-key (kbd "M-n") 'next-line)
(global-set-key (kbd "M-p") 'previous-line)
(global-set-key (kbd "M-e") 'end-of-line)
; Hey! This works!
(define-key key-translation-map (kbd "C-n") (kbd "M-n"))
(define-key key-translation-map (kbd "C-p") (kbd "M-p"))
(define-key key-translation-map (kbd "C-e") (kbd "M-e"))
(define-key key-translation-map (kbd "C-o") (kbd "C-x C-f"))
(define-key key-translation-map (kbd "C-i") (kbd "C-x b"))
(define-key key-translation-map (kbd "C-u") (kbd "C-c f"))

;;; esc quits
; (define-key evil-normal-state-map [escape] 'keyboard-quit)
; (define-key evil-visual-state-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)

; Use vim keybindings
(key-chord-mode -1)
(require 'evil)
(evil-mode 1)

(define-key evil-normal-state-map (kbd "SPC") #'evil-ace-jump-word-mode)
(define-key evil-insert-state-map "d" #'cofi/maybe-jump)

(evil-define-command cofi/end-line ()
  :repeat change
  (prelude-move-beginning-of-line 1))

(evil-define-command cofi/maybe-jump ()
                     :repeat change
                     (interactive)
                     (let ((modified (buffer-modified-p)))
                       (insert "d")
                       (let ((evt (read-event (format "Insert %c to activate ace jump mode" ?f)
                                              nil 0.5)))
                         (cond
                          ((null evt) (message ""))
                          ((and (integerp evt) (char-equal evt ?f))
                           (delete-char -1)
                           (set-buffer-modified-p modified)
                           (evil-ace-jump-word-mode)
                           (push #'evil-ace-jump-word-mode unread-command-events))
                          (t (setq unread-command-events (append unread-command-events
                                                                 (list evt))))))))

(define-key evil-insert-state-map "k" #'cofi/maybe-exit)
(evil-define-command cofi/maybe-exit ()
                     :repeat change
                     (interactive)
                     (let ((modified (buffer-modified-p)))
                       (insert "k")
                       (let ((evt (read-event (format "Insert %c to exit insert state" ?j)
                                              nil 0.5)))
                         (cond
                          ((null evt) (message ""))
                          ((and (integerp evt) (char-equal evt ?j))
                           (delete-char -1)
                           (set-buffer-modified-p modified)
                           (push 'escape unread-command-events))
                          (t (setq unread-command-events (append unread-command-events
                                                                 (list evt))))))))
