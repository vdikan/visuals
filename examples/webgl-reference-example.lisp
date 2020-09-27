;; Reference TWGL tiny example: no WebSockets
(ql:quickload :visuals)
(load #P"./webgl-ref.lisp")

(defpackage :glexp
  (:use :cl :webgl-ref :ps))

(in-package :glexp)

;; Vertex Shader
(defparameter vs (uiop:read-file-string "glexp.vert"))

;; Fragment Shader
(defparameter fs (uiop:read-file-string "glexp.frag"))

;; Js code to control the scene - to be scripted with Parenscript
(defparameter js
  (ps* `(let (())
          (defparameter gl (chain document (query-selector "#c") (get-context "webgl")))
          (defparameter program-info (chain twgl (create-program-info gl (array "vs" "fs"))))
          (defparameter arrays (create position (array -1 -1 0 1 -1 0 -1 1 0 -1 1 0 1 -1 0 1 1 0)))
          (defparameter buffer-info (chain twgl (create-buffer-info-from-arrays gl arrays)))

          (defun render (time)
            (chain twgl (resize-canvas-to-display-size (@ gl canvas)))
            (chain gl (viewport 0 0 (@ gl canvas width) (@ gl canvas height)))

            (defparameter uniforms
              (create time (* time 0.001)
                      resolution (array (@ gl canvas width)
                                        (@ gl canvas height))))

            (chain gl (use-program (@ program-info program)))
            (chain twgl (set-buffers-and-attributes gl program-info buffer-info))
            (chain twgl (set-uniforms  program-info uniforms))
            (chain twgl (draw-buffer-info gl buffer-info))

            (request-animation-frame render))

          (request-animation-frame render))))


;; Span two plots. Same style, different datasets.
(defvar *scene-handler* (handle-webgl 8000 vs fs js :title "GL experiment"))


;; --- scratch ---
;; (setf *scene-handler* (handle-webgl 8000 vs fs js :title "GL experiment"))

(clack:stop *scene-handler*)
