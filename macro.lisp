

;Lispマクロ概要


;１を足すだけのマクロ。
(defmacro 1+ (x) `(+ 1 ,x))

;defunでも書ける
(defun 1+ (x) (+ 1 x))

;マクロでしか定義できない動作もたくさんある
(defmacro let1 (var val &body body)
  `(let ((,var ,val))
    ,@body))




;defunを書き換えて、defunしたものをリスト保存するマクロ
;（書き中）

;override予定のdefun M 
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


;defunをオーバーライド

;これはOK。defunをprintにしてしまう
(defun defun (x)  (print x))

;二回目はエラーでるの当たり前。もうdefunではく、上記のコードでprintになっている。
;(defun defun (x)  (print x))

;マクロしちゃダメ１回目でも。predefinedがどうとか言われる・・・
;(defmacro defun (x) (print x))

;printはdefunしてもpredefined言われる
;(defun print (x) (+ x x))


;printは退避できる
;(setq temp-print #'print)
;(temp-print 3)

;defunは退避できない
;(setq temp-defun #'defun)

;printはシンボルなので中身表示してくれる
;#'print

;defunはマクロなのでエラー。マクロは代入できないの？
;#'defun

;
(defmacro defun (x) (print x))