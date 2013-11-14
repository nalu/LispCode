#|
Lisp Rough は、lispのREPLを使ってアプリケーションの開発を迅速にするライブラリ
絵を書く際のラフのように、素早く、雑だけど全容が把握できるような状態を目指している。

・画面サイズ
デフォルトは決定済みだが、ゲームコード側でlr-beginを呼ぶ時に
オプションでサイズを指定できる

|#


(ql:quickload :cl-ppcre);文字列ライブラリ
(load "c:/Lisp/LispCode/util.lisp")


;--------------------------------- SYSTEM ---------------------------------
(defparameter *cui-cell-width-character* 2) ;ＣＵＩで１マスを表現するための文字数

(defparameter *quit* 0)


(defparameter *default-screen-w* 28)
(defparameter *default-screen-h* 24)

(defparameter *screen-w* 28)
(defparameter *screen-h* 24)
(defparameter *screen-map* (make-array (* *screen-w* *screen-h*)))



;; (defparameter *object-array* nil)
;; (defparameter *object-num* 0);配列をやめて、追加ができるリストを採用するのが望ましい

;;object-arrayを追加できる形式に変更
(defparameter *object-array* (make-array 0 :fill-pointer t :adjustable t))
(defun object-add (object)
  (vector-push-extend object *object-array*))

