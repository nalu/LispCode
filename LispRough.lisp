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

(defparameter *moniter-mode* nil)
(defparameter *moniter-obj-vec* nil)


;;object-arrayを追加できる形式に変更
(defparameter *object-array* nil)
(defun init-object-array ()
	(setq *object-array* (make-array 0 :fill-pointer t :adjustable t))
)

(defun object-add (object)
  (vector-push-extend object *object-array*))
(defun gob-remove (object)
  (vec-remove-if *object-array* object)
)

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
  (init-object-array)
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
  (loop for i below (length *object-array*) do
       (let ((obj (aref *object-array* i)))
	 ;; (if (equal (label-visible obj) t)
	 ;;     (draw-label (aref *object-array* i ))
	 ;;     )
	 (if (equal (square-visible obj) t)
	     (cond 
	       ((equal (type-of obj) 'image) (draw-image obj))
	       (t (draw-label obj))
	       );cond
	     );if

	 );let
       );loop

  ; draw map
  (draw-map)
  
  (fresh-line)

  ;;moniter
  (if (equal *moniter-mode* t)
      (setq *moniter-vec (remove-if (lambda(obj)(not (square-visible obj))) *object-array*))
      );if
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
  (if (and (> *screen-h* y)  (> *screen-w* x) (<= 0 y) (<= 0 x) )

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
	    (cond 
		  ( (= x left) (map-set-char x y "| ") )
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
;; (defstruct (square (:include object)) (x 0) (y 0) (w 0) (h 0) )
(defstruct (square (:include object)) (x 0) (y 0) (w 0) (h 0) (visible t) )
(defmethod draw-square ((obj square))
  (map-set-square (square-x obj) (square-y obj)
		  (square-w obj) (square-h obj) )
)

 
;Label
;; (defstruct (label (:include square)) (text "") (visible t))
(defstruct (label (:include square)) (text "") )
(defun draw-label ( obj )
  (draw-square obj)
  (map-set-str (+ (square-x obj) 1) (+ (square-y obj) 1) (label-text obj))
)
(defun set-text ( obj text)
  (setf (label-text obj) text)
)

;Button
(defstruct (button (:include label)) (key) (call) (enable t)　(tag nil) )
;; (defun draw-button ( obj )
;;   (draw-label obj)
;; )

;Image
(defstruct (image (:include square)) (filepath) (draw-method 'draw-image))
(defun draw-image (obj)
  (draw-square obj)
  (map-set-str (+ (square-x obj) 1) (+ (square-y obj) 1) (image-filepath obj))
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

(defun new-image (x y w h filepath )
  (let (obj)
    (setq obj (make-image :x x :y y :w w :h h :filepath filepath ))
    (object-add obj)
    obj)
)



;defunの代用を作成
;このメソッドで関数定義しておけば、*def-f-arary*に内容が保管され、コンバート可能になる。
;リードマクロは展開された後保存される
(defmacro def-f (name args &body body) 
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

















;--------------------------------- MULTIPLE GOB ---------------------------------

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

	;;アップデートコールバックがnilならデフォルト関数をセット
	(if (not callback-update-cell)
		(setq callback-update-cell #'grid-default-callback-update-cell))

	;;セルデータ作成コールバックが無ければデフォルト関数をセット
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
			  );make cell
			 );setq


		   ;;セルのボタンを作成
		   ;;ボタンはデフォルトで確実に作成する
		   ;;作成後、ユーザー指定のコールバックでオブジェクトを作成する
		   (setq button
				  (funcall 
				   #'grid-default-callback-make-cell-obj
				   cell-obj-x
				   cell-obj-y
				   cell-w
				   cell-h
				   i
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
(defun grid-default-callback-make-cell-obj ( x y w h index )

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


;; ;;グリッドのボタン群のうちテキスト内容がox以外の配列を抽出。
;; (defun get-empty-cell-array (cell-array)
;;   (remove-if 
;; 	 #'(lambda (cell) 
;; 		 (if (or ( equal (button-text (cell-obj cell)) "o" ) 
;; 				 ( equal (button-text (cell-obj cell)) "x"))
;; 			 t
;; 			 nil)
;; 		 ) cell-array)
	
;; )

;;汎用的に使えるように作り直し。
;;グリッドのデータが空セルの配列を作成する
(defun get-empty-cell-array (cell-array)
  (remove-if 
	 #'(lambda (cell) 
		 (if (equal (cell-data cell) nil)
			 nil
			 t)
		 ) cell-array)
	
)



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
(defun grid-random-get-empty-cell (grid )
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
		 (setq empty-cell (grid-random-get-empty grid))
		 (set-text empty-cell "x")
		 )
	)
	
)



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
					   (grid-check-match-r-horizontal grid cell 
													  require-num test match-list))
				   (if (equal vertical t)
					   (grid-check-match-r-vertical grid cell 
													require-num test match-list))
				   (if (equal slanting t)
					   (grid-check-match-r-slanting grid cell 
													require-num test match-list))
				  )
				  );cond
				
				);let
			  
			  
			  );loop x
		 );loop y
	
	;;作成したマッチリストの重複を削除して返す
	(remove-duplicates match-list :from-end t)
	(print match-list)

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
			(if (and
				 (equal (funcall test (cell-data cell)) t)
				 (equal (funcall test (cell-data before-cell)) t)
				 )
				(setq match-count (+ match-count 1) );t
				(setq recursive-finish t);nil
			);if check match color
		);if check left block

  ;;次のセルへ再帰使う
  (if (equal recursive-finish nil)
  (let (next-cell)
    ;次のセルを取得
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
		(vec-push match-list (cell-data cell))
		);if match count
	
	);let
  );if recursive


	;;マッチ数を返す
 	match-count
	);let recursive

)

