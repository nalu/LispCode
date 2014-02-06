(QL:QUICKLOAD :Alexandria);�����񃉃C�u����
(load "at-accessor.lisp")


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
(defmacro += (x y) `(setf ,x (+ ,x ,y)))
(defmacro -= (x y) `(setf ,x (- ,x ,y)))
(defmacro ++ (x) `(setf ,x (1+ ,x)))
(defmacro -- (x) `(setf ,x (1- ,x)))
(defmacro % (x y) `(mod ,x ,y))
;���X�g�̒����烉���_���Ɏ擾
(defun random-get( array )
  (aref array (random (length array)))
)

;;Vec
;;vector���ȒP��`
;;�ߔN�̃v���O���~���O�X�^�C���ɂȂ�ׂ��߂Â���d�l�ɂ�����
(defmethod new-vec (&optional (size 0))
  (make-array size :fill-pointer t :adjustable t)
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

;;�폜���ċl�߂�B
(defun vec-remove (vec index)
  (delete
   (elt vec index) 
   vec
   :count 1
   :start index)
)

;;�w��̃I�u�W�F�N�g���P�폜
(defun vec-remove-if (vec obj)
  (delete
   obj
   vec
   :count 1)
)

;;�A��
(defmacro vec-concat (vec sequence)
  `(setf ,vec 
		(concatenate 'vector ,vec ,sequence)
		)
)

;;�Ȉ�for
;;�g����
;;(for (i 0 10)
;;  (print i)
;;  (if (= i 5)
;;    (for-continue) ;continue
;;     )
;;  (print <= 4)
;;)


(defmacro for ((var start end) &body body)
  (let ((block-name (gensym "BLOCK")) 
		(direction 'below) )

;; 		(direction (if (> start end) 'above 'below)))
;; 		(print direction)


;; 	(if (> start end ) (setq direction 'above))
;;  	`(if (> ,start ,end ) (setq ,direction 'above))
    `(loop for ,var from ,start below ,end
;;     `(loop for ,var from ,start ,direction ,end

;;     `(loop for ,var from ,start ,(if (> `,start `,end) 'above 'below) ,end
           do (block ,block-name
                (flet ((for-continue ()
                         (return-from ,block-name)))
                  ,@body))))

)


;;�f�N�������g����������������肠�����̂Œ��~
;;���̏�ԓ�������Ԃ̊֌W�Ŗ�����
;;�Ƃ肠�����C���N�������g�����Ŏg�p
;; (defmacro for ((var start end) &body body)
;;   (let ((block-name (gensym "BLOCK")) 
;; 		(direction 'below) )

;; ;; 		(direction (if (> start end) 'above 'below)))
;; ;; 		(print direction)


;; ;; 	(if (> start end ) (setq direction 'above))
;; ;;  	`(if (> ,start ,end ) (setq ,direction 'above))
;;     `(loop for ,var from ,start below ,end
;; ;;     `(loop for ,var from ,start ,direction ,end

;; ;;     `(loop for ,var from ,start ,(if (> `,start `,end) 'above 'below) ,end
;;            do (block ,block-name
;;                 (flet ((for-continue ()
;;                          (return-from ,block-name)))
;;                   ,@body))))

;; )



