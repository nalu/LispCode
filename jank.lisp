(load "LispRough.lisp")
;--------------------------------- GAME ---------------------------------


(defun game-variable()

  (def-v *message-label* (new-label 3 2 13 3 "message"))
  (def-v *button-quit* (new-button 15 18 5 3 "[Q]uit" 'q #'push-quit))
  (def-v *label-money* (new-label 18 6 7 3 "money"))
  
  (def-v *money* 100)
  (def-v *hp-gage* 10)
  


  (def-v *button-player-goo* (new-button 3 14 5 3 "[G]oo" 'g #'push-goo))
  (def-v *button-p-choki* (new-button 9 14 5 3 "[C]hoki" 'c #'push-choki))
  (def-v *button-per* (new-button 15 14 5 3 "[P]er" 'p #'push-per))
  (def-v *label-enemy-hand*  (new-label 9 6 5 5 "???"))
 
  (def-enum 'hand '(goo choki per hand-max))
  (def-v *player-hand* goo)
  (def-v *enemy-hand* goo)

  

);end-variable


;;ゲージクラス作りたい
;; (defstruct gage
;;   (value 0)
;;   (max-value 0)


(defun game-start()

  (lr-begin)  
  (game-variable)
  (game-init)
  (lr-start)
)

(def-f game-init()
  (setq *mode* 'hide)  

  (update-money)

)




(def-f push-quit()
  (setq *quit* 1)
)


(def-f update-money()
  (let (str)
    (setq str (format nil "$ ~d" *money*))
    (set-text *label-money* str)
    )
)




(def-f push-goo()
  (setq *player-hand* goo)
  (open-enemy-hand)
)

(def-f push-choki()
  (setq *player-hand* choki)
  (open-enemy-hand)
)

(def-f push-per()
  (setq *player-hand* per)
  (open-enemy-hand)
)

(def-f open-enemy-hand()
  (setq *enemy-hand* (random hand-max))

  ;ラベルにセット
  (let (str)
	(cond
	  ((eql *enemy-hand* goo) (setq str "goo"))
	  ((eql *enemy-hand* choki) (setq str "choki"))
	  ((eql *enemy-hand* per) (setq str "per"))
	  )
	(set-text *label-enemy-hand* str)
  )

  ;勝敗判定

  (cond
	((eql *player-hand* goo) 
	 (cond
	   ((eql *enemy-hand* goo) (draw))
	   ((eql *enemy-hand* choki) (win))
	   ((eql *enemy-hand* per) (lose))
	   ))
	((eql *player-hand* choki) 
	 (cond
	   ((eql *enemy-hand* goo) (lose))
	   ((eql *enemy-hand* choki) (draw))
	   ((eql *enemy-hand* per) (win))
	   ))
	((eql *player-hand* per) 
	 (cond
	   ((eql *enemy-hand* goo) (win))
	   ((eql *enemy-hand* choki) (lose))
	   ((eql *enemy-hand* per) (draw))
	   ))
	)
  


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
