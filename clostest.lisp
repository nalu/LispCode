(ql:quickload :cl-utilities)

#|
test

(defclass tclassc () (a b c))
(defparameter tobjc nil)
(setf tobjc (make-instance 'tclassc))
(setf (slot-value tobjc 'a) 9)
                         
(defclass tclass () (x y z)) 
(defparameter tobj nil)
(setf tobj (make-instance 'tclass))
(setf (slot-value tobj 'x) 1)
(setf (slot-value tobj 'y) 5)
(setf (slot-value tobj 'z) tobjc)

(defstruct tstruct x y z)
(defparameter tobj2 (make-tstruct))
(setf (tstruct-x tobj2) 99)
(setf (tstruct-y tobj2) 100)
|#

(defun make-calls (string)

  (let ((symbols (reverse
                  (mapcar (lambda (string)
                            (intern string))
                          (cl-utilities:split-sequence #\. string)))))
;;                          (ppcre:split "#\." string)))))
    (labels ((nest (list)
               (if (not (cddr list))
                   `(slot-value ,(second list) ',(first list))
                 `(slot-value ,(nest (cdr list))
                              ',(first list)))))
      (nest symbols))
    )



)



(defun read-instance-slot-value (stream subchar arg)

 (declare (ignore subchar arg))
 (make-calls (symbol-name (let ((*readtable* (copy-readtable nil)))
                            (read stream))))
)


(set-dispatch-macro-character
  #\# #\!
  #'read-instance-slot-value)


;;ディスパッチ文字当てなければ１文字でも
(defun read-instance-slot-value2 (stream arg)

  (declare (ignore arg))
 (make-calls (symbol-name (let ((*readtable* (copy-readtable nil)))
                            (read stream))))
)
(set-macro-character
  #\@
  #'read-instance-slot-value2)




