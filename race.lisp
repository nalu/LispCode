(load "LispRough.lisp")
;--------------------------------- GAME ---------------------------------


(defun game-variable()

  ;;表示
  (def-v *message-label* (new-label 34 2 7 3 "message"))
  (def-v *label-score* (new-label 34 9 7 3 "Score:"))
  (def-v *label-speed* (new-label 34 12 7 3 "" ))
  (def-v *label-fuel* (new-label 34 15 7 3 "Fuel 100" ))

  ;;マップ
  (def-v *race* (new-race 4 2 30 32 1 2 3 30 1000 ))
  (def-v *label-player* (new-label 19 28 3 3 "P"))

  (def-v *score* 0)
  (def-v *fuel-default* 10)
  (def-v *fuel-max* 200)
  (def-v *fuel-min* 0)
  (def-v *fuel* 0)
  (def-v *speed-default* 27)
  (def-v *speed-max* 300 )
  (def-v *speed-min* 0)
  (def-v *speed* 0);; m/secの速度( * 3600 / 1000で km/hが出せる) 27m/secはだいたい100km/h
  (def-v *speed-up-val* 10)
  (def-v *speed-down-val* 10)
  
  ;;入力
  (def-v *button-next* (new-button 34 19 7 3 "[N]ext" 'n #'push-next))  
  (def-v *button-up* (new-button 34 22 7 3 "[W] Accele" 'w #'push-up))
  (def-v *button-left* (new-button 34 25 7 3 "[A] Left" 'a #'push-left))
  (def-v *button-right* (new-button 34 28 7 3 "[D] Right" 'd #'push-right))
  (def-v *button-down* (new-button 34 31 7 3 "[S] Brake" 's #'push-down))
  (def-v *button-quit* (new-button 34 34 7 3 "[Q]uit" 'q #'push-quit))

  ;;タイトル
  (new-title "race" #'init-gamemain)


  ;;ゲーム状態遷移
  (def-enum 'mode '(title countdown race))
  (def-v *mode* race)
  (def-v *stage-no* 0)

   
);end-variable

;;セルのデータに設定するブロッククラス
;;タイプはdrag,virusのどちらか、connectは接続方向、matchedはマッチチェック用
(defstruct (block) (color nil) (type nil) (connect nil) (direction nil) (matched nil) (moved nil)  )

;;セルのデータを返すコールバック関数
(def-f callback-make-cell-data (index cell)
;;   (make-block)
  nil
)


(defun game-start()

  (lr-begin 42 40 )  
  (game-variable)
  (game-init)
  (lr-start)
)

(def-f game-init()
)




(def-f push-quit()
  (setq *quit* 1)
)

;;ゲームメイン初期化

(def-f init-gamemain()
  
  (setq *stage-no* 0)
  (init-stage *stage-no*)
)

;;ステージ初期化
(def-f init-stage( stage-no )

  (race-init *race*)
  (setq *speed* *speed-default*)
  (update-speed)
  (setq *fuel* *fuel-default*)
  (update-fuel)

  ;;ステージイベント設定
  (cond 
	;;stage 0
	((= stage-no 0)
	  (race-add-event *race* 0 0 'left-line 5)
	  (race-add-event *race* 0 0 'right-line 22)
	  (race-add-event *race* 300 0 'enemy-yellow 10)
	  (race-add-event *race* 500 0 'left-line 4)
	  (race-add-event *race* 500 0 'right-line 21)
	  (race-add-event *race* 500 0 'left-line 3)
	  (race-add-event *race* 500 0 'right-line 20)
	  (race-add-event *race* 600 0 'left-line 4)
	  (race-add-event *race* 600 0 'right-line 21)
	  )
	;;stage 0
	((= stage-no 1)
	  (race-add-event *race* 0 0 'left-line 8)
	  (race-add-event *race* 0 0 'right-line 20)
	  (race-add-event *race* 500 0 'left-line 9)
	  (race-add-event *race* 500 0 'right-line 19)
	  (race-add-event *race* 700 0 'left-line 10)
	  (race-add-event *race* 700 0 'right-line 18)
	  )
	);cond
)


;画面更新
(def-f update-speed()
  (set-text *label-speed* (format nil "~d km/h"  (* *speed* 3.6) ))
)

(def-f update-fuel()
  (set-text *label-fuel* (format nil "FUEL:~d" *fuel*))
)

;;ターンを進める
(def-f next-turn()

  (race-forward *race* *speed*)
  (update-speed)
  
  ;;燃料
  (add-fuel -1)
  (update-fuel)

  

  ;;ゴールチェック
  (if (check-goal) 
 	  (show-clear)
	  )

  ;;壁衝突チェック
  (if (check-hit-wall)
	  (clash-player)
	  )

  ;;ゲームオーバーチェック
  (if (check-gameover)
	  (show-gameover)
	  )
)

;;Nextボタン。次のターンに進める
(def-f push-next()
  (next-turn)
)

(def-f push-up()
  (add-speed *speed-up-val*)
  (update-speed)
)

(def-f push-down()
  (add-speed (- 0 *speed-down-val*))
  (update-speed)
)

(def-f push-right()
  (move-player 1 0)
  (next-turn)
)

(def-f push-left()
  (move-player -1 0)
  (next-turn)
)

;;スピード変更
(def-f add-speed(val)
  (+= *speed* val)
  (if (> *speed* *speed-max*)
	  (setq *speed* *speed-max*)
	  )
  (if (< *speed* *speed-min*)
	  (setq *speed* *speed-min*)
	  )
)
;;燃料変更
(def-f add-fuel(val)
  (+= *fuel* val)
  (if (> *fuel* *fuel-max*)
	  (setq *fuel* *fuel-max*)
	  )
  (if (< *fuel* *fuel-min*)
	  (setq *fuel* *fuel-min*)
	  )
)

;;プレイヤーの位置からｘｙの相対位置をセット
(def-f move-player(x y)
  (+= (label-x *label-player*) x)
  (+= (label-y *label-player*) y)
)

;;壁衝突チェック
(def-f check-hit-wall ()
  (let (player-x player-w)
	(setq player-x (- (label-x *label-player*) (label-x *race*)))
	(setq player-w (label-w *label-player*))
  (cond
	;;左衝突
	((< player-x (race-curse-line-left-x *race*))
		 t
	 )
	;;右衝突
	((> (+ player-x player-w) (race-curse-line-right-x *race*))
		 t
	 )
	(t
	 nil)
	
		 
	 );cond
  );let
)

;;クラッシュ
(def-f clash-player()
  (setf (label-text *label-player*) "x")
  (show-gameover)
)

;;クリアチェック
(def-f check-goal()

  (if (>= (race-player-position *race*) (race-curse-length *race*))
	  t
	  nil)

)

(def-f show-clear()
  (set-text *message-label* "clear")
  (++ *stage-no*)
  (init-stage *stage-no*)
  );

;;ゲームオーバーチェック
(def-f check-gameover()

  (if (<= *fuel* 0 )
	  t
	  nil
	  )
)

(def-f show-gameover()
  (set-text *message-label* "gameover")
)




