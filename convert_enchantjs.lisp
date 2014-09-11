;--------------------------------- Convert enchant JS  ---------------------------------

(defparameter *ui-scale* 10 )

;変数名、初期値からなるdef-vで定義された値を、C++のクラス宣言部用にコンバートする
(defun convert-v-declar ( def-v-obj )

  (let (type-str var-name)
;;     ;これでシンボルのタイプを出せる。実際にコードが実行済みの必要があるが、
;; 	;def-vは実行時にデータを配列にいれるので問題ない
;; 	(setq type-str 
;; 		  (convert-typename
;; 		   (type-of (eval (car def-v-obj)))) )

	;;jsは型名無いので全部var にする
	(setq type-str "var")

	(setq var-name (car def-v-obj))


    ;ハイフン＞アンダーバーに変換
	(setq var-name (convert-syntax-symbol var-name))

	(format nil "~a ~a;" type-str var-name); Label testlabel; のような宣言文字列を出力
	)
)

;変数名、初期値からなるdef-vで定義された値から初期化コードにコンバートする
;new のあとをコンバートできてない。コンストラクタを同対応させるかの仕様が必要。
(defun convert-v-initialize ( def-v-obj )
  (format nil "this.~a = ~a;" 
		  (convert-syntax-symbol (car def-v-obj)) ;変数名
 		  (convert-new-method (cadr def-v-obj)) ;初期化コードは次回バージョンでこうやる
;		  (cadr def-v-obj);初期化コード
		  )
)


(defparameter *new-method-alist*
	  '(
		( new-button . convert-new-button  )
		( new-label . convert-new-label )
		( new-vec . convert-new-vec )
		( new-parameter . convert-new-parameter)
		( new-guage . convert-new-guage)
		)
	  )
(defparameter *init-value-convert-alist*
  '(
	( (SIMPLE-BASE-STRING 0) . "\"\"a")
	)
)


