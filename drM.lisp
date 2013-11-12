(load "LispRough.lisp")
;--------------------------------- GAME ---------------------------------


(defun game-variable()

  (def-v *message-label* (new-label 3 2 13 3 "message"))
  (def-v *button-quit* (new-button 28 30 5 3 "[Q]uit" 'q #'push-quit))
  (def-v *label-money* (new-label 1 6 7 3 "money"))
  
  (def-v *money* 100)
  (def-v *hp-gage* 10)
  

  

;;   (def-v *button-player-goo* (new-button 3 14 5 3 "[G]oo" 'g #'push-goo))
;;   (def-v *button-p-choki* (new-button 9 14 5 3 "[C]hoki" 'c #'push-choki))
;;   (def-v *button-per* (new-button 15 14 5 3 "[P]er" 'p #'push-per))
;;    (def-v *label-enemy-hand*  (new-label 9 6 5 5 "???"))
 
  (def-enum 'hand '(goo choki per hand-max))
  (def-v *player-hand* goo)
  (def-v *enemy-hand* goo)


  
  (def-v *grid* (new-grid 10 6 8 16 2 2))

);end-variable


;;ゲージクラス作りたい
;; (defstruct gage
;;   (value 0)
;;   (max-value 0)




(defun game-start()

  (lr-begin 40 40 )  
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


(def-f push-grid (obj)
  (print (button-text obj))
   (set-hand-grid *grid* (stoi (button-text obj)) "o")

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


 



;;グリッドクラス（テスト）
(defstruct (grid) (x 0) (y 0) (w-cell-num 3) (h-cell-num 3) (visible t) (array nil) )
(defun new-grid (x y w-cell-num h-cell-num cell-w cell-h)
  (let (
		(obj) 
		(cell-array (make-array (* w-cell-num h-cell-num)))
		)

	(loop for i below (length cell-array) do
		 (setf (aref cell-array i) 
			   (new-button 
				(+ x (* (mod i w-cell-num) cell-w )) 
				(+ y (* (truncate i h-cell-num) cell-h)) 
				cell-w cell-h 
				(format nil "~d" i);str
;;  				'a ;key
				(read-from-string (format nil "~d" i)) ;グリッド番号をそのままキーに指定
				#'push-grid) )
		 )
;; )										


	(setq obj 
		  (make-grid :x x :y y 
					 :w-cell-num w-cell-num :h-cell-num h-cell-num
					 :array cell-array))
	
;; 	(add-object obj)
	obj)
  
)

;;指定のグリッド番号に手をセット
(def-f set-hand-grid ( grid cell-num hand )
   (set-text (aref (grid-array grid) cell-num)  hand)
)



;;グリッドのボタン群のうちテキスト内容がox以外の配列を抽出。
(def-f get-empty-cell-array (grid)
  (remove-if 
	 #'(lambda (x) 
		 (if (or ( equal (button-text x) "o" )  (equal (button-text x) "x"))
			 t
			 nil)
		 ) (grid-array grid))
	
)


;;グリッドの状態から勝敗判定
(def-f jadge-win()
  
)



;;指定の位置のグリッドを取得
