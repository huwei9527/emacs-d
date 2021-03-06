;;; -*- lexical-binding : t ; byte-compile-dynamic : t -*-

;;; Commentary:

;;; Code:

(eval-when-compile (/require-meta core))

(defvar /--fgname "foreground" "Foreground face subname")
(defvar /--bgname "background" "Background face subname")

(defun /--intern-face (&optional fg bg)
  (declare (indent defun))
  (:documentation (format "Intern face name string.
If fg and bg are both non-nil, use `FG-BG'.
If fg is nil and bg is non-nil, use `BG-%s'.
If fg is non-nil and bg is nil, use `FG-%s'.
If fg and bg are both nil, user `nil'." /--fgname /--bgname))
  (if fg (if bg (/--intern "%s-%s" (/--name fg) (/--name bg))
	   (/--intern "%s-%s" (/--name fg) /--fgname))
    (and bg (/--intern "%s-%s" (/--name bg) /--bgname))))

(defvar /--color-alist
  ;;            256          t
  '((white    "color-255" "#ffffff")
    (black    "color-16"  "#000000")
    (red      "color-196" "#ff0000")
    (green    "color-46"  "#00ff00")
    (blue     "color-21"  "#0000ff")
    (yellow   "color-226" "#ffff00")
    (magenta  "color-201" "#ff00ff")
    (cyan     "color-51"  "#00ffff")
    )
  "Face color alist.")

(defmacro /defface--single (attrs &optional fg)
  (declare (indent defun))
  (:documentation
   (format "Define face containing one single color.
ATTRS is a list of form (name tty hex):
 name (symbol) - face name `name-F/B'
 tty  (string) - tty display color
 hex  (string) - fall through color
If FG is non-nil, the single color is set to foreground and F/B is
  %s, otherwise the single color is set to background and F/B is %s."
	   /--fgname /--bgname))
  (let* ((attrs (/--list attrs))
	 (name (car attrs)) (attrs (cdr attrs))
	 (tty (car attrs)) (attrs (cdr attrs))
	 (hex (car attrs)) (attrs (cdr attrs))
         prop face)
    (if fg (setq prop :foreground face (/--intern-face name nil))
      (setq prop :background face (/--intern-face nil name)))
    (and (boundp '/--face-list) (push face /--face-list))
    `(defface ,face
       '((default ,prop ,(symbol-name name))
	 (((class color) (type tty) (min-colors 256)) ,prop ,tty)
         (t ,prop ,hex))
       ,(format "Single face %s.\ntty : %s; t : %s" face tty hex))))

(defmacro /defface--double (fattrs battrs)
  (let* ((fattrs (/--list fattrs)) (battrs (/--list battrs))
	 (fname (car fattrs)) (bname (car battrs))
         (face (/--intern-face fname bname)))
    (and (boundp '/--face-list) (push face /--face-list))
    `(defface ,face
       '((t :inherit (,(/--intern-face fname nil) ,(/--intern-face nil bname))))
       ,(format "Double face %s.\ntty : (%s %s); t : (%s %s)" face
		(nth 1 fattrs) (nth 1 battrs) (nth 2 fattrs) (nth 2 battrs)))))

(defmacro /defface-simple ()
  "Define simple faces."
  (let* (white black colors)
    (/--sexp-progn
      ;; single color face
      (dolist (attrs /--color-alist)
	(/--sexp-append
	  `(/defface--single ,attrs 'fg) `(/defface--single ,attrs)))
      (setq colors /--color-alist
	    white (car colors) colors (cdr colors)
	    black (car colors) colors (cdr colors))
      ;; black and white face
      (/--sexp-append
	`(/defface--double ,white ,black) `(/defface--double ,black ,white))
      ;; black color face
      (dolist (battrs `(,white ,black))
	(dolist (cattrs colors)
	  (/--sexp-append
	    `(/defface--double ,battrs ,cattrs)
	    `(/defface--double ,cattrs ,battrs)))))))


(/provide)
;;; meta/ui.el ends here
