;--------------------------------- Convert C++  ---------------------------------

;変数名、初期値からなるdef-vで定義された値を、C++のクラス宣言部用にコンバートする
(defun convert-v-declar ( def-v-obj )

  (let (type-str var-name)
    ;これでシンボルのタイプを出せる。実際にコードが実行済みの必要があるが、
	;def-vは実行時にデータを配列にいれるので問題ない
	(setq type-str 
		  (convert-typename-lisp-to-cpp
		   (type-of (eval (car def-v-obj)))) )
	(setq var-name (car def-v-obj))

    ;C++はハイフン使えないのでアンダーバーに変換
	;あとで関数にかえる
	(setq var-name (convert-syntax-symbol-lisp-to-cpp var-name))

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
	 
		;;ここは同じ構成なので、alist使ってまとめたい
		;new-button > new-button-cpp
		((equal (car initialize-code) 'new-label) 
		 (setf (elt initialize-code 0) 'new-label-cpp)
		 (eval initialize-code))
		
		( t initialize-code)
		)

	  ;not if
	  initialize-code
  )
)

;;new-buttonをCPP用にコンバート
(defun new-button-cpp ( x y w h title key call)
  (format nil 
		  "new Button(gm, ~d, ~d, \"~a\"\, new Callback( multitype_func<~a, &~a::~a>, this))  " 
		  x y title *game-name* *game-name* 
		  (convert-syntax-symbol-lisp-to-cpp (function-name call)))
)

;;new-labelをCPP用にコンバート
;;ex : new Label(gm, x,y,"a", RGB(0,0,0),RGB(100,100,200),16) ;

(defun new-label-cpp ( x y w h title)
  (format nil 
		  "new Label(gm, ~d, ~d, \"~a\"\, RGB(0,0,0), RGB(100,100,200), 16 ) " 
		  x y title
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
  (let (func-name param-name body-source body-convert )
	(setq func-name (car def-f-obj))
	(setq param-name (cadr def-f-obj))
;; 	(setq body-source (caddr def-f-obj))
 	(setq body-source (cddr def-f-obj))
	;C++構文ルールように変換
	(setq func-name (convert-syntax-symbol-lisp-to-cpp func-name))
	(setq param-name
		  (convert-syntax-symbol-lisp-to-cpp
		   (convert-parameter-list-to-string
			param-name)))

	(setq body-convert
		  (convert-function-source body-source)
		  )

	

	(format nil "void ~a::~a(~a)~%{~%/*~%~a~%*/~%~%lisp >>> target~%~%~a~%~%*/~%}~%" 
			class-name
			func-name ;関数名
			param-name;引数
			body-source
			(string-downcase (format nil "~a" body-convert))
			body-convert);本体

	)
)

;列挙型をコンバート
;; enum HAND{
;; 	GOO,
;; 	CHOKI,
;; 	PER
;; };
(defun convert-enum ( enum-obj )
  (format nil "enum ~a{~%~a};"
		  (car enum-obj)
		  (concat-string-delimita 
		   (map 'list (lambda (x) (format nil "~a, "  x)) (cadr enum-obj))
		  #\newline)
;; 		  (cadr enum-obj)
		  )
)


;パラメータのリストをカンマ区切りの文字列に変換
(defun convert-parameter-list-to-string (parameters-list)  
  (concat-list-string
   (map 'list (lambda (x) (format nil "int ~a "  x)) parameters-list)) 
  
)

;関数名、変数名をC++で使えるようにシンタックス適応させる
(defun convert-syntax-symbol-lisp-to-cpp (target)
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
	( += . (+= simple-calc))
	( -= . (-= simple-calc))
	( < . (< simple-calc))
	( > . (> simple-calc))
	( <= . (<= simple-calc))
	( >= . (>= simple-calc))
;; 	( print . console.log)
	( equal . (== simple-calc) )
	( and . (&& simple-calc) )
	( ++ . (++ simple-calc-single))
	( -- . (-- simple-calc-single))
	( not . (! simple-convert))
	( let . (var increase-variable))
	( if . (if format-if))
	( cond . (if format-cond))
	( for . (for format-for))
	( for-- . (for format-for--))
	( slot-value . (-> format-slot-value))
	( length . ( size format-function))
	( elt . ( t format-array))
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
;;++, --
(defun simple-calc-single(converted-symbol var-list)
  (setf var-list 
		  (recursive-list-convert-function-source var-list)
		);setf
  (format nil "~ax~a;~%"
		  (car var-list)
		  converted-symbol)
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
;;cond専用
(defun format-cond(converted-symbol var-list)
  (let (test-src body-list if-list if-str-list)
	(loop for i below (length var-list)  do

	  (setf if-list (elt var-list i))
	  (setf if-list
			(recursive-list-convert-function-source if-list)
			);setf
	  (setf test-src (car if-list))
	  (setf body-list (cdr if-list))

	  (push-back if-str-list
	  (format nil "~a( ~a )~%{~%~a~%}"
			  converted-symbol
			  test-src
			  body-list)
		  )
	  (setf converted-symbol "else if");;２回目以後はelse if
	  );loop
	if-str-list

	);let
)
;;for専用
(defun format-for(converted-symbol var-list)
  (let (test-src body-list temp-var-name start-val end-val)
	(setf test-src (car var-list))
	(setf test-src
		  (recursive-list-convert-function-source test-src)
		  );setf
	(setf body-list (cdr var-list))
	(setf body-list
		  (recursive-list-convert-function-source body-list)
		  );setf

	(setf temp-var-name (car test-src))
	(setf start-val (cadr test-src))
	(setf end-val (caddr test-src))
	(format nil "~a( int ~a=~a; ~a<~a; ~a++ )~%{~%~a~%}"
			converted-symbol
			temp-var-name
			start-val
			temp-var-name
			end-val
			temp-var-name
			body-list)

	);let
)
(defun format-for--(converted-symbol var-list)
  (let (test-src body-list temp-var-name start-val end-val)
	(setf test-src (car var-list))
	(setf test-src
		  (recursive-list-convert-function-source test-src)
		  );setf
	(setf body-list (cdr var-list))
	(setf body-list
		  (recursive-list-convert-function-source body-list)
		  );setf
	(setf temp-var-name (car test-src))
	(setf start-val (cadr test-src))
	(setf end-val (caddr test-src))
	(format nil "~a( int ~a=~a; ~a>=~a; ~a-- )~%{~%~a~%}"
			converted-symbol
			temp-var-name
			start-val
			temp-var-name
			end-val
			temp-var-name
			body-list)

	);let
)
;;slot-value専用
(defun format-slot-value(converted-symbol var-list)
  (format nil "~a~a~a"
		  (car var-list)
		  converted-symbol
		  (cadr var-list))
)
;;length > .size()など通常関数専用
(defun format-function(converted-symbol var-list)
  (setf var-list 
		  (recursive-list-convert-function-source var-list)
		);setf
  (format nil "~a.~a()"
		  (car var-list)
		  converted-symbol)
)
;;配列
(defun format-array(converted-symbol var-list)
  (setf var-list 
		  (recursive-list-convert-function-source var-list)
		);setf
  (format nil "~a[~a]"
		  (car var-list)
		  (cadr var-list))
)

(defun recursive-list-convert-function-source (src-list)
(setf a src-list)
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

;; (defun convert-function-source(src)
;;   (let (function variable-list format-function converted-symbol )
;; (print "-------")
;; (setf b src)

;; 	(setf function (car src))
;; 	(setf variable-list (cdr src))
;; ;; 	(setf variable-list (sublis variable-list *value-convert-alist*));;シンボルを変換

;; (print variable-list)
	

;; 	;;対応変換関数を取得し、そこに引数リストを渡して実行
;; 	(setf format-function (caddr (assoc function *function-convert-alist*)))
;; 	(setf converted-symbol (cadr (assoc function *function-convert-alist*)))
;; 	;;変換関数が定義済みでなければ引数だけ再帰させて、関数名はそのまま出力
;; 	;;定義済みなら通常変換
;; 	(if (equal converted-symbol nil)
;; 		(format nil "~a ~a" function 
;; 				(recursive-list-convert-function-source variable-list))
;; 		(funcall format-function converted-symbol variable-list  )
;; 		)
	
;; 	);let

;; )


(defun convert-function-source(src)
  (let (function variable-list format-function converted-symbol )
(print "-------")
(setf b src)


;;関数部がlistだったら関数＋引数ではなく普通のリストなのでmapで再帰
(cond 
  ( (listp (car src))
;; 	(return-from convert-function-source (map 'list #'convert-function-source src)))
;; 	(setf src (map 'list #'convert-function-source src)))
	(let (codes)
	  (setf codes (map 'list #'convert-function-source src))
	  (setf codes (format nil "~{~a;~%~}" codes))
	  (return-from convert-function-source codes) 
	)))



	(setf function (car src))
	(setf variable-list (cdr src))
;; 	(setf variable-list (sublis variable-list *value-convert-alist*));;シンボルを変換

(print variable-list)
	
	

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

