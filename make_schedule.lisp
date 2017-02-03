;; スケジュールテキストをスケジュール用のCSVに変換 
;; v1では、１行１タスクのタスクリストとしてテキストを読み込み
;; 現在の日付を付与してCSV化して吐き出すようにする

;;フォーマット
;;タスク名 4d
;;スペース区切りの２値で定義。

;;タスクは上から順に、スケジュールが早いものとして処理する

(load "./util.lisp")
(ql:quickload :cl-ppcre)
(ql:quickload :metatilities)
(ql:quickload :date-calc)

(defparameter *line-str* "------------------------------------------")
(defparameter *count-day* 0)
(defun make-schedule-str (start-day seed-text)
  (let (r-str task-name task-date line-split-str list-tasks total-day csv-list)

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

	;;日付行を作成
	;;実行時の日付から全タスク合計日数まで１日ずつ足したリストを作る
	;;(day, 30, 1, 2, 4, 5...
	(let (day-list month-list current-month)

	  (setf current-month -1)
	  (push-back month-list "month")
	  (push-back day-list "day")

	  (for (i 0 total-day) 
		(multiple-value-bind (year month day)
			(date-calc:today)
		  (multiple-value-bind (y m  next-day) 
			(date-calc:add-delta-days year month day i);; to next
			;;day
			(push-back day-list next-day)
			;;month
			( if (not ( = current-month m))
				 (push-back month-list m)
				 (push-back month-list "")
			)
			(setf current-month m)
			)
		  )
		)
	  ;;リストを挿入
	  (setf list-tasks (cons day-list list-tasks))
	  (setf list-tasks (cons month-list list-tasks))
	  )
	  
	
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
						
 	(setf r-str csv-list)

	


    r-str
    );let
)
