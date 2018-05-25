;;; -*- lexical-binding : t ; byte-compile-dynamic : t -*-

;;; Commentary:

;;; Code:

(eval-when-compile (/require-meta core hook ui))

(defvar /--evil-state-list
  '(insert normal visual emacs motion replace operator)
  "Evil states list.")


(defun /--intern-evil-hook (state &optional exit)
  "Intern a evil state entry or exit hook for STATE.
If exit is non-nil, return a exit state hook.
Otherwise return a entry state hook."
  (if exit
      (/--intern-format "evil-%s-state-%s-hook" (/--name state) "exit")
    (/--intern-format "evil-%s-state-%s-hook" (/--name state) "entry")))

(defvar /--evil-entry-hook-list
  (mapcar (lambda (state) (/--intern-evil-hook state)) /--evil-state-list)
  "Evil state entry hook list.")

(defvar /--evil-exit-hook-list
  (mapcar (lambda (state) (/--intern-evil-hook state 'exit)) /--evil-state-list)
  "Evil state entry exit list.")


(defmacro /add-hook--evil-state (fun exit &optional st)
  "Add function FUN to evil state hook.
If ST is nil, add to all the evil state hook.
If exit is nil, add to entry state hook, otherwise add to exit state hook."
  (declare (indent defun))
  (let* ((list (if st `(,(/--intern-evil-hook st exit))
		 (if exit /--evil-exit-hook-list
		   /--evil-entry-hook-list))))
    `(/add-hook ,list ,fun)))

(defmacro /add-hook-evil-entry-state (fun &optional st)
  "Add function FUN to evil state ST entry hook.
If ST is nil, add to all the evil state entry hook."
  (declare (indent defun))
  `(/add-hook--evil-state ,fun nil ,st))

(defmacro /add-hook-evil-exit-state (fun &optional st)
  "Add function FUN to evil state ST exit hook.
If ST is nil, add to all the evil state exit hook."
  (declare (indent defun))
  `(/add-hook--evil-state ,fun 'exit ,st))


;;; {{ Evil mode line tag
(defvar /--evil-mode-line-tag-alist
  '((normal .   (:tag "N" :color black))
    (insert .   (:tag "I" :color red))
    (motion .   (:tag "M" :color blue))
    (visual .   (:tag "V" :color green))
    (emacs .    (:tag "E" :color cyan))
    (operator . (:tag "O" :color yellow))
    (replace .  (:tag "R" :color magenta)))
  "Evil mode line tag face configuration alist.")

(defun /--intern-evil-mode-line-face (state)
  "Intern the evil mode line face symbol."
  (/--intern "mode-line-evil-%s-state-tag" (/--name state)))

(defmacro /defface-evil-mode-line-tag ()
  "Define faces for evil to used in the mode line showing the current state."
  (declare (indent defun))
  (/--sexp-progn
    (dolist (attrs /--evil-mode-line-tag-alist)
      (let* ((state (car attrs))
	     (color (plist-get (cdr attrs) :color)))
	(/--sexp-append-1
	  `(defface ,(/--intern-evil-mode-line-face state)
	     '((t (:inherit (,(if (eq state 'normal)
				  (/--intern-face color)
				(/--intern-face 'black color))
			     bold))))
	     ,(format "evil-%s-state face used in tag in mode line."
		      (/--name state))))))))

(defmacro /setup-evil-state-tags ()
  "Set the face of evil mode line tag."
  (declare (indent defun))
  (/--sexp-setq
    (dolist (attrs /--evil-mode-line-tag-alist)
      (let* ((state (car attrs)))
	(/--sexp-pair (/--intern-format "evil-%s-state-tag" state)
		      (propertize (plist-get (cdr attrs) :tag)
				  'face
				  (/--intern-evil-mode-line-face state)))))))
;;; }}

;;; {{ Text objext
;; https://stackoverflow.com/questions/18102004/emacs-evil-mode-how-to-create-a-new-text-object-to-select-words-with-any-non-sp
(defmacro /def-evil-text-object (key start end)
  "Define new text object and bind it to text object map."
  (declare (indent defun))
  (let* ((inner (make-symbol "inner")) (outer (make-symbol "outer")))
    (/--sexp-progn-exec
      `(evil-define-text-object ,inner (cnt &optional beg end type)
	 (evil-select-paren ,start ,end beg end type cnt nil))
      `(evil-define-text-object ,outer (cnt &optional beg end type)
	 (evil-select-paren ,start ,end beg end type cnt t))
      `(define-key evil-inner-text-objects-map ,key ',inner)
      `(define-key evil-outer-text-objects-map ,key ',outer))))
;;; }}



(/provide)
;;; meta/evil.el ends here
