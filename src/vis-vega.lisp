(defpackage :vis-vega
  (:use :cl :parenscript)
  (:export
   #:view-page
   #:handle-plot

   #:vega-view-p
   #:vega-view
   #:make-vega-view
   #:copy-vega-view
   #:vega-view-title
   #:vega-view-mark
   #:vega-view-encoding
   #:vega-view-extras))

(in-package :vis-vega)

(setf (cl-who:html-mode) :html5)


(defun array-of-creates (lst)
  (append '(array) (mapcar (lambda (c) (append `(create) c)) lst)))


(defun vis-vega-page (&key data title mark encoding extras)
  (cl-who:with-html-output-to-string
      (*standard-output* nil :prologue t :indent t)
    (:html
     (:head
      (:title "Vega-Lite Clack app")
      (:script :src "https://cdn.jsdelivr.net/npm/vega@5.15.0")
      (:script :src "https://cdn.jsdelivr.net/npm/vega-lite@4.15.0")
      (:script :src "https://cdn.jsdelivr.net/npm/vega-embed@6.11.1"))
     (:body
      (:div :id "vis")
      (:script
       :type "text/javascript"
       (cl-who:str
        (ps*
         `(defvar vis-vega-spec
            (create $schema "https://vega.github.io/schema/vega-lite/v4.json"
                    description "Vega-lite chart assembled with CL web libs."
                    title ,title
                    data (create values ,(array-of-creates data))
                    mark ,mark
                    encoding ,encoding
                    ,@extras))
         '(vega-embed "#vis" vis-vega-spec))))))))


(defstruct vega-view
  (title "Vega-lite View" :type sequence)
  (mark  "line" :type sequence)
  (encoding '(create
              :x (create :field "x" :type "ordinal")
              :y (create :field "y" :type "quantitative")) :type sequence)
  (extras nil :type sequence))


(defmethod view-page ((obj vega-view) data)
  (vis-vega-page :data  data
    :title (vega-view-title obj)
    :mark  (vega-view-mark obj)
    :encoding (vega-view-encoding obj)
    :extras (vega-view-extras obj)))


(defmacro handle-plot (plot-view data-list port-num)
  `(clack:clackup
    (lambda (env)
      (declare (ignore env))
      `(200 (:content-type "text/html")
            (,(vis-vega:view-page ,plot-view ,data-list)))) :port ,port-num))
