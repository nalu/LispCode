#|
Lisp Rough は、lispのREPLを使ってアプリケーションの開発を迅速にするライブラリ

・画面サイズ
デフォルトは決定済みだが、ゲームコード側でlr-beginを呼ぶ時に
オプションでサイズを指定できる

|#


(ql:quickload :cl-ppcre);文字列ライブラリ
(load "./util.lisp")


;--------------------------------- SYSTEM ---------------------------------
(defparameter *cui-cell-width-character* 2) ;ＣＵＩで１マスを表現するための文字数

(defparameter *quit* 0)


(defparameter *default-screen-w* 28)
(defparameter *default-screen-h* 24)

(defparameter *screen-w* 28)
(defparameter *screen-h* 24)
(defparameter *screen-map* (make-array (* *screen-w* *screen-h*)))



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
  (setq *screen-w* screen-w )
  (setq *screen-h* screen-h)
  (setq *screen-map* (make-array (* *screen-w* *screen-h*)))
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
;; (defstruct (square (:include object)) (x 0) (y 0) (w 0) (h 0) (visible t) )
(defmethod draw-square ((obj square))
  (map-set-square (square-x obj) (square-y obj)
		  (square-w obj) (square-h obj) )
)

 
;Label
(defstruct (label (:include square)) (text "") (visible t) )
;; (defstruct (label (:include square)) (text "") )
(defun draw-label ( obj )
  (draw-square obj)
  (map-set-str (+ (square-x obj) 1) (+ (square-y obj) 1) (label-text obj))
)
(defun set-text ( obj text)
  (setf (label-text obj) text)
)

;Button
(defstruct (button (:include label)) (key) (call) (enable t)　(tag nil) )
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

;;セルの上にオブジェクトを乗せて使う
;;グリッド作成時、セルに乗せるアイテムを返すメソッドをセットする事を前提とする
;;この関数がnilの場合は、デフォルトのオブジェクト作成関数が使用される

;;データの配列をセットが必要
;;セルの見た目を作る関数とは別に、データ配列を持っておいて、
;;セル位置と対応してｘ，ｙの取得、座標指定でのデータ取得など行えるようにする
;;セルの見た目を作る関数でもこのデータを利用する事ができる
;;セルの見た目を更新する際にもこのデータは使える

;;グリッドはマッチチェック用にmatchd-listを持ち

