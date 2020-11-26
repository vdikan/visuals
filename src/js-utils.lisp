;; Utility definitions for Paren-scripting,
;; developed upon: https://github.com/byulparan/websocket-demo/blob/master/js.lisp
(defpackage :js-utils
  (:use :cl :ps)
  (:export #:define-ps-macro
     #:define-jsfun
     ;; dom
     #:c>
     #:log>
     #:by-id
     #:by-tagname
     #:create-element
     #:create-text-node))

(in-package :js-utils)


(defmacro define-ps-macro (name arg &body body)
  `(progn
     (defmacro ,name ,arg
       ,@body)
     (import-macros-from-lisp ',name)
     (export ',name)))


(defmacro define-jsfun (name args &body body)
  (let ((table-name (intern "*JS-TABLE*" *package*)))
    `(progn
       (defvar ,table-name nil)
       (setf (getf ,table-name ',name))
       (quote (setf ,name (lambda ,args ,@body)))
       ',name)))


(defpsmacro define-jsfun (name args &body body)
  `(progn (setf ,name (lambda ,args ,@body))
    "undefined"))

;; DOM shortcuts
;; The `chain` shortcut is `c>` since I don't want to mistake it
;; for rather familiar threading macro inspired by clojure.
(defpsmacro c> (&body chain)
  `(chain ,@chain))

(defpsmacro log> (obj)
  `(c> console (log ,obj)))

(defpsmacro by-id (id)
  `(c> document (get-element-by-id ,id)))

(defpsmacro by-tagname (tagname)
  `(c> document (get-elements-by-tag-name ,tagname)))

(defpsmacro create-element (tagname)
  `(c> document (create-element ,tagname)))

(defpsmacro create-text-node (text)
  `(c> document (create-text-node ,text)))
