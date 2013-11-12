
/*


*/


#pragma once
#include "../../task2.h"
#include "time.h"

//-------------------------------------グローバルデータ定義-------------------------------





//-------------------------------------クラス定義-------------------------------

/*
( check-highlow ((open_n hide_n))
  ((let (val)
    (cond ((= open_n hide_n)
      (setq val 'draw)
     )
     ((< open_n hide_n)
      (setq val 'low)
     )
     ((> open_n hide_n)
      (setq val 'high)
     )
    )
    val)
  )
 
)
*/
/*
( get-card-random-number ()
  ((+ (random 12)
    1)
  )
 
)
*/
/*
( mode-hide ()
  ((setq *a-card* x)
   (setq *b-card* (get-card-random-number)
   )
   (set-text *message-label* high or low?)
   (visible-button *button-high* t)
   (visible-button *button-low* t)
   (visible-button *button-retry* nil)
   (set-text *card-a-obj* *a-card*)
   (set-text *card-b-obj* *b-card*)
  )
 
)
*/
/*
( mode-open ()
  ((setq *a-card* (get-card-random-number)
   )
   (visible-button *button-high* nil)
   (visible-button *button-low* nil)
   (visible-button *button-retry* t)
   (let (highlow)
    (setq highlow (check-highlow *a-card* *b-card*)
    )
    (cond ((equal highlow 'draw)
      (set-text *message-label* open >>>>>> draw)
     )
     ((equal highlow *select*)
      (set-text *message-label* open >>>>>> win!!)
      (win)
     )
     (t (set-text *message-label* open >>>>>> lose..)
      (lose)
     )
    )
   )
   (set-text *card-a-obj* *a-card*)
  )
 
)
*/
/*
( push-quit ()
  ((setq *quit* 1)
  )
 
)
*/
/*
( push-retry ()
  ((setq *mode* 'hide)
   (mode-hide)
  )
 
)
*/
/*
( push-high ()
  ((setq *select* 'high)
   (setq *mode* 'open)
   (mode-open)
  )
 
)
*/
/*
( push-low ()
  ((setq *select* 'low)
   (setq *mode* 'open)
   (mode-open)
  )
 
)
*/
/*
( win ()
  ((setq *money* (+ *money* 10)
   )
   (update-money)
  )
 
)
*/
/*
( lose ()
  ((setq *money* (- *money* 10)
   )
   (update-money)
  )
 
)
*/
/*
( update-money ()
  ((let (str)
    (setq str (format nil $ ~d *money*)
    )
    (set-text *label-money* str)
   )
  )
 
)
*/



class hilow : public TaskGM
{
public:


	hilow(GameManager2 *game_manager );
	~hilow();
	void Main(){};
	void Draw(){};

	LABEL *CARD-A-OBJ*;
LABEL *CARD-B-OBJ*;
LABEL *MESSAGE-LABEL*;
BUTTON *BUTTON-HIGH*;
BUTTON *BUTTON-LOW*;
BUTTON *BUTTON-RETRY*;
BUTTON *BUTTON-QUIT*;
LABEL *LABEL-MONEY*;
(SIMPLE-VECTOR 2) *CARD-ARRAY*;
(SIMPLE-BASE-STRING 1) *A-CARD*;
(INTEGER 0 536870911) *B-CARD*;
SYMBOL *MODE*;
(SIMPLE-BASE-STRING 0) *SELECT*;
(INTEGER 0 536870911) *MONEY*;



};


GameManager2 *gm;



//-------------------------------------全体管理クラス-------------------------------

hilow::hilow(GameManager2 *game_manager)
{
	gm = game_manager;

	new Title();

}

hilow::~hilow()
{

}
