;;; -*- lexical-binding : t ; byte-compile-dynamic : t -*-

;;; Commentary:

;;; Code:

(/require-lib buffer)

(defun /tex-temporary-buffer-p (&optional buf)
  "Return non-nil if BUF is a TeX temporary buffer."
  (or buf (setq buf (current-buffer)))
  (with-current-buffer buf
    (or (eq major-mode 'TeX-error-overview-mode)
	(string= (buffer-name) "*TeX Help*"))))

(defun /tex-close-other-buffer ()
  "Close other temporary buffer in TeX mode."
  (save-selected-window
    (let* ((lives (window-list-1))
	   (next (next-window))
	   win closed)
      (while lives
	(setq win (car lives))
	(and (/kill-temporary-buffer win #'/tex-temporary-buffer-p)
	     (eq curr other)
	     (setq closed t))
	(pop lives))
      closed)))

(/provide)
;;; lib/tex.el ends here
