enchant();

window.onload = function() {

	var game_title_str = "ballaction";

	//列挙型定義
	var MODE = {
MODE-TITLE : 0, 
MODE-READY : 1, 
MODE-MAIN : 2, 
MODE-CLEAR : 3, 
MODE-GAMEOVER : 4, 
MODE-SCORE : 5, 
};
var ENEMY-TYPE = {
ENEMY-TYPE-A : 0, 
ENEMY-TYPE-B : 1, 
ENEMY-TYPE-C : 2, 
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
	var start_obj = new ballaction;
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




	
    ballaction = Class.create

    ( TaskBase,{


		//初期化
		initialize:function()
		{
			TaskBase.call(this); //スーパークラスのコンストラクタ呼び出し

			//変数宣言
			var message_label;
var label_score;
var player_speed;
var default_player_jump_power;
var enemy_speed;
var enemy_w;
var enemy_h;
var player_stock;
var score;
var enemy_generate_timer;
var enemy_generate_wait;
var action_world;
var player;
var button_next;
var button_left;
var button_right;
var button_down;
var button_quit;
var title;
var mode;


			//変数初期化
			this.message_label = makeLabel(340, 20, 70, 30,  "message", "#ffffff", "20px Palatino" );
this.label_score = makeLabel(340, 90, 70, 30,  "Score:", "#ffffff", "20px Palatino" );
this.player_speed = 1;
this.default_player_jump_power = 4;
this.enemy_speed = 1;
this.enemy_w = 3;
this.enemy_h = 3;
this.player_stock = (NIL 3 0 3);
this.score = (NIL 0 0 9999);
this.enemy_generate_timer = 0;
this.enemy_generate_wait = 10;
this.action_world = (NIL 0 0 30 20 1 3);
this.player = (NIL 3 14 3 3);
this.button_next = new Button( 340, 190, 70, 30, "[N]ext", 'N', this.push_next, color_button_default);
this.button_left = new Button( 340, 250, 70, 30, "[A] Left", 'A', this.push_left, color_button_default);
this.button_right = new Button( 340, 280, 70, 30, "[D] Right", 'D', this.push_right, color_button_default);
this.button_down = new Button( 340, 310, 70, 30, "[J] jump", 'J', this.push_jump, color_button_default);
this.button_quit = new Button( 340, 340, 70, 30, "[Q]uit", 'Q', this.push_quit, color_button_default);
this.title = (NIL Action Ball #'NEW-GAME-CALLBACK);
this.mode = MODE-MAIN;

			

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
(NIL)
 

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

init_gamemain:function()
 
{
/*
(((SETQ STAGE-NO 0)
    (INIT-STAGE STAGE-NO)
   )
  )
 

lisp >>> target

NIL

*/
},

init_stage:function(stage_no)
 
{
/*
(((SETF ENEMY-GENERATE-TIMER ENEMY-GENERATE-WAIT)
   )
  )
 

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

next_turn:function()
 
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

push_jump:function()
 
{
/*
(((ACTION-JUMP ACTION-WORLD PLAYER)
    (NEXT-TURN)
   )
  )
 

lisp >>> target

NIL

*/
},

move_player:function(x, y)
 
{
/*
(((WORLD-MOVE-OBJ ACTION-WORLD PLAYER X Y)
   )
  )
 

lisp >>> target

NIL

*/
},

jump_player:function()
 
{
/*
(((SETF (SLOT-VALUE PLAYER 'ANGLE)
     270)
    (SETF (SLOT-VALUE PLAYER 'SPEED)
     10)
   )
  )
 

lisp >>> target

NIL

*/
},

generate_player:function(x, y, w, h)
 
{
/*
(((NEW-ACTION-OBJ ACTION-WORLD X Y W H 'PLAYER 0 0 1 DEFAULT-PLAYER-JUMP-POWER P)
   )
  )
 

lisp >>> target

NIL

*/
},

generate_enemy:function(x, y, w, h, type_no)
 
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
 

lisp >>> target

NIL

*/
},

dead_enemy:function(obj)
 
{
/*
(((WORLD-DEAD-OBJ OBJ OBJ x 3)
    (SETF (SLOT-VALUE OBJ 'SPEED)
     0)
    (PARAMETER-ADD SCORE 1)
    (UPDATE-SCORE)
   )
  )
 

lisp >>> target

NIL

*/
},

dead_player:function()
 
{
/*
(((SETF (SLOT-VALUE (SLOT-VALUE PLAYER 'LABEL)
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
(((SET-TEXT MESSAGE-LABEL clear)
    (++ STAGE-NO)
    (INIT-STAGE STAGE-NO)
   )
  )
 

lisp >>> target

NIL

*/
},

check_gameover:function()
 
{
/*
(((IF (<= *FUEL* 0)
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
(((SET-TEXT *MESSAGE-LABEL* gameover)
   )
  )
 

lisp >>> target

NIL

*/
},



    });



};
