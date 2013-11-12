
/*


*/


#pragma once
#include "../../task2.h"
#include "time.h"

//-------------------------------------グローバルデータ定義-------------------------------

<@lisp-rough-enum>




//-------------------------------------クラス定義-------------------------------



class <@lisp-rough-title> : public TaskGM
{
public:


	<@lisp-rough-title>(GameManager2 *game_manager );
	~<@lisp-rough-title>();
	void Main(){};
	void Draw(){};

	<@lisp-rough-variable-declar>
	<@lisp-rough-method-declar>


};


GameManager2 *gm;



//-------------------------------------全体管理クラス-------------------------------

<@lisp-rough-title>::<@lisp-rough-title>(GameManager2 *game_manager)
{
	gm = game_manager;
	
//	new Title();

	<@lisp-rough-variable-initialize>

	this->game_init();
}

<@lisp-rough-title>::~<@lisp-rough-title>()
{

}

<@lisp-rough-method-define>
