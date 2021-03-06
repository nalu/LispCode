enchant();

window.onload = function() {

	var game_title_str = "<@lisp-rough-title>";

	//列挙型定義
	<@lisp-rough-enum>



    

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
	var start_obj = new <@lisp-rough-title>;
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




	
    <@lisp-rough-title> = Class.create

    ( TaskBase,{


		//初期化
		initialize:function()
		{
			TaskBase.call(this); //スーパークラスのコンストラクタ呼び出し

			//変数宣言
			<@lisp-rough-variable-declar>

			//変数初期化
			<@lisp-rough-variable-initialize>
			

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
		<@lisp-rough-method-define>

    });



};
