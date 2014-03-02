
/*


*/


#pragma once
#include "../../task2.h"
#include "time.h"

//-------------------------------------グローバルデータ定義-------------------------------

enum MODE{
HIDE, 
OPEN, 
};





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
BIT mode;
string select;
int money;

	void grid_get_data_array(int grid );
void grid_check_match_r_horizontal(int grid , int cell , int require_num , int test , int match_list );
void grid_check_match_r_vertical(int grid , int cell , int require_num , int test , int match_list );
void grid_check_match_r_slanting(int grid , int cell , int require_num , int test , int match_list );
void grid_check_match_r(int grid , int cell , int before_cell , int match_count , int move_x , int move_y , int require_num , int test , int match_list );
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

	this->card_a_obj = new Label(gm, 3, 6, "a ", RGB(0,0,0), RGB(100,100,200), 16 ) ;
this->card_b_obj = new Label(gm, 11, 6, "b ", RGB(0,0,0), RGB(100,100,200), 16 ) ;
this->message_label = new Label(gm, 3, 2, "message", RGB(0,0,0), RGB(100,100,200), 16 ) ;
this->button_high = new Button(gm, 3, 14, "[H]igh", new Callback( multitype_func<hilow, &hilow::push_high>, this))  ;
this->button_low = new Button(gm, 3, 17, "[L]ow", new Callback( multitype_func<hilow, &hilow::push_low>, this))  ;
this->button_retry = new Button(gm, 11, 14, "[R]try", new Callback( multitype_func<hilow, &hilow::push_retry>, this))  ;
this->button_quit = new Button(gm, 11, 17, "[Q]uit", new Callback( multitype_func<hilow, &hilow::push_quit>, this))  ;
this->label_money = new Label(gm, 18, 6, "money", RGB(0,0,0), RGB(100,100,200), 16 ) ;
this->card_array = (NEW-VEC 2);
this->a_card = 1;
this->b_card = 1;
this->mode = HIDE;
this->select = ;
this->money = 100;


	this->game_init();
}

hilow::~hilow()
{

}

void hilow::grid_get_data_array(int grid )
 
{
/*
(((MAP 'LIST (LAMBDA (X)
      (CELL-DATA X)
     )
     (GRID-CELL-ARRAY GRID)
    )
   )
  )
 
*/
}

void hilow::grid_check_match_r_horizontal(int grid , int cell , int require_num , int test , int match_list )
 
{
/*
(((GRID-CHECK-MATCH-R GRID CELL NIL 0 1 0 REQUIRE-NUM TEST MATCH-LIST)
   )
  )
 
*/
}

void hilow::grid_check_match_r_vertical(int grid , int cell , int require_num , int test , int match_list )
 
{
/*
(((GRID-CHECK-MATCH-R GRID CELL NIL 0 0 1 REQUIRE-NUM TEST MATCH-LIST)
   )
  )
 
*/
}

void hilow::grid_check_match_r_slanting(int grid , int cell , int require_num , int test , int match_list )
 
{
/*
(((GRID-CHECK-MATCH-R GRID CELL NIL 0 1 1 REQUIRE-NUM TEST MATCH-LIST)
   )
  )
 
*/
}

void hilow::grid_check_match_r(int grid , int cell , int before_cell , int match_count , int move_x , int move_y , int require_num , int test , int match_list )
 
{
/*
(((LET ((RECURSIVE-FINISH NIL)
     )
     (IF (NOT (EQUAL (CELL-DATA CELL)
        NIL)
      )
      (FUNCALL TEST (CELL-DATA CELL)
      )
     )
     (IF (NOT (EQUAL BEFORE-CELL NIL)
      )
      (IF (AND (EQUAL (FUNCALL TEST (CELL-DATA CELL)
         )
         T)
        (EQUAL (FUNCALL TEST (CELL-DATA BEFORE-CELL)
         )
         T)
       )
       (SETQ MATCH-COUNT (+ MATCH-COUNT 1)
       )
       (SETQ RECURSIVE-FINISH T)
      )
     )
     (IF (EQUAL RECURSIVE-FINISH NIL)
      (LET (NEXT-CELL)
       (SETQ NEXT-CELL (GRID-GET-CELL-FROM-CELL GRID CELL MOVE-X MOVE-Y)
       )
       (IF (AND (NOT (EQUAL NEXT-CELL NIL)
         )
         (NOT (EQUAL (CELL-DATA NEXT-CELL)
           NIL)
         )
        )
        (SETQ MATCH-COUNT (GRID-CHECK-MATCH-R GRID NEXT-CELL CELL MATCH-COUNT MOVE-X MOVE-Y REQUIRE-NUM TEST MATCH-LIST)
        )
       )
       (IF (>= MATCH-COUNT (- REQUIRE-NUM 1)
        )
        (VEC-PUSH MATCH-LIST (CELL-DATA CELL)
        )
       )
      )
     )
     MATCH-COUNT)
   )
  )
 
*/
}

void hilow::game_init()
 
{
/*
(((SETQ *MODE* HIDE)
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
(((SETQ *MODE* HIDE)
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
    (-= (SLOT-VALUE *LABEL-MONEY* 'Y)
     1)
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


