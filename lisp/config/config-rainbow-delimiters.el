;; -*- lexical-binding : t ; byte-compile-dynamic : t -*-

(code-add-hook
 (prog-mode-hook
  lisp-interaction-mode-hook)
 rainbow-delimiters-mode)

(provide 'config-rainbow-delimiters)
;;; config-rainbow-delimiters.el ends here