enchant();
    var testmode_controller_inside = true;

    var game;
    var base_fps = 24;
    var screen_width = 320;
    if( testmode_controller_inside==true )
	var screen_height = 504; //�R���g���[���[�̈�܂ށB�܂܂Ȃ��ꍇ��379�ƂȂ�
    else
	var screen_height = 379;
    var controller_height = 125;

//color
    var color_button_default = "rgba( 100, 100, 100, 0.0 )";


//HTML�ł̓��̓T�|�[�g
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


    TaskBase = Class.create
    ({
	//������
	initialize:function( )
	{
	    this.dead_task = false;
	    this.self = this;
	},

	//�X�V
	main:function()
	{
	},

	//�`��
	draw:function()
	{
	},
	
	//�f�X�g���N�^�p���e�X�g��
	destruct:function()
	{
	    this.task_dead = true;
	},
	
    });

	var makeLabel = function( x, y, w, h, title, color, font)
	{
		label = new Label(title);
		if( color!=null )
			label.color = "#ffffff";
		if( font!=null)
			label.font = "20px Palatino";
	    label.x = x;
	    label.y = y;
		label.width = w;
		label.height = h;
		return label;
	};

	var makeSquare = function( x, y, w, h, color)
	{
	    var square = new Square(w,h,color);
	    square.x = x;
	    square.y = y;
		return square;
	};

    var makeLine = function( sx, sy, ex, ey, color )
	{
		var line = new Line(sx, sy, ex, ey, color );
		return line;
	};

    //�^�X�N�z��
    var taskArray = [];
    // var enemy_array = [];
    var removeAllTask = function()
    { 
	//��납����Ȃ��Ƃ܂΂�ɏ�����̂Œ���
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
	//���ʂɊ���Z����Ə�������������̂�truncate����ʂɎ���
	this.truncate = function( a, b )
	{
	    return Math.floor( a / b );
	}
	this.truncate = function( a )
	{
	    return Math.floor( a / 1 );
	}
	//�z��̒����烉���_���őI��
	this.random_get = function(array)
	{
	    var no = util.rand( array.length );
	    return array[ no ];
	}
	this.rand = function(num)
	{
	    return Math.floor(Math.random()*num);
	}
	//�z��̒�����v�f�̈�v������̂��폜
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
	//�z��̒�����w��̃I�u�W�F�N�g��T��
	//���������ꍇ�̓I�u�W�F�N�g��Ԃ�
	//������Ȃ������ꍇ��null��Ԃ�
	this.find = function( obj, array )
	{
	   var r_obj = array.indexOf(obj);
	   if( r_obj==-1 )
	       return null;
	    return obj;
	}
	//find�̏����t
	//������Ȃ��ꍇ��null��Ԃ�
	this.find_if = function( test, array )
	{
	    for( var i=array.length-1; i>=0 ; i-- )
	    {
			if( test( array[i] )==true )
				return array[i];
	    }
	    return null;
	}
    };
    util = new Util();

    //��`�N���X
    Square = Class.create
    ( Sprite,{
	//������
	// 		initialize:function( w,h )
	// 		{
	// 			this.initialize(w,h,100,100,100,1.0)
	// 		},
	
	initialize:function( w,h, color)
	{
 	    Sprite.call(this,w,h); //�X�[�p�[�N���X�̃R���X�g���N�^�Ăяo��
	    this.surf = new Surface(w,h);
	    this.surf.context.beginPath();
	    this.surf.context.fillStyle = color;
	    this.surf.context.fillRect( 0,0, w,h);
	    this.image = this.surf;
	},
    });

