
/*


*/


#pragma once
#include "../../task2.h"
#include "time.h"

//-------------------------------------グローバルデータ定義-------------------------------

enum MODE{
MODE-TITLE, 
MODE-READY, 
MODE-MAIN, 
MODE-CLEAR, 
MODE-GAMEOVER, 
MODE-SCORE, 
};
enum ENEMY-TYPE{
ENEMY-TYPE-A, 
ENEMY-TYPE-B, 
ENEMY-TYPE-C, 
};





//-------------------------------------クラス定義-------------------------------



class ballaction : public TaskGM
{
public:


	ballaction(GameManager2 *game_manager );
	~ballaction();
	void Main(){};
	void Draw(){};

	Label* message_label;
Label* label_score;
BIT player_speed;
int default_player_jump_power;
BIT enemy_speed;
int enemy_w;
int enemy_h;
PARAMETER player_stock;
PARAMETER score;
int enemy_generate_timer;
int enemy_generate_wait;
ACTION-WORLD action_world;
ACTION-OBJ player;
Button* button_next;
Button* button_left;
Button* button_right;
Button* button_down;
Button* button_quit;
TITLE title;
int mode;

	void grid_get_data_array(int grid );
void grid_check_match_r_horizontal(int grid , int cell , int require_num , int test , int match_list );
void grid_check_match_r_vertical(int grid , int cell , int require_num , int test , int match_list );
void grid_check_match_r_slanting(int grid , int cell , int require_num , int test , int match_list );
void grid_check_match_r(int grid , int cell , int before_cell , int match_count , int move_x , int move_y , int require_num , int test , int match_list );
void game_init();
void push_quit();
void new_game_callback();
void init_gamemain();
void init_stage(int stage_no );
void update_score();
void next_turn();
void push_next();
void push_up();
void push_down();
void push_right();
void push_left();
void push_jump();
void move_player(int x , int y );
void jump_player();
void generate_player(int x , int y , int w , int h );
void generate_enemy(int x , int y , int w , int h , int type_no );
void dead_enemy(int obj );
void dead_player();
void fresh_player();
void show_clear();
void check_gameover();
void show_gameover();



};


GameManager2 *gm;



//-------------------------------------全体管理クラス-------------------------------

