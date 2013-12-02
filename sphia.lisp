(load "LispRough.lisp")
;--------------------------------- GAME ---------------------------------


(defun game-variable()

  (def-v *label-total-number* (new-label 13 2 13 3 "TOTAL NO:"))
  (def-v *message-label* (new-label 26 2 13 3 "message"))
  (def-v *label-next-break* (new-label 13 5 26 3 "Next Break No"))


  (def-v *button-quit* (new-button 28 30 5 3 "[Q]uit" 'q #'push-quit))

  (def-v *label-turn* (new-label 1 2 10 3 "TURN:"))
  (def-v *label-time* (new-label 1 5 10 3 "TIME:"))
  (def-v *label-nolma* (new-label 1 8 10 3 "NOLMA:"))


  (def-v *label-core-sphia* (new-label 21 8 10 3 "CORE:"))

;;   (def-v *label-next* (new-label 34 6 7 3 "NEXT"))
  

;;   (def-v *button-next* (new-button 1 12 7 3 "[N]ext" 'n #'push-next))  
;;   (def-v *button-fall* (new-button 1 15 7 3 "[A] Left" 'a #'push-left))
;;   (def-v *button-fall* (new-button 1 18 7 3 "[D] Right" 'd #'push-right))
;;   (def-v *button-fall* (new-button 1 21 7 3 "[S] Fall" 's #'push-fall))
;;   (def-v *button-rotate-right* (new-button 1 24 7 3 "[R]otate[R]" 'rr #'push-rr))
;;   (def-v *button-rotate-left* (new-button 1 27 7 3 "[R]otat[L]" 'rl #'push-rl))
  

  ;;変数
  (def-v *core-number* 0)
;;   (def-v *select-coin-array* (make-array 0 :fill-pointer t :adjustable t))
  (def-v *select-coin-vec* (new-vec))

  ;;ゲーム状態遷移
;;   (def-v *flag-block-put* nil);ブロックの設置フラグ
;;   (def-v *flag-fall* nil);落下中フラグ
;;   (def-v *flag-match-check* nil);マッチチェックフラグ

;;   (def-v *fall-block-left* nil)
;;   (def-v *fall-block-right* nil)

  ;;grid用データを作成
   (def-v *grid* (new-grid 14 12 4 4 6 4 
						   #'callback-make-cell-obj 
						   #'callback-make-cell-data 
						   #'callback-update-cell
						   );new-grid
	 );def-v

   ;;マッチチェック
;;    (def-v *match-require-num* 3);３つで消える
);end-variable


;;セルのデータに設定するブロッククラス
;;タイプはdrag,virusのどちらか、connectは接続方向、matchedはマッチチェック用
(defstruct (coin) (number 0) (color nil) (type nil) (checked nil)  )


;;セルのデータを返すコールバック関数
(def-f callback-make-cell-data ()
;;   (make-block)
  nil
)

;;セルの見た目を表すオブジェクト作成関数
(def-f callback-make-cell-obj ( grid-x grid-y x y w h index )
;;   (new-label
;;    (+ grid-x (* x w));x
;;    (+ grid-y (* y h));y
;;    w h ;w, h
;;    (format nil " ");str
;;    )

  (new-button
   (+ grid-x (* x w));x
   (+ grid-y (* y h));y
   w h ;w, h
   (format nil "~d " index);str
   (read-from-string (format nil "~d" index)) ;グリッド番号をそのままキーに指定
   #'push-grid
   )

)

;;セルのアップデート関数
(def-f callback-update-cell (cell)

  (let (coin button str)
	(setq coin (cell-data cell))
	(setq button (cell-obj cell))
	;;チェック済みとそうでない場合で見た目を変える
	(if (equal (coin-checked coin) t)
		(setq str (format nil "[~d] <~d>" (button-key button) (coin-number coin)));t
		(setq str (format nil "[~d] ~d" (button-key button) (coin-number coin)));t
		);if
	(set-text button str)
	);let
)

