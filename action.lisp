(load "LispRough.lisp")
;--------------------------------- GAME ---------------------------------




(defun game-variable()



  ;;表示
  (def-v message-label (new-label 34 2 7 3 "message"))
;;   ( def-v label-stage (new-label 34 6 7 3 "Stage:"))  
  ( def-v label-score (new-label 34 9 7 3 "Score:"))  
;;   ( def-v label-stock (new-label 34 12 7 3 "Stock"))  

  ;;変数
  (def-v player-speed 1)
  (def-v default-player-jump-power 4)
  (def-v enemy-speed 1)
  (def-v enemy-w 3)
  (def-v enemy-h 3)
  (def-v player-stock (new-parameter 3 0 3))
  (def-v score (new-parameter 0 0 9999))

  (def-v enemy-generate-timer 0)
  (def-v enemy-generate-wait 10)


  ;;Action World
  (def-v action-world (new-action-world 0 0 30 20 1 3))
  (def-v player (generate-player 3 14 3 3))

  
  ;;入力
  (def-v button-next (new-button 34 19 7 3 "[N]ext" 'n #'push-next))  
;;   (def-v button-up (new-button 34 22 7 3 "[W] Accele" 'w #'push-up))
  (def-v button-left (new-button 34 25 7 3 "[A] Left" 'a #'push-left))
  (def-v button-right (new-button 34 28 7 3 "[D] Right" 'd #'push-right))
;;   (def-v button-down (new-button 34 31 7 3 "[S] Brake" 's #'push-down))
  (def-v button-down (new-button 34 31 7 3 "[J] jump" 'j #'push-jump))
  (def-v button-quit (new-button 34 34 7 3 "[Q]uit" 'q #'push-quit))


  ;;タイトル
  (def-v *title* (new-title "Action Ball" #'new-game-callback))
  

  ;;ゲーム状態遷移
  (def-enum 'mode '(mode-title mode-ready mode-main mode-clear mode-gameover mode-score))
  (def-enum 'enemy-type '(enemy-type-a enemy-type-b enemy-type-c))
  (def-v mode mode-main)
;;   (def-v stage-no 0)

   
);end-variable




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


(def-f new-game-callback()
  (init-gamemain)
)


;;ゲームメイン初期化

(def-f init-gamemain()

  (setq stage-no 0)
  (init-stage stage-no)
;;   (update-score)
)


(def-f init-stage( stage-no )
  ;;ステージ開始時初期化
  (setf enemy-generate-timer enemy-generate-wait)
)


;画面更新
(def-f update-score()
  (set-text label-score (format nil "Score:~d" @score.value ))
)


;;ターンを進める
(def-f next-turn()

  ;;   (race-forward *race* *speed*)

  ;;一定テンポで敵を生成
  (+= enemy-generate-timer 1)
  (cond ((<= enemy-generate-wait enemy-generate-timer )
		 (generate-enemy 26 20 3 3 enemy-type-a)
		 (setf enemy-generate-timer 0)
	  ))

  ;;ワールド更新
  (action-forward action-world)

  ;;画面左から出たものは消す
  (let (enemy-vec)
	(setf enemy-vec (world-get-obj-vec action-world 'enemy))
	(setf enemy-vec (remove-if (lambda(enemy)(> (+ @enemy.x @enemy.w) 0) ) enemy-vec))
	(world-remove-obj-vec action-world enemy-vec)
	);let

  ;;ヒットチェック
  (world-hit-check action-world 'player 'enemy)

  ;;プレイヤーがジャンプ中はヒットしたら敵が死亡
  (let (enemy-vec enemy)
	(setf enemy-vec (world-get-obj-vec action-world 'enemy))
	(length enemy-vec)
 	(for-- (i (- (length enemy-vec) 1) 0)   
	  (setq enemy (elt enemy-vec i))
	  (cond ( (and @enemy.hit-flag (not @enemy.dead-effect) )
			 (cond 
			   (@player.jump-flag
				(dead-enemy enemy)
				(action-jump action-world player)
				);enemy dead
			   ( t
				(dead-player)
				);player dead
			   ));cond jump
			);cond hit
	);for
  );let
  

)

;;Nextボタン。次のターンに進めるs
(def-f push-next()
  (next-turn)
)

(def-f push-up()
)

(def-f push-down()
)

(def-f push-right()
  (move-player player-speed 0)
  (next-turn)
)

(def-f push-left()
  (move-player (- player-speed) 0)
  (next-turn)
)

(def-f push-jump()
  (action-jump action-world player)
  (next-turn)
)

;;プレイヤーの位置からｘｙの相対位置をセット
(def-f move-player(x y)
  (world-move-obj action-world player x y)
)

;;ジャンプ
(def-f jump-player()
  (setf @player.angle 270)
  (setf @player.speed 10)
)

;;プレイヤ作成
(def-f generate-player (x y w h )

  (new-action-obj
   action-world
   x y w h 'player
   0 0 1 default-player-jump-power
   "P")
)

;;敵作成
(def-f generate-enemy (x y w h type-no)

  (let (obj-str)
	(setq obj-str "?")
	(if (= type-no enemy-type-a) (setq obj-str "e"))
	(if (= type-no enemy-type-b) (setq obj-str "E"))
	(if (= type-no enemy-type-c) (setq obj-str "B"))

	(new-action-obj
	 action-world
	 x y
	 w h
	 'enemy
	 enemy-speed
	 180 1 0
	 obj-str)

  );let
)


;;死亡処理
(def-f dead-enemy (obj)
  (world-dead-obj obj obj "x" 3)
  (setf @obj.speed 0)
  (parameter-add score 1)
  (update-score)
)

(def-f dead-player ()
  (setf @player.label.text "x")
)


(def-f show-clear()
  (set-text message-label "clear")
  (++ stage-no)
  (init-stage stage-no)
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



