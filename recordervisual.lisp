(load "LispRough.lisp")
;--------------------------------- GAME ---------------------------------




(defun game-variable()


  ;;タイトル
  ;; (def-v *title* (new-title "galaga like game" #'new-game-callback))


  ;;変数
  (def-v player-speed 1)
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

  ;;view
  
  (def-v message-label (new-label 34 2 7 3 "message"))
  (def-v label-stage (new-label 34 6 7 3 "Stage:"))  
  (def-v label-score (new-label 34 9 7 3 "Score:"))  
  (def-v player-guage (new-guage 34 12 7 3 "stock" player-stock ))
  (def-v button-actionbar-setting (new-button 15 1 3 3 "[M]enu" 'm #'push-actionbar-setting))
  (def-v tab-button-record (new-button 1 4 7 3 "[RT]record" 'rt #'push-record-tab))
  (def-v tab-button-list (new-button 9 4 7 3 "[LT]List" 'lt #'push-list-tab))
  (def-v recorder-image-label (new-label 5 12 7 3 "<Stop>")) 
  (def-v button-record-start (new-button 1 20 7 3 "[R]ecord" 'r #'push-record-start))
  (def-v button-record-start (new-button 9 20 7 3 "[S]top" 'r #'push-record-stop))
  
  

  ;;obj
  ;; (def-v label-player (new-label 20 34 3 3 "P"))
  (def-v player-obj nil)


  ;;shootng
  (def-v shooting (new-shooting 0 0 20 20))
  
  ;;入力
  (def-v button-next (new-button 34 19 7 3 "[N]ext" 'n #'push-next))  
  (def-v button-left (new-button 34 25 7 3 "[A] Left" 'a #'push-left))
  (def-v button-right (new-button 34 28 7 3 "[D] Right" 'd #'push-right))
  (def-v button-down (new-button 34 31 7 3 "[B] Beam" 'b #'push-beam))
  (def-v button-quit (new-button 34 34 7 3 "[Q]uit" 'q #'push-quit))

  

  ;;ゲーム状態遷移
  (def-enum 'mode '(mode-title mode-ready mode-main mode-clear mode-gameover mode-score))
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

(defparameter map
  '(
	;;stage0
	(
	 ( 0 0 0 0 0 0 0 0 0 0 )
	 ( 0 0 0 0 0 0 0 0 0 0 )
	 ( 0 0 0 0 0 0 0 0 0 0 )
	 ( 0 0 0 0 0 0 0 0 0 0 )
	 ( 0 0 0 0 1 1 0 0 0 0 )
	 )
	;;stage1
	(
	 ( 0 0 0 0 3 3 0 0 0 0 )
	 ( 0 0 2 2 2 2 2 2 0 0 )
	 ( 0 0 2 2 2 2 2 2 0 0 )
	 ( 1 1 1 1 1 1 1 1 1 1 )
	 ( 1 1 1 1 1 1 1 1 1 1 )
	 )
	)
)

(def-f init-stage( stage-no )


  ;;ステージ開始時初期化
  (setq enemy-atack-wait enemy-atack-wait-default)

  

  ;;マップ
  (let (enemy-map)
  (setq enemy-map 
		(elt map stage-no)
		)
  (let (map-w map-h type-no)
	(setq map-w (length (vec-get enemy-map 0)))
	(setq map-h (length enemy-map))
	(for (i 0 map-h)
	  (for (j 0 map-w)

		(setq type-no (vec-get (vec-get enemy-map i) j))
		
		(if (not (= type-no 0) )
			(generate-enemy 
			 (* (+ enemy-map-x j) enemy-w)
			 (* (+ enemy-map-y i) enemy-h) 
			 enemy-w 
			 enemy-h
			 type-no
			 )
			);if

	  ));for
	);let

  )

  ;;plyer
  (generate-player 20 34 3 3)

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

  (shooting-forward shooting)

  

  ;;ヒットチェックとダメージ
  (damage-conflict-object shooting 'enemy 'player-bullet)
  (damage-conflict-object shooting 'player 'enemy-bullet)

  ;;デッドエフェクト終了のものを削除
  

  ;;ダメージ状態に応じて処理
  ;;リスト削除を含むので後ろから処理
  (loop for i from (- (length @shooting.vec-obj) 1) above -1 do
	   (let (obj)
		 (setq obj (vec-get @shooting.vec-obj i))
		 (if (<= @obj.hp 0)
			 (dead-obj obj)
			 );if
		 );let
	   );loop


  ;;敵攻撃
  (-= enemy-atack-wait 1)
  (cond
	(
	 (<= enemy-atack-wait 0)
	 (atack-random-enemy)
	  (setq enemy-atack-wait enemy-atack-wait-default)
	 )
	)
  

  ;;クリアチェック
  (if (check-clear-stage) 
 	  (show-clear)
	  )

;;   ;;壁衝突チェック
;;   (if (check-hit-wall)
;; 	  (clash-player)
;; 	  )

;;   ;;ゲームオーバーチェック
;;   (if (check-gameover)
;; 	  (show-gameover)
;; 	  )
)

;;Nextボタン。次のターンに進める
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
;;   (next-turn)
  (move-player (- player-speed) 0)
  (next-turn)
)

(def-f push-actionbar-setting()
  (print "setting")
)
(def-f push-record-tab()
  (print "tab-record")
)

(def-f push-list-tab()
  (print "tab-list")
)

(def-f push-record-start()
  (print "record-start")
)

(def-f push-record-stop()
  (print "record-stop")
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
  (let (player)
    (setq player 
	  (elt (shooting-get-vec-object shooting 'player) 0))
    (shooting-move-obj shooting player x y)
    )


)

;;プレイヤーオブジェクト作成
(def-f generate-player (x y w h)
    (new-shooting-obj
     shooting
     x
     y
     w h
     'player
     0
     0
     "P")
)

;;自機ショット
(def-f shot-player ()

  (let (player)
    (setq player (elt (shooting-get-vec-object shooting 'player) 0))

    (new-shooting-obj 
     shooting
     @player.label.x
     (- @player.label.y 3)
     3 3 
     'player-bullet
     bullet-speed
     270
     "|")
    )
)

;;敵作成
(def-f generate-enemy (x y w h type-no)

  (let (obj-str)
	(if (= type-no 1) (setq obj-str "e"))
	(if (= type-no 2) (setq obj-str "E"))
	(if (= type-no 3) (setq obj-str "B"))

	(new-shooting-obj
	 shooting
	 ;; (* x w)
	 ;; (* y h)
	 x y
	 w h
	 'enemy
	 enemy-speed
	 270
	 obj-str)
	
  );let
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
	((equal @obj.type 'enemy-bullet)
	 (shooting-remove-obj shooting obj)
	 )
	;;プレイヤー
	((equal @obj.type 'player)
	 (dead-player obj)
	 )
  )

)

(def-f dead-player (obj)
  
  (setf @obj.dead-effect t)
  (setf @obj.label.text "x")
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


