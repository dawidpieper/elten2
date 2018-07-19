#ifndef ELTEN_ENGINE_VERSION
#include "main.c"
#endif
#ifndef ELTEN_FILE_WINDOW
#ifdef WIN32
LRESULT CALLBACK WndProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam) {
switch(Message) {
case WM_KEYDOWN: {
MessageBeep(0);
break;
}
case WM_DESTROY: {
PostQuitMessage(0);
break;
}
default:
return DefWindowProc(hwnd, Message, wParam, lParam);
}
return 0;
}
#endif
int ELTEN_WINDOW_InitThr() {
#ifdef WIN32
void __cdecl ThreadProc( void * Args ) {
MSG msg;
WNDCLASSEX wc;
HINSTANCE hInstance=GetModuleHandle(NULL);
HWND hwnd;
memset(&wc,0,sizeof(wc));
wc.cbSize = sizeof(WNDCLASSEX);
wc.lpfnWndProc = WndProc; /* This is where we will send messages to */
wc.hInstance = hInstance;
wc.hCursor = LoadCursor(NULL, IDC_ARROW);
wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
wc.lpszClassName = "eltenwindow";
wc.hIcon = LoadIcon(NULL, IDI_APPLICATION); wc.hIconSm = LoadIcon(NULL, IDI_APPLICATION); 
if(!RegisterClassEx(&wc)) {
MessageBox(NULL, "Window Registration Failed!","Elten Error!",MB_ICONEXCLAMATION|MB_OK);
return 0;
}
hwnd = CreateWindowEx(WS_EX_CLIENTEDGE,"eltenwindow","Elten", WS_VISIBLE|WS_CAPTION|WS_OVERLAPPED, CW_USEDEFAULT, CW_USEDEFAULT, 640, 480, NULL, NULL, hInstance, NULL);
if(hwnd == NULL) {
MessageBox(NULL, "Elten Window Creation Failed!","Error!",MB_ICONEXCLAMATION|MB_OK);
return 0;
}
while(GetMessage(&msg, NULL, 0, 0) > 0) {
TranslateMessage(&msg);
DispatchMessage(&msg);
}
_endthread();
}
#endif
return (int) _beginthread( ThreadProc, 0, NULL );
}
#endif