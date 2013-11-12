
/*


*/


#pragma once
#include "../../task2.h"
#include "time.h"

//-------------------------------------グローバルデータ定義-------------------------------





//-------------------------------------クラス定義-------------------------------



class hilow : public TaskGM
{
public:


	hilow(GameManager2 *game_manager );
	~hilow();
	void Main(){};
	void Draw(){};

	Label* card_a_obj;
Label* card_b_obj;
Label* message_label;
Button* button_high;
Button* button_low;
Button* button_retry;
Button* button_quit;
Label* label_money;
vector<int> card_array;
string a_card;
int b_card;
SYMBOL mode;
string select;
int money;

	void game_init();
void check_highlow(int open_n , int hide_n );
void get_card_random_number();
void mode_hide();
void mode_open();
void push_quit();
void push_retry();
void push_high();
void push_low();
void win();
void lose();
void update_money();



};


GameManager2 *gm;



//-------------------------------------全体管理クラス-------------------------------

hilow::hilow(GameManager2 *game_manager)
{
	gm = game_manager;
	
//	new Title();

	this->card_a_obj = new (NEW-LABEL 3 6 5 7 a );
this->card_b_obj = new (NEW-LABEL 11 6 5 7 b );
this->message_label = new (NEW-LABEL 3 2 13 3 message);
this->button_high = new (NEW-BUTTON 3 14 5 3 [H]igh 'H #'PUSH-HIGH);
this->button_low = new (NEW-BUTTON 3 17 5 3 [L]ow 'L #'PUSH-LOW);
this->button_retry = new (NEW-BUTTON 11 14 5 3 [R]try 'R #'PUSH-RETRY);
this->button_quit = new (NEW-BUTTON 11 17 5 3 [Q]uit 'Q #'PUSH-QUIT);
this->label_money = new (NEW-LABEL 18 6 7 3 money);
this->card_array = new (MAKE-ARRAY 2);
this->a_card = new 1;
this->b_card = new 1;
this->mode = new 'HIDE;
this->select = new ;
this->money = new 100;


	this->game_init();
}

hilow::~hilow()
{

}

void hilow::game_init()
 
{
/*
(((SETQ *MODE* 'HIDE)
    (MODE-HIDE)
    (UPDATE-MONEY)
   )
  )
 
*/
}

void hilow::check_highlow(int open_n , int hide_n )
 
{
/*
(((LET (VAL)
     (COND ((= OPEN_N HIDE_N)
       (SETQ VAL 'DRAW)
      )
      ((< OPEN_N HIDE_N)
       (SETQ VAL 'LOW)
      )
      ((> OPEN_N HIDE_N)
       (SETQ VAL 'HIGH)
      )
     )
     VAL)
   )
  )
 
*/
}

void hilow::get_card_random_number()
 
{
/*
(((+ (RANDOM 12)
     1)
   )
  )
 
*/
}

void hilow::mode_hide()
 
{
/*
(((SETQ *A-CARD* X)
    (SETQ *B-CARD* (GET-CARD-RANDOM-NUMBER)
    )
    (SET-TEXT *MESSAGE-LABEL* HIGH or LOW?)
    (VISIBLE-BUTTON *BUTTON-HIGH* T)
    (VISIBLE-BUTTON *BUTTON-LOW* T)
    (VISIBLE-BUTTON *BUTTON-RETRY* NIL)
    (SET-TEXT *CARD-A-OBJ* *A-CARD*)
    (SET-TEXT *CARD-B-OBJ* *B-CARD*)
   )
  )
 
*/
}

void hilow::mode_open()
 
{
/*
(((SETQ *A-CARD* (GET-CARD-RANDOM-NUMBER)
    )
    (VISIBLE-BUTTON *BUTTON-HIGH* NIL)
    (VISIBLE-BUTTON *BUTTON-LOW* NIL)
    (VISIBLE-BUTTON *BUTTON-RETRY* T)
    (LET (HIGHLOW)
     (SETQ HIGHLOW (CHECK-HIGHLOW *A-CARD* *B-CARD*)
     )
     (COND ((EQUAL HIGHLOW 'DRAW)
       (SET-TEXT *MESSAGE-LABEL* open >>>>>> DRAW)
      )
      ((EQUAL HIGHLOW *SELECT*)
       (SET-TEXT *MESSAGE-LABEL* open >>>>>> WIN!!)
       (WIN)
      )
      (T (SET-TEXT *MESSAGE-LABEL* open >>>>>> LOSE..)
       (LOSE)
      )
     )
    )
    (SET-TEXT *CARD-A-OBJ* *A-CARD*)
   )
  )
 
*/
}

void hilow::push_quit()
 
{
/*
(((SETQ *QUIT* 1)
   )
  )
 
*/
}

void hilow::push_retry()
 
{
/*
(((SETQ *MODE* 'HIDE)
    (MODE-HIDE)
   )
  )
 
*/
}

void hilow::push_high()
 
{
/*
(((SETQ *SELECT* 'HIGH)
    (SETQ *MODE* 'OPEN)
    (MODE-OPEN)
   )
  )
 
*/
}

void hilow::push_low()
 
{
/*
(((SETQ *SELECT* 'LOW)
    (SETQ *MODE* 'OPEN)
    (MODE-OPEN)
   )
  )
 
*/
}

void hilow::win()
 
{
/*
(((SETQ *MONEY* (+ *MONEY* 10)
    )
    (UPDATE-MONEY)
   )
  )
 
*/
}

void hilow::lose()
 
{
/*
(((SETQ *MONEY* (- *MONEY* 10)
    )
    (UPDATE-MONEY)
   )
  )
 
*/
}

void hilow::update_money()
 
{
/*
(((LET (STR)
     (SETQ STR (FORMAT NIL $ ~d *MONEY*)
     )
     (SET-TEXT *LABEL-MONEY* STR)
    )
   )
  )
 
*/
}