;;MGOB パラメータクラス
(defstruct (parameter)
  value
  default
  min
  max
  add
)
(defun new-parameter (default min max)
  (make-parameter
   :value default
   :default default
   :min min
   :max max
   )
)
(defun parameter-add (param val)
  (+= @param.value val)
  (if (> @param.value @param.max)
	  (setf @param.value @param.max)
	  )
  (if (< @param.value @param.min)
	  (setf @param.value @param.min)
	  )
  param
)
(defun parameter-reset (param)
  (setf @param.value @param.default)
)

;;MGOB Guage
;:nccessary parameter class
(defstruct (guage)
  title
  parameter
  label
)
(defun new-guage( x y w h title parameter )
  (let (guage-obj)
    (setq guage-obj 
	  (make-guage
	   :title title
	   :parameter parameter
	   :label (new-label x y w h title)
	   ))
    (guage-update guage-obj)
    guage-obj
    )
)
(defun guage-update (guage)
  (setf @guage.label.text
   (format nil "~a:~V@{~A~:*~}" @guage.title @guage.parameter.value "*")
   )
)

;;MGOB タイトルクラス
(defstruct (title (:include object)) 
  title-label
  start-button
  start-callback
  )
(defun new-title ( title-name start-callback )

  (let (
		title-label-w 
		title-label-h
		title-label-x
		title-label-y
		title-label
	    start-button
		r-title
		)

	(setq title-label-w 10)
	(setq title-label-h 3)
	(setq title-label-x (truncate (- (/ *screen-w* 2) (/ title-label-w 2))))
	(setq title-label-y (truncate (- (/ *screen-h* 2) (/ title-label-h 2))))


	(setq title-label
		  (new-label 
		   title-label-x
		   title-label-y
		   title-label-w
		   title-label-h
		   title-name)
		  );set label

	(setq start-button
		  (new-button 
		   (+ title-label-x 2)
		   (+ title-label-y 5)
		   6
		   3
		   "[S]tart"
		   's
		   #'start-callback-default
		   )
		  )

	(setq r-title
		  (make-title
		   :title-label title-label
		   :start-button start-button
		   :start-callback start-callback
		   ))

	(setf (button-tag start-button) r-title)

	r-title

	);let
)
;;スタート押下時デフォルト関数
;;タイトルラベルやボタンのUIを隠すだけにしているので、
;;removeする処理を加える必要があるが未実装
(defun start-callback-default(button)
  (let (title-obj)
	(setq title-obj (button-tag button))
	(setf (label-visible (title-title-label title-obj)) nil);;title hidden
	(setf (button-visible (title-start-button title-obj)) nil);;start hidden
	(label-visible (title-title-label title-obj) )
	(funcall (title-start-callback title-obj))
	)
)

;;メニュークラス
;;グリッドの派生
;;選択サポート付き
;;通常時、選択時で状態を変える
;;
(defstruct (menu (:include grid)) (marker nil) )

