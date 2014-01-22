(load "LispRough.lisp")
;--------------------------------- GAME ---------------------------------


(defun game-variable()

  (def-v *message-label* (new-label 3 2 13 3 "message"))
  (def-v *button-quit* (new-button 15 18 5 3 "[Q]uit" 'q #'push-quit))
  (def-v *label-money* (new-label 18 6 7 3 "money"))
  
  (def-v *money* 100)
  (def-v *hp-gage* 10)
  

  

   (def-v *label-enemy-hand*  (new-label 9 6 5 5 "???"))
 
  (def-enum 'hand '(goo choki per hand-max))
  (def-v *player-hand* goo)
  (def-v *enemy-hand* goo)
  (def-v *button-restart* (new-button 20 18 5 3 "[R]estart" 'r #'push-restart))
  (def-v *finish-game* nil)

  (def-v *grid* (new-grid 3 6 3 3 4 4 
						   #'callback-make-cell-obj 
						   #'callback-make-cell-data 
						   #'callback-update-cell
						   'g
						   #'callback-push-cell
						   ))
);end-variable


;;セルのデータに設定するブロッククラス
;;タイプはdrag,virusのどちらか、connectは接続方向、matchedはマッチチェック用
(defstruct (block) (token nil)  )

;;セルのデータを返すコールバック関数
(def-f callback-make-cell-data (index cell)
  (make-block :token nil )
)

;;セルの見た目を表すオブジェクト作成関数
(def-f callback-make-cell-obj ( x y w h index )

  (new-label
   x y
   w h ;w, h
   (format nil "a~d" index);str
   )
)

;;セルのアップデート関数
(def-f callback-update-cell (cell)
  (let (obj block)
	(setq obj (cell-obj cell))
	(setq block (cell-data cell))
	(if (block-token block)
		(setf (label-text obj) (block-token block))
		(setf (label-text obj) " "))
	)
)

;;セル押下時メソッド
(def-f callback-push-cell (cell)
  (let (block)

	(setq block (cell-data cell))

	(cond 
	  ((not (equal (block-token block) nil) )
		(print "token exist. your push other cell"))
	  (*finish-game*
	   (print "finish")
	   )
	  (t
	   (set-hand block "o")
	   ;;enemy
	   (enemy-hand)
	   (grid-update *grid*)
	   ;;check
	   (cond 
		 ((check-win)
		   (print "win")
		   (setq *finish-game* t)
		  )
		 ((check-lose)
		  (print "lose")
		  (setq *finish-game* t))
	   );check win lose
	   );t
	  );cond
   );let
	  
)

(defun game-start()

  (lr-begin)  
  (game-variable)
  (game-init)
  (lr-start)
)

(def-f game-init()

  ;グリッド配列をボタンで初期化

  
  (update-money)

)




(def-f push-quit()
  (print "quit")
  (setq *quit* 1)
)


(def-f update-money()
  (let (str)
    (setq str (format nil "$ ~d" *money*))
    (set-text *label-money* str)
    )
)

;;グリッドボタン押下時
;; (def-f push-grid (obj)

;;   (print obj)
;;   (set-hand obj "o")
;;   ;;enemy
;;    (enemy-hand)
;; )


;;指定のグリッド番号に手をセット
(def-f set-hand ( block hand  )
  (setf (block-token block) hand)
  
)


;;敵の手を決定
(def-f enemy-hand()

  ;;単なるランダム

  (let ((target-cell nil) (empty-cell-array nil) (block nil) (empty-cell) )
	(setq empty-cell-array (get-empty-cell-array (grid-cell-array *grid*)))
;; 	(setq empty-cell (grid-random-get-empty *grid*))
	(setq empty-cell-array (get-can-put-cell-array))

	(cond 
      ;打てる場所が無い
	  ((= (length empty-cell-array) 0) (print "utenaiyo"))
	  ;ランダムに配置
	  ( t
	   (setq target-cell (aref empty-cell-array (random (length empty-cell-array))))
	   (print (format nil "computer hand is ~d,~d > x" (cell-x target-cell) (cell-y target-cell) ))
	   (setq block (cell-data target-cell))
	   (print block)
	   (set-hand block "x")
	   )
	  )
	);let

  )

;;未配置のセルリストを取得
(def-f get-can-put-cell-array()
	(remove-if 
	 #'(lambda(cell) (not (equal (block-token (cell-data cell)) nil)))
			  (grid-cell-array *grid*)
			  )
)

;;勝敗チェック
(def-f check-win()
  (if
    (< 0 (length (grid-check-match *grid* 3 t t t #'match-check-o)))
	t
	nil
	)
)
;;勝敗チェック
(def-f check-lose()
  (if
    (< 0 (length (grid-check-match *grid* 3 t t t #'match-check-x)))
	t
	nil
	)
)

;;グリッドのマッチチェックに登録する判定関数
(def-f match-check-o(block)
  (if (equal (block-token block) "o")
	  t
	  nil)
)
(def-f match-check-x(block)
  (if (equal (block-token block) "x")
	  t
	  nil)
)

(def-f win()
  (setq *money* (+ *money* 10))
  (update-money)
  (set-text *message-label*  "PIKO >>>>>> WIN")
)

(def-f draw()
  (set-text *message-label*  "PIKO >>>>>> DRAW")
)

(def-f lose()
  (setq *money* (- *money* 10))
  (update-money)
  (set-text *message-label*  "PIKO >>>>>> LOSE")
)

(def-f push-restart()
  (game-start)
)