(defun game-start()

  (lr-begin 42 40 )  
  (game-variable)
  (game-init)
  (lr-start)
)

(def-f game-init()

  ;グリッド配列をボタンで初期化
;;   (update-level)
;;   (grid-put-random *grid* 50)
  (next-turn)
)




(def-f push-quit()
  (setq *quit* 1)
)

;画面更新
(def-f update-core-number()
  (setf (label-text *label-core-sphia*) (format nil "CORE: < ~d >" *core-number*))
)


(def-f push-grid (button)
  (let (cell data)
	(setq cell (aref (grid-cell-array *grid*) (eval (button-key button))))
	(setq data (cell-data cell))
	(print data)
	
	)
)


(def-f next-turn()
  (grid-put-random-sphia *grid*)
  (set-next-core-number)
  (update-core-number)
  (grid-update *grid*)
)

;;ランダムに要素を配置。Sphia用
;;レベルの動作は未定
(def-f grid-put-random-sphia( grid)
  (loop for i below (length (grid-cell-array grid) ) do
  	   (let (cell)

		 (setq cell (aref (grid-cell-array grid) i))
		 (setf (cell-data cell ) (make-coin :number (+ 1 (random 5))))
  	   );let
  	   )
)




;;新しいコアナンバーをセット
(def-f set-next-core-number()
  (setq *core-number* (random 20) )
)

;;次のブロックをグリッドに配置
(def-f put-next-block()
  (let ((left-cell (grid-get-cell *grid* 3 0))
		(right-cell (grid-get-cell *grid* 4 0)))
	
		(setf (cell-data left-cell) *next-block-left*)
		(setf (cell-data right-cell) *next-block-right*)
		(grid-update *grid*)

		;;落下中ブロックへセット
		(setq *fall-block-left* *next-block-left*)
		(setq *fall-block-right* *next-block-right*)

		;次ブロックを用意
		(set-next-block)
	);let
)

;;落下
(def-f move-block (block move-x move-y)
  (let ((cell (grid-get-cell-from-data *grid* block)  ) 
		(target-cell nil ))
	;;セル上を移動

	;;移動先のセルを取得して、データをセット
	(setq target-cell 
		  (grid-get-cell *grid* (+ (cell-x cell) move-x) (+ (cell-y cell) move-y)))
	
 	(setf (cell-data target-cell) block)

	;;移動前の位置を削除
	(setf (cell-data cell) nil)
	 )
)

;;着地チェック
;;指定のブロックに対して着地チェックを行なう
;;基本的に指定ブロックの座標の下にブロックがあれば着地だが、
;;下のブロックが操作中のブロックの場合は着地とみなさない
;;着地していたらtを返す。していなければnilを返す
(def-f check-fall-stop (block)


  (if (equal t ( check-cell-empty-from-block block 0 1 ) )
	  nil;t
	  t;
	  )

)

