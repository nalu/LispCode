
#pragma comment(lib,"winmm")
#pragma comment(lib,"User32.lib")
#pragma comment(lib,"Gdi32.lib")


#pragma once
#include<windows.h>
#include<tchar.h>
#include "../../task2.h"
#include "hilow.h"


LRESULT	CALLBACK	WndProc(HWND, UINT, WPARAM, LPARAM);

#define WINDOW_WIDTH 580
#define WINDOW_HEIGHT 320

//各タスク内でも使用する変数
HWND hWnd;
GameManager2 *game_manager;

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPreInst,
	LPSTR lpszCmdLine, int nCmdShow)
{
	MSG msg;
	WNDCLASS myProg;


	if(!hPreInst)
	{
		myProg.style=CS_HREDRAW|CS_VREDRAW;
		myProg.lpfnWndProc=WndProc;
		myProg.cbClsExtra=0;	
		myProg.cbWndExtra=0;
		myProg.hInstance=hInstance;
		myProg.hIcon=NULL;
		myProg.hCursor=LoadCursor(NULL,IDC_ARROW);
		myProg.hbrBackground=(HBRUSH)GetStockObject(WHITE_BRUSH);
		myProg.lpszMenuName=NULL;
		myProg.lpszClassName = _T("クラスネーム");
		if(!RegisterClass(&myProg))
			return FALSE;
	}

	hWnd = CreateWindow(
		myProg.lpszClassName,
		_T("hilow"),
		WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_CLIPCHILDREN,	//ウィンドウスタイル
		CW_USEDEFAULT, CW_USEDEFAULT,	//ウィンドウ座標
		WINDOW_WIDTH, WINDOW_HEIGHT,	//ウィンドウサイズ
		NULL,
		NULL,
		hInstance,
		NULL);


	//CreateWindowで設定した幅と高さの値は、タイトルバーや枠のサイズも含めたものになってしまうので
	//クライアント領域を取得し、ウィンドウサイズを設定し直す。
	RECT wRect, cRect;  // ウィンドウ全体の矩形、クライアント領域の矩形
	int ww, wh;         // ウィンドウ全体の幅、高さ
	int cw, ch;         // クライアント領域の幅、高さ

	// ウィンドウ全体の幅・高さを計算
	GetWindowRect(hWnd, &wRect);
	ww = wRect.right - wRect.left;
	wh = wRect.bottom - wRect.top;
	// クライアント領域の幅・高さを計算
	GetClientRect(hWnd, &cRect);
	cw = cRect.right - cRect.left;
	ch = cRect.bottom - cRect.top;
	// クライアント領域以外に必要なサイズを計算
	ww = ww - cw;
	wh = wh - ch;
	// ウィンドウ全体に必要なサイズを計算
	ww = WINDOW_WIDTH + ww;
	wh = WINDOW_HEIGHT + wh;
	// 計算した幅と高さをウィンドウに設定
	SetWindowPos(hWnd, HWND_TOP, 0, 0, ww, wh, SWP_NOMOVE);

	ShowWindow(hWnd,nCmdShow);
	UpdateWindow(hWnd);

	srand((UINT)time(NULL));	//乱数初期化


	//タスクリスト初期化（最初のタスクも作成しておく）
	TaskGM::InitTaskList();
	game_manager = new GameManager2(hWnd, WINDOW_WIDTH, WINDOW_HEIGHT);
	//タイマー作成
	game_manager->createTimer();
	new hilow(game_manager);

  

	while(true)
	{
		if(PeekMessage(&msg,NULL,0,0,PM_REMOVE))
		{
			if(msg.message==WM_QUIT) break;
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
		else
		{
			Task::RunTask();		// 値の更新
		}
	}
	return(msg.wParam);
}

LRESULT CALLBACK WndProc(HWND hWnd,UINT msg,WPARAM wParam,LPARAM lParam)
{

	TaskGM::WindowProcWraper( hWnd, msg, wParam, lParam );


	switch(msg)
	{
	case WM_CREATE:

		break;

	case WM_PAINT:
		break;

	//	TaskGM::DrawTask();
	//	
	//	break;
	//case WM_LBUTTONDOWN:
	//	TaskGM::setMouseCL( LOWORD(lParam), HIWORD(lParam) );
	//	break;
	case WM_DESTROY:
		Task::ReleaseTaskList();
		PostQuitMessage(0);
	break;
	default:
	return(DefWindowProc(hWnd,msg,wParam,lParam));
	}
	return(0L);
}
