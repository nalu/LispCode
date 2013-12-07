(QL:QUICKLOAD :Alexandria);�����񃉃C�u����


;�����񃊃X�g�̌����pconcatenate
(defun concat-string (list)
  (concat-string-delimita list "")
)

(defun concat-string-delimita (list delimita)
  (if (listp list)
      (with-output-to-string (s)
         (dolist (item list)
           (if (stringp item)
             (format s "~a~a" item delimita))))))
  

;�ċA���ăl�X�g�������o�[�W����
(defun concat-string-deep (list)
  (if (listp list)
      (with-output-to-string (s)
         (dolist (item list)
           (cond
 			 ((stringp item) (format s "~a" item))
 			 ((consp item) (format s "~a" (concat-string-deep item) ));cons�Ȃ�ċA
			 )
))))

;���X�g�̖����ʘA��
;��x�t���b�g�ȃ��X�g�ɂ��Ă���map��������̂Ō^�����čċA������Ȃ��Ȃ���
(defun concat-list-flat (list delimita)

  (let (r-list)
  ;���R��
  (setq r-list
		(alexandria:flatten list))
  
  ;�f���~�^��
  (setq r-list
		(loop for (a b) on r-list by #'cdr
		   collect (if (not (eql b nil)) (list a delimita) a)  ))

  ;�f���~�^���𕽒R��
  (setq r-list
		(alexandria:flatten r-list))

  ;�S�ĕ�����
   (map 'list (lambda (x) (format nil "~a" x)) r-list)

  ;�A��
;  (concat-string r-list)
   )
)


;�J���}��؂�Ń��X�g�𕶎���ɂ���
;�f���~�^���肽�����߂�ǂ��Ȃ̂ł܂������
;exsample 
;'(a b c) > "A, B, C"
(defun concat-list-string (list)
	(format nil "~{~A~^, ~}" list)
)



;�A�ԃ��X�g(�����K���B�P�����炢����x��)
(defun slist (start size)
  (let ((r-list (make-sequence 'list size :initial-element start )))
	(loop for i below size do
		 (setf (elt r-list i)  (+ (elt r-list i) i))
	)
	r-list
 )
)

;���X�g�̖����ɒǉ�
(defmacro push-back (lat x) 
 `(setf ,lat (append ,lat (list ,x))))

;���X�g�̐擪���폜
(defun pop-begin (list)
  (cdr list)
)


;;�悭����t�H�[�}�b�g�ϊ�
(defun stoi (x)
  (read-from-string x)
)

;���X�g�̒����烉���_���Ɏ擾
(defun random-get( array )
  (aref array (random (length array)))
)

;;Vec
;;vector���ȒP��`
;;�ߔN�̃v���O���~���O�X�^�C���ɂȂ�ׂ��߂Â���d�l�ɂ�����
(defun new-vec ()
;;   `(defparameter ,name (make-array 0 :fill-pointer t :adjustable t))
  (make-array 0 :fill-pointer t :adjustable t)
)
;;vector�ɒǉ�
(defun vec-push ( vec value )
  (vector-push-extend value vec)
)
;;�擾
(defun vec-get ( vec index )
  (elt vec index)
)
;;�Z�b�g
(defun vec-set ( vec index value )
  (setf (elt vec index) value )
)
