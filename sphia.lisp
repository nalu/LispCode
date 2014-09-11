(load "LispRough.lisp")
;--------------------------------- GAME ---------------------------------


(defun game-variable()

  (def-v label-total-number (new-label 13 2 13 3 "TOTAL NO:"))
  (def-v *message-label* (new-label 26 2 13 3 "message"))
  (def-v *label-next-break* (new-label 13 5 26 3 "Next Break No"))


  (def-v *button-quit* (new-button 28 30 5 3 "[Q]uit" 'q #'push-quit))

  (def-v *label-turn* (new-label 1 2 10 3 "TURN:"))
  (def-v *label-time* (new-label 1 5 10 3 "TIME:"))
  (def-v *label-nolma* (new-label 1 8 10 3 "NOLMA:"))


  (def-v *label-core-sphia* (new-label 21 8 10 3 "CORE:"))

;;   (def-v *label-next* (new-label 34 6 7 3 "NEXT"))
  


  ;;変数
  (def-v *core-number* 0)
  (def-v *select-coin-vec* (new-vec))

  ;;ゲーム状態遷移

  ;;grid用データを作成
   (def-v grid (new-grid 14 12 4 4 6 4 
						   #'callback-make-cell-obj 
						   #'callback-make-cell-data 
						   #'callback-update-cell
						   'g
						   #'callback-push-cell
						   );new-grid
	 );def-v

   ;;マッチチェック
;;    (def-v *match-require-num* 3);３つで消える
);end-variable


;;セルのデータに設定するブロッククラス
;;タイプはdrag,virusのどちらか、connectは接続方向、matchedはマッチチェック用
(defstruct (coin) (number 0) (color nil) (type nil) (checked nil)  )


;;セルのデータを返すコールバック関数
(def-f callback-make-cell-data (index cell)
;;   (make-block)
  nil
)

;;セルの見た目を表すオブジェクト作成関数
(def-f callback-make-cell-obj ( x y w h index )
  (new-label
   x y
   w h ;w, h
   (format nil "~d " index);str
   )

)

;;セルのアップデート関数
(def-f callback-update-cell (cell)


  (let (coin label button str)
	(setq coin (cell-data cell))
	(setq button (cell-button cell))
	(setq label (cell-obj cell))
	;;チェック済みとそうでない場合で見た目を変える
	(if (equal (coin-checked coin) t)
		(setq str (format nil "[~d] >>~d" (button-key button) (coin-number coin)));t
		(setq str (format nil "[~d] ~d" (button-key button) (coin-number coin)));t
		);if
	(set-text label  str)
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
;;   (setf (label-text *label-core-sphia*) (format nil "CORE: < ~d >" *core-number*))
  (setf @*label-core-sphia*.text (format nil "CORE: < ~d > " *core-number*))
)

;;セル選択
(def-f callback-push-cell(cell)
  (let (coin)
	(setq coin @cell.data)
	(setf @coin.checked t)
	
	)

  (update-total-number)
  (grid-update grid)
)


(def-f next-turn()
  (grid-put-random-sphia grid)
  (set-next-core-number)
  (update-core-number)
  (grid-update grid)
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

;;トータルナンバーを更新
(def-f update-total-number()
  (let (count checked-coin-array coin)
	(setf count 0)
	(setf checked-coin-array (get-selected-coin-array))
	(for (i 0 (length checked-coin-array)) 
	  (setf coin (elt checked-coin-array i))
	  (+= count @coin.number)
	  );for
	(setf @label-total-number.text (format nil "TOTAL NO:~d" count ))
	)
)

;;選択済みのコイン配列を取得
(def-f get-selected-coin-array()
  (remove nil (map 'list (lambda(cell) (if (equal @cell.data.checked t) @cell.data )) @grid.cell-array))


)