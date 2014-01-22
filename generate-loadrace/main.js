enchant();

window.onload = function() {

	var game_title_str = "loadrace";

	//列挙型定義
	var MODE = {
TITLE : 0, 
COUNTDOWN : 1, 
RACE : 2, 
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
	var start_obj = new loadrace;
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




	
    loadrace = Class.create

    ( TaskBase,{


		//初期化
		initialize:function()
		{
			TaskBase.call(this); //スーパークラスのコンストラクタ呼び出し

			//変数宣言
			var message_label;
var label_score;
var label_speed;
var label_fuel;
var race;
var label_player;
var score;
var fuel_default;
var fuel_max;
var fuel_min;
var fuel;
var speed_default;
var speed_max;
var speed_min;
var speed;
var speed_up_val;
var speed_down_val;
var button_next;
var button_up;
var button_left;
var button_right;
var button_down;
var button_quit;
var mode;
var stage_no;


			//変数初期化
			this.message_label = makeLabel(340, 20, 70, 30,  "message", "#ffffff", "20px Palatino" );
this.label_score = makeLabel(340, 90, 70, 30,  "Score:", "#ffffff", "20px Palatino" );
this.label_speed = makeLabel(340, 120, 70, 30,  "", "#ffffff", "20px Palatino" );
this.label_fuel = makeLabel(340, 150, 70, 30,  "Fuel 100", "#ffffff", "20px Palatino" );
this.race = (NIL 4 2 30 32 1 2 3 30 1000);
this.label_player = makeLabel(190, 280, 30, 30,  "P", "#ffffff", "20px Palatino" );
this.score = 0;
this.fuel_default = 10;
this.fuel_max = 200;
this.fuel_min = 0;
this.fuel = 0;
this.speed_default = 27;
this.speed_max = 300;
this.speed_min = 0;
this.speed = 0;
this.speed_up_val = 10;
this.speed_down_val = 10;
this.button_next = new Button( 340, 190, 70, 30, "[N]ext", 'N', this.push_next, color_button_default);
this.button_up = new Button( 340, 220, 70, 30, "[W] Accele", 'W', this.push_up, color_button_default);
this.button_left = new Button( 340, 250, 70, 30, "[A] Left", 'A', this.push_left, color_button_default);
this.button_right = new Button( 340, 280, 70, 30, "[D] Right", 'D', this.push_right, color_button_default);
this.button_down = new Button( 340, 310, 70, 30, "[S] Brake", 'S', this.push_down, color_button_default);
this.button_quit = new Button( 340, 340, 70, 30, "[Q]uit", 'Q', this.push_quit, color_button_default);
this.mode = RACE;
this.stage_no = 0;

			

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

callback_make_cell_data:function(index, cell)
 
{
/*
((NIL)
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

init_gamemain:function()
 
{
/*
(((SETQ *STAGE-NO* 0)
    (INIT-STAGE *STAGE-NO*)
   )
  )
 

lisp >>> target

NIL

*/
},

init_stage:function(stage_no)
 
{
/*
(((RACE-INIT *RACE*)
    (SETQ *SPEED* *SPEED-DEFAULT*)
    (UPDATE-SPEED)
    (SETQ *FUEL* *FUEL-DEFAULT*)
    (UPDATE-FUEL)
    (COND ((= STAGE-NO 0)
      (RACE-ADD-EVENT *RACE* 0 0 'LEFT-LINE 5)
      (RACE-ADD-EVENT *RACE* 0 0 'RIGHT-LINE 22)
      (RACE-ADD-EVENT *RACE* 300 0 'ENEMY-YELLOW 10)
      (RACE-ADD-EVENT *RACE* 500 0 'LEFT-LINE 4)
      (RACE-ADD-EVENT *RACE* 500 0 'RIGHT-LINE 21)
      (RACE-ADD-EVENT *RACE* 500 0 'LEFT-LINE 3)
      (RACE-ADD-EVENT *RACE* 500 0 'RIGHT-LINE 20)
      (RACE-ADD-EVENT *RACE* 600 0 'LEFT-LINE 4)
      (RACE-ADD-EVENT *RACE* 600 0 'RIGHT-LINE 21)
     )
     ((= STAGE-NO 1)
      (RACE-ADD-EVENT *RACE* 0 0 'LEFT-LINE 8)
      (RACE-ADD-EVENT *RACE* 0 0 'RIGHT-LINE 20)
      (RACE-ADD-EVENT *RACE* 500 0 'LEFT-LINE 9)
      (RACE-ADD-EVENT *RACE* 500 0 'RIGHT-LINE 19)
      (RACE-ADD-EVENT *RACE* 700 0 'LEFT-LINE 10)
      (RACE-ADD-EVENT *RACE* 700 0 'RIGHT-LINE 18)
     )
    )
   )
  )
 

lisp >>> target

NIL

*/
},

update_speed:function()
 
{
/*
(((SET-TEXT *LABEL-SPEED* (FORMAT NIL ~d km/h (* *SPEED* 3.6)
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
(((RACE-FORWARD *RACE* *SPEED*)
    (UPDATE-SPEED)
    (ADD-FUEL -1)
    (UPDATE-FUEL)
    (IF (CHECK-GOAL)
     (SHOW-CLEAR)
    )
    (IF (CHECK-HIT-WALL)
     (CLASH-PLAYER)
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
(((ADD-SPEED *SPEED-UP-VAL*)
    (UPDATE-SPEED)
   )
  )
 

lisp >>> target

NIL

*/
},

push_down:function()
 
{
/*
(((ADD-SPEED (- 0 *SPEED-DOWN-VAL*)
    )
    (UPDATE-SPEED)
   )
  )
 

lisp >>> target

NIL

*/
},

push_right:function()
 
{
/*
(((MOVE-PLAYER 1 0)
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
(((MOVE-PLAYER -1 0)
    (NEXT-TURN)
   )
  )
 

lisp >>> target

NIL

*/
},

add_speed:function(val)
 
{
/*
(((+= *SPEED* VAL)
    (IF (> *SPEED* *SPEED-MAX*)
     (SETQ *SPEED* *SPEED-MAX*)
    )
    (IF (< *SPEED* *SPEED-MIN*)
     (SETQ *SPEED* *SPEED-MIN*)
    )
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
(((+= (LABEL-X *LABEL-PLAYER*)
     X)
    (+= (LABEL-Y *LABEL-PLAYER*)
     Y)
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

clash_player:function()
 
{
/*
(((SETF (LABEL-TEXT *LABEL-PLAYER*)
     x)
    (SHOW-GAMEOVER)
   )
  )
 

lisp >>> target

NIL

*/
},

check_goal:function()
 
{
/*
(((IF (>= (RACE-PLAYER-POSITION *RACE*)
      (RACE-CURSE-LENGTH *RACE*)
     )
     T NIL)
   )
  )
 

lisp >>> target

NIL

*/
},

show_clear:function()
 
{
/*
(((SET-TEXT *MESSAGE-LABEL* clear)
    (++ *STAGE-NO*)
    (INIT-STAGE *STAGE-NO*)
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
