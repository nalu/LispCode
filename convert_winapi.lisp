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


