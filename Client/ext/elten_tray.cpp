#include <windows.h>

#include <process.h>
HWND ewnd, hwnd;

void __cdecl ThreadProc( void * Args ) {
		int cond;
	while(TRUE) {
		Sleep(1);
cond = 0;
if(GetAsyncKeyState(0x10))
cond++;
 if(GetAsyncKeyState(0x11))
 cond++;
 if(GetAsyncKeyState(0x12))
 cond++;
  if(GetAsyncKeyState(69))
  cond++;
  if(cond == 4) {
  	  ShowWindow(ewnd,SW_SHOW);
SetForegroundWindow(ewnd);
				SetActiveWindow(ewnd);
				SetFocus(ewnd);
NOTIFYICONDATA nid;
nid.cbSize = sizeof( NOTIFYICONDATA );
nid.hWnd = hwnd;
nid.uID = 0x8001;
nid.uFlags = 0;
Shell_NotifyIcon( NIM_DELETE, & nid );
			exit(0);
}
	}
_endthread();
}
LRESULT CALLBACK WndProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam) {
	switch(Message) {
		
		case 0x8002: {
if( lParam == WM_LBUTTONDOWN ) {
				ShowWindow(ewnd,SW_SHOW);
				ShowWindow(ewnd,SW_SHOW);
								SetActiveWindow(ewnd);
				SetForegroundWindow(ewnd);
				SetFocus(ewnd);
NOTIFYICONDATA nid;
nid.cbSize = sizeof( NOTIFYICONDATA );
nid.hWnd = hwnd;
nid.uID = 0x8001;
nid.uFlags = 0;
Shell_NotifyIcon( NIM_DELETE, & nid );
			PostQuitMessage(0);				
}
			break;
		}
		case WM_DESTROY: {
			NOTIFYICONDATA nid;
nid.cbSize = sizeof( NOTIFYICONDATA );
nid.hWnd = hwnd;
nid.uID = 0x8001;
nid.uFlags = 0;
Shell_NotifyIcon( NIM_DELETE, & nid );
			PostQuitMessage(0);
			break;
		}
		
				default:
			return DefWindowProc(hwnd, Message, wParam, lParam);
	}
	return 0;
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
	ewnd = FindWindow("RGSS Player","ELTEN");
			if(ewnd == 0) {
						ewnd = FindWindow("RGSS Player",NULL);
					}
	WNDCLASSEX wc; /* A properties struct of our window */
		MSG Msg; /* A temporary location for all messages */

	/* zero out the struct and set the stuff we want to modify */
	memset(&wc,0,sizeof(wc));
	wc.cbSize		 = sizeof(WNDCLASSEX);
	wc.lpfnWndProc	 = WndProc; /* This is where we will send messages to */
	wc.hInstance	 = hInstance;
	wc.hCursor		 = LoadCursor(NULL, IDC_ARROW);
	
	/* White, COLOR_WINDOW is just a #define for a system color, try Ctrl+Clicking it */
	wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
	wc.lpszClassName = "WindowClass";
	wc.hIcon		 = LoadIcon(NULL, IDI_APPLICATION); /* Load a standard icon */
	wc.hIconSm		 = LoadIcon(NULL, IDI_APPLICATION); /* use the name "A" to use the project icon */

	if(!RegisterClassEx(&wc)) {
		MessageBox(NULL, "Window Registration Failed!","Error!",MB_ICONEXCLAMATION|MB_OK);
		return 0;
	}

	hwnd = CreateWindowEx(0,"WindowClass","ELTEN_TRAY",0,
		CW_USEDEFAULT, /* x */
		CW_USEDEFAULT, /* y */
		0, /* width */
		0, /* height */
		NULL,NULL,hInstance,NULL);

	if(hwnd == NULL) {
		MessageBox(NULL, "Window Creation Failed!","Error!",MB_ICONEXCLAMATION|MB_OK);
		return 0;
	}
	LPSTR sTip = "ELTEN";
NOTIFYICONDATA nid;
nid.cbSize = sizeof( NOTIFYICONDATA );
nid.hWnd = hwnd;
nid.uID = 0x8001;
nid.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP;
nid.uCallbackMessage = 0x8002;
nid.hIcon = LoadIcon( NULL, IDI_APPLICATION );
lstrcpy( nid.szTip, sTip );
BOOL r;
r = Shell_NotifyIcon( NIM_ADD, & nid );
if( !r ) MessageBox( hwnd, "Tray icon creation error.", "Error", MB_ICONEXCLAMATION );

	HANDLE hThread =( HANDLE ) _beginthread( ThreadProc, 0, NULL );
		
		while(GetMessage(&Msg, NULL, 0, 0) > 0) { /* If no error is received... */
		TranslateMessage(&Msg); /* Translate key codes to chars if present */
		DispatchMessage(&Msg); /* Send it to WndProc */
	}
		return Msg.wParam;
}
