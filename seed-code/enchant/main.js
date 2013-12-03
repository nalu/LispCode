enchant();

window.onload = function() {

    var testmode_block_label = false;
    var testmode_rigthkey_down = true;
    var testmode_controller_inside = true;

    var base_fps = 24;
    // var screen_width = 640;
    // var screen_height = 960;
    var screen_width = 320;
    if( testmode_controller_inside==true )
	var screen_height = 504; //コントローラー領域含む。含まない場合は379となる
    else
	var screen_height = 379;
    // var screen_height = 388;
    // var controller_height = 250;
    var controller_height = 125;





    if( testmode_controller_inside==false )
    {
	$('#down_button').live('mousedown touchstart', function(){
	    game.input.down = true;
	});
	$('#down_button').live('mouseup touchstart', function(){
    	    game.input.down = false;
	});
	$('#down_button').live('touchstart', function(){
	    game.input.down = true;
	});
	$('#down_button').live('touchend', function(){
    	    game.input.down = false;
	});

	$('#left_button').live('mousedown touchstart', function(){
	    game.input.left = true;
	});
	$('#left_button').live('mouseup touchstart', function(){
    	    game.input.left = false;
	});
	$('#left_button').live('touchstart', function(){
	    game.input.left = true;
	});
	$('#left_button').live('touchend', function(){
    	    game.input.left = false;
	});

	$('#right_button').live('mousedown touchstart', function(){
	    game.input.right = true;
	});
	$('#right_button').live('mouseup touchstart', function(){
    	    game.input.right = false;
	});
	$('#right_button').live('touchstart', function(){
	    game.input.right = true;
	});
	$('#right_button').live('touchend', function(){
    	    game.input.right = false;
	});

	$('#a_button').live('mousedown touchstart', function(){
	    game.input.a = true;
	});
	$('#a_button').live('mouseup touchstart', function(){
    	    game.input.a = false;
	});
	$('#a_button').live('touchstart', function(){
	    game.input.a = true;
	});
	$('#a_button').live('touchend', function(){
    	    game.input.a = false;
	});

	$('#b_button').live('mousedown touchstart', function(){
	    game.input.b = true;
	});
	$('#b_button').live('mouseup touchstart', function(){
    	    game.input.b = false;
	});
	$('#b_button').live('touchstart', function(){
	    game.input.b = true;
	});
	$('#b_button').live('touchend', function(){
    	    game.input.b = false;
	});

    }
    

    //objects
    var title;
    var start_button;
    // var stock;
    var jadge;
    var debug;
    var controller;
    // var grid;
    // var clear_label;

    // var label_level;
    // var level = 1;
    // var level_virus_num = 1;
    // var sprite_next_block_b;
    // var next_block_x = 240;
    // var next_block_y = 50;
    // var next_block_a;
    // var next_block_b;
    // var fall_block_a;
    // var fall_block_b;
    // var fall_block_rotate_index;

    // var block_w = 20;
    // var block_h = 20;

    // var label_score;

    //ゲーム状態遷移
    // var  flag_block_put;
    // var flag_fall;
    // var flag_match_check;
    // var flag_auto_fall;
    // var flag_check_clear;

    // //マッチチェック
    // var match_require_num = 4;


    // var title_bg_color= "rgba( 100, 100, 100, 0.0 )";
    // var block_color= 'rgba( 100, 100, 100, 1.0)';
    // var block_color_blue = 'rgba( 50, 50, 250, 1.0)';
    // var block_color_green = 'rgba( 50, 250, 50, 1.0)';
    // var block_color_red = 'rgba( 250, 50, 50, 1.0)';
    // var block_color_orange = 'rgba( 230, 100, 50, 1.0)';
    // var block_color_yellow = 'rgba( 200, 170, 0, 1.0)';
    // var screen_bg_color = 'rgba( 200, 200, 200, 1.0)';
    // var start_button_color = "rgba( 100, 100, 100, 0.5)";

    var game = new Game(screen_width, screen_height); // ゲーム本体を準備すると同時に、表示される領域の大きさを設定しています。
    game.fps = 24; // frames(フレーム) per(毎) second(秒): ゲームの進行スピードを設定しています。

    // pre(前)-load(読み込み): ゲームに使う素材を予め読み込んでおきます。
    // game.preload('./img/title.png');
    // game.preload('./img/player_dead.png');
    // game.preload('./img/enemy20.png'); 
    // game.preload('./img/enemy_dead.png'); 
    // game.preload('./img/controller.png'); 
    // // game.preload('./media/bgm.mp3');
    // // game.preload('./media/shot.wav');
    // game.preload('./img/drug.png');

    game.rootScene.backgroundColor  = screen_bg_color; // ゲーム背景
	

    //タスク配列
    var taskArray = [];
    // var enemy_array = [];
    var removeAllTask = function()
    { 
	//後ろからやらないとまばらに消えるので注意
	for( var i=game.rootScene.childNodes.length-1; i>=0; i-- )
	{
	    game.rootScene.removeChild( game.rootScene.childNodes[i]);
	}
	

	for( var i =0; i<taskArray.length; i++)
	{
 	    taskArray[i].dead_task = true;
	};
    }

    //Input
    var Input = function()
    {
	this.a = false;
	this.down = false;
	this.last_touch_x = false;
	this.last_touch_y = false;
	this.flame_touch_x = false;
	this.flame_touch_y = false;
	this.key_buffer = [];
	this.touch = function( x, y )
	{
	    this.last_touch_x = x;
	    this.last_touch_y = y;
	    this.flame_touch_x = x;
	    this.flame_touch_y = y;
	}

    }
    

    var Util = function()
    {
	//普通に割り算すると小数が発生するのでtruncateを特別に実装
	this.truncate = function( a, b )
	{
	    return Math.floor( a / b );
	}
	//配列の中からランダムで選択
	this.random_get = function(array)
	{
	    var no = util.rand( array.length );
	    return array[ no ];
	}
	this.rand = function(num)
	{
	    return Math.floor(Math.random()*num);
	}
	//配列の中から要素の一致するものを削除
	this.remove = function( obj, array )
	{
	    for( var i=array.length-1; i>=0 ; i-- )
		if( array[i]==obj)
		    array.splice(i,1);
	    return array;
	}
	this.remove_if = function( test, array )
	{
	    for( var i=array.length-1; i>=0 ; i-- )
	    {
		if( test( array[i] )==true )
		    array.splice(i,1);
	    }
	    return array;
	}
	this.map = function( func, array )
	{
	    var r_list=[];
	    for( var i=0; i<array.length; i++ )
	    {
		r_list[i] = func( array[i] );
	    }
	    return r_list;
	}
	//配列の中から指定のオブジェクトを探す
	//見つかった場合はオブジェクトを返す
	//見つからなかった場合はnullを返す
	this.find = function( obj, array )
	{
	   var r_obj = array.indexOf(obj);
	   if( r_obj==-1 )
	       return null;
	    return obj;
	}
    };
    util = new Util();

    //矩形クラス
    Square = Class.create
    ( Sprite,{
	//初期化
	// 		initialize:function( w,h )
	// 		{
	// 			this.initialize(w,h,100,100,100,1.0)
	// 		},
	
	initialize:function( w,h, color)
	{
 	    Sprite.call(this,w,h); //スーパークラスのコンストラクタ呼び出し
	    this.surf = new Surface(w,h);
	    this.surf.context.beginPath();
	    this.surf.context.fillStyle = color;
	    this.surf.context.fillRect( 0,0, w,h);
	    this.image = this.surf;
	},
    });

    TaskBase = Class.create
    ({
	//初期化
	initialize:function( )
	{
	    this.dead_task = false;
	    this.self = this;
	},

	//更新
	main:function()
	{
	},

	//描画
	draw:function()
	{
	},
	
	//デストラクタ継承テスト版
	destruct:function()
	{
	    this.task_dead = true;
	},
	
    });

    Debug = Class.create
    ( TaskBase,{

	//初期化
	initialize:function( x,y)
	{
 	    TaskBase.call(this,x,y);
	    
	    //ＦＰＳ表示
	    this.fps_label = new Label(" ");
	    this.fps_label.color = "#ffffff";
	    this.fps_label.font = "bold";
	    this.fps_label.x = x;
	    this.fps_label.y = 5;

	    this.fps=0;
	    this.bs=0;
	    this.count=0;
	    game.rootScene.addChild(this.fps_label);

	    //タスク数表示
	    this.task_num_label = new Label(" ");
	    this.task_num_label.color = "#ffffff";
	    this.task_num_label.x = x;
	    this.task_num_label.y = 20;
 	    this.task_num_label.text = "task:";
 	    game.rootScene.addChild(this.task_num_label);
	},
	
	//更新
	main:function()
	{
 	    this.task_num_label.text = "task:"+taskArray.length;
	    
	    this.fps++;
	    this.s = new Date().getSeconds();
	    if( this.s != this.bs )
	    {
		this.fps_label.text = "FPS: " + this.fps + "/" + game.fps;
		this.bs = this.s;
		this.fps = 0;
	    }
	},

	//描画
	draw:function()
	{
	},

	//継承デストラクトテスト
	destruct:function()
	{
	    // 			TaskBase.destruct(this);
	    alert("child");
	},
	self:0,
	
    });

    

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


    // バーチャルボタンを作成するクラス.
    var VButton = enchant.Class.create( enchant.Sprite, {
	// コンストラクタ.
	initialize: function( x, y, mode ) {
            // 継承元をコール.
            enchant.Sprite.call( this, 50, 50 );
            // バーチャルボタン画像を設定.
            this.image = core.assets[ './img/button.png' ];
            this.x = x;                // X座標.
            this.y = y;                // Y座標.
            this.buttonMode = mode;    // ボタンモード.
	}
    });

    //コントローラー
    Controller = Class.create
    ( TaskBase,{
	//初期化
	initialize:function( x,y,w,h  )
	{
 	    TaskBase.call(this); //スーパークラスのコンストラクタ呼び出し
	    this.x = x;
	    this.y = y;
	    this.w = w;
	    this.h = h;

	    this.sprite = new Sprite( w, h );  //スプライト準備、サイズ指定
	    this.sprite.image = game.assets['./img/controller.png']; //画像のセット
	    this.sprite.x = this.x;
	    this.sprite.y = this.y;
 	    game.rootScene.addChild(this.sprite);

	    

	    //Pad
            var pad = new Pad();
            pad.x = x+14;
            pad.y = y+11;
            game.rootScene.addChild(pad);

	    //Button
	    // var a_button = new Button( 200,0, 100, 100,"A",0, this.pushA, title_bg_color);
	    // game.rootScene.addChild(a_button);


		    
   	    this.b_button = new Button( this.x+(this.w/4*2), this.y, this.w/4, h, "" ,0, this.pushB, title_bg_color);
   	    this.a_button = new Button( this.x+(this.w/4*3), this.y, this.w/4, h, "" , 'Z', this.pushA, title_bg_color);
	    this.b_button.setCallbackTouchEnd(this.releaseB);
	    this.a_button.setCallbackTouchEnd(this.releaseA);


	    //bind
 	    game.keybind('Z'.charCodeAt(0), 'a');
	    game.addEventListener("abuttondown", this.pushA);
	    game.addEventListener("abuttonup", this.releaseA);
 	    game.keybind('X'.charCodeAt(0), 'b');
	    game.addEventListener("bbuttondown", this.pushB);
	    game.addEventListener("bbuttonup", this.releaseB);
	    
	},

	//更新
	main:function()
	{
	},

	//描画
	draw:function()
	{
	},
	pushLeft:function()
	{
	    // 			this.push_left = true; //コールバックの中でthisは使えない
	    controller.push_left = true;
	},
	pushRight:function()
	{
	    // 			this.push_right = true; //コールバックの中でthisは使えない
	    controller.push_right = true;

	},
	releaseLeft:function()
	{
	    controller.push_left = false;
	},
	releaseRight:function()
	{
	    controller.push_right = false;
	},

	pushB:function()
	{
	    controller.push_b = true;
	},
	pushA:function()
	{
	    controller.push_a = true;

	},
	releaseB:function()
	{
	    controller.push_b = false;
	},
	releaseA:function()
	{
	    controller.push_a = false;
	},


    });


    StgObj = Class.create
    ( TaskBase,{
	//初期化
	initialize:function( x,y,w,h,angle,speed )
	{
	    TaskBase.call(this,x,y,angle,speed); //スーパークラスのコンストラクタ呼び出し
	    this.speed = speed;
	    this.x = x;
	    this.y = y;
	    this.w = w;
	    this.h = h;
	    this.dead_task = false;
	    this.angle = angle;
	    this.hp = 1;
	    this.nodamage = false; //ヒットしてもダメージを受けない
	    this.atackbody = false; //ヒットした対象にダメージ
	},

	//更新
	main:function()
	{
	},

	//描画
	draw:function()
	{
	},
	//ダメージ
	damage:function()
	{
	    if( this.atackbody==true )
	    {
		return;
	    }

	    if( this.nodamage==true )
		return;

	    this.hp-=1;
	},

    });



    DeadEffect = Class.create
    ( StgObj,{
	//初期化
	initialize:function( x,y,w,h,angle,speed, color )
	{
	    StgObj.call(this,x,y,w,h,angle,speed); //スーパークラスのコンストラクタ呼び出し


	    this.sprite = new Sprite( this.w, this.h);
	    this.sprite.image = game.assets['./img/enemy_dead.png']; //画像のセット
	    game.rootScene.addChild(this.sprite);

	    this.sprite.x = x;
	    this.sprite.y = y;
	    this.hp=1;
	    this.remove_wait = 0;
	},

	//更新
	main:function()
	{
	    if( this.remove_wait>=default_bomb_effect_remove_wait )
	    {
		this.dead_task=true;
		this.destruct();
	    }
	    this.remove_wait+=1;
	},
	//描画
	draw:function()
	{
	},
	destruct:function()
	{
	    game.rootScene.removeChild( this.sprite );

	}

    });

    //審判クラス。
    //判定順序の管理のためにも、当たり判定はここが受け持つようにしたほうがいい
    Jadge = Class.create
    ( TaskBase,{
	//初期化
	initialize:function()
	{
	    TaskBase.call(this); //スーパークラスのコンストラクタ呼び出し
	    this.started = false;
	    this.cleard = false;
	    this.current_stage = 0;
	    this.enemy_action_wait = 0;
	    this.fall_timer=0;
	},

	//更新
	main:function()
	{
	    this.fall_timer++;

	    if( this.fall_timer>=fall_speed )
	    {
		this.fall_timer=0;
		this.next_turn();
	    }



	    if( flag_fall ) 
	    {
		if( game.input.down )
		{
		    this.push_next();
		    game.input.down = false;

		}
    
		if( game.input.right )
		{
		    this.push_right();
		    game.input.right = false;
		}

		if( game.input.left )
		{
		    this.push_left();
		    game.input.left = false;
		}
		if( game.input.a )
		{
		    this.push_a();
		    game.input.a = false;
		}
		if( game.input.b )
		{
		    this.push_b();
		    game.input.b = false;
		}
	    }

	},

	//描画
	draw:function()
	{
	},
	
	gameinit:function()
	{
	    this.update_level();

	    this.put_random_drm( grid, level, 8);
	    this.set_next_block();

	    //   (update-next-block)
	    grid.update(grid);

	    flag_block_put = true;
	},
	//;画面更新
	update_level:function()
	{
	    var str = level;
	    label_level.text = "LEVEL : "+level;
	},
	update_next_block:function()
	{
	    next_block_a.update();
	    next_block_b.update();
	},
	set_next_block:function()
	{
	    next_block_a = new Block( this.make_random_color() ,"drug",true,0,null);
	    next_block_b = new Block( this.make_random_color() ,"drug",true,2,null);
	    next_block_a.sprite.x = next_block_x;
	    next_block_a.sprite.y = next_block_y;
	    next_block_b.sprite.x = next_block_x+block_w;
	    next_block_b.sprite.y = next_block_y;
	},
	//ランダムの色を作成
	make_random_color:function()
	{
	    var color;
	    color_no = util.rand(color_max);
	    if( color_no==0 ) ( color = "o" );
	    if( color_no==1 ) ( color = "x" );
	    if( color_no==2 ) ( color = "i" );
	    if( color_no==3 ) ( color = "a" );
	    if( color_no==4 ) ( color = "b" );
	    if( color_no==5 ) ( color = "c" );
	    return color;
	},
	//次のブロックをグリッドに配置
	put_next_block:function()
	{
	    var left_cell = grid.get_cell(grid,3,0);
	    var right_cell = grid.get_cell(grid,4,0);
	    left_cell.data = next_block_a;
	    right_cell.data = next_block_b;
	    //落下中のブロックへセット
	    fall_block_a = next_block_a;
	    fall_block_b = next_block_b;
	    //回転番号をリセット
	    fall_block_rotate_index = 0;

	    //次ブロックを用意
	    this.set_next_block();
	},

	//移動
	//複数移動可能
	// move_block:function(block,move_x,move_y)
	// {
	//     var cell = grid.get_cell_from_data( grid, block);
	//     var target_cell = null;
	//     //セル上を移動
	//     // 	;;移動先のセルを取得して、データをセット
	//     target_cell = grid.get_cell( grid, (cell.x+move_x), (cell.y+move_y));
	    
	//     target_cell.data = block;
	//     // 	;;移動前の位置を削除
	//     cell.data = null;
	// },

	
	move_block:function(block_list,move_x,move_y)
	{
	    var target_cell_array;
	    target_cell_array = [];
	    for( var i=0; i<block_list.length; i++ )
	    {
		var cell = grid.get_cell_from_data( grid, block_list[i] );
		
		//移動先リストに追加
		target_cell_array[i] = grid.get_cell( grid, cell.x + move_x, cell.y + move_y );

		//元の位置から削除
		cell.data = null;
	    }
	    
	    for( var i=0; i<block_list.length; i++ )
	    {
		var cell;
		var target_cell;
		var block;
		
		block = block_list[i];
		target_cell = target_cell_array[i];
		target_cell.data = block;
	    }

	},

	// ;;着地チェック
	// ;;指定のブロックに対して着地チェックを行なう
	// ;;基本的に指定ブロックの座標の下にブロックがあれば着地だが、
	// ;;下のブロックが操作中のブロックの場合は着地とみなさない
	// ;;着地していたらtを返す。していなければnilを返す
	check_fall_stop:function(block)
	{
	    return !this.check_cell_empty_from_block( block, 0, 1 );
	},
	// ;;指定ブロックの相対位置のセルが空いているかチェック
	check_cell_empty_from_block:function(block,x,y)
	{
	    return this.check_cell_empty( grid.get_cell_from_block( grid, block,x,y));
	},
	// ;;指定のセルが空いているかチェック
	// ;;空いていたらt、ブロックや壁がある場合nilを返す
	// ;;指定のセル上のブロックが操作中のブロックだったら無視する
	check_cell_empty:function(cell)
	{

	    //セルの存在チェック。存在しない場合は壁
	    if( cell==null )
		return false;

	    //セルがブロックを持っていて、かつそれが操作中ブロックではない場合は空ではない
	    if( 
		(cell.data!=null) && //セルがブロックを持っている
		(cell.data!=fall_block_a) && //操作中ブロックでない
		(cell.data!=fall_block_b) //操作中ブロックでない
	    )
	    {
		return false;
	    }
	    return true;
	},
	// ;;ドラッグタイプのブロックが配置されたセルのリストを返す
	get_drug_block_list:function(grid)
	{
	},
	// ;;マッチチェック
	// ;;各行毎に、左から１マスずつチェックし、同じ色が３つ以上続くようなら
	// ;;ブロックのmatchedをtにする
	// ;;その後、列についても上から同じチェックをする
	// ;;再帰を使う
	check_match:function()
	{
	    //   ;;左上から１行ずつチェック
	    //   ;;マッチチェックし終わったブロックは無視しない。
	    //   ;;無視した場合、縦方向にも検索があるので、Ｌの字になっていると失敗するため

	    for( var y=0; y<grid.h_cell_num; y++ )
	    {
		for( var x=0; x<grid.w_cell_num; x++ )
		{
		    var block;
		    block = grid.get_cell(grid,x,y).data;
		    if( block!=null )
		    {
			this.check_match_r_horizontal( block );
			this.check_match_r_vertical( block );
		    }
		}
	    }
	},
	// ;;自分の右側のブロックに潜っていく再帰関数
	check_match_r_horizontal:function(block)
	{
	    this.check_match_r( block, null, 0, 1, 0);
	},
	// ;;自分の下側のブロックに潜っていく再帰関数
	check_match_r_vertical:function(block)
	{
	    this.check_match_r( block, null, 0, 0, 1);
	},
	// ;;指定のブロック位置から、move-x move-yの方向に潜っていく再帰関数
	// ;;同じ色が続かなくなった時に、マッチカウントを返す。
	// ;;マッチカウントを返されて、それが３以上だったらそのブロックのマッチフラグを立てる
	check_match_r:function( block, before_block, match_count, move_x, move_y )
	{
	    var recursive_finish = null;

	    //   ;;前回のセルとマッチしているかチェック
	    //   ;;マッチしていなければ値を返す
	    if( before_block!=null )
	    {
		if( block.color==before_block.color )
		    match_count += 1;
		else
		    recursive_finish = true;
	    }
	    
	    //   ;;次のセルへ再帰使う
	    if( recursive_finish==null )
	    {
		var next_cell;
		//次のセルを取得
		next_cell = grid.get_cell_from_block( grid, block, move_x, move_y);

		if( next_cell!=null && //次のセルがあるかチェック
		    next_cell.data!=null )
		{
		    match_count = this.check_match_r( 
			next_cell.data, block, match_count,
			move_x, move_y);
		}

		//戻ってきたmatch-countでマッチ数をチェック
		//３以上ならフラグ立てる
		if( match_count >= (match_require_num-1))
		{
		    block.matched = true;
		}


	    }

	    return match_count;
	},
	//マッチフラグの立っているブロックリストを取得
	get_matched_block_list:function(grid)
	{
	    var block_list;
	    block_list = util.map( function(x){ return x.data;  }, grid.cell_array  );
	    block_list = util.remove( null, block_list );
	    block_list = util.remove_if( function(x){ if( x.matched==null) return true;  }, block_list);
	    return block_list;
	},
  // (let (block-list)
  //   (setq block-list (map 'list (lambda(cell) (cell-data cell)) (grid-cell-array grid)))
  //   (setq block-list (remove nil block-list))
  //   (setq block-list (remove-if (lambda(block) (equal (block-matched block) nil)) block-list))
  //   block-list
  //   )
	//マッチフラグの立っているブロックリストからスコアを算出
	get_score:function(grid)
	{
	    return this.get_matched_block_list(grid).length * 100;
	},
	// ;;マッチフラグの立っているブロックを全て削除
	delete_matched_block:function()
	{
	    for( var i=0; i<grid.cell_array.length; i++ )
	    {
		var block;
		block = grid.cell_array[i].data;
		if( block!=null && //ブロック存在チェック
		    block.matched==true )
		{
		    var block = grid.cell_array[i].data;
		    var connected_block;

		    //コネクション解除
		    connected_block = this.get_connect_block(block);
		    if( connected_block )
			connected_block.connect = null;

		    //ブロック削除
		    block.delete();
		    grid.cell_array[i].data = null;
		}
	    }
	},
	// ;;コネクションしてあるブロックを取得
	get_connect_block:function(block)
	{
	    var r_block=null;
	    var x=0;
	    var y=0;
	    if( block.connect )
	    {
		if( block.direction==0 ) x=1;
		if( block.direction==1 ) y=1;
		if( block.direction==2 ) x=-1;
		if( block.direction==3 ) y=-1;
		r_block = grid.get_data_from_data( grid, block, x, y);
	    }
	    return r_block;
	},

	next_turn:function()
	{
	    //ブロックが無い場合はまず配置
	    if( flag_block_put )
	    {
		this.put_next_block();
		flag_block_put = null;
		flag_fall = true;
	    }
	    else if( flag_fall )
	    {
		//着地チェック
		if( this.check_fall_stop_controll_block()  )
		{
		    flag_fall = null;
		    flag_match_check = true;
		    controll_block_a = null;
		    controll_block_b = null;
		}
		else
		{
		    //  着地していなかったら落下
		    this.fall_controll_block();
		}

		
	    }
	    //マッチチェック
	    else if( flag_match_check )
	    {
		this.check_match();
		score.add( this.get_score(grid) );
		flag_match_check = null;

		
		// マッチしていなければクリアチェック
		// マッチがあれば削除して自動落下フェーズへ
		if( 0 < this.get_matched_block_list(grid).length )
		{
		    this.delete_matched_block();
		    flag_auto_fall = true;
		}
		else
		    flag_check_clear = true;

	    }
	    //;;自動落下
	    else if( flag_auto_fall )
	    {
		var fall_count;
		fall_count = this.fall_block_all();
		if( fall_count==0 )
		{
		    //着地していればマッチチェックフェーズへ
		    flag_match_check = true;
		    flag_auto_fall = null;
		}
	    }
	    //クリアチェック
	    else if( flag_check_clear )
	    {
		flag_check_clear = null;
		if( this.check_clear() )
		    this.show_clear();
		else
		    flag_block_put = true;
	    }

	    //    
	    grid.update(grid);
	    
	},
	push_next:function()
	{
	    this.next_turn();
	},
	// ;;操作中ブロックを落下させる
	fall_controll_block:function()
	{
	    this.move_block( [fall_block_a, fall_block_b], 0, 1 );
	    // this.move_block( fall_block_b, 0, 1 );
	},
	// ;;操作中ブロックの着地チェック
	check_fall_stop_controll_block:function()
	{
	    if( this.check_fall_stop( fall_block_a ) ||
		this.check_fall_stop( fall_block_b ) )
	    {
		return true;
	    }
	    return false;
	},
	// +;;全ドラッグタイプブロックの落下
	// +;;落下できた数を返す
	fall_block_all:function()
	{
	    var block_list;
	    block_list = grid.get_data_array( grid );
	    block_list = util.remove( null, block_list );
	    block_list = util.remove_if( function(x){ if( x.type=="virus") return true;  }, block_list);
	    block_list = util.remove_if( function(x){ if( jadge.check_fall_stop(x)) return true;  }, block_list);
	    block_list = util.remove_if( function(x){ return jadge.check_pair_lost_in_list(x, block_list); }, block_list);
	    this.move_block( block_list, 0, 1);
	    return block_list.length;
	},
	// +;;リストからペアが見つからないものについてtを返す
	// +;;ブロックリストから、ペアが見つからないものを排除
	// +;;リストの中にペアのブロックが含まれているかチェック
	// +;;最初からコネクションがない場合は無視し、コネクションがあるものはペアがリスト内に存在するかチェック
	check_pair_lost_in_list:function( block, block_list )
	{
	    var pair_block=null;
	    var r_check=null;
	    pair_block = this.get_connect_block(block);
	    if( pair_block &&
		block.connect &&
		util.find( pair_block, block_list ) == null
		)
		{
		    r_check = true;
		}
	    return r_check;
	},
	// ;;着地するまで落下
	push_fall:function()
	{
	    //   ;;着地していないかぎり落下を繰り返す
	    for( var i=0; i<grid.h_cell_num; i++ )
	    {
		if( this.check_fall_stop_controll_block()!=null )
		{
		    this.fall_controll_block();
		}
	    }
	    flag_fall = null;
	    grid.update();
	},
	push_right:function()
	{
	    //右セルのチェック
	    if( this.check_cell_empty_from_block( fall_block_a,1,0 ) &&
		this.check_cell_empty_from_block( fall_block_b,1,0 ) )		
	    {
		this.move_block( [fall_block_a, fall_block_b],1,0);
		// this.move_block(fall_block_a,1,0);
	    }
	    grid.update(grid);
	},
	push_left:function()
	{
	    //左セルのチェック
	    if( this.check_cell_empty_from_block( fall_block_a,-1,0 ) &&
		this.check_cell_empty_from_block( fall_block_b,-1,0 ) )		
	    {
		this.move_block( [fall_block_a,fall_block_b],-1,0);
		// this.move_block(fall_block_b,-1,0);
	    }
	    grid.update(grid);
	},
	push_rl:function()
	{
	},
	push_ll:function()
	{
	},
	//ランダムに要素を配置。ＤＲＭ用
	// ;;レベル＊４の要素を配置
	// ;;ベース・ラインより下にランダム配置する
	// ;;飽和量が一定を超えると、ベースラインより上にも配置する
	put_random_drm:function( grid, level, base_line_y )
	{
	    for( var i=0; i<(level*level_virus_num); i++ )
	    {
		var empty_cell;
		var color_no;
		var put_block;
		empty_cell = grid.random_get_empty_area( grid, 0, base_line_y, grid.w_cell_num, (grid.h_cell_num - base_line_y) );

		//空きセルが無い（ベースライン以下が一杯）
		if( empty_cell==null )
		{
		}
		else
		{
		    var color = jadge.make_random_color();
		    put_block = new Block( color, "virus", null,0,null );
		    empty_cell.data = put_block;
		}

	    }
	},


	push_a:function()
	{
	    this.rotate_block_right();
	    grid.update(grid);
	},
	push_b:function()
	{
	    this.rotate_block_left();
	    grid.update(grid);
	},

	// ;;回転処理
	// ;;回転方向はＡの時計回りとＢの反時計回り。
	// ;;どちらもブロックの座標は２パターンで、右に倒れるか、タテに戻るか。
	// ;;右に倒れた際、右側にブロックや壁が存在する場合はブロック自身が左にずれる。
	// ;;左にずれるスペースがない場合は、回転が無効になる
	// ;;タテに戻る場合は、上側に障害物がある場合、回転が無効になる
	// ;;回転が成功した場合のみ、回転状態を表すrotate-indexを変更する
	rotate_block_left:function()
	{
	    var next_index;
	    next_index = fall_block_rotate_index - 1;
	    if( next_index < 0 ) next_index = 3;
	    this.set_rotate(next_index);
	},
	rotate_block_right:function()
	{
	    var next_index;
	    next_index = fall_block_rotate_index + 1;
	    if( next_index >= 4 ) next_index = 0;
	    this.set_rotate(next_index);
	},
	// ;;回転番号から、a,bブロックをそれぞれ正しい位置にセットする
	// ;;位置は操作ブロックの基本セルを取得して、そこを基準にして判断する
	set_rotate:function( rotate_index )
	{
	    var rotate_target_cell_a;
	    var rotate_target_cell_b;
	    var enable_rotate;
	    var rotate_to_point_a;
	    var rotate_to_point_b;
	    
	    // ;;回転先座標を取得
	    rotate_to_point_a = this.get_rotate_point( rotate_map_a, rotate_index );
	    rotate_to_point_b = this.get_rotate_point( rotate_map_b, rotate_index );

	    // ;;回転先セルを取得		
	    rotate_target_cell_a = this.get_rotate_to_cell( fall_block_a, rotate_to_point_a );
	    rotate_target_cell_b = this.get_rotate_to_cell( fall_block_b, rotate_to_point_b );

	    // ;;回転が可能かチェック
	    if( (this.check_cell_empty(rotate_target_cell_a)==true ) &&
		(this.check_cell_empty(rotate_target_cell_b)==true ))
	    {
		enable_rotate = true;
	    }

	    // ;;縦から横にする時に障害物がある（右が埋まっている）場合は、左に移動
	    // ;;横向き左移動した場合にも障害物がある場合、回転は失敗とする
	    // ;;横から縦にする時に障害物がある（上が埋まっている）場合は、なにもせずそのまま回転失敗とする

	    if(
		(rotate_index==0 || rotate_index==2) &&
		    (enable_rotate==null)
	    )
	    {

		// ;;回転先ｘ座標を−１ 
		rotate_to_point_a[0] = rotate_to_point_a[0]-1;
		rotate_to_point_b[0] = rotate_to_point_b[0]-1;
       

		// ;;回転先セルを再取得
		rotate_target_cell_a = this.get_rotate_to_cell( fall_block_a, rotate_to_point_a );
		rotate_target_cell_b = this.get_rotate_to_cell( fall_block_b, rotate_to_point_b );


		// ;;障害物が無いかチェック
		if( 
		    (this.check_cell_empty( rotate_target_cell_a )) &&
		    (this.check_cell_empty( rotate_target_cell_b ))
		    )
		{
		    enable_rotate = true;
		}
		else
		    enable_rotate = null;

	    }


            if( enable_rotate )
	    {
		
		// ;元の位置から削除
		var cell;
		cell = grid.get_cell_from_block( grid, fall_block_a, 0, 0);
		cell.data = null;
		grid.get_cell_from_block( grid, fall_block_b, 0, 0).data = null;
		// ;回転先にセット
		rotate_target_cell_a.data = fall_block_a;
		rotate_target_cell_b.data = fall_block_b;
		// ;;回転番号に応じてabブロックのdirectionをセット
		if( rotate_index==0 )
		{
		    fall_block_a.direction = 0;
		    fall_block_b.direction = 2;
		}
		if( rotate_index==1 )
		{
		    fall_block_a.direction = 1;
		    fall_block_b.direction = 3;
		}
		if( rotate_index==2 )
		{
		    fall_block_a.direction = 2;
		    fall_block_b.direction = 0;
		}
		if( rotate_index==3 )
		{
		    fall_block_a.direction = 3;
		    fall_block_b.direction = 1;
		}

		// ;回転成功したら回転番号をセット
		fall_block_rotate_index = rotate_index;
	    }

	    return enable_rotate;
	},
	// ;;現在の回転状態を考慮して、指定の回転番号に対応するaブロックの座標マップを返す
	get_rotate_point:function( map, rotate_index )
	{
	    var current_rotate_map;
	    var target_rotate_map;
	    current_rotate_map = map[fall_block_rotate_index];
	    target_rotate_map = map[rotate_index];
	    var r_list =[
		target_rotate_map[0] - current_rotate_map[0],
		target_rotate_map[1] - current_rotate_map[1]
	    ];
	    return r_list;
	},
	// ;;ブロックと回転マップ要素から、回転先のセルを返す
	get_rotate_to_cell:function( block, point )
	{
	    return grid.get_cell_from_cell( grid,
					  grid.get_cell_from_data( grid, block),
					  point[0],
					  point[1]);
	},

	check_clear:function()
	{
	    var virus_list;
	    virus_list = util.map( function(cell){ return cell.data;  }, grid.cell_array);
	    virus_list = util.remove( null, virus_list );
	    virus_list = util.remove_if( function(block){ return (block.type!="virus")   }, virus_list);
	    console.log(virus_list);
	    if( virus_list.length==0 )
		return true;
	    else
		return null;
	},

	show_clear:function()
	{
	    clear_label.visible = true;
	},

	
    });


    //スコア
    Score = Class.create
    ( TaskBase,{
	//初期化
	initialize:function(x,y)
	{
	    TaskBase.call(this); //スーパークラスのコンストラクタ呼び出し
	    this.score=0;
	    this.label = new Label(" ");
	    this.label.color = "#ffffff";
	    this.label.font = "20px Palatino";
	    this.label.x = x;	// X座標
	    this.label.y = y;	// Y座標
	    game.rootScene.addChild(this.label);
	    this.updateScore();
	},

	//更新
	main:function()
	{

	},

	//描画
	draw:function()
	{
	},

	set:function(set_score)
	{
	    this.score = set_score;
	    this.updateScore();
	},
	add:function(plus_num)
	{
	    this.score+=plus_num;
	    this.updateScore();
	},

	updateScore:function()
	{
	    this.label.text = String(this.score);
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
	    this.label.text = "Waffle Party Beta version";
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


    Grid = Class.create( TaskBase,{
	initialize:function(x,y,w_cell_num,h_cell_num, cell_w, cell_h, callback_make_cell_obj, callback_make_cell_data, callback_update_cell  )
	{
	    TaskBase.call(this);
	    this.x = x;
	    this.y = y;
	    this.w_cell_num = w_cell_num;
	    this.h_cell_num = h_cell_num;
	    this.cell_w = cell_w;
	    this.cell_h = cell_h;
	    this.callback_make_cell_obj = callback_make_cell_obj;
	    this.callback_update_cell = callback_update_cell;
	    this.callback_make_cell_data = callback_make_cell_data;
	    
	    this.cell_array = new Array(w_cell_num*h_cell_num);

	    //コールバックが空ならデフォルトをセット
	    if( callback_make_cell_obj==null )
	    {
		this.callback_make_cell_obj = this.default_callback_make_cell_obj;
		this.callback_update_cell = this.default_callback_update;
		this.callback_make_cell_data = this.default_callback_make_cell_data;
	    }
	    

	    // //セルを作成
	    for( var i=0; i<this.cell_array.length; i++ )
	    {
	    	var cell = new Cell( 
	    	    i % w_cell_num, //x
	    	    util.truncate( i ,w_cell_num), //y
	    	    this.callback_make_cell_obj(x,y, i % w_cell_num, Math.floor(i / w_cell_num), cell_w, cell_h,i),
	    	    this.callback_make_cell_data()
		    // 0,0,0,0
	    	);
		this.cell_array[i] = cell;
	    }


	    
	},
	
	default_callback_make_cell_obj:function( grid_x, grid_y, x, y, w, h, index)
	{
	    new Button( grid_x+(x*w),
			grid_y+(y*h),
			w,h,index,0, 0, start_button_color);

	    // 	    (new-button 
	    // 	     (+ grid-x (* x w));x
	    // 	     (+ grid-y (* y h))
	    // 	     w h ;w, h
	    // 	     (format nil "~d" index);str
	    // 	     ;;  				'a ;key
	    // (read-from-string (format nil "~d" index)) ;                
	    // #'push-grid) 
	    
	},
	default_callback_update:function()
	{
	},
	default_callback_make_cell_data:function()
	{
	    return null;
	},
	update:function(grid)
	{
	    for( var i=0; i<(grid.cell_array.length); i++ )
	    {
		var cell =  grid.cell_array[i];
		grid.callback_update_cell(cell);
		
	    }
	},
	// ;;指定のオブジェクトのグリッド上のｘ座標を返す
	grid_x_cell:function(grid,obj)
	{
	    var index = grid.cell_array.indexOf(obj);
	    return index / grid.grid_w_cell_num;
	},
	// ;;指定のオブジェクトのグリッド上のｙ座標を返す
	grid_y_cell:function(grid,obj)
	{
	    var index = grid.cell_array.indexOf(obj);
	    return util.truncate( index, grid.grid_w_cell_num);
	},

	//ランダムに空のセル配列を返す。
	get_empty_cell_array:function( cell_array )
	{
	    var r_array = [];
	    for( var i=0; i<cell_array.length; i++ )
	    {
	     	if( cell_array[i].data == null )
	     	    r_array.push(cell_array[i]);
	    }
	    return r_array;
	},

	// ;;指定の位置のセルを取得
	// ;;範囲外を指定したらnilを返す
	get_cell:function( grid, x, y)
	{
	    if( x<0 ) return null;
	    if( y<0 ) return null;
	    if( x >= grid.w_cell_num) return null;
	    if( y >= grid.h_cell_num) return null;
	    return grid.cell_array[ (y * grid.w_cell_num)+x ];
	},
	//指定のセルの相対位置のセルを返す
	get_cell_from_cell:function(grid, cell, x, y )
	{
	    return this.get_cell( grid, (cell.x + x), (cell.y + y)  );
	},
	// ;;指定ブロックの相対位置のセルを返す
	get_cell_from_block:function( grid, block, x, y)
	{
	    var cell;
	    cell = grid.get_cell_from_data( grid, block);
	    return grid.get_cell( grid, cell.x + x, cell.y + y);
	},
	
	//;;指定データの相対位置のデータを返す
	get_data_from_data:function( grid, data, x, y)
	{
	    var cell;
	    cell = grid.get_cell_from_block( grid, data, x,y );
	    return cell.data;
	},
	
	// ;;指定のデータを持つ最初のセルを取得
	// ;;存在しなければnilを返す
	get_cell_from_data:function(grid,data)
	{
	    for( var i=0; i<grid.cell_array.length; i++ )
	    {
		var cell = grid.cell_array[i];
		if( cell.data==data )
		    return cell;
	    }
	    return null;
	},

	// ;;指定エリアのセル配列を返す
	get_area_cell_array:function( grid, area_x, area_y, area_w, area_h )
	{
	    var r_array = [];
	    for( var i=0; i<grid.cell_array.length; i++ )
	    {
		var cell = grid.cell_array[i];
		if( 
		    ((area_x + area_w) <= cell.x) ||
			((area_y + area_h) <= cell.y) ||
			( cell.x < area_x ) ||
			( cell.y < area_y ) 
		)
		{
		}
		else
		{
		    r_array.push( cell );
		}
		
	    }
	    return r_array;
	},
	// +;;全セルの持つデータを配列にして返す。nilも含む 
	get_data_array:function( grid )
	{
	   return util.map( function(x){ return x.data;  }, grid.cell_array);
	},

	// ;;ランダムに空白のセルを取得
	random_get_empty:function( grid )
	{
	    return util.get_random( grid.cell_array );
	},

	// ;;ランダムに空白のセルを取得。範囲指定
	random_get_empty_area:function( grid, x, y, w, h )
	{
	    //;指定のエリアのセル配列を作成後、要素が空の配列を取得し、ランダムで返す
	    var area_cell_array =  grid.get_area_cell_array( grid, x, y, w, h);
	    var empty_cell_array =  grid.get_empty_cell_array( area_cell_array );
	    var r_cell = util.random_get( empty_cell_array );
	    return r_cell;
	},
	// ;;ランダムにx個の要素を配置
	//使ってない可能性たかい
	put_random:function( grid, put_num )
	{
	    var empty_cell;
	    for( var i=0; i<put_num; i++ )
	    {
		empty_cell = random_get_empty( grid );
		empty_cell.text = "x";
	    }
	},



	
    });




    //セルのデータに設定するためのブロッククラス
    //タイプはdrag,virusのどちらか、connectは接続方向、matchedはマッチチェック用
    function block( color, type, connect, matched )
    {
	this.color = color;
	this.type = type;
	this.connect = connect;
	this.matched = matched;
	this.sprite;
    }

    Block = Class.create
    ( TaskBase,{
	initialize:function(color,type,connect,direction,matched)
	{
	    TaskBase.call(this);
	    this.color = color;
	    this.type = type;
	    this.connect = connect;
	    this.direction = direction;
	    this.matched = matched;
	    var w = block_w;
	    var h = block_h;
	    var sprite = new Sprite(w,h);  //             
	    if( type=="virus" )
		sprite.image = game.assets['./img/enemy20.png']; //      
	    if( type=="drug" )
		sprite.image = game.assets['./img/drug.png']; //      
	    game.rootScene.addChild(sprite);
	    this.sprite = sprite;
	    this.update();

	},

	//  
	main:function()
	{

	},

	//  
	draw:function()
	{
	},
	update:function()
	{
	    var color_num=0;
	    if( this.color=="o" )
		color_num = 1;
	    if( this.color=="x" )
		color_num = 2;
	    if( this.color=="i" )
		color_num = 3;
	    if( this.color=="a" )
		color_num = 0;
	    if( this.color=="b" )
		color_num = 4;
	    if( this.color=="c" )
		color_num = 5;

	    if( this.type=="virus" )
	    {
		var to_no = color_num + 6;
		this.sprite.frame = [ color_num, color_num, color_num, color_num,
				      to_no, to_no, to_no, to_no];
		// if( this.color=="o")
		//     this.sprite.frame = [1,1,1,1,7,7,7,7];
		// if( this.color=="x")
		//     this.sprite.frame = [2,2,2,2,8,8,8,8];
		// if( this.color=="i")
		//     this.sprite.frame = [3,3,3,3,9,9,9,9];
	    }
	    if( this.type=="drug" )
	    {

		this.sprite.frame = [ (color_num*4) + this.direction];

	    }
	},
	delete:function()
	{
	    this.sprite.parentNode.removeChild(this.sprite);
	    this.sprite = null;
	},
    });


    //セルのデータを返すコールバック関数
    var callback_make_cell_data = function()
    {
	return null;
    }

    //セルの見た目を表すオブジェクト作成関数
    var callback_make_cell_obj = function( grid_x, grid_y, x, y, w, h, index )
    {
	if( testmode_block_label )
	{
	    var label = new Label("["+index+"]");
	    label.color = "#ffffff";
	    label.font = "bold";
	    label.x = grid_x+(x*w);
	    label.y = grid_y+(y*h);
	    game.rootScene.addChild(label);
	    
	    return label;
	}

	// 	var sprite = new Sprite( w, h );  //             
	// 	sprite.image = game.assets['./img/enemy.png']; //      
	// 	game.rootScene.addChild(sprite);
	// 	sprite.frame = [1,1,1,1,5,5,5,5];
	// //			if( color==block_color_red )
	// //				this.sprite.frame = [0,0,0,0,4,4,4,4];
	// //			if( color==block_color_blue )
	// //				this.sprite.frame = [1,1,1,1,5,5,5,5];
	// //			if( color==block_color_green )
	// //				this.sprite.frame = [2,2,2,2,6,6,6,6];
	// //			if( color==block_color_yellow )
	// //				this.sprite.frame = [3,3,3,3,7,7,7,7];

	// 	sprite.x = grid_x+(x*w);
	// 	sprite.y = grid_y+(y*h);
	return null;
    };

    //;;セルのアップデート関数
    var callback_update_cell = function(cell)
    {
	var block = cell.data;
	if( block!=null )
	{
	    block.sprite.x = grid.x+(cell.x*grid.cell_w);
	    block.sprite.y = grid.y+(cell.y*grid.cell_h);

	    if( block.type=="drug" )
	    {
		block.update();
	    }

	}
    };



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




	    //グリッド
	    grid = new Grid(50,50,8,16,block_w,block_h,
			    callback_make_cell_obj,
			    callback_make_cell_data,
			    callback_update_cell);
	    taskArray.push(grid);



	    //レベル
	    label_level = new Label("Level");
	    label_level.color="#ffffff";
	    label_level.x =240;
	    label_level.y = 100;
	    game.rootScene.addChild(label_level);

	    //スコア
	    score = new Score( 240, 150 );


	    //ジャッジ
	    jadge = new Jadge();
	    taskArray.push( jadge  );
	    jadge.gameinit();
	    
	    //デバッグ
	    debug = new Debug(250,0);
	    taskArray.push( debug );


	    //クリアメッセージ
	    clear_label = new Label("CLEAR");
	    clear_label.color = "#ffffff";
	    clear_label.font = "40px Palatino";
	    clear_label.x = 60;  
	    clear_label.y = 160;
	    clear_label.visible = false;
	    game.rootScene.addChild(clear_label);

	    
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

	//インプット
	input = new Input();


	//タイトル
   	title = new Title();





        // シーンに「毎フレーム実行イベント」を追加します。
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

        // シーンに「タッチイベント」を追加します。
        game.rootScene.addEventListener(Event.TOUCH_START, function(e) {

	    //inputタスクバインド
	    input.last_touch_x = e.x;
	    input.last_touch_y = e.y;

        });

        game.rootScene.addEventListener(Event.TOUCH_MOVE, function(e) {

	    //inputタスクバインド
	    input.last_touch_x = e.x;
	    input.last_touch_y = e.y;

        });
        game.rootScene.addEventListener(Event.TOUCH_END, function(e) {
	    
        });

        game.rootScene.onenterframe = function() {
            //BGMのループ再生
	    //            game.assets["./media/bgm.mp3"].play();
        };

    }
    game.start(); // ゲームをスタートさせます




};
