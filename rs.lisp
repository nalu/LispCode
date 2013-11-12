(load "LispRough.lisp")
;--------------------------------- GAME ---------------------------------


(defun game-variable()

;  (defparameter *card-a-obj* 0)
;  (defparameter *card-b-obj* 0)
;  (defparameter *button-high* 0)
;  (defparameter *button-low* 0)
  (defparameter *button-retry* 0)
;  (defparameter *button-quit* 0)
  (defparameter *label-money* 0)
  
  (defparameter *card-array* (make-array 2))
  
  (defparameter *select* "")
  (defparameter *money* 100)
  (defparameter *player-hp* 10)



  ;rs menu
  (setq *button-dungeon-dolban* (new-button 3 14 5 3 "[D]olban" 'd #'push-dungeon-dolban))
  (setq *button-forward* (new-button 5 14 10 3 "[F]orward" 'f #'push-forward))
  (setq *button-back* (new-button 5 17 10 3 "[B]ack" 'b #'push-walk-back))
  (setq *quit-button* ( new-button 1 20 5 3 "[Q]uit" 'q #'push-quit))

  (setq  *label-deep* (new-label 18 3 7 3 "deep"))
  (setq  *label-hp* (new-label 18 6 7 3 "HP"))
  
  (setq *message-label* (new-label 3 2 13 3 ""))

  (setq *label-trap* (new-label 7 6 5 5 "TRAP"))
  (setq *button-remove-trap* (new-button 10 20 5 3 "[R]emoveTrap" 'r #'push-remove-trap))

  ;battle
  (setq *label-enemy* (new-label 7 6 5 5 "ENEMY"))
  (setq *button-attack* (new-button  5 14 10 3 "[A]ttack" 'a #'push-attack))
  (setq *button-magic* (new-button  5 17 10 3 "[M]agic" 'm #'push-magic))
  (setq *button-escape* (new-button 10 20 5 3 "[E]scape" 'e #'push-escape))

  ;rs parameter
  (defparameter *deep* 0)
  (defparameter *trap-flag* 0)
  (defparameter *battle-mode* 0)

)


(defun game-start()
  (lr-begin)
  (game-variable)
  (game-init)
  (lr-start)
)

(defmethod game-init()


  (setf (label-visible *label-trap*) nil)
  (setf (label-visible *button-remove-trap*) nil)
  (setq *deep* 100)

  (mode-dungeon)

)


;---------------------------------- button ----------------------------------


(defun push-quit()
  (lr-quit)
)

(defun push-dungeon-dolban()
  (print "go to dungeon..")
  (dungeon-init)
)

(defun push-forward()
  (walk-forward)
)

(defun push-walk-back()
  (walk-back)
)

(defun push-remove-trap()
  (set-text *message-label* "REMOVE TRAP")
  (remove-trap)
)

(defun push-attack()
  (print "attack")
)

(defun push-magic()
  (print "magic")
)

(defun push-escape()
  (print "escape")
)

;---------------------------------- screen ----------------------------------
(defun update-parameter()
  (let (str)
    (setq str (format nil "$ ~d" *money*))
    (set-text *label-money* str)
    )
)

;---------------------------------- mode ----------------------------------
(defun mode-dungeon()
  (setf (label-visible *button-attack* ) nil)
  (setf (label-visible *button-magic* ) nil)
  (setf (label-visible *button-escape*) nil)
  (setf (label-visible *label-enemy*) nil)
)

(defun mode-battle()
  (setq *battle-mode* 1)
  (set-text *message-label* "Enemy!!")
  (setf (label-visible *button-attack* ) t)
  (setf (label-visible *button-magic* ) t)
  (setf (label-visible *button-escape*) t)
  (setf (label-visible *label-enemy*) t)
)

;---------------------------------- dungeon ----------------------------------
;Forward
(defun walk-forward()
  (print "forward")
  (set-text *message-label* "toko...toko...")
  (setq *deep* (- *deep* 1))

  (cond ( (equal *trap-flag* 1)
      (fire-trap)
      (return-from walk-forward)
	  ))

  ; event
  (cond
    ((equal (event) "trap") (appear-trap))
;   ((equal (event) "item") (appear-item))
    ((equal (event) "battle") (start-battle))
    )
     
  ;trap appear
  #|
  (if (equal (random 5) 0)
       (appear-trap))

  ;battle
  (if (equal (random 5) 0)
      (battle-start))
|#
       
  (update-parameter)
)

;Back

(defun walk-back()
  (print "back")
  (setq *deep* (+ *deep* 1))
  (trap-back)
  (update-parameter)
)

;Event
(def-f event()
  (let ( (r (random 10)) return-val)
    (cond 
      ( (< r 3 ) "trap")
      ( (< r 5 ) "item")
      ( (< r 7 ) "battle")
      ( t "noevent")
      )
    )
)


;TRAP
(defun appear-trap()
  (setq *trap-flag* 1)
  (setf (label-visible *label-trap*) t)
  (setf (label-visible *button-remove-trap*) t)
)

(defun fire-trap()
  (set-text *message-label* "TRAP FIRE!!")
  (setq *player-hp* (- *player-hp* 10))
  (remove-trap)
  (update-parameter)
)


(defun remove-trap()
  (setq *trap-flag* 0)
  (setf (label-visible *label-trap*) nil)
  (setf (label-visible *button-remove-trap*) nil)
)

(defun trap-back()
  (setq *trap-flag* 0)
  (setf (label-visible *label-trap*) nil)
  (setf (label-visible *button-remove-trap*) nil)
)


;Display
(defun update-parameter()
  (set-text *label-deep* (format nil "~d m" *deep*) )
  (set-text *label-hp* (format nil "HP:~d" *player-hp*))
)


(defun dungeon-init()
  (setq *trap-flag* 0)
  (setq *battle-mode* 0)
)

;Battle
(def-f start-battle()
  (print "start battle")
  (mode-battle)
)

;LispRoughTest
(def-f lisp-rough-test(x)
  (print x)
)
