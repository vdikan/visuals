(ql:quickload :visuals)

(defpackage :vis-vega-example
  (:use :cl :vis-vega :ps))

(in-package :vis-vega-example)

;; Datasets
(defparameter data-uno '((:x "A" :y 35)
                         (:x "B" :y 56)
                         (:x "C" :y 22)
                         (:x "D" :y 44)))

(defparameter data-dos '((:x "F" :y 55)
                         (:x "G" :y 77)
                         (:x "H" :y 11)
                         (:x "K" :y 13)))

;; Plot description struct.
;; Yes, with Parenscript forms. Same to me as meddling with JSONs.
(defparameter plot-view
  (make-vega-view
   :extras '(config (create axis (create grid t))
             width 800 height 600)))


;; Span two plots. Same style, different datasets.
(defvar *plot-handler-uno* (handle-plot plot-view data-uno 8000))
(defvar *plot-handler-dos* (handle-plot plot-view data-dos 8001))


;; Change the datasets. Plots changing accordingly upon F5.
(push '(:x "E" :y 28) data-uno)
(pop data-dos)

;; Edit the style view instance. Both plots are being edit correspondingly.
(setf (vega-view-title plot-view) "Hello from Vega-Lite!"
      (vega-view-mark plot-view)
      '(create :type "line" :point (create :filled false :fill "white"))
      (vega-view-extras plot-view)
      '(config
        (create axis (create grid false))
        width  600
        height 400))
