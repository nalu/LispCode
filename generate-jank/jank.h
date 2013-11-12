
/*


*/


#pragma once
#include "../../task2.h"
#include "time.h"

//-------------------------------------グローバルデータ定義-------------------------------

enum HAND{
GOO, 
CHOKI, 
PER, 
HAND-MAX, 
};





//-------------------------------------クラス定義-------------------------------



class jank : public TaskGM
{
public:


	jank(GameManager2 *game_manager );
	~jank();
	void Main(){};
	void Draw(){};

	Label* message_label;
Button* button_quit;
Label* label_money;
int money;
int hp_gage;
Button* button_player_goo;
Button* button_p_choki;
Button* button_per;
Label* label_enemy_hand;
BIT player_hand;
BIT enemy_hand;

	void game_init();
void push_quit();
void update_money();
void push_goo();
void push_choki();
void push_per();
void open_enemy_hand();
void win();
void draw();
void lose();



};


GameManager2 *gm;



//-------------------------------------全体管理クラス-------------------------------

jank::jank(GameManager2 *game_manager)
{
	gm = game_manager;
	
//	new Title();

	this->message_label = new Label(gm, 3, 2, "message", RGB(0,0,0), RGB(100,100,200), 16 ) ;
this->button_quit = new Button(gm, 15, 18, "[Q]uit", new Callback( multitype_func<jank, &jank::push_quit>, this))  ;
this->label_money = new Label(gm, 18, 6, "money", RGB(0,0,0), RGB(100,100,200), 16 ) ;
this->money = 100;
this->hp_gage = 10;
this->button_player_goo = new Button(gm, 3, 14, "[G]oo", new Callback( multitype_func<jank, &jank::push_goo>, this))  ;
this->button_p_choki = new Button(gm, 9, 14, "[C]hoki", new Callback( multitype_func<jank, &jank::push_choki>, this))  ;
this->button_per = new Button(gm, 15, 14, "[P]er", new Callback( multitype_func<jank, &jank::push_per>, this))  ;
this->label_enemy_hand = new Label(gm, 9, 6, "???", RGB(0,0,0), RGB(100,100,200), 16 ) ;
this->player_hand = GOO;
this->enemy_hand = GOO;


	this->game_init();
}

jank::~jank()
{

}

void jank::game_init()
 
{
/*
(((SETQ *MODE* 'HIDE)
    (UPDATE-MONEY)
   )
  )
 
*/
}

void jank::push_quit()
 
{
/*
(((SETQ *QUIT* 1)
   )
  )
 
*/
}

void jank::update_money()
 
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

void jank::push_goo()
 
{
/*
(((SETQ *PLAYER-HAND* GOO)
    (OPEN-ENEMY-HAND)
   )
  )
 
*/
}

void jank::push_choki()
 
{
/*
(((SETQ *PLAYER-HAND* CHOKI)
    (OPEN-ENEMY-HAND)
   )
  )
 
*/
}

void jank::push_per()
 
{
/*
(((SETQ *PLAYER-HAND* PER)
    (OPEN-ENEMY-HAND)
   )
  )
 
*/
}

void jank::open_enemy_hand()
 
{
/*
(((SETQ *ENEMY-HAND* (RANDOM HAND-MAX)
    )
    (LET (STR)
     (COND ((EQL *ENEMY-HAND* GOO)
       (SETQ STR goo)
      )
      ((EQL *ENEMY-HAND* CHOKI)
       (SETQ STR choki)
      )
      ((EQL *ENEMY-HAND* PER)
       (SETQ STR per)
      )
     )
     (SET-TEXT *LABEL-ENEMY-HAND* STR)
    )
    (COND ((EQL *PLAYER-HAND* GOO)
      (COND ((EQL *ENEMY-HAND* GOO)
        (DRAW)
       )
       ((EQL *ENEMY-HAND* CHOKI)
        (WIN)
       )
       ((EQL *ENEMY-HAND* PER)
        (LOSE)
       )
      )
     )
     ((EQL *PLAYER-HAND* CHOKI)
      (COND ((EQL *ENEMY-HAND* GOO)
        (LOSE)
       )
       ((EQL *ENEMY-HAND* CHOKI)
        (DRAW)
       )
       ((EQL *ENEMY-HAND* PER)
        (WIN)
       )
      )
     )
     ((EQL *PLAYER-HAND* PER)
      (COND ((EQL *ENEMY-HAND* GOO)
        (WIN)
       )
       ((EQL *ENEMY-HAND* CHOKI)
        (LOSE)
       )
       ((EQL *ENEMY-HAND* PER)
        (DRAW)
       )
      )
     )
    )
   )
  )
 
*/
}

void jank::win()
 
{
/*
(((SETQ *MONEY* (+ *MONEY* 10)
    )
    (UPDATE-MONEY)
    (SET-TEXT *MESSAGE-LABEL* PIKO >>>>>> WIN)
   )
  )
 
*/
}

void jank::draw()
 
{
/*
(((SET-TEXT *MESSAGE-LABEL* PIKO >>>>>> DRAW)
   )
  )
 
*/
}

void jank::lose()
 
{
/*
(((SETQ *MONEY* (- *MONEY* 10)
    )
    (UPDATE-MONEY)
    (SET-TEXT *MESSAGE-LABEL* PIKO >>>>>> LOSE)
   )
  )
 
*/
}


