enchant();

window.onload = function() {

	var game_title_str = "cow";

	//列挙型定義
	var ENEMY_TYPE = {
RED : 0, 
YELLOW : 1, 
BLUE : 2, 
};
var MODE = {
MODE_TITLE : 0, 
MODE_READY : 1, 
MODE_MAIN : 2, 
MODE_CLEAR : 3, 
MODE_GAMEOVER : 4, 
MODE_SCORE : 5, 
};




    

    //objects
    var title;
    var start_button;
    // var stock;
    var jadge;
    var debug;
    var controller;

    var title_bg_color= "rgba( 100, 100, 100, 0.0 )";
    var screen_bg_color = 'rgba( 200, 200, 200, 1.0)';

    var game = new Game(screen_width, screen_height); // ゲーム本体を準備すると同時に、表示される領域の大きさを設定しています。
    game.fps = 24; // frames(フレーム) per(毎) second(秒): ゲームの進行スピードを設定しています。

    // pre(前)-load(読み込み): ゲームに使う素材を予め読み込んでおきます。
    game.preload('./img/title.png');
    game.preload('./img/controller.png'); 

    game.rootScene.backgroundColor  = screen_bg_color; // ゲーム背景
	

    Button = Class.create
    ( TaskBase,{

	//初期化
	initialize:function( x,y,w,h,title,key,call, bg_color)
	{
 	    TaskBase.call(this,x,y,w,h,title,key,call); //スーパークラスのコンストラクタ呼び出し

	    //ラベルの高さを指定しても、縦の中央に配置する事ができないため、背景専用のSquareオブジェクトを内包する。
	    var square = new Square(w,h,bg_color);
	    square.x = x;
	    square.y = y;

	    //ラベルを準備
	    var label = new Label();
	    label.x=x;
	    label.width = w;
	    this.call = call;
 	    label.text = title;

	    //ラベルの高さを取得して縦中央に配置
	    //ラベルの見た目の実際の高さは_boundHeight/3で取れる。なぜ３倍大きくなってるのか不明。
	    //また、_boundHeightの値はlabel.textをセットした後に決まるので、取得タイミングに注意。
	    var label_display_height = label._boundHeight/3;
 	    label.y= y+ (h/2) - (label_display_height/2);
	    label.textAlign = "center";
	    label.touchEnabled = false; //背景のタッチを阻害するのでラベルのタッチは無効にする。

	    //   			label.backgroundColor = 'orange';
	    // 			label.font = '2em"Ariar"';


	    this.square = square;
	    this.label = label;


	    //コールバックの扱いは面倒。thisでオブジェクトがうまく管理できないのでこうする

	    //リスナーは背景のSquareにセットする。ラベルが上に乗っているがタッチイベントを無効にしているので問題ない。
	    //コールバック関数の本体の中では this が使えないので注意
	    // 			var action = function(evt,call){ call();};
	    //   			square.addEventListener("touchstart",function(evt){ action(evt,call) },true);


	    this.setCallbackTouchStart(call);
	    

 	    game.rootScene.addChild(this.square);
	    game.rootScene.addChild(label);
	},





	setCallbackTouchEnd:function( call )
	{
	    var action = function(evt,call){ call();};
   	    this.self.square.addEventListener("touchend",function(evt){ action(evt,call) },true);
	},
	setCallbackTouchStart:function( call )
	{
	    var action = function(evt,call){ call();};
   	    this.self.square.addEventListener("touchstart",function(evt){ action(evt,call) },true);
	},
	
	setVisible:function( visible )
	{
	    this.square.visible = visible;
	    this.label.visible =  visible;
	    this.square.touchEnabled = visible;
	},
	test:function( target )
	{
	},
	

    });


    //タイトルシーン
    Title = Class.create
    ( TaskBase,{


	//初期化
	initialize:function()
	{
	    TaskBase.call(this); //スーパークラスのコンストラクタ呼び出し
	    this.w = screen_width;
	    this.h = screen_height;

	    this.sprite = new Sprite(this.w,this.h);  //スプライト準備、サイズ指定
	    this.sprite.image = game.assets['./img/title.png']; //画像のセット
	    game.rootScene.addChild(this.sprite);

	    this.label = new Label();
	    this.label.x=50;
	    this.label.y=200;
	    this.label.font = "16px Palatino";
	    this.label.color="white";
	    this.label.text = game_title_str;
	    game.rootScene.addChild(this.label);

	    title_button = new Button(0,0, this.w, this.h,"TITLE",0, this.startGame, title_bg_color);
	    if( testmode_controller_inside )
		controller = new Controller(0,screen_height-controller_height, 640,controller_height);


	},
	startGame:function()
	{
	    // game.assets["./media/bgm.mp3"].play();
	    title.destruct();
	    title_button.setVisible(false);
	    new GameMain();
	},
	destruct:function()
	{
	    game.rootScene.removeChild( this.sprite );
	    game.rootScene.removeChild( this.label );
	}
    });


    Cell = Class.create( TaskBase,{
	initialize:function(x,y,obj,data)
	{
	    TaskBase.call(this);

	    this.x = x;
	    this.y = y;
	    this.obj = obj;
	    this.data = data;
	},
    });

    Parameter = Class.create( TaskBase,{
			initialize:function(default_value,min,max)
	{
	    TaskBase.call(this);

		this.value = default_value;
		this.default_value =default_value;
		this.min = min;
		this.max = max;
		
	},
    });




    //メインシーン
    var first_initialize = false;
    GameMain = Class.create
    ( TaskBase,{
	//初期化
	initialize:function()
	{
 	    TaskBase.call(this); //スーパークラスのコンストラクタ呼び出し
	    
	    if(first_initialize)
		return;
	    
	    first_initialize = true;


	    //スコア
	    score = new Score( 240, 150 );

	    //デバッグ
	    debug = new Debug(250,0);
	    taskArray.push( debug );

	    
	},
    });


    //ボタン実行
    pushStart = function(){
	
	jadge.gameStart();
    }

    pushGameOver = function(){
 	gameover_button.setVisible(false);
  	removeAllTask();
  	title = new Title();
    }
    
    //クリア画面で押下
    pushClear = function(){
	jadge.nextStage();
    }

    //ミス画面表示
    displayPushStart = function(){
 	start_button.setVisible(true);
    }

    //ゲームオーバー表示
    displayPushGameOver = function(){
		gameover_button.setVisible(true);
    }

    //クリア画面表示
    displayPushClear = function(){
	player.ball.pause = true;
 	clear_button.setVisible(true);
    }



    //メイン処理
    game.onload = function() 
    {

	//タスク



//    	title = new Title();


	//メインタスクの作成
	var start_obj = new cow;
	start_obj.game_init();




	game.rootScene.addEventListener(Event.ENTER_FRAME, function() {

	    //全タスク実行
	    for ( var i = 0; i < taskArray.length; i++ )
            {
		var task = taskArray[i];
		if(task.dead_task) continue;
                task.main();
            }

	    //タスク掃除（現状では毎フレーム行っている。時間が余っていたらという条件でこれをやるようにすることで速度チューニング可）
	    for ( var i = taskArray.length-1; i >= 0; i-- )
            {
		var task = taskArray[i];
 		if( task.die==true )
		    if( task.dead_task==true )
		{
		    delete task;
		    taskArray.splice(i,1);
		}
            }
	    
        });


        game.rootScene.onenterframe = function() {
            //BGMのループ再生
	    //            game.assets["./media/bgm.mp3"].play();
        };

    }
    game.start(); // ゲームをスタートさせます




	
    cow = Class.create

    ( TaskBase,{


		//初期化
		initialize:function()
		{
			TaskBase.call(this); //スーパークラスのコンストラクタ呼び出し

			//変数宣言
			var player_speed;
var bullet_speed;
var enemy_speed;
var enemy_w;
var enemy_h;
var enemy_map_x;
var enemy_map_y;
var score;
var score_normal_enemy;
var player_stock;
var enemy_atack_wait_default;
var enemy_atack_wait;
var level_max;
var enemy_bounce_right_x;
var enemy_bounce_left_x;
var enemy_offset_x;
var enemy_offset_y;
var enemy_offset_angle;
var enemy_offset_speed;
var stage_turn;
var message_label;
var label_stage;
var label_score;
var player_guage;
var player;
var shooting;
var button_next;
var button_left;
var button_right;
var button_down;
var button_quit;
var mode;
var level;
var event_list;


			//変数初期化
			this.player_speed = 1;
this.bullet_speed = 3;
this.enemy_speed = 0;
this.enemy_w = 3;
this.enemy_h = 3;
this.enemy_map_x = 1;
this.enemy_map_y = 1;
this.score = new Parameter( 0 0 999999);
this.score_normal_enemy = 100;
this.player_stock = new Parameter( 5 0 10);
this.enemy_atack_wait_default = 5;
this.enemy_atack_wait = 5;
this.level_max = 49;
this.enemy_bounce_right_x = 5;
this.enemy_bounce_left_x = -5;
this.enemy_offset_x = 0;
this.enemy_offset_y = 0;
this.enemy_offset_angle = 0;
this.enemy_offset_speed = 1;
this.stage_turn = 0;
this.message_label = makeLabel(340, 20, 70, 30,  "message", "#ffffff", "20px Palatino" );
this.label_stage = makeLabel(340, 60, 70, 30,  "Stage:", "#ffffff", "20px Palatino" );
this.label_score = makeLabel(340, 90, 70, 30,  "Score:", "#ffffff", "20px Palatino" );
this.player_guage = new Guage( 34 12 7 3 stock #S(PARAMETER :VALUE 5 :DEFAULT 5 :MIN 0 :MAX 10 :ADD NIL));
this.player = NIL;
this.shooting = (NIL 0 0 20 20);
this.button_next = new Button( 340, 190, 70, 30, "[N]ext", 'N', this.push_next, color_button_default);
this.button_left = new Button( 340, 250, 70, 30, "[A] Left", 'A', this.push_left, color_button_default);
this.button_right = new Button( 340, 280, 70, 30, "[D] Right", 'D', this.push_right, color_button_default);
this.button_down = new Button( 340, 310, 70, 30, "[B] Beam", 'B', this.push_beam, color_button_default);
this.button_quit = new Button( 340, 340, 70, 30, "[Q]uit", 'Q', this.push_quit, color_button_default);
this.mode = MODE-TITLE;
this.level = 0;
this.event_list = (NIL (LIST* (MAKE-EVENT BLOCK 1 TURN 0 ENEMY RED) (LIST (MAKE-EVENT BLOCK 2 TURN 5 ENEMY YELLOW))) (LIST (LIST* (MAKE-EVENT BLOCK 1 TURN 0 ENEMY RED) (LIST* (MAKE-EVENT BLOCK 2 TURN 5 ENEMY YELLOW) (LIST* (MAKE-EVENT BLOCK 3 TURN 6 ENEMY RED) (LIST (MAKE-EVENT BLOCK 4 TURN 20 ENEMY BLUE)))))));

			

		},
		//更新
		main:function()
		{
		},
		
		//描画
		draw:function()
		{
		},
		//デストラクタ
		destruct:function()
		{
		},

		//関数定義
		grid_get_data_array:function(grid)
 
{
/*
(((MAP 'LIST (LAMBDA (X)
      (CELL-DATA X)
     )
     (GRID-CELL-ARRAY GRID)
    )
   )
  )
 

lisp >>> target

NIL

*/
},

grid_check_match_r_horizontal:function(grid, cell, require_num, test, match_list)
 
{
/*
(((GRID-CHECK-MATCH-R GRID CELL NIL 0 1 0 REQUIRE-NUM TEST MATCH-LIST)
   )
  )
 

lisp >>> target

NIL

*/
},

grid_check_match_r_vertical:function(grid, cell, require_num, test, match_list)
 
{
/*
(((GRID-CHECK-MATCH-R GRID CELL NIL 0 0 1 REQUIRE-NUM TEST MATCH-LIST)
   )
  )
 

lisp >>> target

NIL

*/
},

grid_check_match_r_slanting:function(grid, cell, require_num, test, match_list)
 
{
/*
(((GRID-CHECK-MATCH-R GRID CELL NIL 0 1 1 REQUIRE-NUM TEST MATCH-LIST)
   )
  )
 

lisp >>> target

NIL

*/
},

grid_check_match_r:function(grid, cell, before_cell, match_count, move_x, move_y, require_num, test, match_list)
 
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
 

lisp >>> target

NIL

*/
},

game_init:function()
 
{
/*
(((SHOW-TITLE)
   )
  )
 

lisp >>> target

NIL

*/
},

push_quit:function()
 
{
/*
(((SETQ *QUIT* 1)
   )
  )
 

lisp >>> target

NIL

*/
},

new_game_callback:function()
 
{
/*
(((INIT-GAMEMAIN)
   )
  )
 

lisp >>> target

NIL

*/
},

clear_callback:function()
 
{
/*
(((++ LEVEL)
    (INIT-STAGE LEVEL)
   )
  )
 

lisp >>> target

NIL

*/
},

gameover_callback:function()
 
{
/*
(((SHOW-TITLE)
   )
  )
 

lisp >>> target

NIL

*/
},

show_title:function()
 
{
/*
(((NEW-TITLE cow galaga #'NEW-GAME-CALLBACK)
   )
  )
 

lisp >>> target

NIL

*/
},

init_gamemain:function()
 
{
/*
(((SETQ LEVEL 0)
    (INIT-STAGE LEVEL)
    (UPDATE-SCORE)
   )
  )
 

lisp >>> target

NIL

*/
},

get_event_list_level:function(level)
 
{
/*
(((ELT EVENT-LIST LEVEL)
   )
  )
 

lisp >>> target

NIL

*/
},

get_event:function(level, block)
 
{
/*
(((LET (LEVEL-EVENT-LIST EVENT)
     (SETQ LEVEL-EVENT-LIST (GET-EVENT-LIST-LEVEL LEVEL)
     )
     (FOR (I 0 (LENGTH LEVEL-EVENT-LIST)
      )
      (SETQ EVENT (ELT LEVEL-EVENT-LIST I)
      )
      (IF (EQL (SLOT-VALUE EVENT 'BLOCK)
        BLOCK)
       (RETURN-FROM GET-EVENT EVENT)
      )
     )
    )
    NIL)
  )
 

lisp >>> target

NIL

*/
},

get_event_list_turn:function(level, turn)
 
{
/*
(((LET (LEVEL-EVENT-LIST EVENT R-LIST)
     (SETQ R-LIST (MAP 'LIST (LAMBDA (EVENT)
        (IF (EQUAL (SLOT-VALUE EVENT 'TURN)
          TURN)
         EVENT NIL)
       )
       (GET-EVENT-LIST-LEVEL LEVEL)
      )
     )
     (SETQ R-LIST (REMOVE NIL R-LIST)
     )
     R-LIST)
   )
  )
 

lisp >>> target

NIL

*/
},

get_enemy_list_block:function(shooting_world, block_no)
 
{
/*
(((LET (ENEMY-VEC R-LIST)
     (SETQ ENEMY-VEC (WORLD-GET-OBJ-VEC SHOOTING-WORLD 'ENEMY)
     )
     (SETQ R-LIST (MAP 'LIST (LAMBDA (OBJ)
        (IF (EQUAL (SLOT-VALUE OBJ 'TEAM-NO)
          BLOCK-NO)
         OBJ)
       )
       ENEMY-VEC)
     )
     (SETF R-LIST (REMOVE NIL R-LIST)
     )
     R-LIST)
   )
  )
 

lisp >>> target

NIL

*/
},

init_stage:function(level)
 
{
/*
(((SETQ ENEMY-ATACK-WAIT ENEMY-ATACK-WAIT-DEFAULT)
    (SETQ STAGE-TURN 0)
    (WORLD-REMOVE-ALL-OBJ SHOOTING)
    (SETQ MODE MODE-MAIN)
    (LET (ENEMY-MAP)
     (SETQ ENEMY-MAP (ELT MAP LEVEL)
     )
     (LET (MAP-W MAP-H BLOCK-NO BLOCK-EVENT TYPE-NO)
      (SETQ MAP-W (LENGTH (VEC-GET ENEMY-MAP 0)
       )
      )
      (SETQ MAP-H (LENGTH ENEMY-MAP)
      )
      (FOR (I 0 MAP-H)
       (FOR (J 0 MAP-W)
        (SETQ BLOCK-NO (VEC-GET (VEC-GET ENEMY-MAP I)
          J)
        )
        (SETQ BLOCK-EVENT (GET-EVENT LEVEL BLOCK-NO)
        )
        (SETQ TYPE-NO 0)
        (IF (NOT (EQUAL BLOCK-EVENT NIL)
         )
         (SETQ TYPE-NO (SLOT-VALUE BLOCK-EVENT 'ENEMY)
         )
        )
        (IF (NOT (= BLOCK-NO 0)
         )
         (GENERATE-ENEMY (* (+ ENEMY-MAP-X J)
           ENEMY-W)
          (* (+ ENEMY-MAP-Y I)
           ENEMY-H)
          ENEMY-W ENEMY-H TYPE-NO BLOCK-NO T)
        )
       )
      )
     )
    )
    (GENERATE-PLAYER 20 34 3 3)
    (SETQ PLAYER (ELT (WORLD-GET-OBJ-VEC SHOOTING 'PLAYER)
      0)
    )
   )
  )
 

lisp >>> target

NIL

*/
},

generate_event_enemys:function(event_array)
 
{
/*
(NIL)
 

lisp >>> target

NIL

*/
},

update_score:function()
 
{
/*
(((SET-TEXT LABEL-SCORE (FORMAT NIL Score:~d (SLOT-VALUE SCORE 'VALUE)
     )
    )
   )
  )
 

lisp >>> target

NIL

*/
},

update_fuel:function()
 
{
/*
(((SET-TEXT *LABEL-FUEL* (FORMAT NIL FUEL:~d *FUEL*)
    )
   )
  )
 

lisp >>> target

NIL

*/
},

next_turn:function()
 
{
/*
(((IF (EQUAL MODE MODE-CLEAR)
     (RETURN-FROM NEXT-TURN)
    )
    (IF (EQUAL MODE MODE-GAMEOVER)
     (RETURN-FROM NEXT-TURN)
    )
    (SHOOTING-FORWARD SHOOTING)
    (LET (TURN-EVENT-LIST TURN-EVENT BLOCK-ENEMY-LIST ENEMY)
     (SETF TURN-EVENT-LIST (GET-EVENT-LIST-TURN LEVEL STAGE-TURN)
     )
     (FOR (I 0 (LENGTH TURN-EVENT-LIST)
      )
      (SETQ TURN-EVENT (ELT TURN-EVENT-LIST I)
      )
      (SETQ BLOCK-ENEMY-LIST (GET-ENEMY-LIST-BLOCK SHOOTING (SLOT-VALUE TURN-EVENT 'BLOCK)
       )
      )
      (FOR (J 0 (LENGTH BLOCK-ENEMY-LIST)
       )
       (SETQ ENEMY (ELT BLOCK-ENEMY-LIST J)
       )
       (PRINT ENEMY)
       (APPEAR-ENEMY ENEMY)
      )
     )
    )
    (++ STAGE-TURN)
    (LET (ENEMY-VEC MOVE-ANGLE)
     (SETQ ENEMY-VEC (WORLD-GET-OBJ-VEC SHOOTING 'ENEMY)
     )
     (FOR (I 0 (LENGTH ENEMY-VEC)
      )
      (WORLD-MOVE-OBJ SHOOTING (VEC-GET ENEMY-VEC I)
       (GET-MOVE-X-RAD ENEMY-OFFSET-ANGLE ENEMY-OFFSET-SPEED)
       (GET-MOVE-Y-RAD ENEMY-OFFSET-ANGLE ENEMY-OFFSET-SPEED)
      )
     )
     (PRINT ENEMY-OFFSET-ANGLE)
     (IF (EQUAL ENEMY-OFFSET-ANGLE 0)
      (+= ENEMY-OFFSET-X 1)
     )
     (IF (EQUAL ENEMY-OFFSET-ANGLE 180)
      (+= ENEMY-OFFSET-X -1)
     )
     (IF (EQUAL ENEMY-OFFSET-ANGLE 90)
      (+= ENEMY-OFFSET-Y 1)
     )
     (COND ((> ENEMY-OFFSET-X ENEMY-BOUNCE-RIGHT-X)
       (IF (EQUAL ENEMY-OFFSET-ANGLE 0)
        (SETQ ENEMY-OFFSET-ANGLE 90)
        (SETQ ENEMY-OFFSET-ANGLE 180)
       )
      )
      ((< ENEMY-OFFSET-X ENEMY-BOUNCE-LEFT-X)
       (IF (EQUAL ENEMY-OFFSET-ANGLE 180)
        (SETQ ENEMY-OFFSET-ANGLE 90)
        (SETQ ENEMY-OFFSET-ANGLE 0)
       )
      )
     )
     (PRINT ENEMY-OFFSET-ANGLE)
    )
    (WORLD-DAMAGE-CONFLICT-OBJECT SHOOTING 'ENEMY 'PLAYER-BULLET)
    (WORLD-DAMAGE-CONFLICT-OBJECT SHOOTING 'PLAYER 'ENEMY-BULLET)
    (LOOP FOR I FROM (- (LENGTH (SLOT-VALUE SHOOTING 'VEC-OBJ)
      )
      1)
     ABOVE -1 DO (LET (OBJ)
      (SETQ OBJ (VEC-GET (SLOT-VALUE SHOOTING 'VEC-OBJ)
        I)
      )
      (IF (<= (SLOT-VALUE OBJ 'HP)
        0)
       (DEAD-OBJ OBJ)
      )
     )
    )
    (-= ENEMY-ATACK-WAIT 1)
    (COND ((<= ENEMY-ATACK-WAIT 0)
      (ATACK-RANDOM-ENEMY)
      (SETQ ENEMY-ATACK-WAIT ENEMY-ATACK-WAIT-DEFAULT)
     )
    )
    (IF (CHECK-CLEAR-STAGE)
     (SHOW-CLEAR)
    )
    (IF (CHECK-GAMEOVER)
     (SHOW-GAMEOVER)
    )
   )
  )
 

lisp >>> target

NIL

*/
},

push_next:function()
 
{
/*
(((NEXT-TURN)
   )
  )
 

lisp >>> target

NIL

*/
},

push_up:function()
 
{
/*
(NIL)
 

lisp >>> target

NIL

*/
},

push_down:function()
 
{
/*
(NIL)
 

lisp >>> target

NIL

*/
},

push_right:function()
 
{
/*
(((MOVE-PLAYER PLAYER-SPEED 0)
    (NEXT-TURN)
   )
  )
 

lisp >>> target

NIL

*/
},

push_left:function()
 
{
/*
(((MOVE-PLAYER (- PLAYER-SPEED)
     0)
    (NEXT-TURN)
   )
  )
 

lisp >>> target

NIL

*/
},

push_beam:function()
 
{
/*
(((SHOT-PLAYER)
    (NEXT-TURN)
   )
  )
 

lisp >>> target

NIL

*/
},

add_fuel:function(val)
 
{
/*
(((+= *FUEL* VAL)
    (IF (> *FUEL* *FUEL-MAX*)
     (SETQ *FUEL* *FUEL-MAX*)
    )
    (IF (< *FUEL* *FUEL-MIN*)
     (SETQ *FUEL* *FUEL-MIN*)
    )
   )
  )
 

lisp >>> target

NIL

*/
},

move_player:function(x, y)
 
{
/*
(((LET (PLAYER)
     (SETQ PLAYER (ELT (SHOOTING-GET-VEC-OBJECT SHOOTING 'PLAYER)
       0)
     )
     (SHOOTING-MOVE-OBJ SHOOTING PLAYER X Y)
    )
   )
  )
 

lisp >>> target

NIL

*/
},

generate_player:function(x, y, w, h)
 
{
/*
(((NEW-SHOOTING-OBJ SHOOTING X Y W H 'PLAYER 0 0 P)
   )
  )
 

lisp >>> target

NIL

*/
},

shot_player:function()
 
{
/*
(((LET (PLAYER)
     (SETQ PLAYER (ELT (SHOOTING-GET-VEC-OBJECT SHOOTING 'PLAYER)
       0)
     )
     (NEW-SHOOTING-OBJ SHOOTING (SLOT-VALUE (SLOT-VALUE PLAYER 'LABEL)
       'X)
      (- (SLOT-VALUE (SLOT-VALUE PLAYER 'LABEL)
        'Y)
       3)
      3 3 'PLAYER-BULLET BULLET-SPEED 270 |)
    )
   )
  )
 

lisp >>> target

NIL

*/
},

generate_enemy:function(x, y, w, h, type_no, team_no, hide)
 
{
/*
(((LET (OBJ-STR OBJ)
     (IF (= TYPE-NO RED)
      (SETQ OBJ-STR e)
     )
     (IF (= TYPE-NO YELLOW)
      (SETQ OBJ-STR E)
     )
     (IF (= TYPE-NO BLUE)
      (SETQ OBJ-STR B)
     )
     (SETQ OBJ (NEW-SHOOTING-OBJ SHOOTING X Y W H 'ENEMY ENEMY-SPEED 270 OBJ-STR)
     )
     (SETF (SLOT-VALUE OBJ 'TEAM-NO)
      TEAM-NO)
     (IF HIDE (SETF (SLOT-VALUE (SLOT-VALUE OBJ 'LABEL)
        'VISIBLE)
       NIL)
      (SETF (SLOT-VALUE OBJ 'NO-HIT)
       T)
     )
    )
   )
  )
 

lisp >>> target

NIL

*/
},

appear_enemy:function(enemy)
 
{
/*
(((SETF (SLOT-VALUE (SLOT-VALUE ENEMY 'LABEL)
      'VISIBLE)
     T)
    (SETF (SLOT-VALUE ENEMY 'NO-HIT)
     NIL)
   )
  )
 

lisp >>> target

NIL

*/
},

check_clear_stage:function()
 
{
/*
(((IF (= 0 (LENGTH (SHOOTING-GET-VEC-OBJECT SHOOTING 'ENEMY)
      )
     )
     T NIL)
   )
  )
 

lisp >>> target

NIL

*/
},

check_hit_wall:function()
 
{
/*
(((LET (PLAYER-X PLAYER-W)
     (SETQ PLAYER-X (- (LABEL-X *LABEL-PLAYER*)
       (LABEL-X *RACE*)
      )
     )
     (SETQ PLAYER-W (LABEL-W *LABEL-PLAYER*)
     )
     (COND ((< PLAYER-X (RACE-CURSE-LINE-LEFT-X *RACE*)
       )
       T)
      ((> (+ PLAYER-X PLAYER-W)
        (RACE-CURSE-LINE-RIGHT-X *RACE*)
       )
       T)
      (T NIL)
     )
    )
   )
  )
 

lisp >>> target

NIL

*/
},

dead_obj:function(obj)
 
{
/*
(((COND ((EQUAL (SLOT-VALUE OBJ 'TYPE)
       'ENEMY)
      (COND ((SLOT-VALUE OBJ 'DEAD-EFFECT)
        (SHOOTING-REMOVE-OBJ SHOOTING OBJ)
       )
       (T (PARAMETER-ADD SCORE SCORE-NORMAL-ENEMY)
        (UPDATE-SCORE)
        (SETF (SLOT-VALUE OBJ 'DEAD-EFFECT)
         T)
        (SETF (SLOT-VALUE (SLOT-VALUE OBJ 'LABEL)
          'TEXT)
         x)
       )
      )
     )
     ((EQUAL (SLOT-VALUE OBJ 'TYPE)
       'PLAYER-BULLET)
      (SHOOTING-REMOVE-OBJ SHOOTING OBJ)
     )
     ((EQUAL (SLOT-VALUE OBJ 'TYPE)
       'ENEMY-BULLET)
      (SHOOTING-REMOVE-OBJ SHOOTING OBJ)
     )
     ((EQUAL (SLOT-VALUE OBJ 'TYPE)
       'PLAYER)
      (DEAD-PLAYER OBJ)
     )
    )
   )
  )
 

lisp >>> target

NIL

*/
},

dead_player:function(obj)
 
{
/*
(((SETF (SLOT-VALUE OBJ 'DEAD-EFFECT)
     T)
    (SETF (SLOT-VALUE (SLOT-VALUE OBJ 'LABEL)
      'TEXT)
     x)
   )
  )
 

lisp >>> target

NIL

*/
},

show_clear:function()
 
{
/*
(((SETF MODE MODE-CLEAR)
    (NEW-TITLE clear #'CLEAR-CALLBACK)
   )
  )
 

lisp >>> target

NIL

*/
},

check_gameover:function()
 
{
/*
(((IF (<= (SLOT-VALUE PLAYER 'HP)
      0)
     T NIL)
   )
  )
 

lisp >>> target

NIL

*/
},

show_gameover:function()
 
{
/*
(((SET-TEXT MESSAGE-LABEL gameover)
    (SETF MODE MODE-GAMEOVER)
    (NEW-TITLE gameover #'GAMEOVER-CALLBACK)
   )
  )
 

lisp >>> target

NIL

*/
},

atack_random_enemy:function()
 
{
/*
(((LET (ENEMY-VEC ENEMY)
     (SETQ ENEMY (WORLD-GET-OBJ-RANDOM SHOOTING 'ENEMY)
     )
     (IF ENEMY (ATACK-ENEMY ENEMY)
     )
    )
   )
  )
 

lisp >>> target

NIL

*/
},

atack_enemy:function(enemy)
 
{
/*
(((NEW-SHOOTING-OBJ SHOOTING (SLOT-VALUE (SLOT-VALUE ENEMY 'LABEL)
      'X)
     (+ (SLOT-VALUE (SLOT-VALUE ENEMY 'LABEL)
       'Y)
      3)
     3 3 'ENEMY-BULLET BULLET-SPEED 90 |)
   )
  )
 

lisp >>> target

NIL

*/
},



    });






};
