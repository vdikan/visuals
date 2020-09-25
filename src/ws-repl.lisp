(defpackage :ws-repl
  (:use :cl :ps)
  (:export #:websock-repl-page
           #:start-ws-repl
           #:shutdown-ws-repl
           #:in-ws-repl))

(in-package :ws-repl)


(setf (cl-who:html-mode) :html5)
(setq cl-who:*attribute-quote-char* #\")

(defvar *open-tab-command* "sensible-browser")

(defvar *client* nil)
(defvar *repl*   nil)

(defvar *ws-app* nil)
(defvar *client-app*  nil)


;; Websocket Server:
(defun attach-client (con)
  (if (equal *client* nil)
      (setf *client* con)
      (websocket-driver:send            ; Meddles also with selected client app. Needs improvement.
       con (format nil "\"WS-REPL is working with another *client* tab: ~a\"" *client*))))

(defun detach-client (con)
  (if (equal *client* con)
      (setf  *client* nil)))

(defun on-recieved-msg (con msg)
  (if (equal *client* con)
      (format t "~%ws-repl > ~a~%" msg)
      (websocket-driver:send *client* msg)))

(defun start-websock-server (env)
  (let ((ws (websocket-driver:make-server env)))

    (websocket-driver:on :open ws
                         (lambda () (attach-client ws)))

    (websocket-driver:on :message ws
                         (lambda (msg) (on-recieved-msg ws msg)))

    (websocket-driver:on :close ws
                         (lambda (&key code reason)
                           (declare (ignore code reason))
                           (detach-client ws)))

    (lambda (responder)
      (declare (ignore responder))
      (websocket-driver:start-connection ws))))


;; Client App page:
(defpsmacro install-websock (port)
  `(progn
     (defvar socket (new (-web-socket (lisp (format nil "ws://127.0.0.1:~a/repl" ,port)))))
     (setf (chain socket onopen)
           (lambda () (chain console (log "Connecting to WS server..."))))
     (setf (chain socket onmessage)
           (lambda (msg)
             (chain console (log "In recieved:"))
             (chain console (log (@ msg data)))
             (let* ((json (eval (@ msg data))))
               (try (progn (setf result json))
                    (:catch (error)
                      (setf result error))
                    (:finally (progn
                                (chain console (log "Out result:"))
                                (chain console (log result))
                                (chain socket (send result))))))))))


(defmacro websock-repl-page (&key (port 13000))
  "Clauses do not work here with clack app.
For now I pass a mesage in console.log()"
  `(cl-who:with-html-output-to-string (html nil)
     (:html
      (:head
       (:title "Websock-REPL Window"))
      (:body
       (:h2 :id "info" "WS-REPL App")
       (:script (ps:ps-to-stream html (install-websock ,port)))))))


(defun handle-client-app (client-port ws-port)
  "Launches the WS-REPL client app."
  (clack:clackup
   (lambda (env)
     (declare (ignore env))
     `(200 (:content-type "text/html")
           (,(ws-repl:websock-repl-page :port ws-port))))
   :port client-port))


;; Start Up:
(defun start-ws-repl (&key (client-port 8000) (ws-port 13000))
  (setf *ws-app* (clack:clackup #'start-websock-server :port ws-port))

  (setf *client-app* (handle-client-app client-port ws-port))

  (sleep 2)

  (uiop:run-program
   (format nil "~a \"http://localhost:~a\"" *open-tab-command* client-port))

  (sleep 2)

  (setf *repl* (wsd:make-client "ws://localhost:13000"))

  (wsd:start-connection *repl*))


;; Shut Down:
(defun shutdown-ws-repl ()
  (wsd:close-connection *repl*)
  (clack:stop *ws-app*)
  (clack:stop *client-app*)
  (setf *client* nil *repl* nil
        *ws-app* nil *client-app* nil))


;; Repl Command:
(defmacro in-ws-repl (&body body)
  `(wsd:send-text *repl* (ps ,@body)))
