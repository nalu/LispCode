

;Lisp�}�N���T�v


;�P�𑫂������̃}�N���B
(defmacro 1+ (x) `(+ 1 ,x))

;defun�ł�������
(defun 1+ (x) (+ 1 x))

;�}�N���ł�����`�ł��Ȃ�������������񂠂�
(defmacro let1 (var val &body body)
  `(let ((,var ,val))
    ,@body))




;defun�����������āAdefun�������̂����X�g�ۑ�����}�N��
;�i�������j

;override�\���defun M 
(defmacro defunm (name arglist &body body)
	(print "for lisp rough")
	(print name)
	`(defun ,name ,arglist ,@body)
	   )


(defparameter *def-array* (make-array 100))
(defparameter *defun-num* 0)
(defmacro defun (name arglist &body body)
	   (print "for lisp rough")
	   (print name)
	   (setf (aref *def-array* *defun-num*	) name)		
	   (setq *defun-num* (+ *defun-num* 1))
	   `(defun ,name ,arglist ,@body)
	   )


;defun���I�[�o�[���C�h

;�����OK�Bdefun��print�ɂ��Ă��܂�
(defun defun (x)  (print x))

;���ڂ̓G���[�ł�̓�����O�B����defun�ł͂��A��L�̃R�[�h��print�ɂȂ��Ă���B
;(defun defun (x)  (print x))

;�}�N��������_���P��ڂł��Bpredefined���ǂ��Ƃ�������E�E�E
;(defmacro defun (x) (print x))

;print��defun���Ă�predefined������
;(defun print (x) (+ x x))


;print�͑ޔ��ł���
;(setq temp-print #'print)
;(temp-print 3)

;defun�͑ޔ��ł��Ȃ�
;(setq temp-defun #'defun)

;print�̓V���{���Ȃ̂Œ��g�\�����Ă����
;#'print

;defun�̓}�N���Ȃ̂ŃG���[�B�}�N���͑���ł��Ȃ��́H
;#'defun

;
(defmacro defun (x) (print x))