(load "LispRough.lisp")
;--------------------------------- GAME ---------------------------------


(defun game-variable()

  (def-v *message-label* (new-label 3 2 13 3 "message"))
  (def-v *button-quit* (new-button 15 18 5 3 "[Q]uit" 'q #'push-quit))
  (def-v *label-money* (new-label 18 6 7 3 "money"))
  
  (def-v *money* 100)
  (def-v *hp-gage* 10)
  

  

;;   (def-v *button-player-goo* (new-button 3 14 5 3 "[G]oo" 'g #'push-goo))
;;   (def-v *button-p-choki* (new-button 9 14 5 3 "[C]hoki" 'c #'push-choki))
;;   (def-v *button-per* (new-button 15 14 5 3 "[P]er" 'p #'push-per))
   (def-v *label-enemy-hand*  (new-label 9 6 5 5 "???"))
 
  (def-enum 'hand '(goo choki per hand-max))
  (def-v *player-hand* goo)
  (def-v *enemy-hand* goo)

;;   (defparameter *grid-array* (make-array (* 3 3)));3x3のグリッド用配列用意

;;   (def-v *button-grid-a1* (new-button 3 6 4 4 "a1" 'a #'push-grid))
;;   (def-v *button-grid-a2* (new-button 7 6 4 4 "a2" 'a #'push-grid))
;;   (def-v *button-grid-a2* (new-button 11 6 4 4 "a3" 'a #'push-grid))

  
;;   (def-v *grid* (new-grid 3 6 3 3))

   (def-v *grid* (new-grid 3 6 3 3 4 4 
						   nil
						   nil
						   nil))

);end-variable


;;ゲージクラス作りたい
;; (defstruct gage
;;   (value 0)
;;   (max-value 0)



;; (defun draw-label ( obj )
;;   (draw-square obj)
;;   (map-set-str (+ (square-x obj) 1) (+ (square-y obj) 1) (label-text obj))


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
  (setq *quit* 1)
)


(def-f update-money()
  (let (str)
    (setq str (format nil "$ ~d" *money*))
    (set-text *label-money* str)
    )
)

;;グリッドボタン押下時
(def-f push-grid (obj)

  (print obj)
  (set-hand obj "o")
  ;;enemy
   (enemy-hand)
)


;;指定のグリッド番号に手をセット
(def-f set-hand ( button hand  )
;;   (set-text (aref (grid-cell-array grid) cell-num)  hand)
  (set-text button hand)
)


;;敵の手を決定
(def-f enemy-hand()

  ;;単なるランダム

  (let ((target-cell nil) (empty-cell-array nil) )
	(setq empty-cell-array (get-empty-cell-array (grid-cell-array *grid*)))

	(cond 
      ;打てる場所が無い
	  ((= (length empty-cell-array) 0) (print "utenaiyo"))
	  ;ランダムに配置
	  ( t
	   (setq target-cell (aref empty-cell-array (random (length empty-cell-array))))
	   (print (format nil "computer hand is ~d,~d > x" (cell-x target-cell) (cell-y target-cell) ))
	   (set-text (cell-obj target-cell) "x")
	   )
	  )
	);let

  )

;;勝敗チェック
(def-f check-win()
  ;;ここにはGridのシステム内のマッチを使いたい
  ;;なので、DRMのシステムをLispRough側に移動させてからここをやる。
  
)

;;グリッドのマッチチェックに登録する判定関数

(def-f match-check-o(block)
  (if (equal (block-text block) "o")
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


 

