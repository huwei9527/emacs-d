;;; -*- lexical-binding : t ; byte-compile-dynamic : t -*-

;;; Commentary:

;;; Code:

(eval-when-compile (/require-meta file))
(/require-custom file)

(defsubst /file-name (path)
  "Return the filename of PATH.
If PATH is a directory, the system directory character is ommited."
  (file-name-nondirectory (directory-file-name path)))

(defsubst /file-name-match (path regexp)
  "Return non-nil if the non-directory filename of PATH match REGEXP."
  (string-match-p regexp (/file-name path)))

(/def-file-name-predictor-all)

(defun /subdirectory-1 (path)
  "Return list of the sub-directories of path at depth 1."
  (let* ((dirs nil))
    (dolist (fn (directory-files path 'full))
      (when (file-directory-p fn)
        (unless (/dotdirectory-p fn)
          (push fn dirs))))
    dirs))

(defun /subdirectory (path &optional depth)
  "Return the list of the sub-directories in path at depth at most DEPTH.
PATH itself is excluded. If DEPTH is not a positive interger, the
  whole directory tree will be searched."
  (let* ((dirs nil)
         (dirs-par (list path))
         (dirs-ch nil))
    (unless (and (integerp depth) (> depth 0))
      (setq depth -1))
    (while dirs-par
      (setq dirs-ch nil)
      (dolist (fn-par dirs-par)
        (dolist (fn-ch (/subdirectory-1 fn-par))
          (push fn-ch dirs)
          (push fn-ch dirs-ch)))
      (setq dirs-par (if (eq (setq depth (1- depth)) 0) nil dirs-ch)))
    dirs))

(defun /add-subdirectory-to-list (path list &optional depth)
  "Add the sub-directories of PATH of depth at most DEPTH to LIST.
This function use `add-to-list' to add element to LIST.
This function doesn't add PATH itself.
If DEPTH is not a positive integer, the whole directory tree is searched."
  (let* ((path (file-name-as-directory path)))
    (dolist (fn (/subdirectory path depth))
      (add-to-list list fn))))

(defun /add-directory-to-list (path list &optional depth)
  "Add the directories of PATH of depth at most DEPTH to LIST.
This function use `add-to-list' to add element to LIST.
The PATH itself is also added.
If DEPTH is not a positive integer, the whole directory tree is searched."
  (let* ((path (file-name-as-directory path)))
    (add-to-list list path)
    (/add-subdirectory-to-list path list depth)))

(defun /save-buffer (&optional silent)
  "Save the current buffer.
Return t if the save actually performed, otherwise return nil.
If SILENT is nil, avoid message when saving."
  (if (and buffer-file-name			       ;; Vaid buffer
	   (buffer-modified-p)			       ;; Modified
	   (not (/uneditable-file-p buffer-file-name)) ;; Emacs editable
	   (file-writable-p buffer-file-name)	       ;; Write permission
	   )
      (progn
	(if silent (with-temp-message "" (save-buffer)) (save-buffer))
	t)
    nil))

(defun /save-buffer-all (&optional silent)
  "Save all the buffers.
Return the number of buffers actually saved."
  (let* ((cnt 0))
    (save-excursion
      (dolist (buf (buffer-list))
	(set-buffer buf)
	(and (/save-buffer silent) (setq cnt (1+ cnt)))))
    cnt))

(/provide)
;;; lib/file.el ends here
