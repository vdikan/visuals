(ql:quickload '(:visuals))

(defpackage :ws-repl-example
  (:use :cl :ws-repl :ps))

(in-package :ws-repl-example)


(start-ws-repl)                         ; <- launch repl and client app

;; go to localhost:8000

;; Send Parenscript to the apps console:
(in-ws-repl
  (let* ((x (chain document (create-element "P")))
         (txt (chain document (create-text-node "Lisp is Great!"))))
    (chain x (append-child txt))
    (chain document body (append-child x))))


(in-ws-repl                             ; <- local scope var
  (let ((nv (create d (new (-date)))))
    (@ nv d)))


(in-ws-repl                             ; <- global var declaration
  (funcall (lambda () (setf (@ window dat) (new (-date))))))


(shutdown-ws-repl)                      ; <- finish consing into Js
