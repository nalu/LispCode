(load "LispRough.lisp")
;--------------------------------- GAME ---------------------------------




(defun game-variable()



  ;;表示
  (def-v message-label (new-label 34 2 7 3 "message"))
  ( def-v label-stage (new-label 34 6 7 3 "Stage:"))  
  ( def-v label-score (new-label 34 9 7 3 "Score:"))  
  ( def-v label-stock (new-label 34 12 7 3 "Stock"))  

  ;;変数
  (def-v player-speed 1)
  (def-v vec-player-bullet (new-vec))
  (def-v vec-enemy (new-vec))
  (def-v bullet-speed 3)
  (def-v enemy-speed 0)
  (def-v enemy-w 3)
  (def-v enemy-h 3)
  (def-v enemy-map-x 1)
  (def-v enemy-map-y 1)
  (def-v score (new-parameter 0 0 999999 ))
  (def-v score-normal-enemy 100)
  (def-v player-stock (new-parameter 3 0 3))
  (def-v enemy-atack-wait-default 5)
  (def-v enemy-atack-wait 5)

  ;;obj
;;   (def-v label-player (new-label 20 34 3 3 "P"))


  ;;Action World
  (def-v action-world (new-action-world 0 0 30 20 1 3))
  (def-v player (generate-player 3 3 3 3))

  
  ;;入力
  (def-v button-next (new-button 34 19 7 3 "[N]ext" 'n #'push-next))  
;;   (def-v button-up (new-button 34 22 7 3 "[W] Accele" 'w #'push-up))
  (def-v button-left (new-button 34 25 7 3 "[A] Left" 'a #'push-left))
  (def-v button-right (new-button 34 28 7 3 "[D] Right" 'd #'push-right))
;;   (def-v button-down (new-button 34 31 7 3 "[S] Brake" 's #'push-down))
  (def-v button-down (new-button 34 31 7 3 "[J] jump" 'b #'push-jump))
  (def-v button-quit (new-button 34 34 7 3 "[Q]uit" 'q #'push-quit))


  ;;タイトル
  (def-v *title* (new-title "Action Ball" #'new-game-callback))
  

  ;;ゲーム状態遷移
  (def-enum 'mode '(mode-title mode-ready mode-main mode-clear mode-gameover mode-score))
  (def-enum 'enemy-type '(enemy-type-a enemy-type-b enemy-type-c))
  (def-v mode mode-main)
  (def-v stage-no 0)

   
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
  (update-score)
)


(def-f init-stage( stage-no )
  ;;ステージ開始時初期化
  
  (generate-enemy 10 3 3 3 enemy-type-a)
  
)


;画面更新
(def-f update-score()
  (set-text label-score (format nil "Score:~d" @score.value ))
)

(def-f update-fuel()
  (set-text *label-fuel* (format nil "FUEL:~d" *fuel*))
)


;;ターンを進める
(def-f next-turn()

  ;;   (race-forward *race* *speed*)
  (action-forward action-world)

  
;;   (check-hit-bullet)

  ;;ヒットチェックとダメージ
;;   (damage-conflict-object shooting 'enemy 'player-bullet)

;;   ;;デッドエフェクト終了のものを削除
  

;;   ;;ダメージ状態に応じて処理
;;   ;;リスト削除を含むので後ろから処理
;;   (loop for i from (- (length @shooting.vec-obj) 1) above -1 do
;; 	   (let (obj)
;; 		 (setq obj (vec-get @shooting.vec-obj i))
;; 		 (if (<= @obj.hp 0)
;; 			 (dead-obj obj)
;; 			 );if
;; 		 );let
;; 	   );loop


;;   ;;敵攻撃
;;   (-= enemy-atack-wait 1)
;;   (cond
;; 	(
;; 	 (<= enemy-atack-wait 0)
;; 	 (atack-random-enemy)
;; 	  (setq enemy-atack-wait enemy-atack-wait-default)
;; 	 )
;; 	)
  

;;   ;;クリアチェック
;;   (if (check-clear-stage) 
;;  	  (show-clear)
;; 	  )

;;   ;;壁衝突チェック
;;   (if (check-hit-wall)
;; 	  (clash-player)
;; 	  )

;;   ;;ゲームオーバーチェック
;;   (if (check-gameover)
;; 	  (show-gameover)
;; 	  )
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
;;   (next-turn)
  (move-player player-speed 0)
  (next-turn)
)

(def-f push-left()
  (move-player (- player-speed) 0)
  (next-turn)
)

(def-f push-jump()
  (shot-player)
  (next-turn)
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
  (world-move-obj action-world player x y)
;;   (+= @label-player.x x)
;;   (+= @label-player.y y)
)

;;自機ショット
(def-f shot-player ()
  (vec-push vec-player-bullet 
			(new-shooting-obj 
			 shooting
			 @label-player.x
			 (- @label-player.y 3)
			 3 3 
			 'player-bullet
			 bullet-speed
			 270
			 "|")
			)
)

;;プレイヤ作成
(def-f generate-player (x y w h )

  (new-action-obj
   action-world
   x y w h 'player
   0 0 1
   "P")
)

;;敵作成
(def-f generate-enemy (x y w h type-no)

  (let (obj-str)
	(setq obj-str "?")
	(if (= type-no 1) (setq obj-str "e"))
	(if (= type-no 2) (setq obj-str "E"))
	(if (= type-no 3) (setq obj-str "B"))

  (vec-push vec-enemy
			(new-action-obj
			 action-world
			 x y
			 w h
			 'enemy
			 enemy-speed
			 270 1
			 obj-str)
			)

  );let
)

;;敵と弾ヒットチェック
(def-f check-hit-bullet()

  (for (i 0 (length vec-player-bullet))
	(for (j 0 (length vec-enemy))
	  (let (bullet enemy)
		(setq bullet (vec-get vec-player-bullet i))
		(setq enemy (vec-get vec-enemy j))
		(if (hitcheck-rect-in-rect 
			 @bullet.x @bullet.y @bullet.w @bullet.h
			 @enemy.x @enemy.y @enemy.w @enemy.h)
			(return-from check-hit-bullet enemy)
			nil
			);if

	  );let
	));for
)



;;矩形と矩形のヒットチェック
(def-f hitcheck-rect-in-rect ( ax ay aw ah bx by bw bh)
  (if
   (and 
	(< ax (+ bx bw)) 
	(< bx (+ ax aw))
	(< ay (+ by bh))
	(< by (+ ay ah)))
   t
   nil
   )

)

;;ステージクリアチェック
(def-f check-clear-stage ()
  (if (= 0 (length (shooting-get-vec-object shooting 'enemy)))
  t
  nil)
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


;;死亡処理
(def-f dead-obj (obj)
  (cond
	((equal @obj.type 'enemy)
	 (cond 
	   ;;既にエフェクト出てたら削除
	   (@obj.dead-effect 
		(shooting-remove-obj shooting obj)
		)
	   ;;死亡エフェクトとスコア
	   (t
		(parameter-add score score-normal-enemy)
		(update-score)
		(setf @obj.dead-effect t)
		(setf @obj.label.text "x")
		
		)
	   )
	 )
	 ;;弾は即削除
	((equal @obj.type 'player-bullet)
	 (shooting-remove-obj shooting obj)
	 )
  )

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




;;敵攻撃
(def-f atack-random-enemy()
  (let (enemy-vec enemy)
	(setq enemy-vec (shooting-get-vec-object shooting 'enemy))
	(setq enemy (elt enemy-vec (random (length enemy-vec))))
	(atack-enemy enemy)
	);let
)

(def-f atack-enemy( enemy )

  (new-shooting-obj 
   shooting
   @enemy.label.x
   (+ @enemy.label.y 3)
   3 3 
   'enemy-bullet
   bullet-speed
   90
   "|")
  
)
