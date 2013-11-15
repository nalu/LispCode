(load "LispRough.lisp")
;--------------------------------- GAME ---------------------------------


(defun game-variable()

  (def-v *message-label* (new-label 26 2 13 3 "message"))
  (def-v *button-quit* (new-button 28 30 5 3 "[Q]uit" 'q #'push-quit))
  (def-v *label-level* (new-label 1 6 7 3 "level"))

  (def-v *level* 1)
  (def-v *hp-gage* 10)
  (def-v *label-next* (new-label 34 6 7 3 "NEXT"))
  

  (def-v *button-next* (new-button 1 12 7 3 "[N]ext" 'n #'push-next))  
  (def-v *button-fall* (new-button 1 15 7 3 "[L]eft" 'n #'push-fall))
  (def-v *button-fall* (new-button 1 18 7 3 "[R]ight" 'n #'push-fall))
  (def-v *button-fall* (new-button 1 21 7 3 "[F]all" 'n #'push-fall))
  (def-v *button-rotate-right* (new-button 1 24 7 3 "[R]otate[R]" 'n #'push-fall))
  (def-v *button-rotate-left* (new-button 1 27 7 3 "[R]otat[L]" 'n #'push-fall))
  

  (def-enum 'hand '(goo choki per hand-max))
  (def-v *player-hand* goo)
  (def-v *enemy-hand* goo)


  
   (def-v *grid* (new-grid 10 2 8 18 3 2))

);end-variable


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
)




(def-f push-quit()
  (setq *quit* 1)
)


(def-f update-level()
  (let (str)
    (setq str (format nil "level:~d" *level*))
    (set-text *label-level* str)
    )
)


(def-f push-grid (obj)
  (print (button-text obj))
   ( grid-set-hand *grid* (stoi (button-text obj)) "o")

  ;;enemy
   (enemy-hand)
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


(def-f push-next()
  
)

(def-f push-fall()
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


 



