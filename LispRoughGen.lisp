
(ql:quickload :cl-ppcre);文字列ライブラリ
(load "./LispRough.lisp")


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

;;シンボルから必要な関数をセットするためのオブジェクト
;;change-token時に使用

(defun generate-source (seed-filename game-filename game-name generate-filename generate-symbol )
  (setq *game-name* game-name)
  (setq *game-filename* game-filename)
  (let ((loadstr (load-seed-code seed-filename)))
    (setq loadstr (change-token loadstr game-filename game-name generate-symbol));トークン変換
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
;現状ではタイトル、変数宣言・初期化、関数宣言・定義、列挙型定義の５つ
;トークンが無くても存在するものだけについて埋め込みを行なう
#|
<@lisp-rough-title>
<@lisp-rough-variable-declar>
<@lisp-rough-variable-initialize>
<@lisp-rough-method-declar>
<@lisp-rough-method-define>
<@lisp-rough-enum>
|#
(defun change-token (source game-filename game-name generate-symbol)
  
  ;;変換ターゲットに応じた関数セットを読み込む
  (if (equal generate-symbol 'winapi)
	  (load "./convert_winapi.lisp"))
  (if (equal generate-symbol 'enchant-js)
	  (load "./convert_enchantjs.lisp"))
  
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
  ;列挙型定義
  (setq source (cl-ppcre:regex-replace "<@lisp-rough-enum>" source (make-enum-str game-filename)))
  
)




;escape-all-childaにして、全部置換しよう。
;replaceの第二匹数を、multiple-value-bind (x y)してゲット。nilがでるまで繰り返せばいい
;と思ったが、チルダをダブルチルダにしているので、無限ループする
;ダブルチルダは省いて処理したいが、そもそも、文字列中のチルダをエスケープするメソッドはないかな
(defun escape-childa-all (str)
 (cl-ppcre:regex-replace-all "~" str "~~") 
 
)

;;コンバートタイプを示す連想リスト
;;環境ごとの適切な関数を記述しておく
;; '( 
  
;;   ( enchant-js . convert-v-declar )
;; )

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

;;関数定義の文字列をファイルパスから作成
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

;列挙型定義の文字列をファイルパスから作成
(defun make-enum-str (filename)
  (load filename)
  (concat-string-delimita
   (map 'list #'convert-enum *enum-array*)
   #\newline)
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
  (generate-source "c:/Lisp/LispCode/seed-code/win/seed-win-main.cpp" game-filename game-title "main.cpp" 'winapi)
  (generate-source "c:/Lisp/LispCode/seed-code/win/seed-win-game.h" game-filename game-title (format nil "~a.h" game-title) 'winapi)
)

;hi_lowを生成
(defun generate-hilow-cpp()
  (generate-cpp "c:/Lisp/LispCode/hi_low.lisp" "hilow")
)

;jankを生成
(defun generate-jank()
  (generate-cpp "c:/Lisp/LispCode/jank.lisp" "jank")
)




;JS用のコードを生成
;lispのゲームファイルパスと、ゲームのタイトルを入力して実行する
(defun generate-js ( game-filename game-title )
  (generate-source "c:/Lisp/LispCode/seed-code/enchant/main.js" game-filename game-title "main.js" 'enchant-js)

;;ヘッダはいらない
;;   (generate-source "c:/Lisp/LispCode/seed-code/win/seed-win-game.h" game-filename game-title (format nil "~a.h" game-title))
)
;;hilow-jsを生成
;hi_lowを生成
(defun generate-hilow-js()
  (generate-js "c:/Lisp/LispCode/hi_low.lisp" "hilow")
)

;actionを生成
(defun generate-action-js()
  (generate-js "./action.lisp" "ballaction")
)
(defun generate-action-win()
  (generate-cpp "./action.lisp" "ballaction")
)

;;html-moniter
(defun generate-html-moniter()

  
  (setq seed-filename "./seed-code/html_moniter/html_moniter.html")
  (let (loadstr draw-code))
    (setq loadstr (load-seed-code seed-filename))
    (setq draw-code "test")
    
  (setq loadstr (cl-ppcre:regex-replace-all "<@lisp-rough-html-moniter>" loadstr draw-code))

    (setq loadstr (escape-childa-all loadstr)) ; escape childa
	(setq loadstr (convert-return-all-crlf loadstr)) ;          newline return  
	(create-directory (format nil "./generate-~a/" "html_moniter"));
    (make-code-win (format nil "./generate-~a/~a" "html_moniter" "html_moniter.html") loadstr)
)



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

;; ;変数名、初期値からなるdef-vで定義された値を、C++のクラス宣言部用にコンバートする
;; (defun convert-v-declar ( def-v-obj )

;;   (let (type-str var-name)
;;     ;これでシンボルのタイプを出せる。実際にコードが実行済みの必要があるが、
;; 	;def-vは実行時にデータを配列にいれるので問題ない
;; 	(setq type-str 
;; 		  (convert-typename-lisp-to-cpp
;; 		   (type-of (eval (car def-v-obj)))) )
;; 	(setq var-name (car def-v-obj))

;;     ;C++はハイフン使えないのでアンダーバーに変換
;; 	;あとで関数にかえる
;; 	(setq var-name (convert-syntax-symbol-lisp-to-cpp var-name))

;; 	(format nil "~a ~a;" type-str var-name); Label testlabel; のような宣言文字列を出力
;;   )
;; )

;; ;変数名、初期値からなるdef-vで定義された値から初期化コードにコンバートする
;; ;new のあとをコンバートできてない。コンストラクタを同対応させるかの仕様が必要。
;; (defun convert-v-initialize ( def-v-obj )
;;   (format nil "this->~a = ~a;" 
;; 		  (convert-syntax-symbol-lisp-to-cpp (car def-v-obj)) ;変数名
;;  		  (cpp-new-method (cadr def-v-obj)) ;初期化コードは次回バージョンでこうやる
;; ;		  (cadr def-v-obj);初期化コード
;; 		  )
;; )

;; ;次回バージョンで実装予定。
;; ;CPP用初期化コードを生成する。クラスタイプから生成
;; ;new Button(gm, 0,1,"str", new Callback( multitype_func<hilow, &hilow::push_low>, this));)
;; ;というコード。
;; (defun cpp-new-method (initialize-code)

;;   ;リストでなければそのまま返す
;;   ;リストであれば先頭の１つが関数名なので、それをコンバートして実行
;;   (if (equal 'CONS (type-of initialize-code))
;; 	  (cond
;; 		;new-button > new-button-cpp
;; 		((equal (car initialize-code) 'new-button) 
;; 		 (setf (elt initialize-code 0) 'new-button-cpp)
;; 		 (eval initialize-code))
	 
;; 		;;ここは同じ構成なので、alist使ってまとめたい
;; 		;new-button > new-button-cpp
;; 		((equal (car initialize-code) 'new-label) 
;; 		 (setf (elt initialize-code 0) 'new-label-cpp)
;; 		 (eval initialize-code))
		
;; 		( t initialize-code)
;; 		)

;; 	  ;not if
;; 	  initialize-code
;;   )
;; )

;; ;;new-buttonをCPP用にコンバート
;; (defun new-button-cpp ( x y w h title key call)
;;   (format nil 
;; 		  "new Button(gm, ~d, ~d, \"~a\"\, new Callback( multitype_func<~a, &~a::~a>, this))  " 
;; 		  x y title *game-name* *game-name* 
;; 		  (convert-syntax-symbol-lisp-to-cpp (function-name call)))
;; )

;; ;;new-labelをCPP用にコンバート
;; ;;ex : new Label(gm, x,y,"a", RGB(0,0,0),RGB(100,100,200),16) ;

;; (defun new-label-cpp ( x y w h title)
;;   (format nil 
;; 		  "new Label(gm, ~d, ~d, \"~a\"\, RGB(0,0,0), RGB(100,100,200), 16 ) " 
;; 		  x y title
;; 		  )
;; )


;; ;関数名をクラス宣言部用にコンバート
;; (defun convert-f-declar ( def-f-obj )
;;   (format nil "void ~a(~a);"
;; 		  (convert-syntax-symbol-lisp-to-cpp  (car def-f-obj)) ;関数名
;; 		  (convert-syntax-symbol-lisp-to-cpp
;; 		   (convert-parameter-list-to-string (cadr def-f-obj))
;; 		   );引数
;; 		  )
;; )

;; ;関数名をクラス定義部用にコンバート
;; (defun convert-f-define ( class-name def-f-obj )
;;   (let (func-name param-name body-source )
;; 	(setq func-name (car def-f-obj))
;; 	(setq param-name (cadr def-f-obj))
;; 	(setq body-source (cddr def-f-obj))

;; 	;C++構文ルールように変換
;; 	(setq func-name (convert-syntax-symbol-lisp-to-cpp func-name))
;; 	(setq param-name
;; 		  (convert-syntax-symbol-lisp-to-cpp
;; 		   (convert-parameter-list-to-string
;; 			param-name)))


;; 	(format nil "void ~a::~a(~a)~%{~%/*~%~a~%*/~%}~%" 
;; 			class-name
;; 			func-name ;関数名
;; 			param-name;引数
;; 			body-source);本体
;; 	)
;; )

;; ;列挙型をコンバート
;; ;; enum HAND{
;; ;; 	GOO,
;; ;; 	CHOKI,
;; ;; 	PER
;; ;; };
;; (defun convert-enum ( enum-obj )
;;   (format nil "enum ~a{~%~a};"
;; 		  (car enum-obj)
;; 		  (concat-string-delimita 
;; 		   (map 'list (lambda (x) (format nil "~a, "  x)) (cadr enum-obj))
;; 		  #\newline)
;; ;; 		  (cadr enum-obj)
;; 		  )
;; )


;; ;パラメータのリストをカンマ区切りの文字列に変換
;; (defun convert-parameter-list-to-string (parameters-list)  
;;   (concat-list-string
;;    (map 'list (lambda (x) (format nil "int ~a "  x)) parameters-list)) 
  
;; )

;; ;関数名、変数名をC++で使えるようにシンタックス適応させる
;; (defun convert-syntax-symbol-lisp-to-cpp (target)
;;   (print target)
;;   (setq target ( format nil "~a" target))
;;   (setq target (replace-string-all target "-" "_"));ハイフンをアンダーバーに
;;   (setq target (replace-string-all target "\\*" ""));アスタリスクを削除（エスケープしつつ）
;;   (setq target (string-downcase target));小文字化
;;   target
;;   )


;; ;特定のタイプ名をC++用のクラス名に対応するように変換
;; (defun convert-typename-lisp-to-cpp (target)
;;   (setq target ( format nil "~a" target))
  
;;   (setq target (replace-string-all target "LABEL" "Label*"))
;;   (setq target (replace-string-all target "BUTTON" "Button*"))
;;   (setq target (replace-string-all target ".*INTEGER.*" "int"))
;;   (setq target (replace-string-all target ".*STRING.*" "string"))
;;   (setq target (replace-string-all target ".*VECTOR.*" "vector<int>"))

;;   target
;; )



(defun convert-method-str ( source target class-name )

  (if (equal target 'winapi)
	  (load "./convert_winapi.lisp"))
  (if (equal target 'enchant-js)
	  (load "./convert_enchantjs.lisp"))
;;   (make-method-define-str "c:/Lisp/LispCode/hi_low.lisp" "hilow")

  (let (def-f-obj)
	(setq def-f-obj (cdr (read-from-string source)))
	(convert-f-define class-name def-f-obj )
	);let

)

(defun testfunc()
  (convert-method-str  "(defun test(x) ((setq x (+ x 2))(print x)))" 'enchant-js "classname")
  )


