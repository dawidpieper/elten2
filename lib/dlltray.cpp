 /*
A part of Elten - EltenLink / Elten Network desktop client.
Copyright (C) 2014-2021 Dawid Pieper
Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 
*/

#include <windows.h>
#include <shlobj.h>
#include <process.h>
#include "dlltray.h"

HWND ewnd=0, hwnd;
int autostart=0;

void showElten(void) {
if((autostart==0) && (ewnd!=0)) {
ShowWindow(ewnd,5);
SetForegroundWindow(ewnd);
SetActiveWindow(ewnd);
SetFocus(ewnd);
ShowWindow(ewnd,3);
} else {
wchar_t szFile[MAX_PATH];
GetModuleFileName(GetModuleHandle(NULL), szFile, MAX_PATH);
int siz=0;
for(int i=0; i<MAX_PATH; ++i) {
if(szFile[i]=='\\') siz=i;
else if(szFile[i]==0) break;
}
wchar_t *eltenexe = (wchar_t*)malloc(sizeof(wchar_t)*(siz+9+13+1+2));
if(eltenexe) {
#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable : 4996)
#endif
eltenexe[0]='"';
wcsncpy(eltenexe+1, szFile, siz+1);
eltenexe[siz+2]=0;
wcscat(eltenexe, L"elten.exe\" /silentstart");
szFile[siz]=0;
#ifdef _MSC_VER
#pragma warning(pop)
#endif
STARTUPINFO si;
    PROCESS_INFORMATION pi;
    ZeroMemory( &si, sizeof(si) );
    si.cb = sizeof(si);
    ZeroMemory( &pi, sizeof(pi) );
if( !CreateProcess( NULL, eltenexe, NULL, NULL, FALSE, 0, NULL, szFile, &si, &pi)) MessageBeep(0);
free(eltenexe);
}
else if(autostart==1) hideTray();
}
}

LRESULT CALLBACK TrayWndProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam) {
switch(Message) {
case WM_HOTKEY:
if(wParam == 0x8003)
showElten();
case 0x8002:
if( lParam == WM_LBUTTONDOWN )
showElten();
break;
case WM_DESTROY:
hideTray();
break;
default:
return DefWindowProc(hwnd, Message, wParam, lParam);
}
return 0;
}

void TrayProcessor() {
MSG Msg;
if(GetMessage(&Msg, NULL, 0, 0) > 0) {
TranslateMessage(&Msg);
DispatchMessage(&Msg);
}
}

void __cdecl ThreadWindowProc(void *Args) {
WNDCLASSEX wc;
memset(&wc,0,sizeof(wc));
wc.cbSize		 = sizeof(WNDCLASSEX);
wc.lpfnWndProc	 = TrayWndProc;
wc.hInstance	 = GetModuleHandle(NULL);
wc.hCursor		 = LoadCursor(NULL, IDC_ARROW);
wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
wc.lpszClassName = L"EltenTray";
wc.hIcon		 = LoadIcon(NULL, IDI_APPLICATION);
wc.hIconSm		 = LoadIcon(NULL, IDI_APPLICATION);
if(!RegisterClassEx(&wc)) return;
hwnd = CreateWindowEx(0, L"EltenTray", L"EltenTray", 0 , CW_USEDEFAULT, CW_USEDEFAULT, 0, 0, NULL, NULL, GetModuleHandle(NULL), NULL);
if(hwnd==NULL) return;
NOTIFYICONDATA nid;
nid.cbSize = sizeof( NOTIFYICONDATA );
nid.hWnd = hwnd;
nid.uID = 0x8001;
nid.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP;
nid.uCallbackMessage = 0x8002;
nid.hIcon = LoadIcon( NULL, IDI_APPLICATION );
#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable : 4996)
#endif
wcscpy(nid.szTip, L"ELTEN");
#ifdef _MSC_VER
#pragma warning(pop)
#endif
BOOL r = Shell_NotifyIcon( NIM_ADD, & nid );
if(!r) return;
RegisterHotKey(hwnd, 0x8003, MOD_ALT|MOD_CONTROL|MOD_SHIFT, 'T');
MSG Msg;
while(GetMessage(&Msg, hwnd, 0, 0)) {
TranslateMessage(&Msg);
DispatchMessage(&Msg);
if(hwnd==0) break;
}
}

int showTray(HWND window) {
if(hwnd!=0) return -1;
ewnd = window;
if(window==0) autostart=1;
HANDLE hThread =(HANDLE) _beginthread(ThreadWindowProc, 0, 0);
return 0;
}

void hideTray() {
NOTIFYICONDATA nid;
nid.cbSize = sizeof( NOTIFYICONDATA );
nid.hWnd = hwnd;
nid.uID = 0x8001;
nid.uFlags = 0;
Shell_NotifyIcon( NIM_DELETE, & nid );
UnregisterHotKey(hwnd, 0x8003);
DestroyWindow(hwnd);
hwnd=0;
}