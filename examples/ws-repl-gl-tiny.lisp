;; Live recreation of the tiny TWGL example: http://twgljs.org/examples/tiny.html
(ql:quickload '(:visuals))

(defpackage :ws-repl-gl
  (:use :cl :ws-repl :ps :js-utils))

(in-package :ws-repl-gl)


(start-ws-repl)                         ; <- launch repl and client app

;; go to localhost:8000

(defvar *twgl-cdn* "http://twgljs.org/dist/4.x/twgl-full.min.js")


(in-ws-repl                             ; drop default header
  (let ((h (by-id "info")))
    (c> h (remove))))


(in-ws-repl                             ; viewport setting
  (let ((m (create-element "meta")))
    (c> m (set-attribute "name" "viewport"))
    (c> m (set-attribute "content"
                         "width=device-width, initial-scale=1.0, user-scalable=yes"))
    ;; (log> m)))
    (c> document head (append-child m))))


(in-ws-repl                             ; document style
  (let ((s (create-element "style")))
    (c> s (append-child
           (create-text-node "body { margin: 0; font-family: monospace; }")))
    (c> s (append-child
           (create-text-node
            "canvas { display: block; width: 100vw; height: 100vh; }")))
    (c> s (append-child
           (create-text-node
            "#b { position: absolute; top: 10px; width: 100%; text-align: center; z-index: 2; }")))
    ;; (log> s)))
    (c> document head (append-child s))))


(in-ws-repl                             ; adding canvas
  (let ((canvas (create-element "canvas")))
    (c> canvas (set-attribute "id" "c"))
    ;; (log> canvas)))
    (c> document body (append-child canvas))))


(in-ws-repl                             ; adding banner text
  (let ((d (create-element "div")))
    (c> d (set-attribute "id" "b"))
    (c> d (append-child (create-text-node "Lisp-controlled WebGL Window")))
    ;; (log> d)))
    (c> document body (append-child d))))


(in-ws-repl                             ; load TWGL library script
  (let ((twgls (create-element "script")))
    (c> twgls (set-attribute "id" "twgls"))
    (c> twgls (set-attribute "src" (lisp *twgl-cdn*)))
    ;; (log> twgls)
    (c> document body (append-child twgls))))


(in-ws-repl                             ; vertex shader
  (let ((vs (create-element "script")))
    (c> vs (set-attribute "id" "vs"))
    (c> vs (set-attribute "type" "notjs"))
    (c> vs (append-child
            (create-text-node
             (lisp (uiop:read-file-string "glexp.vert")))))
    ;; (log> vs)))
    (c> document body (append-child vs))))


(in-ws-repl                             ; fragment shader
  (let ((fs (create-element "script")))
    (c> fs (set-attribute "id" "fs"))
    (c> fs (set-attribute "type" "notjs"))
    (c> fs (append-child
            (create-text-node
             (lisp (uiop:read-file-string "glexp.frag")))))
    ;; (log> vs)))
    (c> document body (append-child fs))))


(defparameter position-vec #(-1 -1 0 1 -1 0 -1 1 0 -1 1 0 1 -1 0 1 1 0))

(defparameter webgl-module
  (ps   (let (())
          (defparameter gl (chain document (query-selector "#c") (get-context "webgl")))
          (defparameter program-info (chain twgl (create-program-info gl (array "vs" "fs"))))
          ;; (defparameter arrays (create position (array -1 -1 0 1 -1 0 -1 1 0 -1 1 0 1 -1 0 1 1 0)))
          (defparameter arrays (create position (lisp position-vec)))
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


(in-ws-repl                             ; WebGL renderer module
  (let ((glmod (create-element "script")))
    (c> glmod (set-attribute "id" "glmod"))
    (c> glmod (set-attribute "type" "module"))
    (c> glmod (append-child
               (create-text-node (lisp webgl-module))))
    ;; (log> glmod)))
    (c> document body (append-child glmod))))


;; (in-ws-repl
;;   (c> (by-id "c") (remove))
;;   (c> (by-id "glmod") (remove)))


;; (in-ws-repl                             ; <- local scope var
;;   (let ((nv (create d (new (-date)))))
;;     (@ nv d)))


;; (in-ws-repl                             ; <- global var declaration
;;   (funcall (lambda () (setf (@ window dat) (new (-date))))))


(shutdown-ws-repl)                      ; <- finish consing into Js