;;セルのオブジェクトはデフォルトでボタンを持つ形式に変更
;;クリック機能を持つ事が前提で、ユーザーはＯＦＦにもできる
;;グリッドの初期値に与えたキーとインデックスの組み合わせで押すことができるようにする
;;デフォルトのオブジェクトの考え方は無く、
;; (defstruct (grid)  (x 0) (y 0) (w-cell-num 3) (h-cell-num 3) (cell-array nil) (callback-update nil) (callback-push-cell nil) )
(defstruct (grid (:include label))  (w-cell-num 3) (h-cell-num 3) (cell-array nil) (callback-update nil) (callback-push-cell nil) )
(defstruct (cell) (x 0) (y 0) (obj nil) (data nil) (button nil))
(defun new-grid (x y w-cell-num h-cell-num cell-w cell-h 
				 callback-make-cell-obj
				 callback-make-cell-data
				 callback-update-cell
				 key
				 callback-push-cell
				 )
  (let (
		(new-grid-obj)
		(cell-array (make-array (* w-cell-num h-cell-num)))
		)

	;;セルの見た目作成コールバックがnilならデフォルト関数をセット
;; 	(cond 
;; 	  ((equal callback-make-cell-obj nil)
;; 		(setq callback-make-cell-obj #'grid-default-callback-make-cell-obj)
;; 		(setq callback-update-cell #'grid-default-callback-update-cell)
;; 	    (setq callback-make-cell-data #'grid-default-callback-make-cell-data)
	    
;; 		))

	(if (not callback-update-cell)
		(setq callback-update-cell #'grid-default-callback-update-cell))

	(if (not callback-make-cell-data)
	    (setq callback-make-cell-data #'grid-default-callback-make-cell-data))


	;;セルを作成
	(loop for i below (length cell-array) do
		 (let (cell button cell-x cell-y cell-obj-x cell-obj-y)
		   (setq cell-x (mod i w-cell-num))
		   (setq cell-y (truncate i w-cell-num))
		   (setq cell-obj-x (+ x (* cell-x cell-w)))
		   (setq cell-obj-y (+ y (* cell-y cell-h)))
		   (setq cell
				 (make-cell 
				  :x cell-x
				  :y cell-y
				  
										;コールバックを用いてオブジェクトを作成
;; 				  :obj 
;; 				  (funcall 
;; 				   #'grid-default-callback-make-cell-obj
;; 				   x;grid x
;; 				   y;grid y
;; 				   (mod i w-cell-num);cell x
;; 				   (truncate i w-cell-num); cell y
;; 				   cell-w
;; 				   cell-h
;; 				   i
;; 				   callback-make-cell-obj
;; 				   )

;; 				  :data
;; 				  (funcall
;; 				   callback-make-cell-data
;; 				   )
				  );make cell
				 );setq


		   ;;セルのボタンを作成
		   (setq button
				  (funcall 
				   #'grid-default-callback-make-cell-obj
				   cell-obj-x
				   cell-obj-y
				   cell-w
				   cell-h
				   i
				   callback-make-cell-obj
				   )
				 )
		   (setf (cell-button cell) button)

		   ;;セルのオブジェクトを作成
		   (cond (callback-make-cell-obj 
				  (setf (cell-obj cell)
						(funcall callback-make-cell-obj
								 cell-obj-x
								 cell-obj-y
								 cell-w
								 cell-h
								 i)
						)
			   ));cond



		   ;;セルの初期化データを作成
		   (setf (cell-data cell) 
				 (funcall callback-make-cell-data i cell))

		   
		   
		 (setf (aref cell-array i) cell)
			   );let

		 );loop
		  
	

	(setq new-grid-obj 
		  (make-grid :x x :y y 
					 :w-cell-num w-cell-num :h-cell-num h-cell-num
					 :cell-array cell-array
					 :callback-update callback-update-cell
					 :callback-push-cell callback-push-cell))

;; 	(add-object obj)
	(object-add new-grid-obj)

	new-grid-obj
   )
  
)

;;セルに置くオブジェクトを作成するコールバック。
;;この関数は必ず実行され、オプションでユーザーが初期化時にオブジェクト作成関数を
;;セットすることもできる。
;;セル専用のボタンを作成し、ボタンのタグにはセルを持たせる
;;x,y,w,h,indexは、グリッド上のセル座標、セル幅、高さ、セル番号
;; (defun grid-default-callback-make-cell-obj ( grid-x grid-y cell x y w h index 
;; 											custom-make-cell-obj-callback )
;;   (let (button)

;; 	(setq button 
;; 		  (new-button 
;; 		   (+ grid-x (* x w));x
;; 		   (+ grid-y (* y h))
;; 		   w h ;w, h
;; 		   (format nil "~d" index);str
;; 		   ;;  				'a ;key
;; 		   (read-from-string (format nil "~d" index)) ;グリッド番号をそのままキーに指定
;; 		   #'grid-push-cell) 
;; 		  );setq
		  


;; 	);let

;; )

(defun grid-default-callback-make-cell-obj ( x y w h index 
											custom-make-cell-obj-callback )

  (new-button 
   x y
   w h ;w, h
   (format nil "~d" index);str
   ;;  				'a ;key
   (read-from-string (format nil "~d" index)) ;グリッド番号をそのままキーに指定
   #'grid-push-cell) 
)



;;セルの見た目アップデートにつかうデフォルトのコールバック関数
(defun grid-default-callback-update-cell (cell)
  (let ((button (cell-obj cell)))
	(set-text button "up")
	)
)

;;セルのデータを返すコールバック関数
(defun grid-default-callback-make-cell-data ()
;;   (make-block)
  nil
)

;;セルの見た目アップデート
(defun grid-update (grid)
  (loop for i below (length (grid-cell-array grid)) do
	   (let ((cell (aref (grid-cell-array grid) i)))
		 (funcall (grid-callback-update grid) cell)
		 );let
	   );loop
)

;;セル押下時のメソッド
(defun grid-push-cell(cell-button)
  ;;   キーからセル場所を判定
  (print (button-key cell-button))
  (let (obj grid cell)

  ;;全オブジェクトからグリッドを検索
	(loop for i below (length *object-array*) do
		 (setq obj (aref *object-array* i))
		 (cond ( (equal (type-of obj) 'grid)
				(setq cell (grid-get-cell-from-button obj cell-button))
				 (cond ( cell
					 (setq grid obj)
					 (return)
					 ));cell cond
				 )); grid cond
		 );loop
	
  ;;ユーザー設定のセル押下時コールバック関数に、セルを渡す
	(print cell)
	(funcall (grid-callback-push-cell grid) cell)

  );let

)

;;指定のオブジェクトのグリッド上のｘ座標を返す
(defun grid-x-cell (grid obj)
  (let (index)
	(setq index (position obj (grid-cell-array grid)))
	(mod index (grid-w-cell-num grid))
   )

)
;;指定のオブジェクトのグリッド上のｙ座標を返す
(defun grid-y-cell (grid obj)

  (let (index)
	(setq index (position obj (grid-cell-array grid)))
	(truncate index (grid-w-cell-num grid))  ;y
   )

)


;;グリッドのボタン群のうちテキスト内容がox以外の配列を抽出。
(defun get-empty-cell-array (cell-array)
  (remove-if 
	 #'(lambda (cell) 
		 (if (or ( equal (button-text (cell-obj cell)) "o" ) 
				 ( equal (button-text (cell-obj cell)) "x"))
			 t
			 nil)
;; 		 ) (grid-array grid))
		 ) cell-array)
	
)


;;グリッドの状態から勝敗判定
;; (defun jadge-win()
  
;; )



;;指定の位置のセルを取得
;;範囲外を指定したらnilを返す
(defun grid-get-cell (grid x y)
  
  (cond 
	((< x 0) nil)
	((< y 0) nil)
	((>= x (grid-w-cell-num grid)) nil)
	((>= y (grid-h-cell-num grid)) nil)
	(t (aref (grid-cell-array grid)
		(+
		 (* y (grid-w-cell-num grid))
		 x )
		))
  )
)

;;指定セルの相対位置のセルを返す
(defun grid-get-cell-from-cell ( grid cell x y )
  (grid-get-cell grid (+ (cell-x cell) x) (+ (cell-y cell) y) )
)

;;指定ブロックの相対位置のセルを返す
(defun grid-get-cell-from-block( grid block x y )
  (let (cell)

	(setq cell (grid-get-cell-from-data grid block) )
	(grid-get-cell grid (+ (cell-x cell) x) (+ (cell-y cell) y) )
	)
)

;;指定データの相対位置のデータを返す
(defun grid-get-data-from-data( grid data x y )
  (let (cell)
    (setq cell (grid-get-cell-from-block grid data x y))
    (cell-data cell)
    );let

)

;;指定のデータを持つ最初のセルを取得
;;存在しなければnilを返す
(defun grid-get-cell-from-data (grid data)
  (loop for i below (length (grid-cell-array grid)) do
	   (let ((cell (aref (grid-cell-array grid) i)))
		 (if (equal (cell-data cell) data)
			 (return cell);t
			 )
	   );let
	   );loop

)

;;指定のボタンオブジェクトを持つセルを取得
(defun grid-get-cell-from-button (grid button)
  (loop for i below (length (grid-cell-array grid)) do
	   (let ((cell (aref (grid-cell-array grid) i)))
		 (if (equal (cell-button cell) button)
			 (return cell);t
			 )
	   );let
	   );loop

)

;; 指定のセルのグリッドのｘ位置を返す
;; (def-f grid-get-cell-x (grid cell)
;;   (find cell (grid-array grid))
;; )

;;指定エリアのセル配列を返す
(defun grid-get-area-cell-array (grid area-x area-y area-w area-h)
  (remove-if #'(lambda(cell) 
				 (if (or
						  (<= (+ area-x area-w) (cell-x cell)) 
						  (<= (+ area-y area-h) (cell-y cell)) 
						  (< (cell-x cell) area-x)
						  (< (cell-y cell) area-y)
						  )
					 t;t
					 nil);nil
				 ) (grid-cell-array grid))
)

;;全セルの持つデータを配列にして返す。nilも含む
(def-f grid-get-data-array (grid)
  (map 'list (lambda(x) (cell-data x)) (grid-cell-array grid))
)

;;ランダムに空白のセルを取得
(defun grid-random-get-empty (grid )
  (random-get (get-empty-cell-array (grid-cell-array grid)))
)

;;作り中
;;ランダムに空白のセルを取得。範囲指定
;;グリッドのセルから、セルのグリッド上の位置を割り出さないといけない
;;（ｘ，ｙはボタンの位置であり、グリッド上の座標の情報がない）
;;ので、結構手間。
(defun grid-random-get-empty-area (grid x y w h )
	;指定のエリアのセル配列を作成後、要素が空の配列を取得し、ランダムで返す

  (random-get 
   (get-empty-cell-array 
	(grid-get-area-cell-array grid x y w h))
   )
)


;;ランダムにx個の要素を配置
(defun grid-put-random( grid put-num )
  
  (let (empty-cell)
	(loop for i below put-num do
;; 		 (setq empty-cell (random-get (get-empty-cell-array grid)))
		 (setq empty-cell (grid-random-get-empty grid))
		 (set-text empty-cell "x")
		 )
	)
	
)


;; ;;マッチチェック
;; ;;マッチのアルゴリズム悩ましい
;; ;;再帰使う
;; ;;ターゲットがｘマッチしているかどうかのチェック
;; (def-f grid-check-match ( grid x y match-num )
;;   (grid-check-match-r grid x y match-num 0)
;; )

;; ;;マッチチェック再帰用
;; (def-f grid-check-match-r ( grid x y match-num deep-count)
;;   ;;マッチ条件を満たしているかチェック
;;   (cond 
;; 	;;マッチ数クリアしたらtを返す
;; 	((>= match-num deep-count) t)
;; 	;;セルがなければnil返す
	
;; 	;それ以外なら上下左右に潜る
;; 	(t
;; 	;;右チェック
;; 	 (cond 
;; 	   ((not (= nil (grid-get-cell grid (+ x 1) y))) 
;; 		;;t時さらに潜る
;; 		(+ deep-count 1)
;; 		(grid-check-match-r grid (+ x 1) y match-num deep-count)
;; 		)
;; 	   ;;false時なにもしない
;; 	   )
;; 	;;左チェック
;; 	;;上チェック
;; 	;;下チェック
;; 	 )
;; 	)
;; )


;;汎用マッチチェック関数
;;Match-3パズルで使う連続マッチ数チェックをベースに
;;マッチ数、ラインの向き、チェック内容をカスタマイズできるように構成
;;マッチしたデータのリストを返す。このリストは重複しない
(defun grid-check-match (grid require-num 
						 horizontal vertical slanting
						 test)


  ;;各行毎に、左から１マスずつチェックし、同じ色が３つ以上続くようなら
  ;;ブロックのmatchedをtにする
  ;;その後、列についても上から同じチェックをする
  ;;再帰を使う

  ;;左上から１行ずつチェック
  ;;マッチチェックし終わったブロックは無視しない。
  ;;無視した場合、縦方向にも検索があるので、Ｌの字になっていると失敗する

  ;;再帰の中でマッチチェックが成立したものを、マッチリストに追加していき、
  ;;全部終わったらこのリストを返す
  (let (match-list)
	(setq match-list (new-vec))

	(loop for y below (grid-h-cell-num grid) do
		 (loop for x below (grid-w-cell-num grid) do
			  
			  (let (cell)
				(setq cell (grid-get-cell grid x y))
				(cond
				  (
				   (not (equal cell nil))
										;t
				   (if (equal horizontal t)
					   (grid-check-match-r-horizontal grid cell require-num test match-list))
				   (if (equal vertical t)
					   (grid-check-match-r-vertical grid cell require-num test match-list))
				   (if (equal slanting t)
					   (grid-check-match-r-slanting grid cell require-num test match-list))
				  )
				  );cond
				
				);let
			  
			  
			  );loop x
		 );loop y
	
	;;作成したマッチリストの重複を削除して返す
	(remove-duplicates match-list :from-end t)

	);let match-list
  
)

;;自分の右側のブロックに潜っていく再帰関数
(def-f grid-check-match-r-horizontal (grid cell require-num test match-list)
  (grid-check-match-r grid cell nil 0 1 0 require-num test match-list)
)
;;自分の下側のブロックに潜っていく再帰関数
(def-f grid-check-match-r-vertical (grid cell require-num  test match-list)
  (grid-check-match-r grid cell nil 0 0 1 require-num test match-list)
)
;;自分の右下のブロックに潜っていく再帰関数
(def-f grid-check-match-r-slanting (grid cell require-num test match-list)
  (grid-check-match-r grid cell nil 0 1 1 require-num test match-list)
)
;;指定のブロック位置から、move-x move-yの方向に潜っていく再帰関数
;;同じ色が続かなくなった時に、マッチカウントを返す。
;;マッチカウントを返されて、それが３以上だったらそのブロックのマッチフラグを立てる

(def-f grid-check-match-r (grid cell before-cell match-count move-x move-y 
								 require-num test match-list)


  (let ((recursive-finish nil))
	(if (not (equal (cell-data cell) nil))
		(funcall test (cell-data cell))
		)
	;;前回のセルとマッチしているかチェック
	;;マッチしていなければ値を返す
	;;マッチ判定は引数のtest関数にセルのデータを渡し、返ってくるデータを使って判定
	(if (not (equal before-cell nil))
;; 		(if (equal (block-color block) (block-color before-block))
			(if (equal (funcall test (cell-data cell))
					   (funcall test (cell-data before-cell)))
				(setq match-count (+ match-count 1) );t
				(setq recursive-finish t);nil
			);if check match color
		);if check left block

  ;;次のセルへ再帰使う
  (if (equal recursive-finish nil)
  (let (next-cell)
    ;次のセルを取得
;; 	(setq next-cell (grid-get-cell-from-block grid block move-x move-y))
	(setq next-cell (grid-get-cell-from-cell grid cell move-x move-y))
	(if (and
		 (not (equal next-cell nil));;次のセルがあるかチェック
		 (not (equal (cell-data next-cell) nil));;次のセルにデータがあるか
		 )

		(setq match-count
		 (grid-check-match-r grid next-cell cell match-count move-x move-y require-num test match-list)
		 )
		 );if

	;;戻ってきたmatch-countでマッチ数をチェック
	;;３以上ならフラグ立てる
	(if (>= match-count (- require-num 1) )
;; 		(setf (block-matched block) t)
;;  		(print (grid-get-cell-from-data *grid* block))
		(vec-push match-list (cell-data cell))
		);if match count
	
	);let
  );if recursive


	;;マッチ数を返す
 	match-count
	);let recursive

)