;;着地していないブロックのリストを返す
;;全て着地済みであれば、空のリストを返す
;;操作ブロック落下＞マッチ＞全部落下処理の時に使う
(def-f check-fall-stop-all ()
;;   (loop for x below (grid-w-cell-num *grid*) do
;; 	   (loop for y below (grid-h-cell-num *grid*) do
			
;; 			(let ((block (grid-get-cell *grid* x y)))
;; 			  ;;ドラッグタイプのみを対象とする
;; 			  (if (equal (block-type block) "drug")
;; 				  (;t
;; 				  );if drug check
;; 			  );let

;; 			));loop*2

)

;;指定のブロックの下の位置にあるブロックを取得
;;存在しなければnilを返す
(def-f get-bottom-block(block)
  (let ((cell (grid-get-cell-from-data *grid* block)  ) 
		(bottom-cell nil) )

	;;下のセルを取得
	(setq bottom-cell
		  (grid-get-cell *grid* (cell-x cell) (+ (cell-y cell) 1)))

	(if (not (equal bottom-cell nil))
			 (cell-data bottom-cell);t
			 nil; nil
			 );if
  )
)




;;指定ブロックの相対位置のセルが空いているかチェック
(def-f check-cell-empty-from-block( block x y )
  (check-cell-empty
   (grid-get-cell-from-block *grid* block x y))
)

;;指定のセルが空いているかチェック
;;空いていたらt、ブロックや壁がある場合nilを返す
;;指定のセル上のブロックが操作中のブロックだったら無視する
(def-f check-cell-empty (cell)
	(if (and
		 (not (equal cell nil));セルが存在
		 (equal (cell-data cell) nil);セルがブロックを持っている
		 (not (equal (cell-data cell) *fall-block-left*));操作中ブロックでない
		 (not (equal (cell-data cell) *fall-block-right*));操作中ブロックでない
		 )
		t;t
		nil; nil
		);if
)



;;ドラッグタイプのブロックが配置されたセルのリストを返す
(def-f get-drug-block-list (grid)
;;   (map 'list (lambda (x) (print t)) (grid-cell-array grid))
)

;;敵の手を決定
(def-f enemy-hand()

  ;;単なるランダム

  (let ((target-grid nil) (empty-cell-array nil) )
	(setq empty-cell-array (get-empty-cell-array *grid*))
	
	(cond 
	  ;打てる場所が無い
	  ((= (length empty-cell-array) 0) (print "utenaiyo"))
	  ;ランダムに配置
	  ( t
	   (setq target-grid (aref empty-cell-array (random (length empty-cell-array))))
	   (print (format nil "computer hand is ~a > x" (button-text target-grid)))
	   (set-text target-grid "x")
	   )
	  )
	)
)

;;マッチチェック
;;各行毎に、左から１マスずつチェックし、同じ色が３つ以上続くようなら
;;ブロックのmatchedをtにする
;;その後、列についても上から同じチェックをする
;;再帰を使う
(def-f check-match()

  ;;左上から１行ずつチェック
  ;;マッチチェックし終わったブロックは無視しない。
  ;;無視した場合、縦方向にも検索があるので、Ｌの字になっていると失敗する
  (loop for y below (grid-h-cell-num *grid*) do
	   (loop for x below (grid-w-cell-num *grid*) do
			
			(let (block)
			  (setq block (cell-data (grid-get-cell *grid* x y)))
			  (cond
				(
;; 				 (and
				  (not (equal block nil))
;; 				  (not (equal (block-matched block) t))
;; 				  )
				;t
				  (check-match-r-horizontal block);t
				  (check-match-r-vertical block);t
				  )
				  );cond

			  );let


			);loop x
	   );loop y

)

;;自分の右側のブロックに潜っていく再帰関数
(def-f check-match-r-horizontal (block)
  (check-match-r block nil 0 1 0)
)
;;自分の下側のブロックに潜っていく再帰関数
(def-f check-match-r-vertical (block)
  (check-match-r block nil 0 0 1)
)

;;指定のブロック位置から、move-x move-yの方向に潜っていく再帰関数
;;同じ色が続かなくなった時に、マッチカウントを返す。
;;マッチカウントを返されて、それが３以上だったらそのブロックのマッチフラグを立てる

(def-f check-match-r (block before-block match-count move-x move-y)


  (let ((recursive-finish nil))

  ;;前回のセルとマッチしているかチェック
  ;;マッチしていなければ値を返す
  (if (not (equal before-block nil))
	  (if (equal (block-color block) (block-color before-block))
		  (setq match-count (+ match-count 1) );t
		  (setq recursive-finish t);nil
		  );if check match color
	  );if check left block

  ;;次のセルへ再帰使う
  (if (equal recursive-finish nil)
  (let (next-cell)
    ;次のセルを取得
	(setq next-cell (grid-get-cell-from-block *grid* block move-x move-y))
	(if (and
		 (not (equal next-cell nil));;次のセルがあるかチェック
		 (not (equal (cell-data next-cell) nil));;次のセルにブロックがあるか
		 )

		(setq match-count
		 (check-match-r (cell-data next-cell) block match-count move-x move-y)
		 )
		 );if

	;;戻ってきたmatch-countでマッチ数をチェック
	;;３以上ならフラグ立てる
	(if (>= match-count (- *match-require-num* 1) )
		(setf (block-matched block) t)
;;  		(print (grid-get-cell-from-data *grid* block))
		);if match count
	
	);let
  );if recursive


	;;マッチ数を返す
 	match-count
	);let recursive

)

;;マッチフラグの立っているブロックを全て削除
(def-f delete-matched-block()
  (loop for i below (length (grid-cell-array *grid*)) do
	   (let (block)
		 (setq block (cell-data (aref (grid-cell-array *grid*) i)))
		 
		 (if (and
			  (not (equal block nil));ブロック存在チェック
			  (equal (block-matched block) t));マッチフラグチェック
;; 			 (setq block nil)
;;  			 (setf (block-color block) "A")
;;  			 (setf block nil)
			 (setf (cell-data (aref (grid-cell-array *grid*) i)) nil)
			 );if

		 );let
	   );loop
)

;;Nextボタン。次のターンに進める
(def-f push-next()

  

  ;;ブロックが無い場合はまず配置
  (cond

	;;ブロック設置
	((equal *flag-block-put* t)
	 (put-next-block)
	 (setq *flag-block-put* nil)
	 (setq *flag-fall* t))

	;;落下
	((equal *flag-fall* t)
	 (fall-controll-block)
	 
	 ;;着地チェック
	 (cond 
	   ((check-fall-stop-controll-block)
		(setq *flag-fall* nil)
		(setq *flag-match-check* t)
		)
	   );cond

	 )
	
	;;マッチチェック
	((equal *flag-match-check* t)
	 (check-match)
	 (delete-matched-block);
	 (setq *flag-block-put* t)
	 )
	);cond


  

  ;;画面更新
  (grid-update *grid*)

)

;;操作中ブロックを落下させる
(def-f fall-controll-block()
  (move-block *fall-block-left* 0 1 )
  (move-block *fall-block-right* 0 1)
)
;;操作中ブロックの着地チェック
(def-f check-fall-stop-controll-block()
   (or
	   (equal t (check-fall-stop *fall-block-left*))
	   (equal t (check-fall-stop *fall-block-right*)))
)

;;着地するまで落下
(def-f push-fall()

  ;;着地していないかぎり落下を繰り返す
  (loop for i below (grid-h-cell-num *grid*) do
	   (if (not (check-fall-stop-controll-block))
		   (fall-controll-block);t
		   (return);nil
		   );if
	   );loop
  
  (setq *flag-fall* nil);t
  (grid-update *grid*)
)

(def-f push-right()

  (cond 
	((check-cell-empty-from-block *fall-block-right* 1 0);右セルのチェック
	 (move-block *fall-block-right* 1 0)
	 (move-block *fall-block-left* 1 0)
	);move
	(t
	 (print "don"));wall
	);cond
  (grid-update *grid*)

)

(def-f push-left()
  

  (cond 
	((check-cell-empty-from-block *fall-block-left* -1 0);左セルのチェック
	 (move-block *fall-block-left* -1 0)
	 (move-block *fall-block-right* -1 0)
	);move
	(t
	 (print "don"));wall
	);cond
  (grid-update *grid*)
)

(def-f push-rl()
)

(def-f push-rr()
)


;; (def-f win()
;;   (setq *money* (+ *money* 10))
;;   (update-money)
;;   (set-text *message-label*  "PIKO >>>>>> WIN")
;; )

;; (def-f draw()
;;   (set-text *message-label*  "PIKO >>>>>> DRAW")
;; )

;; (def-f lose()
;;   (setq *money* (- *money* 10))
;;   (update-money)
;;   (set-text *message-label*  "PIKO >>>>>> LOSE")
;; )


 