//�����N���X
//color�͋@�\���Ȃ������s��
    Line = Class.create
    ( Sprite,{
		initialize:function( sx, sy, ex,ey, color)
		{
			
			this.w = Math.abs(sx-ex);
			this.h = Math.abs(sy-ey);
			this.color = color;
			var x1,x2,y1,y2;
			
			Sprite.call(this,this.w+1,this.h+1);//�T�C�Y���O�̏ꍇ���`�悷��
			this.surf = new Surface(this.w+1,this.h+1);
			
			this.setPosition( sx, sy ,ex, ey );
			
			
		},
		
		setPosition:function( sx, sy, ex, ey )
		{

			if( this.surf!=null )
				this.surf.context.clearRect(0,0,this.w+2,this.h+2);

			this.w = Math.abs(sx-ex);
			this.h = Math.abs(sy-ey);

			
			var ctx = this.surf.context;
			
			console.log(this.w+","+this.h);
  			ctx.clearRect(0,0,this.w+2,this.h+2);
			ctx.beginPath();
			ctx.moveTo(0,0);
			ctx.lineTo(this.w,this.h);
			ctx.strokeStyle = this.color;
			ctx.closePath();
			ctx.stroke();
			
			this.image = this.surf;
			
			this.x = sx;
			this.y = sy;
			if( this.x > ex ) this.x = ex;
			if( this.y > ey ) this.y = ey;
		},
		
    });

//     TaskBase = Class.create
//     ({
// 	//������
// 	initialize:function( )
// 	{
// 	    this.dead_task = false;
// 	    this.self = this;
// 	},

// 	//�X�V
// 	main:function()
// 	{
// 	},

// 	//�`��
// 	draw:function()
// 	{
// 	},
	
// 	//�f�X�g���N�^�p���e�X�g��
// 	destruct:function()
// 	{
// 	    this.task_dead = true;
// 	},
	
//     });

    Debug = Class.create
    ( TaskBase,{

	//������
	initialize:function( x,y)
	{
 	    TaskBase.call(this,x,y);
	    
	    //�e�o�r�\��
	    this.fps_label = new Label(" ");
	    this.fps_label.color = "#ffffff";
	    this.fps_label.font = "bold";
	    this.fps_label.x = x;
	    this.fps_label.y = 5;

	    this.fps=0;
	    this.bs=0;
	    this.count=0;
	    game.rootScene.addChild(this.fps_label);

	    //�^�X�N���\��
	    this.task_num_label = new Label(" ");
	    this.task_num_label.color = "#ffffff";
	    this.task_num_label.x = x;
	    this.task_num_label.y = 20;
 	    this.task_num_label.text = "task:";
 	    game.rootScene.addChild(this.task_num_label);
	},
	
	//�X�V
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

	//�`��
	draw:function()
	{
	},

	//�p���f�X�g���N�g�e�X�g
	destruct:function()
	{
	    // 			TaskBase.destruct(this);
	    alert("child");
	},
	self:0,
	
    });

    

//     Button = Class.create
//     ( TaskBase,{

// 	//������
// 	initialize:function( x,y,w,h,title,key,call, bg_color)
// 	{
//  	    TaskBase.call(this,x,y,w,h,title,key,call); //�X�[�p�[�N���X�̃R���X�g���N�^�Ăяo��

// 	    //���x���̍������w�肵�Ă��A�c�̒����ɔz�u���鎖���ł��Ȃ����߁A�w�i��p��Square�I�u�W�F�N�g������B
// 	    var square = new Square(w,h,bg_color);
// 	    square.x = x;
// 	    square.y = y;

// 	    //���x��������
// 	    var label = new Label();
// 	    label.x=x;
// 	    label.width = w;
// 	    this.call = call;
//  	    label.text = title;

// 	    //���x���̍������擾���ďc�����ɔz�u
// 	    //���x���̌����ڂ̎��ۂ̍�����_boundHeight/3�Ŏ���B�Ȃ��R�{�傫���Ȃ��Ă�̂��s���B
// 	    //�܂��A_boundHeight�̒l��label.text���Z�b�g������Ɍ��܂�̂ŁA�擾�^�C�~���O�ɒ��ӁB
// 	    var label_display_height = label._boundHeight/3;
//  	    label.y= y+ (h/2) - (label_display_height/2);
// 	    label.textAlign = "center";
// 	    label.touchEnabled = false; //�w�i�̃^�b�`��j�Q����̂Ń��x���̃^�b�`�͖����ɂ���B

// 	    //   			label.backgroundColor = 'orange';
// 	    // 			label.font = '2em"Ariar"';


// 	    this.square = square;
// 	    this.label = label;


