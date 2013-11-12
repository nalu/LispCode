#|
Lisp Rough は、lispのREPLを使ってアプリケーションの開発を迅速にするライブラリ
絵を書く際のラフのように、素早く、雑だけど全容が把握できるような状態を目指している。


|#


(ql:quickload :cl-ppcre);文字列ライブラリ
(load "c:/Lisp/LispCode/util.lisp")


;--------------------------------- SYSTEM ---------------------------------
(defparameter *cui-cell-width-character* 2) ;ＣＵＩで１マスを表現するための文字数

(defparameter *quit* 0)


(defparameter *default-screen-w* 28)
(defparameter *default-screen-h* 24)

(defparameter *screen_w* 28)
(defparameter *screen_h* 24)
(defparameter *screen-map* (make-array (* *screen_w* *screen_h*)))
(defparameter *object-array* nil)
;(defparameter *object-array* nil)
(defparameter *object-num* 0);配列をやめて、追加ができるリストを採用するのが望ましい

;メソッド変換用(alistにしたい
(defparameter *def-f-array* (make-array 0 :fill-pointer t :adjustable t))
(defun def-f-add (method)
    (vector-push-extend method *def-f-array*)
)
(defparameter *def-v-array* (make-array 0 :fill-pointer t :adjustable t))
(defun def-v-add (variable)
  (vector-push-extend variable *def-v-array*)
)


(defun lr-begin ( &optional (screen-w *default-screen-w*) (screen-h *default-screen-h*) ) 
  (setq *quit* 0)
  (setq *object-array* (make-array 100))
  (setq *screen_w* screen-w )
  (setq *screen_h* screen-h)
  (setq *screen-map* (make-array (* *screen_w* *screen_h*)))
  (setq *object-num* 0)
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
    (loop for i below *object-num* do
   
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
  (map-set-square 0 0 *screen_w* *screen_h*)


  ;Object - draw
  (loop for i below *object-num* do
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
  (loop for y below *screen_h* do 
       ( progn (fresh-line)
	       (loop for x below *screen_w* do 
		    ( 
		     princ (aref *screen-map* (+ (* y *screen_w*) x ) )
			   )
    )))
)


;文字をマップにセット
;*cui-cell-width-character*の文字数を越えた分はカットされる
;format-numには半角なら１、全角なら２
;マップ範囲外の位置を指定すると何もセットしない
(defun map-set-char ( x y char &optional (one-character-cell-num 1) ) 
  (if (and (> *screen_h* y)  (> *screen_w* x))

    (let (cut-char f-char)
      (setq f-char (format nil "~~~da" one-character-cell-num))
      (setq cut-char (format nil f-char char))    
      (setf (aref *screen-map* (+ (* *screen_w* y) x))  cut-char)
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
   (loop for y below *screen_h* do 
	(loop for x below *screen_w* do 
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


;Object

(defun add-object ( obj )
  (setf (aref *object-array* *object-num*) obj)
  (setq *object-num* (+ *object-num* 1))
)

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
(defun call-button ( obj )
  (funcall (button-call obj))
)
(defun enable-button (obj enable)
  (setf (button-enable obj) enable)
  )
(defun visible-button (obj visible)
  (setf (button-visible obj) visible)
)

(defun new-label ( x y w h title )
  (let (obj)
	(setq obj (make-label :x x :y y :w w :h h :text title))
	(add-object obj)
	obj
	)
)

(defun new-button ( x y w h title key call )
  (let (obj)
    (setq obj (make-button :x x :y y :w w :h h :text title :key key :call call))
	(add-object obj)
	obj)
)

;new Button(gm, 0,1,"str", new Callback( multitype_func<hilow, &hilow::push_low>, this));)
(defun new-button-cpp ( x y w h title key call)
  (format nil 
		  "new Button(gm, ~d, ~d, \"~a\"\, new Callback( multitype_func<~a, &~a::~a>, this));  " 
		  x y title *game-name* *game-name* call)
)

;--------------------------------- CODE MAKER ---------------------------------

(defparameter *game-name* 0)
(defparameter *game-filename* 0)

#|
コード生成部
Lisp Rough対応コードを解析して別言語のコードを生成する
設計ができていないが運用テストも込で仮実装する
|#
(defun make-code-win( filename save-str )
  
  (with-open-file 
      (my-stream filename 
		 :direction :output 
		 :if-exists :supersede ;overwrite
		 )
    (print save-str)
    (format my-stream save-str)
    )
)

;ファイルをロードして、その文字列を返す
(defun load-seed-code( filename )
  (load-file-str filename)
)

(defun load-file-str( filename )
  (let (loadstr)
    (with-open-file (my-stream filename :direction :input )
      (loop 
	 (let ((line (read-line my-stream nil 'eof)))
	   (if (eql line 'eof) (return))
;	   (print line)
	   (setq loadstr (concatenate 'string loadstr line))
	   )))
    
    loadstr
    ) 
)

(defun generate-source (seed-filename game-filename game-name generate-filename )
  (let ((loadstr (load-seed-code seed-filename)))
    (setq loadstr (change-token loadstr game-filename game-name));トークン変換
    (setq loadstr (escape-childa-all loadstr)) ; escape childa
	(setq loadstr (convert-return-all-crlf loadstr)) ; 改行コード揃え（全newlineをreturnへ）
	(create-directory (format nil "./generate-~a/" game-name));
    (make-code-win (format nil "./generate-~a/~a" game-name generate-filename) loadstr)
    )
  
)

(defun replace-string (target-str from-str to-str)
  (cl-ppcre:regex-replace from-str target-str to-str)
)

(defun replace-string-all (target-str from-str to-str)
  (cl-ppcre:regex-replace-all from-str target-str to-str)
)

;シードコード内のトークンに適切な値を埋め込み。
;現状ではタイトル、変数宣言、関数定義の３つ
(defun change-token (source game-filename game-name)
  ;タイトル
  (setq source (cl-ppcre:regex-replace-all "<@lisp-rough-title>" source game-name))
  ;変数宣言
  (setq source (cl-ppcre:regex-replace "<@lisp-rough-variable-declar>" source (make-variable-str game-filename) ))
  ;変数初期化
  (setq source (cl-ppcre:regex-replace "<@lisp-rough-variable-initialize>" 
									   source (make-variable-initialize-str game-filename) ))
  ;関数宣言
  (setq source (cl-ppcre:regex-replace "<@lisp-rough-method-declar>" source (make-method-declar-str game-filename)))
  ;関数定義
  (setq source (cl-ppcre:regex-replace "<@lisp-rough-method-define>" source (make-method-define-str game-filename game-name)))
)


;; (defun change-token (source)
;;   ;タイトル
;;   (setq source (cl-ppcre:regex-replace-all "<@lisp-rough-title>" source *game-name*))
;;   ;変数宣言
;;   (setq source (cl-ppcre:regex-replace "<@lisp-rough-variable-declar>" source (make-variable-str *game-filename*) ))
;;   ;変数初期化
;;   (setq source (cl-ppcre:regex-replace "<@lisp-rough-variable-initialize>" 
;; 									   source (make-variable-initialize-str *game-filename*) ))
;;   ;関数宣言
;;   (setq source (cl-ppcre:regex-replace "<@lisp-rough-method-declar>" source (make-method-declar-str *game-filename*)))
;;   ;関数定義
;;   (setq source (cl-ppcre:regex-replace "<@lisp-rough-method-define>" source (make-method-define-str *game-filename* *game-name*)))
;; )


;escape-all-childaにして、全部置換しよう。
;replaceの第二匹数を、multiple-value-bind (x y)してゲット。nilがでるまで繰り返せばいい
;と思ったが、チルダをダブルチルダにしているので、無限ループする
;ダブルチルダは省いて処理したいが、そもそも、文字列中のチルダをエスケープするメソッドはないかな
(defun escape-childa-all (str)
 (cl-ppcre:regex-replace-all "~" str "~~") 
 
)


;指定ゲームソースファイルの変数宣言を全て抽出し、C++の変数宣言部のソース文字列を作成
(defun make-variable-str ( filename )
  (load filename)
  ( concat-string-delimita 
	(map 'list #'convert-v-declar *def-v-array*)
	#\newline)
)

;指定ゲームソースファイルの変数初期化文字列を作成する
(defun make-variable-initialize-str ( filename )
  (load filename)
  ( concat-string-delimita
	(map 'list #'convert-v-initialize *def-v-array*)
	#\newline)
)

;関数宣言の文字列をファイルパスから作成
(defun make-method-declar-str (filename)
  (load filename)
  (concat-string-delimita
   (map 'list #'convert-f-declar *def-f-array*)
   #\newline)
)

(defun make-method-define-str (filename game-name)
  (load filename)

  (let (source-str)
	(setq source-str 
		  ( concat-string-delimita 
			(map 'list (lambda (gname obj) (convert-f-define gname obj)) 
				 (make-list (length *def-f-array*) :initial-element game-name);map内に同じ値を渡したいので、*def-f-array*と同じサイズで同じ内容のリストを渡す(name name name)
				 *def-f-array* )
			#\newline)
		  )

	;入れ子の処理したくて整形関数つくったが、
	;この関数はインデントするもののそれだけじゃ汚すぎるので使わん
	(body-source-formatter source-str 0)
	)
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
(defun enum (values)
  (loop for i below (length values) do
	   (eval (read-from-string (format nil "(setq ~a ~d)" (elt values i) i ))))
)

(defparameter *test-soruce*
 "  (((SETQ *A-CARD* (GET-CARD-RANDOM-NUMBER)) (VISIBLE-BUTTON *BUTTON-HIGH* NIL) (VISIBLE-BUTTON *BUTTON-LOW* NIL) (VISIBLE-BUTTON *BUTTON-RETRY* T) (LET (HIGHLOW) (SETQ HIGHLOW (CHECK-HIGHLOW *A-CARD* *B-CARD*)) (COND ((EQUAL HIGHLOW 'DRAW) (SET-TEXT *MESSAGE-LABEL* open >>>>>> DRAW)) ((EQUAL HIGHLOW *SELECT*) (SET-TEXT *MESSAGE-LABEL* open >>>>>> WIN!!) (WIN)) (T (SET-TEXT *MESSAGE-LABEL* open >>>>>> LOSE..) (LOSE)))) (SET-TEXT *CARD-A-OBJ* *A-CARD*)))"
)

;x文字単位で改行を埋め込む
(defun body-source-formatter (source-str one-line-cha-num)  
;  (let (r-str)
    ;閉じ括弧に改行を追加
;    (setq r-str (format nil (replace-string-all source-str "\\)" ")~%") ""))
    ;行頭には、入れ子のレベルに応じてスペースを追加
;    ((replace-string-all ")~%" 
	(source-format source-str)
   
;    )
)



(defparameter *t4* "((LET (VAL) (COND ((= OPEN_N HIDE_N) (SETQ VAL 'DRAW)) ((< OPEN_N HIDE_N) (SETQ VAL 'LOW)) ((> OPEN_N HIDE_N) (SETQ VAL 'HIGH))) VAL))")


#|
test
１．受け取った文字列の後ろから探して、最初に発見した開き括弧を対象とする
２．全文字を見て、その位置の開き括弧の入れ子レベルを取得
３．入れ子レベルに応じて、開き括弧の前にスペースを挿入（この時についでに改行を挿入すればいい）
４．その文字より前の文字列を渡して自分を再帰呼び出し
５．文字が無くなったら終了

|#

;last test
(defun source-format ( source )
  (concat-string 
   (map 'list
       #'(lambda (x pos) 
	   ;mapで閉じ括弧にのみ改行とスペース。全て文字列化
	   (if (equal #\) x ) 
	       (format nil ")~%~a" (get-nest-level-space source pos ) )
	       (format nil "~a" x) 
	       ))
       source
	   (slist 0 (length source));連番リストを作って、ポジション判定に利用
       )
  )
  
)



;入れ子レベルの取得
;括弧がペアになっていなければ、-1を返す
;エスケープ非対応
;正常に処理できれば、０以上のネストレベルを返す
(defun get-nest-level (str pos)
  (if (eql (- (count #\( str) (count #\) str) ) 0 )
      ;括弧がペア
      (-  (count #\( (subseq str 0 pos)) (count #\) (subseq str 0 pos)))
      ;ペアではない
      -1
   )
)

;ネストレベル分のスペース文字列を返す
(defun get-nest-level-space (str pos)
   (format nil (format nil "~~~da" (get-nest-level str pos) ) "")
)


;C++用のコードを生成
;lispのゲームファイルパスと、ゲームのタイトルを入力して実行する
(defun generate-cpp ( game-filename game-title )
  (generate-source "c:/Lisp/LispCode/seed-code/win/seed-win-main.cpp" game-filename game-title "main.cpp")
  (generate-source "c:/Lisp/LispCode/seed-code/win/seed-win-game.h" game-filename game-title (format nil "~a.h" game-title))
)

;hi_lowを生成
(defun generate-hilow()
  (generate-cpp "c:/Lisp/LispCode/hi_low.lisp" "hilow")
  
)

;jankを生成
(defun generate-jank()
  (generate-cpp "c:/Lisp/LispCode/jank.lisp" "jank")
)


;error
;; (defun test-kaigyo ()
;;   (make-code-win "./test.h" (load-file-str "c:/Lisp/LispCode/seed-code/win/seed-win-game.h"))  )


;改行コードをすべてCRLF( return + newline) に揃えた文字列を返す
;windowsはCRLFなので重用
(defun convert-return-all-CRLF (str)
  ;最初からある全てのCRLF(return+newline)をnewlinにそろえて退避
  (setq str (replace-string-all str (format nil "~a~a" #\return #\newline) #\newline))
  ;全ての単独return改行をnewlineに揃える
  (setq str (replace-string-all str #\return (format nil "~a" #\newline)))
  ;その後全部CRLFへ
  (setq str (replace-string-all str #\newline (format nil "~a~a" #\return #\newline)))
  str
)


;--------------------------------- Convert C++  ---------------------------------

;変数名、初期値からなるdef-vで定義された値を、C++のクラス宣言部用にコンバートする
(defun convert-v-declar ( def-v-obj )
;  *def-v-array*
  (let (type-str var-name)
    ;これでシンボルのタイプを出せる。実際にコードが実行済みの必要があるが、def-vは実行時にデータを配列にいれるので問題ない
	(setq type-str 
		  (convert-typename-lisp-to-cpp
		   (type-of (eval (car def-v-obj)))) )
	(setq var-name (car def-v-obj))

    ;C++はハイフン使えないのでアンダーバーに変換
	;あとで関数にかえる
	(setq var-name (convert-syntax-symbol-lisp-to-cpp var-name))
;; 	(setq var-name (format nil "~a" var-name) )
;; 	(setq var-name (replace-string-all  var-name "-" "_"))

	(format nil "~a ~a;" type-str var-name); Label testlabel; のような宣言文字列を出力
  )
)

;変数名、初期値からなるdef-vで定義された値から初期化コードにコンバートする
;new のあとをコンバートできてない。コンストラクタを同対応させるかの仕様が必要。
(defun convert-v-initialize ( def-v-obj )
  (format nil "this->~a = ~a;" 
		  (convert-syntax-symbol-lisp-to-cpp (car def-v-obj)) ;変数名
 		  (cpp-new-method (cadr def-v-obj)) ;初期化コードは次回バージョンでこうやる
;		  (cadr def-v-obj);初期化コード
		  )
)

;次回バージョンで実装予定。
;CPP用初期化コードを生成する。クラスタイプから生成
;new Button(gm, 0,1,"str", new Callback( multitype_func<hilow, &hilow::push_low>, this));)
;というコード。
(defun cpp-new-method (initialize-code)

  ;リストでなければそのまま返す
  ;リストであれば先頭の１つが関数名なので、それをコンバートして実行
  (if (equal 'CONS (type-of initialize-code))
	  (cond
		;new-button > new-button-cpp
		((equal (car initialize-code) 'new-button) 
		 (setf (elt initialize-code 0) 'new-button-cpp)
		 (eval initialize-code))
	 
		
		( t initialize-code)
		)

	  ;not if
	  initialize-code
  )
)

;関数名をクラス宣言部用にコンバート
(defun convert-f-declar ( def-f-obj )
  (format nil "void ~a(~a);"
		  (convert-syntax-symbol-lisp-to-cpp  (car def-f-obj)) ;関数名
		  (convert-syntax-symbol-lisp-to-cpp
		   (convert-parameter-list-to-string (cadr def-f-obj))
		   );引数
		  )
)

;関数名をクラス定義部用にコンバート
(defun convert-f-define ( class-name def-f-obj )
  (let (func-name param-name body-source )
	(setq func-name (car def-f-obj))
	(setq param-name (cadr def-f-obj))
	(setq body-source (cddr def-f-obj))

	;C++構文ルールように変換
	(setq func-name (convert-syntax-symbol-lisp-to-cpp func-name))
	(setq param-name
		  (convert-syntax-symbol-lisp-to-cpp
		   (convert-parameter-list-to-string
			param-name)))


	(format nil "void ~a::~a(~a)~%{~%/*~%~a~%*/~%}~%" 
			class-name
			func-name ;関数名
			param-name;引数
			body-source);本体
	)
)

;パラメータのリストをカンマ区切りの文字列に変換
(defun convert-parameter-list-to-string (parameters-list)  
  (concat-list-string
   (map 'list (lambda (x) (format nil "int ~a "  x)) parameters-list)) 
  
)

;関数名、変数名をC++で使えるようにシンタックス適応させる
(defun convert-syntax-symbol-lisp-to-cpp (target)
  (print target)
  (setq target ( format nil "~a" target))
  (setq target (replace-string-all target "-" "_"));ハイフンをアンダーバーに
  (setq target (replace-string-all target "\\*" ""));アスタリスクを削除（エスケープしつつ）
  (setq target (string-downcase target));小文字化
  target
  )


;特定のタイプ名をC++用のクラス名に対応するように変換
(defun convert-typename-lisp-to-cpp (target)
  (setq target ( format nil "~a" target))
  
  (setq target (replace-string-all target "LABEL" "Label*"))
  (setq target (replace-string-all target "BUTTON" "Button*"))
  (setq target (replace-string-all target ".*INTEGER.*" "int"))
  (setq target (replace-string-all target ".*STRING.*" "string"))
  (setq target (replace-string-all target ".*VECTOR.*" "vector<int>"))

  target
)


