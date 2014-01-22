enchant();

window.onload = function() {

	var game_title_str = "hilow";

	//列挙型定義
	var MODE = {
HIDE : 0, 
OPEN : 1, 
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
	var start_obj = new hilow;
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




	
    hilow = Class.create

    ( TaskBase,{


		//初期化
		initialize:function()
		{
			TaskBase.call(this); //スーパークラスのコンストラクタ呼び出し

			//変数宣言
			var card_a_obj;
var card_b_obj;
var message_label;
var button_high;
var button_low;
var button_retry;
var button_quit;
var label_money;
var card_array;
var a_card;
var b_card;
var mode;
var select;
var money;


			//変数初期化
			this.card_a_obj = makeLabel(30, 60, 50, 70,  "a ", "#ffffff", "20px Palatino" );
this.card_b_obj = makeLabel(110, 60, 50, 70,  "b ", "#ffffff", "20px Palatino" );
this.message_label = makeLabel(30, 20, 130, 30,  "message", "#ffffff", "20px Palatino" );
this.button_high = new Button( 30, 140, 50, 30, "[H]igh", 'H', this.push_high, color_button_default);
this.button_low = new Button( 30, 170, 50, 30, "[L]ow", 'L', this.push_low, color_button_default);
this.button_retry = new Button( 110, 140, 50, 30, "[R]try", 'R', this.push_retry, color_button_default);
this.button_quit = new Button( 110, 170, 50, 30, "[Q]uit", 'Q', this.push_quit, color_button_default);
this.label_money = makeLabel(180, 60, 70, 30,  "money", "#ffffff", "20px Palatino" );
this.card_array = [];
this.a_card = 1;
this.b_card = 1;
this.mode = HIDE;
this.select = "";
this.money = 100;

			

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
(((SETQ *MODE* HIDE)
    (MODE-HIDE)
    (UPDATE-MONEY)
   )
  )
 

lisp >>> target

NIL

*/
},

check_highlow:function(open_n, hide_n)
 
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
 

lisp >>> target

NIL

*/
},

get_card_random_number:function()
 
{
/*
(((+ (RANDOM 12)
     1)
   )
  )
 

lisp >>> target

NIL

*/
},

mode_hide:function()
 
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
 

lisp >>> target

NIL

*/
},

mode_open:function()
 
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

push_retry:function()
 
{
/*
(((SETQ *MODE* HIDE)
    (MODE-HIDE)
   )
  )
 

lisp >>> target

NIL

*/
},

push_high:function()
 
{
/*
(((SETQ *SELECT* 'HIGH)
    (SETQ *MODE* 'OPEN)
    (MODE-OPEN)
    (-= (SLOT-VALUE *LABEL-MONEY* 'Y)
     1)
   )
  )
 

lisp >>> target

NIL

*/
},

push_low:function()
 
{
/*
(((SETQ *SELECT* 'LOW)
    (SETQ *MODE* 'OPEN)
    (MODE-OPEN)
   )
  )
 

lisp >>> target

NIL

*/
},

win:function()
 
{
/*
(((SETQ *MONEY* (+ *MONEY* 10)
    )
    (UPDATE-MONEY)
   )
  )
 

lisp >>> target

NIL

*/
},

lose:function()
 
{
/*
(((SETQ *MONEY* (- *MONEY* 10)
    )
    (UPDATE-MONEY)
   )
  )
 

lisp >>> target

NIL

*/
},

update_money:function()
 
{
/*
(((LET (STR)
     (SETQ STR (FORMAT NIL $ ~d *MONEY*)
     )
     (SET-TEXT *LABEL-MONEY* STR)
    )
   )
  )
 

lisp >>> target

NIL

*/
},



    });



};