;;タイプ名を返す。タイプ名がSYMBOLでもCONSでも一律先頭のタイプ名だけを返す
;; (defun type-name (value)
;;   (let (type)
;; 	(setq type (type-of value))
;; 	(if (equal type 'CONS)
;; 		(setq type (car type))
;; 		);if
;; 	type
;; 	);let
;; )
(defun type-name (value)

  (if (consp (type-of value))
	  (car (type-of value))
	  (type-of value)
	  )
)

;;初期化コードコンバート用newメソッドの変換
(defun convert-new-method (initialize-code)

  ;リストでなければそのまま返す
  ;リストであれば先頭の１つが関数名なので、それをコンバートして実行
  ;リストで無ければ値なので、その値のタイプを判別して初期化コードを実行する

  (if (equal 'CONS (type-of initialize-code))
	  (cond
		((setf
		 (elt initialize-code 0)
		 (cdr (assoc (car initialize-code) *new-method-alist*))
		 )
		(eval initialize-code))
	 
		( t initialize-code)
		);cond

	  ;not if cons
	  (let (value)
		(setq value (cdr (assoc (type-name initialize-code) *init-value-convert-alist*)))
		(if (equal (type-name initialize-code) 'SIMPLE-BASE-STRING)
			(setq value "\"\"")
			(setq value initialize-code))
		value
		);let
	  
  )


)

;;new-buttonを対象環境用にコンバート
(defun convert-new-button ( x y w h title key call)
  (format nil 
		  "new Button( ~d, ~d, ~d, ~d, \"~a\"\, '~a', this.~a, color_button_default)" 

		  (* x *ui-scale*)
		  (* y *ui-scale*)
		  (* w *ui-scale*)
		  (* h *ui-scale*)
		  title key 
		  (convert-syntax-symbol (function-name call)))
)

;;new-labelを対象環境用にコンバート
;; ;ex :
;;	var makeLabel = function( x, y, w, h, title, color, font)
(defun convert-new-label ( x y w h title)
  (format nil 
		  "makeLabel(~d, ~d, ~d, ~d,  \"~a\"\, \"#ffffff\", \"20px Palatino\" )" 
		  (* x *ui-scale*)
		  (* y *ui-scale*)
		  (* w *ui-scale*)
		  (* h *ui-scale*)
		  title 
		  )
)

;;new-vecを対象環境用にコンバート
;; ;ex :
;;	var makeLabel = function( x, y, w, h, title, color, font)
(defun convert-new-vec (num )
  (format nil 
		  "[]" 		  )
)

(defun convert-new-parameter (default min max)
  (format nil "new Parameter( ~d ~d ~d)" default min max)
)

(defun convert-new-guage ( x y w h title parameter )
  (format nil "new Guage( ~d ~d ~d ~d ~a ~a)" x y w h title parameter)
)


;関数名をクラス宣言部用にコンバート
(defun convert-f-declar ( def-f-obj )
  (format nil "void ~a(~a);"
		  (convert-syntax-symbol  (car def-f-obj)) ;関数名
		  (convert-syntax-symbol
		   (convert-parameter-list-to-string (cadr def-f-obj))
		   );引数
		  )
)

;関数本体をクラス定義部用にコンバート
(defun convert-f-define ( class-name def-f-obj )

  (let (func-name param-name body-source body-convert)
	(setq func-name (car def-f-obj))
	(setq param-name (cadr def-f-obj))
	(setq body-source (caddr def-f-obj))

	(setq func-name (convert-syntax-symbol func-name))

	;;パラメータリスト変換
	(setq param-name
		  (convert-syntax-symbol
		   (convert-parameter-list-to-string
			param-name)))

	(setq body-convert
		  (convert-function-source body-source)
		  )

	(format nil "~a:function(~a)~%{~%/*~%~a~%~%lisp >>> target~%~%~a~%~%*/~%},~%" 
			func-name ;関数名
			param-name ;引数
			body-source ;本体(lisp)
			(string-downcase (format nil "~a" body-convert))
			)
	);let

)

(defparameter *test-code* '(setq a 3))
(defparameter *test-code2* '(setq a (+ 3 2)))
(defun testf () (convert-funtion-source *test-code* nil))



;;関数内部を環境に合わせて構造変換
(defun convert-funtion-source (source r-str)

  ;;右辺を展開

  ;;左辺を展開
  (loop for i below (length source) do
	   (if (equal (elt source i) 'setq)
		   (setq r-str (format nil "~a = ~a;" (cadr source) (caddr source)))
		   );if
	   );loop

	   r-str
)

;列挙型をコンバート
;; enum HAND{
;; 	GOO,
;; 	CHOKI,
;; 	PER
;; };
(defun convert-enum ( enum-obj )
  (setq test enum-obj)
  (format nil "var ~a = {~%~a};"
		  (car enum-obj)
		  (concat-string-delimita 
		   (map 'list (lambda (x) 
						(format nil "~a : ~d, "  x (eval x) )) 
				(cadr enum-obj) )
		   #\newline)
		  ;; 		  (cadr enum-obj)
		  )
)


;パラメータのリストをカンマ区切りの文字列に変換
(defun convert-parameter-list-to-string (parameters-list)  
  (concat-list-string
   (map 'list (lambda (x) (format nil "~a"  x)) parameters-list)) 
  
)

;関数名、変数名を対象環境で使えるようにシンタックス適応させる
(defun convert-syntax-symbol (target)
  (print target)
  (setq target ( format nil "~a" target))
  (setq target (replace-string-all target "-" "_"));ハイフンをアンダーバーに
  (setq target (replace-string-all target "\\*" ""));アスタリスクを削除（エスケープしつつ）
  (setq target (string-downcase target));小文字化
  target
  )


;タイプ名を対象環境のタイプ名に対応するように変換
(defparameter *typename-list*
	  '(
		( LABEL . "var"  )
		( BUTTON . "var" )
		( INTEGER . "var" )
		( STRING . "var")
		( VECTOR . "var")
		)
	  )

(defun convert-typename (target)
  (setq target ( format nil "~a" target))
  (setq target (replace-string-all target "LABEL" "var"))
  (setq target (replace-string-all target "BUTTON" "var"))
  (setq target (replace-string-all target ".*INTEGER.*" "var"))
  (setq target (replace-string-all target ".*STRING.*" "var"))
  (setq target (replace-string-all target ".*VECTOR.*" "var"))
  target
)



;;関数内部記述を対象環境に対応するように変換
;;確実な対応は不可能なので、ピックアップして使える補助的なものとしてざっくり変換
(defparameter etst nil)
(defparameter *symbol-convert-alist*
  '(
	( setq . =)
	( setf . =)
	( print . console.log)
	( equal . == )
	( not . !)
	( let . var)
	( t . true )
;; 	( nil . null ) ;;error

	)
)
;; (defun convert-function-source(src)
;; ;;   (sublis *symbol-convert-alist* src)

;;   ;;test 1
;; ;;   (map 'list (lambda(x) 
;; ;; 			   (
;; ;; 				cond 
;; ;; 					  ((consp x) (convert-function-source x))
;; ;; 					  ((symbolp x) x)
;; ;; 				)) src)

;;   ;;test 2
;; ;;   (map 'list (lambda(x) 
;; ;; 			   (
;; ;; 				cond 
;; ;; 					  ((consp x)  
;; ;; 					   (format nil "~a = ~a" 
;; ;; 							   (cadr x) 
;; ;; 							   (convert-function-source (cddr x))))
;; ;; 					  ((symbolp x) x)
;; ;; 				)) src)

;;   ;;test 3

;;   (print "-------")
;;   (print src)
;;   (cond
;; 	;;ifのやつ
;; 	( (equal (car src) 'if)
;; 	  (format nil "if( ~a ~a )"
;; 			  (cadr src)
;; 			  (caddr src)
;; 			  );format
;; 	  );equal if
;; 	;;単純前置後置型のやつ（例：=,+-*/,)
;; 	( t
;; 	 (let (converted-symbol first-var second-var var-list ) 
;; 	   (setf converted-symbol (sublis *symbol-convert-alist* (car src)))
;; 	   (setf first-var (cadr src))
;; 	   (if (consp first-var)
;; 		   (setf first-var (convert-function-source (cadr src))))
;; 	   (setf second-var (caddr src))
;; 	   (if (consp second-var)
;; 		   (setf second-var (convert-function-source (caddr src))))
;; 	   (setf var-list (cdr src))
;; ;; 	   (setf var-list (map 'list (lambda(x) (convert-function-source x)) var-list))
;; 	   (cond
;; 		 ((consp src)
;; 			  (format nil "~a ~a ~a"
;; 					  first-var
;; 					  converted-symbol
;; 					  second-var))
;; 		 ((symbolp src) src)
;; 		 );cond
;; 	   ;;   );if
;; 	   );let
;; 	 );equal setf
	
	
;; 	);cond
;; )  









;;--------------------------------------------------------------------------
;;ここから基本変換部
;;enchant/ winapiで共通
(defparameter *function-convert-alist*
  '(
	( setq . (= simple-calc))
	( setf . (= simple-calc))
	( + . (+ simple-calc))
	( - . (- simple-calc))
	( * . (* simple-calc))
	( / . (/ simple-calc))
	( % . (% simple-calc))
;; 	( print . console.log)
	( equal . (== simple-calc) )
	( and . (&& simple-calc) )
	( not . (! simple-convert))
	( let . (var increase-variable))
	( if . (if format-if))
	( for . (for format-for))
	)
)

(defun simple-convert( converted-symbol var-list)
  (setf var-list 
		  (recursive-list-convert-function-source var-list)
		);setf
  (format nil "~a ~a "
		  converted-symbol
		  var-list)
)

;;単純に左の値を中央に置き換える
;;主に四則演算に適用するが、(+ a b c) など、
;;３つ以上の計算は正しく変換されないので注意
(defun simple-calc(converted-symbol var-list)
  (setf var-list 
		  (recursive-list-convert-function-source var-list)
		);setf
  (format nil "~a ~a ~a"
		  (car var-list)
		  converted-symbol
		  (cadr var-list))
)


;;let専用。変数宣言文を含めたソースを作成
(defun increase-variable(converted-symbol var-list)
  (let (variable-name body-list)
	(setf variable-name (car var-list))
	(setf body-list (cdr var-list))
	(setf body-list
		  (recursive-list-convert-function-source body-list)
		  );setf
	(format nil "~a ~{~a~^,~}; ~% ~{~a;~%~}"
			converted-symbol
			variable-name
			body-list)

	);let
)

;;if専用
(defun format-if(converted-symbol var-list)
  (let (test-src body-list)
	(setf var-list
		  (recursive-list-convert-function-source var-list)
		  );setf
	(setf test-src (car var-list))
	(setf body-list (cdr var-list))
	(format nil "~a( ~a )~%{~%~a~%}"
			converted-symbol
			test-src
			body-list)

	);let
)
;;for専用
(defun format-for(converted-symbol var-list)
  (let (test-src body-list temp-var-name start-val end-val)
	(setf test-src (car var-list))
	(setf body-list (cdr var-list))
	(setf body-list
		  (recursive-list-convert-function-source body-list)
		  );setf

	(setf temp-var-name (car test-src))
	(setf start-val (cadr test-src))
	(setf end-val (caddr test-src))
	(format nil "~a( ~a=~a; ~a<~a; ~a++ )~%{~%~a~%}"
			converted-symbol
			temp-var-name
			start-val
			temp-var-name
			end-val
			temp-var-name
			body-list)

	);let
)

(defun recursive-list-convert-function-source (src-list)
  (map 'list (lambda(x)
			   (if (listp x)
				   (convert-function-source x)
				   x))
	   src-list)
)

(defparameter *value-convert-alist*
  '( 
	(t . true)
;; 	(nil . null);;うまく処理できない
))
(defun convert-function-source(src)
  (let (function variable-list format-function converted-symbol )

	(setf function (car src))
	(setf variable-list (cdr src))
;; 	(setf variable-list (sublis variable-list *value-convert-alist*));;シンボルを変換
	
	;;対応変換関数を取得し、そこに引数リストを渡して実行
	(setf format-function (caddr (assoc function *function-convert-alist*)))
	(setf converted-symbol (cadr (assoc function *function-convert-alist*)))
	;;変換関数が定義済みでなければ引数だけ再帰させて、関数名はそのまま出力
	;;定義済みなら通常変換
	(if (equal converted-symbol nil)
		(format nil "~a ~a" function 
				(recursive-list-convert-function-source variable-list))
		(funcall format-function converted-symbol variable-list  )
		)
	
	);let

)


(setf etst '((SETQ X (+ X 2)) (PRINT X)))
(defun convert-symbol(symbol tree alist) 
  (subst (cdr (assoc symbol alist)) symbol tree)
)
(map 'list (lambda(x) (subst (cdr x) (car x) etst)) *symbol-convert-alist*)

(convert-symbol 'setq etst *symbol-convert-alist* )

(sublis *symbol-convert-alist* etst)