;; -*- lexical-binding : t ; byte-compile-dynamic : t -*-

(eval-when-compile
  (require 'hook-code))

(code-add-hook
 (prog-mode-hook)
 rainbow-delimiters-mode)

(provide 'config-rainbow-delimiters)
;;; config-rainbow-delimiters.el ends here