;; (defun new-menu (x y w-cell-num h-cell-num cell-w cell-h 
;; 				 callback-make-cell-obj
;; 				 callback-make-cell-data
;; 				 callback-update-cell
;; 				 key
;; 				 callback-push-cell
;; 				 )


;;レースクラス
;;レースゲームのマップとそのオブジェクト表示管理
(defstruct (race (:include label)) x y w h minimap curse-length minimap-player-obj 
		   player-position 
		   event-vec
		   enemy-vec
		   curse-square-left
		   curse-square-right
		   curse-line-left-x
		   curse-line-right-x
		   )
(defstruct (minimap (:include label)) x y w h)
(defstruct (race-event  (:include object) )
			 start-pos
			 end-pos
			 type
			 x-pos
			 finish
			 )

(defun new-race ( x y w h minimap-x minimap-y minimap-w minimap-h curse-length )


  (new-label minimap-x minimap-y minimap-w minimap-h "")
  (new-label minimap-x minimap-y 3 3 "G")
  (new-label minimap-x (+ minimap-y minimap-h) 3 3 "S")
  (new-label x y w h "")


  (let (minimap race label-minimap-player)

	(setq label-minimap-player (new-label minimap-x (+ minimap-y minimap-h) 3 3 "p"))


	(setq minimap (make-minimap :x minimap-x :y minimap-y :w minimap-w :h minimap-h))


	(setq race
		  (make-race :x x :y y :w w :h h
			   :minimap
			   minimap
			   :curse-length
			   curse-length
			   :minimap-player-obj
			   label-minimap-player
			   :player-position
			   0
			   :event-vec
			   (new-vec)
			   :enemy-vec
			   (new-vec)
			   :curse-square-left
			   (new-square (+ x 2) y 1 h)
			   :curse-square-right
			   (new-square (- (+ x w) 3) y 1 h)
			   :curse-line-left-x 
			   0
			   :curse-line-right-x
			   w
			   )
		  )


	(race-init race)

	race
	);let

)

;;レース状態初期化
(defun race-init(race)
  (setf (race-player-position race) 0)
  (race-clear-all-event race)
  (race-update-curse race)
  (race-update-minimap race)
)

;;レース進行
(defun race-forward (race forward-m)


	;;位置更新
	(+= (race-player-position race) forward-m)
	(if (> (race-player-position race) (race-curse-length race))
		(setf (race-player-position race) (race-curse-length race))
		)
	
	;;位置イベント処理
	(race-update-curse race)


	;;ミニマップ更新
	(race-update-minimap race)
	
)


;;コース状態更新
(defun race-update-curse (race)

  (let (recent-event-number recent-event target-square)
	;;コース
	(setq recent-event-number (race-get-recent-event-number race))
	;;イベントが無ければ更新しない
	(if (equal recent-event-number nil) (return-from race-update-curse) )

	(setq recent-event (elt (race-event-vec race) recent-event-number) )


	;;未処理のイベントが後方にある場合はそのイベントでマップを作る
	;;前方にある場合はまだ処理しない
	(if (< (race-event-start-pos recent-event) (race-player-position race))
		t
		(return-from race-update-curse)
		)

	;;未処理のイベントが前方にある場合は後方の消化済みのイベントを処理する
	;;未処理のイベントが画面内にある場合は両方のイベントを使用する

	;;ライン引き（矩形で表現）
	;;暫定的に後方イベントだけ処理

	(if (equal (race-event-type recent-event) 'left-line)
		(race-event-set-left-line race recent-event))
	(if (equal (race-event-type recent-event) 'right-line)
		(race-event-set-right-line race recent-event))
	(if (equal (race-event-type recent-event) 'enemy-yellow)
		(race-event-appear-enemy race recent-event))

	;;イベントフラグ
	(setf (race-event-finish recent-event) t)

	;;再帰で同時時間の発生イベントを処理
	(race-update-curse race)

  );let

)

(defun race-event-set-left-line (race event)
  (setf (race-curse-line-left-x race) (race-event-x-pos event))
  (race-event-set-line race event (race-curse-square-right race))
)

(defun race-event-set-right-line (race event)
  (setf (race-curse-line-right-x race)  (race-event-x-pos event))
  (race-event-set-line race event (race-curse-square-left race))
)

(defun race-event-set-line (race event square)
  (setf (square-x square ) 
		(+ (label-x race) (race-event-x-pos event)))
  
)

;;イベント：敵出現
(defun race-event-appear-enemy (race event)
  (let (enemy-vec)
	(setq enemy-vec (race-enemy-vec race))
	(vec-push enemy-vec 
			   (new-label (+ (label-x race) (race-event-x-pos event))
						  (label-y race)
						  3 3 "e"))
	);let
)

;;ミニマップ更新
(defun race-update-minimap (race)
  (let (player minimap)
		(setq player (race-minimap-player-obj race))
		(setq minimap (race-minimap race))
		(setf (label-y player)
			  (+ (label-y minimap)
			  (truncate
			   (- (label-h minimap)
				  (*
				   (/ (race-player-position race) (race-curse-length race))
				   (label-h minimap)))
			   );truncate
			  ));setf
		);let
)

;;コースイベント設定
;;カーブの開始、直線コースなど、イベントを数回セットすることでコース表現をする
(defun race-add-event ( race start end type x)
  (let (event-vec)
	(setq event-vec (race-event-vec race) )
	(vec-push event-vec
			  (make-race-event
			   :start-pos start
			   :end-pos end
			   :type type
			   :x-pos x
			   ))
	);let
)

(defun race-clear-all-event (race)
  (setf (race-event-vec race) (new-vec))
)

;;未処理の最初のイベントの番号を返す
(defun race-get-recent-event-number (race)

  (let (vec event number)
	(setq vec (race-event-vec race) )

	(for (i 0 (length vec))
	  (setq event (vec-get vec i))
	  (setq number i)
	  (if (not (race-event-finish event))
		  (return-from race-get-recent-event-number i)
		  );if
	  );for

;;     number

	nil
	);let

)




;;SHOOTINGクラス
;;STGのオブジェクトと敵の配置管理
(defstruct (shooting (:include object)) 
  x y w h  
  vec-obj
  )

(defstruct (shooting-obj(:include object))
  x y w h 
  type
  speed
  angle 
  label
  hp 
  no-damage ;;ダメージを受けない
  atack-body ;;衝突の際にダメージを与える
  dead-effect ;;死亡エフェクトフラグ
)


;; (defstruct (race-event  (:include object) )
;; 			 start-pos
;; 			 end-pos
;; 			 type
;; 			 x-pos
;; 			 finish
;; 			 )

(defun new-shooting ( x y w h )

  (let (r-shooting vec-obj)
	(setq vec-obj (new-vec))
	(setq r-shooting 
		  (make-shooting
		   :x x
		   :y y 
		   :w w 
		   :h h
		   :vec-obj vec-obj
		   )
		  )



	r-shooting

	);let

)

(defun new-shooting-obj (shooting x y w h type speed angle obj-str)
  (let (r-obj)


	(setq r-obj
		  (make-shooting-obj 
		   :x x
		   :y y
		   :w w
		   :h h
		   :type type
		   :label (new-label x y w h obj-str)
		   :speed speed
		   :angle angle
		   :hp 1
		   :no-damage nil
		   :atack-body nil
		   :dead-effect nil
		   )
		  )

		  (vec-push @shooting.vec-obj r-obj)

		  r-obj 
	)

)



(defun shooting-move-obj (shooting obj x y)
  (+= @obj.x x)
  (+= @obj.y y)
  (setf @obj.label.x @obj.x)
  (setf @obj.label.y @obj.y)
)

(defun radian-to-x ( angle )
  (cos (* (/ angle 180) pi))
)
(defun radian-to-y ( angle )
  (cos (* (/ angle 180) pi))
)

(defun shooting-forward (shooting)
  ;;位置更新
  (for (i 0 (length @shooting.vec-obj))
	(let (obj)
	  (setq obj (vec-get @shooting.vec-obj i))
	  (shooting-move-obj shooting
			     obj 
			     (get-move-x-rad @obj.angle @obj.speed)
			     (get-move-y-rad @obj.angle @obj.speed))
	  (vec-set @shooting.vec-obj i obj)
	  );let
	);for
)

(defun get-move-x-rad (rad speed)
  ;; (* (cos (* (/ rad 180) pi) ) speed)

  ;;精度コントロール
  (let (r-x)
   (setq r-x (* (cos (* (/ rad 180) pi) ) speed))
   (setq r-x (truncate r-x 1.0000))
   r-x
   )
)

(defun get-move-y-rad (rad speed)

  (let (r-y)
    (setq r-y (* (sin (* (/ rad 180) pi) ) speed))
    (setq r-y (truncate r-y 1.0000))
    r-y
    )
)

;;指定のタイプのオブジェクト同士の衝突をチェックし、ダメージ処理を行なう
;;このメソッドでは衝突した双方にダメージを与える
(defun damage-conflict-object ( shooting type1 type2 )
  
  (let (vec1 vec2 obj1 obj2)
	(setq vec1 (shooting-get-vec-object shooting type1))
	(setq vec2 (shooting-get-vec-object shooting type2))

	(for (i 0 (length vec1))
	  (for (j 0 (length vec2))
		(setq obj1 (vec-get vec1 i))
		(setq obj2 (vec-get vec2 j))
		(cond 
		  ((hitcheck-rect-in-rect 
			@obj1.x @obj1.y @obj1.w @obj1.h
			@obj2.x @obj2.y @obj2.w @obj2.h)
		   (-= @obj1.hp 1)
		   (-= @obj2.hp 1)
		   )
		  );cond
		
		));for

	);let
)

;;指定のタイプのオブジェクト配列を取得
(defun shooting-get-vec-object ( shooting type )
  (remove-if #'(lambda (obj) (not (equal @obj.type type))) @shooting.vec-obj)
)

;;指定のオブジェクトをリストから除外、UIも削除する
(defun shooting-remove-obj (shooting obj)
  (gob-remove @obj.label)
  (vec-remove-if @shooting.vec-obj obj)
)


