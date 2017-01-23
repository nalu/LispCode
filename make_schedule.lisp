

;; スケジュールテキストをスケジュール用のCSVに変換 
;; v1では、１行１タスクのタスクリストとしてテキストを読み込み
;; 現在の日付を付与してCSV化して吐き出すようにする

;;フォーマット
;;タスク名 4d
;;スペース区切りの２値で定義。

;;タスクは上から順に、スケジュールが早いものとして処理する

;; (ppcre:split " " (ppcre:split #\newline "a b
;;c d"))
;;
;;これでいけるかとおもったが、
;;newline でのsplit後、リストになっているので、mapで複数回splitしないといけん
;;次はこれやる


(load "./util.lisp")
(ql:quickload :cl-ppcre)

(defparameter *line-str* "------------------------------------------")
(defparameter *count-day* 0)
(defun make-schedule-str (seed-text)
  (let (r-str task-name task-date line-split-str list-tasks total-day)

	(setf line-split-str (ppcre:split #\newline seed-text))
	(setf list-tasks (map 'list (lambda (x) (ppcre:split " " x)) line-split-str))

	;;"4"を4の数値に変換
	(setf list-tasks 
		  (map 'list (lambda (x)  `(,(elt x 0) ,(stoi (elt x 1))) ) list-tasks))

	;;全日数を計算
	(setf total-day (apply '+ (map 'list (lambda (x) (elt x 1)) list-tasks)) )
	(print (format nil "total-day ~d" total-day))

	;;日数をoやxにしたリストを追加
	;; ( ( "tskname" 4 (x o o o x))) など
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
	;の形式のリストを処理し、taskname,o,o,oのようなcsv用文字を作成
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

	;;１タスク１行のcsv文字列を作成
	;;(o,x)部をフラット化
	(setf csv-list
		  (map 'list (lambda (x)
					   (alexandria:flatten x))
			   list-tasks)
		  );setf
	;;１行をカンマ区切り化
	(setf csv-list
	 (map 'list (lambda (x) (concat-list-string x)) csv-list)
	 )

	;;全行を改行でつなげ文字列化
	(setf csv-list
		  (concat-string-delimita csv-list #\newline))
						
;; 	(setf csv-list 
;; 		  (map 'list (lambda (x)
;; 					   (format nil "~a" (concat-list-flat x ",") ) 
;; 					   )
;; 		 list-tasks)
;; 		  );setf

	;;全行をcsv文字列化
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
