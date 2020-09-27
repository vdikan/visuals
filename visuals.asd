(defsystem "visuals"
  :version "0.1.0"
  :author "Vladimir Dikan"
  :license "GPL"
  :depends-on ("cl-who"
               "parenscript"
               "websocket-driver"
               "websocket-driver-client"
               "clack")
  :components ((:module "src"
                :components
                ((:file "ws-repl")
                 (:file "js-utils")
                 ;; (:file "vis-webgl")
                 (:file "vis-vega"))))
  :description "A collection of packages to produce various visuals.")
  ;; :in-order-to ((test-op (test-op "visuals/tests"))))

;; (defsystem "visuals/tests"
;;   :author "Vladimir DIkan"
;;   :license ""
;;   :depends-on ("visuals"
;;                "rove")
;;   :components ((:module "tests"
;;                 :components
;;                 ((:file "main"))))
;;   :description "Test system for visuals"
;;   :perform (test-op (op c) (symbol-call :rove :run c)))
