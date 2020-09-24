(ql:quickload '(:cl-who :parenscript :clack))

(defpackage :vis-webgl
  (:use :cl :parenscript :clack)
  (:export
   #:vis-webgl-page
   #:handle-webgl))

(in-package :vis-webgl)

(setf (cl-who:html-mode) :html5)
(setq cl-who:*attribute-quote-char* #\")

(defvar *twgl-cdn* "http://twgljs.org/dist/4.x/twgl-full.module.js")

(defvar *canvas-style*
  "
      body {
          margin: 0;
          font-family: monospace;
      }
      canvas {
          display: block;
          width: 100vw;
          height: 100vh;
      }
      #b {
        position: absolute;
        top: 10px;
        width: 100%;
        text-align: center;
        z-index: 2;
      }")


(defun prepend-cdn (str)
  (format nil "import * as twgl from '~a'~%var __PS_MV_REG;~%~a" *twgl-cdn* str))


(defun vis-webgl-page (vs fs js title)
  (cl-who:with-html-output-to-string
      (*standard-output* nil :prologue t :indent t)
    (:html
     (:head
      (:title (or title "Lisp WebGL Window"))
      (:meta :charset "utf8")
      (:meta :name "viewport"
             :content "width=device-width, initial-scale=1.0, user-scalable=yes")
      (:style (cl-who:str *canvas-style*))))
    (:body
     (:canvas :id "c")
     (:div :id "b" (or title "Lisp WebGL Window")))
    (:script :id "vs" :type "notjs" (cl-who:str vs))
    (:script :id "fs" :type "notjs" (cl-who:str fs))
    (:script :id "gl_mod" :type "module" (cl-who:str (prepend-cdn js)))))


(defmacro handle-webgl (port-num vs fs js &key title)
  "Launches the WebGL canvas ap."
  `(clack:clackup
    (lambda (env)
      (declare (ignore env))
      `(200 (:content-type "text/html")
            (,(vis-webgl:vis-webgl-page ,vs ,fs ,js ,title))))
    :port ,port-num))
