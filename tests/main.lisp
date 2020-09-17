(defpackage visuals/tests/main
  (:use :cl
        :visuals
        :rove))
(in-package :visuals/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :visuals)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
