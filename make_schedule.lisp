

;; �X�P�W���[���e�L�X�g���X�P�W���[���p��CSV�ɕϊ� 
;; v1�ł́A�P�s�P�^�X�N�̃^�X�N���X�g�Ƃ��ăe�L�X�g��ǂݍ���
;; ���݂̓��t��t�^����CSV�����ēf���o���悤�ɂ���

;;�t�H�[�}�b�g
;;�^�X�N�� 4d
;;�X�y�[�X��؂�̂Q�l�Œ�`�B

;;�^�X�N�͏ォ�珇�ɁA�X�P�W���[�����������̂Ƃ��ď�������

;; (ppcre:split " " (ppcre:split #\newline "a b
;;c d"))
;;
;;����ł����邩�Ƃ����������A
;;newline �ł�split��A���X�g�ɂȂ��Ă���̂ŁAmap�ŕ�����split���Ȃ��Ƃ�����
;;���͂�����


(load "./util.lisp")
(ql:quickload :cl-ppcre)

(defparameter *line-str* "------------------------------------------")
(defparameter *count-day* 0)
(defun make-schedule-str (seed-text)
  (let (r-str task-name task-date line-split-str list-tasks total-day)

	(setf line-split-str (ppcre:split #\newline seed-text))
	(setf list-tasks (map 'list (lambda (x) (ppcre:split " " x)) line-split-str))

	;;"4"��4�̐��l�ɕϊ�
	(setf list-tasks 
		  (map 'list (lambda (x)  `(,(elt x 0) ,(stoi (elt x 1))) ) list-tasks))

	;;�S�������v�Z
	(setf total-day (apply '+ (map 'list (lambda (x) (elt x 1)) list-tasks)) )
	(print (format nil "total-day ~d" total-day))

	;;������o��x�ɂ������X�g��ǉ�
	;; ( ( "tskname" 4 (x o o o x))) �Ȃ�
	(setf *count-day* 0)
	(setf list-tasks
		  (map 'list (lambda (x) 
					   (let (list-marubatsu day)
						 (setf day (elt x 1))
						 
						 (for (i 0 total-day)
						   (if (and (<= *count-day* i) (> (+ *count-day* day) i ))
							   (push-back list-marubatsu "o") 
							   (push-back list-marubatsu "x") 
							   );if
									  );for
					   (push-back x list-marubatsu)						 
						 (+= *count-day* day)
						 x
						 ));lambda let
					   list-tasks);map
		  );setf

;	(print list-tasks)

	;(("taskname" "3d") ("taskname2" "5d"))
	;�̌`���̃��X�g���������Ataskname,o,o,o�̂悤��csv�p�������쐬
;; 	(setf csv-list 
;; 		  (map 'list (lambda (x)
;; 				 (format nil "~a~v@{~A~:*~} ~a" 
;; 						 (elt x 0) 
;; 						 (elt x 1)
;; 						 "o"
;; 						 (elt x 2))					   
;; 				 )
;; 		 list-tasks)
;; 		  );setf

	;;�P�^�X�N�P�s��csv��������쐬
	;;(o,x)�����t���b�g��
	(setf csv-list
		  (map 'list (lambda (x)
					   (alexandria:flatten x))
			   list-tasks)
		  );setf
	;;�P�s���J���}��؂艻
	(setf csv-list
	 (map 'list (lambda (x) (concat-list-string x)) csv-list)
	 )

	;;�S�s�����s�łȂ�������
	(setf csv-list
		  (concat-string-delimita csv-list #\newline))
						
;; 	(setf csv-list 
;; 		  (map 'list (lambda (x)
;; 					   (format nil "~a" (concat-list-flat x ",") ) 
;; 					   )
;; 		 list-tasks)
;; 		  );setf

	;;�S�s��csv������
;; 	(setf csv-string
;; 		  (map 'list (lambda 


 	(setf r-str csv-list)

; 	(setf splited (ppcre:split " " seed-text)) 
;;     (setf list-values (multiple-value-list (ppcre:scan-to-strings "(.*)d" (elt splited 1))))
;; 	(setf day (stoi (elt (elt list-values 1) 0)))
;; 	(setf task-name (elt splited 0))

;; 	(setf r-str (concatenate 'string r-str task-name))

;; 	(for (j 0 day)
;; 	  (let (count)
;; 		(setf r-str (concatenate 'string r-str ",o"))
;; 		);let
;; 	  );for



;;     (loop for i below 31 do
;; 	 (setq r-str
;; 	 (concatenate 'string
;; 		     r-str
;; 		     (format nil "~a ~2,'0d~2,'0d~2,'0d ~a~d" 
;; 			     *line-str* year month (+ i 1) 
;; 			     *line-str* #\newline );format
;; 		     );concat
;; 		     );setq
;;        );loop

    r-str
    );let
)
