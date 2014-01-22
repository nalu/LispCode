(load "LispRough.lisp")
;--------------------------------- GAME ---------------------------------


(defun game-variable()

  (def-v *card-a-obj*  (new-label 3 6 5 7 "a "))
  (def-v *card-b-obj* (new-label 11 6 5 7 "b "))
  (def-v *message-label* (new-label 3 2 13 3 "message"))
  (def-v *button-high* (new-button 3 14 5 3 "[H]igh" 'h #'push-high))
  (def-v *button-low* (new-button 3 17 5 3 "[L]ow" 'l #'push-low))
  (def-v *button-retry* (new-button 11 14 5 3 "[R]try" 'r #'push-retry))
  (def-v *button-quit* (new-button 11 17 5 3 "[Q]uit" 'q #'push-quit))
  (def-v *label-money* (new-label 18 6 7 3 "money"))
  
;;   (def-v *card-array* (make-array 2))
  (def-v *card-array* (new-vec 2))
  

  (def-enum 'mode '(hide open))
  
  (def-v *a-card* 1 )
  (def-v *b-card* 1)
  (def-v *mode* hide )
  (def-v *select* "")
  (def-v *money* 100)

  

);end-variable


(defun game-start()

  (lr-begin)  
  (game-variable)
  (game-init)
  (lr-start)
)

;(defmethod game-init()
(def-f game-init()
  (setq *mode* hide)  

  (mode-hide)
  (update-money)
)


(def-f check-highlow(open_n hide_n)
  (let (val)
  (cond 
    ((= open_n hide_n) (setq val 'draw))
    ((< open_n hide_n) (setq val 'low))
    ((> open_n hide_n) (setq val 'high))
    )
  val)
)


(def-f get-card-random-number()
  (+ (random 12 ) 1)
)


(def-f mode-hide()
  (setq *a-card* "X") 
  (setq *b-card*  (get-card-random-number) )
  (set-text *message-label* "HIGH or LOW?")
  (visible-button *button-high* t)
  (visible-button *button-low* t)
  (visible-button *button-retry* nil)
  (set-text *card-a-obj* *a-card*)
  (set-text *card-b-obj* *b-card*)
)

(def-f mode-open()
  (setq *a-card* (get-card-random-number)  )
  (visible-button *button-high* nil)
  (visible-button *button-low* nil)
  (visible-button *button-retry* t)
  (let (highlow)
    (setq highlow (check-highlow *a-card* *b-card*))
    (cond 
      ((equal highlow 'draw) 
       (set-text *message-label*  "open >>>>>> DRAW"))
      ((equal highlow *select*) 
       (set-text *message-label* "open >>>>>> WIN!!")
       (win)
       )
      
      (t 
       ( set-text *message-label* "open >>>>>> LOSE..")
       (lose)
       )

      ))
  (set-text *card-a-obj* *a-card*)
  
)


(def-f push-quit()
  (setq *quit* 1)
)


(def-f push-retry()
  (setq *mode* hide )
  (mode-hide)
)

(def-f push-high()
 (setq *select* 'high )
 (setq *mode* 'open)
 (mode-open)
;;  (setf (label-y *label-money*) (- (label-y *label-money*) 1))
;;  (setf @*label-money*.y (- @*label-money*.y 1))
 (-= @*label-money*.y 1)
)

(def-f push-low()
  (setq *select* 'low )
  (setq *mode* 'open)
  (mode-open)
)

(def-f win()
  (setq *money* (+ *money* 10))
  (update-money)
)

(def-f lose()
  (setq *money* (- *money* 10))
  (update-money)
)

(def-f update-money()
  (let (str)
    (setq str (format nil "$ ~d" *money*))
    (set-text *label-money* str)
    )
)


