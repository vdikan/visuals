(ql:quickload '(:visuals :websocket-driver-client :jonathan))

(defpackage :vis-vega-websocket
  (:use :cl :vis-vega :ps))

(in-package :vis-vega-websocket)

;; Initial Dataset
(defparameter init-data '((:x "A" :y 35)
                          (:x "B" :y 56)
                          (:x "C" :y 22)
                          (:x "D" :y 44)))


;; Plot description struct. Same to me as meddling with JSONs...
;; ...unless one wants serialize JS object for data point.
;; This better be done with sane serializers (vis-vega has an ugly heper too).
(defparameter plot-view
  (make-vega-view
   :extras '(config (create axis (create grid t))
             width 800 height 600)))


;; Launhing a data server:
(clack:clackup (make-data-server) :port 13000)


;; Vega-plot apps are its clients (all who were instantiated under same port 13000).
;; We need an extra one to broadcast new data points:
(defvar *wsc* (wsd:make-client "ws://localhost:13000"))
(wsd:start-connection *wsc*)


;; Default "static" plot requires the only `vega-view` style `data` and app port:
(defvar *plot-handler* (handle-plot plot-view init-data 8000))


;; But when a ws-port is specified, the plotter will start listening to data server,
;; plotting it alongside the defaults. The resuting page code will change a bit,
;; adding callback to Vega's view updater.
(defvar *plot-handler-ws* (handle-plot plot-view init-data 8888 13000))


;; Watch new data appearing at http://localhost:8888
(loop
  :for letter :in '("E" "F" "G" "H" "K" "L" "M")
  :do (progn
        (wsd:send *wsc* (%data-point-to-js (list :x letter :y (random 80))))
        (sleep 1)))


;;NOTE: Vega does not store the broadcasted data anywhere!
;; It won't appear on the vega-editor either.
;; One needs to e.g. push it to initial dataset for persistence.

;; I'll demonstrate it with a better JSON serializer:
(loop
  :for letter :in '("N" "O" "P" "Q" "R" "Z" "Y" "X")
  :do (let ((point (list :|x| letter :|y| (random 80))))
        (wsd:send *wsc* (jonathan:to-json point))
        (push point init-data)
        (sleep 1)))


;; Close connections, stop servers:
(wsd:close-connection *wsc*)
(clack:stop *plot-handler*)
(clack:stop *plot-handler-ws*)
