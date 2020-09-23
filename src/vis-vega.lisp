(defpackage :vis-vega
  (:use :cl :parenscript :websocket-driver)
  (:export
   #:view-page
   #:handle-plot
   #:%data-point-to-js
   #:make-data-server

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
  "Helper func to Paren-script the initial data."
  (append '(array) (mapcar (lambda (c) (append `(create) c)) lst)))


(defun vis-vega-page (&key data title mark encoding extras (ws-port 0))
  "Generates a webage markup and Js for plot application.
Injects bindings to websocket data server if WS-PORT is provided."
  (declare (type integer ws-port))
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
                    data (create :values ,(array-of-creates data)
                                 :name :data-table)
                    mark ,mark
                    encoding ,encoding
                    ,@extras))
         (if (= ws-port 0)
             `(vega-embed "#vis" vis-vega-spec)
             `(chain (vega-embed "#vis" vis-vega-spec)
                (then (lambda (result)
                        (defparameter view (@ result view))
                        (defparameter conn (new (-web-socket
                                                 ,(format nil "ws://localhost:~d/" ws-port))))
                        (setf (@ conn onopen)
                              (lambda (event)
                                (setf (@ conn onmessage)
                                      (lambda (event)
                                        ((@ console log) (@ event data))
                                        (chain ((@ view insert)
                                                "data-table"
                                                ((@ -J-S-O-N parse) (@ event data)))
                                          (run))))))))
                (catch- (@ console warn)))))))))))


(defstruct vega-view
  (title "Vega-lite View" :type sequence)
  (mark  "line" :type sequence)
  (encoding '(create
              :x (create :field "x" :type "ordinal")
              :y (create :field "y" :type "quantitative")) :type sequence)
  (extras nil :type sequence))


(defmethod view-page ((obj vega-view) data &optional (ws-port 0))
  "Dispatch DATA with specified VEGA-VIEW style.
Optionally give the websocket port WS-PORT for additional data."
  (vis-vega-page :data  data
    :title (vega-view-title obj)
    :mark  (vega-view-mark obj)
    :encoding (vega-view-encoding obj)
    :extras (vega-view-extras obj)
    :ws-port ws-port))


(defmacro handle-plot (plot-view data-list port-num &optional (ws-port 0))
  "Launches the plotting application."
  `(clack:clackup
    (lambda (env)
      (declare (ignore env))
      `(200 (:content-type "text/html")
            (,(vis-vega:view-page ,plot-view ,data-list ,ws-port))))
    :port ,port-num))


(defun %data-point-to-js (lst)
  "Ugly way to JSONify one data point. Better use normal encoders for that purpose."
  (let ((cheap-json (ps-inline* (append '(create) lst))))
    (subseq cheap-json 11 (- (length cheap-json) 1)))) ; to get double quotes in result


(defun make-data-server ()
  "Simple one-to-many data echo ws-server.
Traps a table of clients in a closure object with itself."
  (let ((tab (make-hash-table)))
    (lambda (env)
      (let ((ws (make-server env)))
        (on :open ws
            (lambda ()
              (setf (gethash ws tab)
                    (format nil "data-consummer-~a" (random 100000)))))
        (on :message ws
            (lambda (message)
              (loop :for con :being :the :hash-key :of tab :do
                (websocket-driver:send con message))))
        (on :close ws
            (lambda (&key code reason)
              (declare (ignore code reason))
              (remhash ws tab)))
        (lambda (responder)
          (declare (ignore responder))
          (start-connection ws))))))