// 	    //�R�[���o�b�N�̈����͖ʓ|�Bthis�ŃI�u�W�F�N�g�����܂��Ǘ��ł��Ȃ��̂ł�������
// 	    //���X�i�[�͔w�i��Square�ɃZ�b�g����B���x������ɏ���Ă��邪�^�b�`�C�x���g�𖳌��ɂ��Ă���̂Ŗ��Ȃ��B
// 	    //�R�[���o�b�N�֐��̖{�̂̒��ł� this ���g���Ȃ��̂Œ���
// 	    // 			var action = function(evt,call){ call();};
// 	    //   			square.addEventListener("touchstart",function(evt){ action(evt,call) },true);


// 	    this.setCallbackTouchStart(call);
	    

//  	    game.rootScene.addChild(this.square);
// 	    game.rootScene.addChild(label);
// 	},





// 	setCallbackTouchEnd:function( call )
// 	{
// 	    var action = function(evt,call){ call();};
//    	    this.self.square.addEventListener("touchend",function(evt){ action(evt,call) },true);
// 	},
// 	setCallbackTouchStart:function( call )
// 	{
// 	    var action = function(evt,call){ call();};
//    	    this.self.square.addEventListener("touchstart",function(evt){ action(evt,call) },true);
// 	},
	
// 	setVisible:function( visible )
// 	{
// 	    this.square.visible = visible;
// 	    this.label.visible =  visible;
// 	    this.square.touchEnabled = visible;
// 	},
// 	test:function( target )
// 	{
// 	},
	

//     });


    // �o�[�`�����{�^�����쐬����N���X.
    var VButton = enchant.Class.create( enchant.Sprite, {
	// �R���X�g���N�^.
	initialize: function( x, y, mode ) {
            // �p�������R�[��.
            enchant.Sprite.call( this, 50, 50 );
            // �o�[�`�����{�^���摜��ݒ�.
            this.image = core.assets[ './img/button.png' ];
            this.x = x;                // X���W.
            this.y = y;                // Y���W.
            this.buttonMode = mode;    // �{�^�����[�h.
	}
    });

    //�R���g���[���[
    Controller = Class.create
    ( TaskBase,{
	//������
		initialize:function( game,x,y,w,h  )
	{
 	    TaskBase.call(this); //�X�[�p�[�N���X�̃R���X�g���N�^�Ăяo��
	    this.x = x;
	    this.y = y;
	    this.w = w;
	    this.h = h;

// 	    this.sprite = new Sprite( w, h );  //�X�v���C�g�����A�T�C�Y�w��
// 	    this.sprite.image = game.assets['./img/controller.png']; //�摜�̃Z�b�g
// 	    this.sprite.x = this.x;
// 	    this.sprite.y = this.y;
//  	    game.rootScene.addChild(this.sprite);

	    

	    //Pad
            var pad = new Pad();
            pad.x = x+14;
            pad.y = y+11;
            game.rootScene.addChild(pad);

	    //Button
	    // var a_button = new Button( 200,0, 100, 100,"A",0, this.pushA, title_bg_color);
	    // game.rootScene.addChild(a_button);


		    
   	    this.b_button = new Button( this.x+(this.w/4*2), this.y, this.w/4, h, "" ,0, this.pushB, 'rgba( 50, 150, 50, 1.0)');
   	    this.a_button = new Button( this.x+(this.w/4*3), this.y, this.w/4, h, "" , 'Z', this.pushA, 'rgba( 50, 150, 50, 1.0)');
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

	//�X�V
	main:function()
	{
	},

	//�`��
	draw:function()
	{
	},
	pushLeft:function()
	{
	    // 			this.push_left = true; //�R�[���o�b�N�̒���this�͎g���Ȃ�
	    controller.push_left = true;
	},
	pushRight:function()
	{
	    // 			this.push_right = true; //�R�[���o�b�N�̒���this�͎g���Ȃ�
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


var makeController = function(x,y,w,h)
{
	return new Controller(x,y,w,h);
}




    //�X�R�A
    Score = Class.create
    ( TaskBase,{
	//������
	initialize:function(x,y)
	{
	    TaskBase.call(this); //�X�[�p�[�N���X�̃R���X�g���N�^�Ăяo��
	    this.score=0;
	    this.label = new Label(" ");
	    this.label.color = "#ffffff";
	    this.label.font = "20px Palatino";
	    this.label.x = x;	// X���W
	    this.label.y = y;	// Y���W
	    game.rootScene.addChild(this.label);
	    this.updateScore();
	},

	//�X�V
	main:function()
	{

	},

	//�`��
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
