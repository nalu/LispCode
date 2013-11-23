(load "LispRough.lisp")
;--------------------------------- GAME ---------------------------------


(defun game-variable()

  (def-v *message-label* (new-label 26 2 13 3 "message"))
  (def-v *button-quit* (new-button 28 30 5 3 "[Q]uit" 'q #'push-quit))
  (def-v *label-level* (new-label 1 6 7 3 "level"))

  (def-v *level* 20)
  (def-v *hp-gage* 10)
  (def-v *label-next* (new-label 34 6 7 3 "NEXT"))
  

  (def-v *button-next* (new-button 1 12 7 3 "[N]ext" 'n #'push-next))  
  (def-v *button-fall* (new-button 1 15 7 3 "[A] Left" 'a #'push-left))
  (def-v *button-fall* (new-button 1 18 7 3 "[D] Right" 'd #'push-right))
  (def-v *button-fall* (new-button 1 21 7 3 "[S] Fall" 's #'push-fall))
  (def-v *button-rotate-right* (new-button 1 24 7 3 "[R]otate[R]" 'rr #'push-rr))
  (def-v *button-rotate-left* (new-button 1 27 7 3 "[R]otat[L]" 'rl #'push-rl))
  

  (def-enum 'hand '(goo choki per hand-max))
  (def-v *player-hand* goo)
  (def-v *enemy-hand* goo)
  (def-v *label-next-block-left* (new-label 34 9 4 3 ""))
  (def-v *label-next-block-right* (new-label 38 9 4 3 ""))

  (def-v *next-block-left* nil)
  (def-v *next-block-right* nil)

  ;;ゲーム状態遷移
  (def-v *flag-block-put* nil);ブロックの設置フラグ
  (def-v *flag-fall* nil);落下中フラグ
  (def-v *flag-match-check* nil);マッチチェックフラグ

  (def-v *fall-block-left* nil)
  (def-v *fall-block-right* nil)

  ;;grid用データを作成
   (def-v *grid* (new-grid 10 2 8 18 3 2 
						   #'callback-make-cell-obj 
						   #'callback-make-cell-data 
						   #'callback-update-cell
						   );new-grid
	 );def-v

   ;;マッチチェック
   (def-v *match-require-num* 3);３つで消える
   
);end-variable

;;セルのデータに設定するブロッククラス
;;タイプはdrag,virusのどちらか、connectは接続方向、matchedはマッチチェック用
(defstruct (block) (color nil) (type nil) (connect nil) (matched nil)  )

;;セルのデータを返すコールバック関数
(def-f callback-make-cell-data ()
;;   (make-block)
  nil
)

;;セルの見た目を表すオブジェクト作成関数
(def-f callback-make-cell-obj ( grid-x grid-y x y w h index )
  (new-label
   (+ grid-x (* x w));x
   (+ grid-y (* y h));y
   w h ;w, h
   (format nil " ");str
   )
)

;;セルのアップデート関数
(def-f callback-update-cell (cell)
  (let ((block (cell-data cell)))
	(if (not (eql block nil))
		(set-text (cell-obj cell) (block-color block));t
		(set-text (cell-obj cell) " ");nil
		);if
	);let
)

;;グリッドのセルボタン押下時のコールバック
;;グリッドはボタンの設置タイミングについて仕様変更した方がいい
(def-f push-grid (obj)
)


;;ゲージクラス作りたい
;; (defstruct gage
;;   (value 0)
;;   (max-value 0)




(defun game-start()

  (lr-begin 42 40 )  
  (game-variable)
  (game-init)
  (lr-start)
)

(def-f game-init()

  ;グリッド配列をボタンで初期化
  (update-level)
;;   (grid-put-random *grid* 50)
  (grid-put-random-drm *grid* *level* 8)
  (set-next-block)

  (update-next-block)
  (grid-update *grid*)

  (setq *flag-block-put* t);ブロックの設置フェイズから開始
)




(def-f push-quit()
  (setq *quit* 1)
)

;画面更新
(def-f update-level()
  (let (str)
    (setq str (format nil "level:~d" *level*))
    (set-text *label-level* str)
    )
)

(def-f update-next-block()
  (set-text *label-next-block-left* (block-color *next-block-left*))
  (set-text *label-next-block-right* (block-color *next-block-right*))
)




;;ランダムに要素を配置。ＤＲＭ用
;;レベル＊４の要素を配置
;;ベース・ラインより下にランダム配置する
;;飽和量が一定を超えると、ベースラインより上にも配置する
(def-f grid-put-random-drm( grid level base-line-y)
  (loop for i below (* level 4) do
	   (let ((empty-cell) (color-no) (put-block) )
		 (setq empty-cell 
			   (grid-random-get-empty-area grid 
										   0
										   base-line-y 
										   (grid-w-cell-num grid)
										   (- (grid-h-cell-num grid) base-line-y)
										   ))
		 (setq put-block (make-block :type "virus" ))
		 (setf (cell-data empty-cell) put-block)
		 (setq color-no (random 3))
		 (cond
		   ((= color-no 0) (setf (block-color (cell-data empty-cell)) "o"))
		   ((= color-no 1) (setf (block-color (cell-data empty-cell)) "x"))
		   ((= color-no 2) (setf (block-color (cell-data empty-cell)) "i"))
		 )
	   );let
	   )
)


;;次のブロックを用意
(def-f set-next-block()
  (setq *next-block-left* 
		(make-block 
		 :color "o"
		 :type "drag"
		 :connect "right"
		 ))
  (setq *next-block-right* 
		(make-block 
		 :color "x"
		 :type "drag"
		 :connect "left"
		 ))  
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


 