;メソッド変換用(alistにしたい
(defparameter *def-f-array* (make-array 0 :fill-pointer t :adjustable t))
(defun def-f-add (method)
    (vector-push-extend method *def-f-array*)
)
(defparameter *def-v-array* (make-array 0 :fill-pointer t :adjustable t))
(defun def-v-add (variable)
  (vector-push-extend variable *def-v-array*)
)

(defparameter *enum-array* (make-array 0 :fill-pointer t :adjustable t))
(defun enum-add (enum)
  (vector-push-extend enum *enum-array*))


(defun lr-begin ( &optional (screen-w *default-screen-w*) (screen-h *default-screen-h*) ) 
  (setq *quit* 0)
;;   (setq *object-array* (make-array 100))
  (setq *screen-w* screen-w )
  (setq *screen-h* screen-h)
  (setq *screen-map* (make-array (* *screen-w* *screen-h*)))
;;   (setq *object-num* 0)
)

(defun lr-start()
  (lr-init)
  (lr-loop)
)


(defun lr-init()
 
)

(defun lr-quit()
  (setq *quit* 1)
)

(defun lr-loop()


  (draw-screen)
  (input)

  (case *quit*
    (0 (lr-loop))
    (1 ))
  
)

;入力
(defun input()

  (let (obj readkey (push-obj 0))
    (setq readkey (read))
;;     (loop for i below *object-num* do
	(loop for i below (length *object-array*) do
   
	 (setq obj (aref *object-array* i) )
	 (if (equal (type-of obj) 'button)
	     (if (equal readkey (button-key obj) )
		 (if (equal (button-enable obj) t )
		     (if (equal (button-visible obj) t)
			 (setq push-obj obj)
	     )))))

    (if (equal push-obj 0)
	(print "please push any key")
	(call-button push-obj))
    )
  
)



(defun draw-screen ()

  ;BG
;  (map-set-char-all "  ")
  (map-set-square 0 0 *screen-w* *screen-h*)


  ;Object - draw
;;   (loop for i below *object-num* do
  (loop for i below (length *object-array*) do
       (let ((obj (aref *object-array* i)))
		 (if (equal (label-visible obj) t)
		     (draw-label (aref *object-array* i ))
		     )))
 
  ; draw map
  (draw-map)
  
  (fresh-line)

)

;Map
(defun draw-map ()
  (loop for y below *screen-h* do 
       ( progn (fresh-line)
	       (loop for x below *screen-w* do 
		    ( 
		     princ (aref *screen-map* (+ (* y *screen-w*) x ) )
			   )
    )))
)


;文字をマップにセット
;*cui-cell-width-character*の文字数を越えた分はカットされる
;format-numには半角なら１、全角なら２
;マップ範囲外の位置を指定すると何もセットしない
(defun map-set-char ( x y char &optional (one-character-cell-num 1) ) 
  (if (and (> *screen-h* y)  (> *screen-w* x))

    (let (cut-char f-char)
      (setq f-char (format nil "~~~da" one-character-cell-num))
      (setq cut-char (format nil f-char char))    
      (setf (aref *screen-map* (+ (* *screen-w* y) x))  cut-char)
      )
   )
)
;test日本語
(defun map-set-char-ja ( x y char ) 
  (map-set-char x y char 2)
)


;文字列をマップにセットする
;セルの文字数に満たない場合は空白で埋めて、はみ出す場合は隣のセルに書く
(defun map-set-str ( x y str ) 
  
  (setq str (format nil "~a" str))
  ;文字数を空白で埋めて調整
  (let (set-char len new-len format-char)
    (setq len (length str))
    (setq new-len (+ len (mod len *cui-cell-width-character*)))
    (setq format-char (format nil "~~~da" new-len))
    (setq set-char (format nil format-char str))


    ;１セル分ずつセット
   
    (loop for i below new-len by *cui-cell-width-character* do
	 ( let (sub-str set-cell-x)
	   (setq sub-str (subseq set-char i (+ i *cui-cell-width-character*)))
	   (setq set-cell-x (+ x (/ i *cui-cell-width-character*)))
	   (map-set-char set-cell-x y sub-str)
	 )))
)
  
(defun map-set-str-ja ( x y str &optional (one-character-cell-num 1) ) 
  
  (setq str (format nil "~a" str))
  ;文字数を空白で埋めて調整
  (let (set-char len new-len format-char)
    (setq len (length str))
    (setq new-len (+ len (mod len *cui-cell-width-character*)))
    (setq format-char (format nil "~~~da" new-len))
    (setq set-char (format nil format-char str))


    ;１セル分ずつセット
   
    (loop for i below new-len by *cui-cell-width-character* do
	 ( let (sub-str set-cell-x)
	   (setq sub-str (subseq set-char i (+ i *cui-cell-width-character*)))
	   (setq set-cell-x (+ x (/ i one-character-cell-num)))
	   (map-set-char set-cell-x y sub-str one-character-cell-num)
	   ))
    )
)




(defun map-set-char-all ( char )
   (loop for y below *screen-h* do 
	(loop for x below *screen-w* do 
	  (map-set-char x y char)
	))
   
)

(defun map-set-square ( left top width height)

  (loop for y from top below (+ top height) do
       (loop for x from left below (+ left width) do
	    (cond ( (= x left) (map-set-char x y "| ") )
		  ( (= x (+ left (- width 1))) (map-set-char x y " |"))
		  ( (= y top) (map-set-char x y "--"))
		  ( (= y (+ top (- height 1))) (map-set-char x y "--"))
		  ( t (map-set-char x y "  "))
	    )
	    ))
)


;--------------------------------- GOB ---------------------------------

;; (defun add-object ( obj )
;;   (setf (aref *object-array* *object-num*) obj)
;;   (setq *object-num* (+ *object-num* 1))
;; )

(defstruct object )
(defmethod object-draw())


;Square
(defstruct (square (:include object)) (x 0) (y 0) (w 0) (h 0) )
(defmethod draw-square ((obj square))
  (map-set-square (square-x obj) (square-y obj)
		  (square-w obj) (square-h obj) )
)

 
;Label
(defstruct (label (:include square)) (text "") (visible t) )
(defun draw-label ( obj )
  (draw-square obj)
  (map-set-str (+ (square-x obj) 1) (+ (square-y obj) 1) (label-text obj))
)
(defun set-text ( obj text)
  (setf (label-text obj) text)
)

;Button
(defstruct (button (:include label)) (key) (call) (enable t) )
(defun draw-button ( obj )
  (draw-label obj)
)

;ボタンが押された時は、セットしてあるコールバックの引数の数をカウントして、
;引数がなければそのまま呼び出し、１つ以上ある場合は自分自身を渡す
(defun call-button ( obj )
  (if (= (length (arglist (button-call obj))) 0)
	  (funcall (button-call obj))
	  (funcall (button-call obj) obj )
	  )
)
(defun enable-button (obj enable)
  (setf (button-enable obj) enable)
  )
(defun visible-button (obj visible)
  (setf (button-visible obj) visible)
)


;;初期化と登録を同時に行う関数。基本的にオブジェクトはこれで作る
(defun new-square (x y w h)
  (let (obj)
	(setq obj (make-label :x x :y y :w w :h h))
;; 	(add-object obj)
	(object-add obj)
	obj)
)

(defun new-label ( x y w h title )
  (let (obj)
	(setq obj (make-label :x x :y y :w w :h h :text title))
;; 	(add-object obj)
	(object-add obj)
	obj
	)
)

(defun new-button ( x y w h title key call )
  (let (obj)
    (setq obj (make-button :x x :y y :w w :h h :text title :key key :call call))
;; 	(add-object obj)
	(object-add obj)
	obj)
)




;defunの代用を作成
;このメソッドで関数定義しておけば、*def-f-arary*に内容が保管され、コンバート可能になる。
(defmacro def-f (name args &body body) 
;  (print name)
  (def-f-add (list name args body)  )
  `(defun ,name ,args ,@body);なぜかこの行を先にすると、定義されない
)


(defmacro def-v (name value)
  (def-v-add (list name value ))
  `(defparameter ,name ,value)
)

;列挙型サポート
;リストを渡すと単純に０から代入する
;この関数は別言語へのコンバート時に適切に変換される
;; (defun enum ( name values)
;;   (loop for i below (length values) do
;; 	   (eval (read-from-string (format nil "(setq ~a ~d)" (elt values i) i )))) 
;; )

(defmacro def-enum (group-name namelist)
  (enum-add (list (eval group-name) (eval namelist)))
  `(loop for i below (length ,namelist) do
		(eval (read-from-string (format nil "(defparameter ~a ~d)" 
										(elt ,namelist i) i) ))
	   )
)

















;--------------------------------- MULTI GOB ---------------------------------

;;グリッドクラス（テスト）
;;グリッド、セルの２クラスで構成する
;;グリッドがセルを持ち、セルが用途に応じたオブジェクトを持っているという構成
;;ユーザーはセルの位置をカスタマイズしない事を前提とし、
;;セル上のオブジェクトに自由にアクセスして使う想定
;;セルは位置インデックスを持ち、位置、範囲指定、検索などを容易に行えるようにする

;;ということを予定していたが、ぶっちゃけセル使う時はｘ，ｙにアクセスしたいだけなので、
;;暫定バージョンとしてはgetX, getYができればいいということになった。
;;AndroidやiOSを見てもわかるが、グリッドクラスは複雑すぎる上完成度を高めるのは難しい

;;セルを使えば効率的なコードも書けるかもしれないが、
;;どうせコンバートして使うので今セルを作る意味はない。
(defstruct (grid) (x 0) (y 0) (w-cell-num 3) (h-cell-num 3) (visible t) (array nil) )
(defun new-grid (x y w-cell-num h-cell-num cell-w cell-h)
  (let (
		(obj) 
		(cell-array (make-array (* w-cell-num h-cell-num)))
		)

	(loop for i below (length cell-array) do
		 (setf (aref cell-array i) 
			   (new-button 
				(+ x (* (mod i w-cell-num) cell-w )) ;x
				(+ y (* (truncate i w-cell-num) cell-h))  ;y
				cell-w cell-h  ;w,h
				(format nil "~d" i);str
;;  				'a ;key
				(read-from-string (format nil "~d" i)) ;グリッド番号をそのままキーに指定
				#'push-grid) )
		 )
;; )										


	(setq obj 
		  (make-grid :x x :y y 
					 :w-cell-num w-cell-num :h-cell-num h-cell-num
					 :array cell-array))
	
;; 	(add-object obj)
	obj)
  
)

;;指定のグリッド番号に手をセット
(def-f grid-set-hand ( grid cell-num hand )
   (set-text (aref (grid-array grid) cell-num)  hand)
)

;;指定のオブジェクトのグリッド上のｘ座標を返す
(def-f grid-x-cell (grid obj)
;;   (loop for i below (length (grid-array grid)) do
;; 	   (if (equal (aref (grid-array grid) i) obj)
;; 		   (button-x (aref (grid-array grid) i) ) ;t
;; 		   ;nil
;; 	   )
;; 	   )

  (let (index)
	(setq index (position obj (grid-array grid)))
	(mod index (grid-w-cell-num grid))
   )

)
;;指定のオブジェクトのグリッド上のｙ座標を返す
(def-f grid-y-cell (grid obj)
;;   (loop for i below (length (grid-array grid)) do
;; 	   (if (equal (aref (grid-array grid) i) obj)
;; 		   (button-y (aref (grid-array grid) i) ) ;t
;; 		   ;nil
;; 	   )
;; 	   )

  (let (index)
	(setq index (position obj (grid-array grid)))
	(truncate index (grid-w-cell-num grid))  ;y
   )

)


;;グリッドのボタン群のうちテキスト内容がox以外の配列を抽出。
(def-f get-empty-cell-array (cell-array)
  (remove-if 
	 #'(lambda (x) 
		 (if (or ( equal (button-text x) "o" )  (equal (button-text x) "x"))
			 t
			 nil)
;; 		 ) (grid-array grid))
		 ) cell-array)
	
)


;;グリッドの状態から勝敗判定
(def-f jadge-win()
  
)



;;指定の位置のグリッドを取得
;;範囲外を指定したらnilを返す
(def-f grid-get-cell (grid x y)
  
  (cond 
	((>= x (grid-w-cell-num grid)) nil)
	((>= y (grid-h-cell-num grid)) nil)
	(t (aref (grid-array grid)
		(+
		 (* y (grid-w-cell-num grid))
		 x )
		))
  )
)

;; 指定のセルのグリッドのｘ位置を返す
;; (def-f grid-get-cell-x (grid cell)
;;   (find cell (grid-array grid))
;; )

;;指定エリアのセル配列を返す
(def-f grid-get-area-cell-array (grid area-x area-y area-w area-h)
  (remove-if #'(lambda(cell) 
				 (if (or
						  (<= (+ area-x area-w) (grid-x-cell grid cell)) 
						  (<= (+ area-y area-h) (grid-y-cell grid cell)) 
						  (< (grid-x-cell grid cell) area-x)
						  (< (grid-y-cell grid cell) area-y)
						  )
					 t;t
					 nil);nil
				 ) (grid-array grid))
)

;;ランダムに空白のセルを取得
(def-f grid-random-get-empty (grid )
  (random-get (get-empty-cell-array (grid-array grid)))
)

;;作り中
;;ランダムに空白のセルを取得。範囲指定
;;グリッドのセルから、セルのグリッド上の位置を割り出さないといけない
;;（ｘ，ｙはボタンの位置であり、グリッド上の座標の情報がない）
;;ので、結構手間。
(def-f grid-random-get-empty-area (grid x y w h )
	;指定のエリアのセル配列を作成後、要素が空の配列を取得し、ランダムで返す

  (random-get 
   (get-empty-cell-array 
	(grid-get-area-cell-array grid x y w h))
   )
)


;;ランダムにx個の要素を配置
(def-f grid-put-random( grid put-num )
  
  (let (empty-cell)
	(loop for i below put-num do
;; 		 (setq empty-cell (random-get (get-empty-cell-array grid)))
		 (setq empty-cell (grid-random-get-empty grid))
		 (set-text empty-cell "x")
		 )
	)
	
)

;;ランダムに要素を配置。ＤＲＭ用
;;レベル＊４の要素を配置
;;ベース・ラインより下にランダム配置する
;;飽和量が一定を超えると、ベースラインより上にも配置する
(def-f grid-put-random-drm( grid level base-line-y)
  (loop for i below (* level 4) do
	   (let ((empty-cell) (color-no))
		 (setq empty-cell 
			   (grid-random-get-empty-area grid 
										   0
										   base-line-y 
										   (grid-w-cell-num grid)
										   (- (grid-h-cell-num grid) base-line-y)
										   ))
		 (setq color-no (random 3))
		 (cond
		   ((= color-no 0) (set-text empty-cell "o"))
		   ((= color-no 1) (set-text empty-cell "x"))
		   ((= color-no 2) (set-text empty-cell "i"))
		 )
	   );let
	   )
)

;;マッチチェック
;;マッチのアルゴリズム悩ましい
;;再帰使う
;;ターゲットがｘマッチしているかどうかのチェック
(def-f grid-check-match ( grid x y match-num )
  (grid-check-match-r grid x y match-num 0)
)

;;マッチチェック再帰用
(def-f grid-check-match-r ( grid x y match-num deep-count)
  ;;マッチ条件を満たしているかチェック
  (cond 
	;;マッチ数クリアしたらtを返す
	((>= match-num deep-count) t)
	;;セルがなければnil返す
	
	;それ以外なら上下左右に潜る
	(t
	;;右チェック
	 (cond 
	   ((not (= nil (grid-get-cell grid (+ x 1) y))) 
		;;t時さらに潜る
		(+ deep-count 1)
		(grid-check-match-r grid (+ x 1) y match-num deep-count)
		)
	   ;;false時なにもしない
	   )
	;;左チェック
	;;上チェック
	;;下チェック
	 )
	)
)

(def-f grid-get-cell-right (grid target-cell)
  
)