ballaction::ballaction(GameManager2 *game_manager)
{
	gm = game_manager;
	
//	new Title();

	this->message_label = new Label(gm, 34, 2, "message", RGB(0,0,0), RGB(100,100,200), 16 ) ;
this->label_score = new Label(gm, 34, 9, "Score:", RGB(0,0,0), RGB(100,100,200), 16 ) ;
this->player_speed = 1;
this->default_player_jump_power = 4;
this->enemy_speed = 1;
this->enemy_w = 3;
this->enemy_h = 3;
this->player_stock = (NEW-PARAMETER 3 0 3);
this->score = (NEW-PARAMETER 0 0 9999);
this->enemy_generate_timer = 0;
this->enemy_generate_wait = 10;
this->action_world = (NEW-ACTION-WORLD 0 0 30 20 1 3);
this->player = (GENERATE-PLAYER 3 12 3 3);
this->button_next = new Button(gm, 34, 19, "[N]ext", new Callback( multitype_func<ballaction, &ballaction::push_next>, this))  ;
this->button_left = new Button(gm, 34, 25, "[A] Left", new Callback( multitype_func<ballaction, &ballaction::push_left>, this))  ;
this->button_right = new Button(gm, 34, 28, "[D] Right", new Callback( multitype_func<ballaction, &ballaction::push_right>, this))  ;
this->button_down = new Button(gm, 34, 31, "[J] jump", new Callback( multitype_func<ballaction, &ballaction::push_jump>, this))  ;
this->button_quit = new Button(gm, 34, 34, "[Q]uit", new Callback( multitype_func<ballaction, &ballaction::push_quit>, this))  ;
this->title = (NEW-TITLE Action Ball #'NEW-GAME-CALLBACK);
this->mode = MODE-MAIN;


	this->game_init();
}

ballaction::~ballaction()
{

}

void ballaction::grid_get_data_array(int grid )
 
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

void ballaction::grid_check_match_r_horizontal(int grid , int cell , int require_num , int test , int match_list )
 
{
/*
(((GRID-CHECK-MATCH-R GRID CELL NIL 0 1 0 REQUIRE-NUM TEST MATCH-LIST)
   )
  )
 
*/
}

void ballaction::grid_check_match_r_vertical(int grid , int cell , int require_num , int test , int match_list )
 
{
/*
(((GRID-CHECK-MATCH-R GRID CELL NIL 0 0 1 REQUIRE-NUM TEST MATCH-LIST)
   )
  )
 
*/
}

void ballaction::grid_check_match_r_slanting(int grid , int cell , int require_num , int test , int match_list )
 
{
/*
(((GRID-CHECK-MATCH-R GRID CELL NIL 0 1 1 REQUIRE-NUM TEST MATCH-LIST)
   )
  )
 
*/
}

void ballaction::grid_check_match_r(int grid , int cell , int before_cell , int match_count , int move_x , int move_y , int require_num , int test , int match_list )
 
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

void ballaction::game_init()
 
{
/*
(NIL)
 
*/
}

void ballaction::push_quit()
 
{
/*
(((SETQ *QUIT* 1)
   )
  )
 
*/
}

void ballaction::new_game_callback()
 
{
/*
(((INIT-GAMEMAIN)
   )
  )
 
*/
}

void ballaction::init_gamemain()
 
{
/*
(((SETQ STAGE-NO 0)
    (INIT-STAGE STAGE-NO)
   )
  )
 
*/
}

void ballaction::init_stage(int stage_no )
 
{
/*
(((SETF ENEMY-GENERATE-TIMER ENEMY-GENERATE-WAIT)
   )
  )
 
*/
}

void ballaction::update_score()
 
{
/*
(((SET-TEXT LABEL-SCORE (FORMAT NIL Score:~d (SLOT-VALUE SCORE 'VALUE)
     )
    )
   )
  )
 
*/
}

void ballaction::next_turn()
 
{
/*
(((+= ENEMY-GENERATE-TIMER 1)
    (COND ((<= ENEMY-GENERATE-WAIT ENEMY-GENERATE-TIMER)
      (GENERATE-ENEMY 26 20 3 3 ENEMY-TYPE-A)
      (SETF ENEMY-GENERATE-TIMER 0)
     )
    )
    (ACTION-FORWARD ACTION-WORLD)
    (LET (ENEMY-VEC)
     (SETF ENEMY-VEC (WORLD-GET-OBJ-VEC ACTION-WORLD 'ENEMY)
     )
     (SETF ENEMY-VEC (REMOVE-IF (LAMBDA (ENEMY)
        (> (+ (SLOT-VALUE ENEMY 'X)
          (SLOT-VALUE ENEMY 'W)
         )
         0)
       )
       ENEMY-VEC)
     )
     (WORLD-REMOVE-OBJ-VEC ACTION-WORLD ENEMY-VEC)
    )
    (WORLD-HIT-CHECK ACTION-WORLD 'PLAYER 'ENEMY)
    (LET (ENEMY-VEC ENEMY)
     (SETF ENEMY-VEC (WORLD-GET-OBJ-VEC ACTION-WORLD 'ENEMY)
     )
     (LENGTH ENEMY-VEC)
     (FOR-- (I (- (LENGTH ENEMY-VEC)
        1)
       0)
      (SETQ ENEMY (ELT ENEMY-VEC I)
      )
      (COND ((AND (SLOT-VALUE ENEMY 'HIT-FLAG)
         (NOT (SLOT-VALUE ENEMY 'DEAD-EFFECT)
         )
        )
        (COND ((SLOT-VALUE PLAYER 'JUMP-FLAG)
          (DEAD-ENEMY ENEMY)
          (ACTION-JUMP ACTION-WORLD PLAYER)
         )
         (T (DEAD-PLAYER)
         )
        )
       )
      )
     )
    )
   )
  )
 
*/
}

void ballaction::push_next()
 
{
/*
(((NEXT-TURN)
   )
  )
 
*/
}

void ballaction::push_up()
 
{
/*
(NIL)
 
*/
}

void ballaction::push_down()
 
{
/*
(NIL)
 
*/
}

void ballaction::push_right()
 
{
/*
(((MOVE-PLAYER PLAYER-SPEED 0)
    (NEXT-TURN)
   )
  )
 
*/
}

void ballaction::push_left()
 
{
/*
(((MOVE-PLAYER (- PLAYER-SPEED)
     0)
    (NEXT-TURN)
   )
  )
 
*/
}

void ballaction::push_jump()
 
{
/*
(((ACTION-JUMP ACTION-WORLD PLAYER)
    (NEXT-TURN)
   )
  )
 
*/
}

void ballaction::move_player(int x , int y )
 
{
/*
(((WORLD-MOVE-OBJ ACTION-WORLD PLAYER X Y)
   )
  )
 
*/
}

void ballaction::jump_player()
 
{
/*
(((SETF (SLOT-VALUE PLAYER 'ANGLE)
     270)
    (SETF (SLOT-VALUE PLAYER 'SPEED)
     10)
   )
  )
 
*/
}

void ballaction::generate_player(int x , int y , int w , int h )
 
{
/*
(((NEW-ACTION-OBJ ACTION-WORLD X Y W H 'PLAYER 0 0 1 DEFAULT-PLAYER-JUMP-POWER P)
   )
  )
 
*/
}

void ballaction::generate_enemy(int x , int y , int w , int h , int type_no )
 
{
/*
(((LET (OBJ-STR)
     (SETQ OBJ-STR ?)
     (IF (= TYPE-NO ENEMY-TYPE-A)
      (SETQ OBJ-STR e)
     )
     (IF (= TYPE-NO ENEMY-TYPE-B)
      (SETQ OBJ-STR E)
     )
     (IF (= TYPE-NO ENEMY-TYPE-C)
      (SETQ OBJ-STR B)
     )
     (NEW-ACTION-OBJ ACTION-WORLD X Y W H 'ENEMY ENEMY-SPEED 180 1 0 OBJ-STR)
    )
   )
  )
 
*/
}

void ballaction::dead_enemy(int obj )
 
{
/*
(((WORLD-DEAD-OBJ OBJ OBJ x 3)
    (SETF (SLOT-VALUE OBJ 'SPEED)
     0)
    (PARAMETER-ADD SCORE 1)
    (UPDATE-SCORE)
   )
  )
 
*/
}

void ballaction::dead_player()
 
{
/*
(((SETF (SLOT-VALUE (SLOT-VALUE PLAYER 'LABEL)
      'TEXT)
     x)
   )
  )
 
*/
}

void ballaction::fresh_player()
 
{
/*
(((SETF (SLOT-VALUE PLAYER 'DEAD-EFFECT)
     NIL)
    (SETF (SLOT-VALUE (SLOT-VALUE PLAYER 'LABEL)
      'TEXT)
     P)
   )
  )
 
*/
}

void ballaction::show_clear()
 
{
/*
(((SETF (SLOT-VALUE MESSAGE-LABEL 'TEXT)
     clear)
    (++ STAGE-NO)
    (INIT-STAGE STAGE-NO)
   )
  )
 
*/
}

void ballaction::check_gameover()
 
{
/*
(((IF (<= *FUEL* 0)
     T NIL)
   )
  )
 
*/
}

void ballaction::show_gameover()
 
{
/*
(((SETF (SLOT-VALUE MESSAGE-LABEL 'TEXT)
     gameover)
   )
  )
 
*/
}


