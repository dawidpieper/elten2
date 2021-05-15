 /*
A part of Elten - EltenLink / Elten Network desktop client.
Copyright (C) 2014-2021 Dawid Pieper
Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 
*/

#include <windows.h>
#include <process.h>
#include <chrono>
#include <thread>
#include <queue>
#include "dllhkbase.h"

typedef struct HKInitializer {
HKEntry *entries;
int size;
} HKInitializer;

HWND hkWnd;
int hkErrors;
BOOL hkInit=false;
std::priority_queue<WPARAM> hkQueue;
std::priority_queue<int> hkIds;

LRESULT CALLBACK HKWndProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam) {
switch(Message) {
case WM_HOTKEY:
if(wParam>0) hkQueue.push(wParam);
break;
case WM_CLOSE:
while(!hkIds.empty()) {
UnregisterHotKey(hkWnd, hkIds.top());
hkIds.pop();
}
DestroyWindow(hwnd);
break;
case WM_DESTROY:
PostQuitMessage(0);
break;
default:
return DefWindowProc(hwnd, Message, wParam, lParam);
}
return 0;
}

void __cdecl HKThreadWindowProc(void *Args) {
HKInitializer *initializer = (HKInitializer*)Args;
if(hkInit==false) {
hkInit=true;
WNDCLASSEX wc;
memset(&wc,0,sizeof(wc));
wc.cbSize		 = sizeof(WNDCLASSEX);
wc.lpfnWndProc	 = HKWndProc;
wc.hInstance	 = GetModuleHandle(NULL);
wc.hCursor		 = LoadCursor(NULL, IDC_ARROW);
wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
wc.lpszClassName = L"EltenHK";
wc.hIcon		 = LoadIcon(NULL, IDI_APPLICATION);
wc.hIconSm		 = LoadIcon(NULL, IDI_APPLICATION);
if(!RegisterClassEx(&wc)) return;
}
hkWnd = CreateWindowEx(0, L"EltenHK", L"EltenHK", 0 , CW_USEDEFAULT, CW_USEDEFAULT, 0, 0, NULL, NULL, GetModuleHandle(NULL), NULL);
if(hkWnd==NULL) return;
for(int i=0; i<initializer->size; ++i) {
if(RegisterHotKey(hkWnd, initializer->entries[i].id, initializer->entries[i].modifiers, initializer->entries[i].vk) == 0) ++hkErrors;
hkIds.push(initializer->entries[i].id);
}
MSG Msg;
while(GetMessage(&Msg, hkWnd, 0, 0)) {
TranslateMessage(&Msg);
DispatchMessage(&Msg);
if(hkWnd==0) break;
}
}

int initHK(HKEntry *entries, int size) {
if(hkWnd!=0) destroyHK();
HKInitializer initializer;
initializer.entries=entries;
initializer.size=size;
HANDLE hThread =(HANDLE) _beginthread(HKThreadWindowProc, 0, &initializer);
int i=0;
hkErrors=0;
while(hkWnd==0) {
std::this_thread::sleep_for(std::chrono::milliseconds(100));
++i;
if(i>20) break;
}
return hkErrors;
}

void destroyHK() {
PostMessage(hkWnd, WM_CLOSE, 0, 0);
hkWnd=0;
}

WPARAM getHK() {
if(hkQueue.empty()) return 0;
WPARAM r=hkQueue.top();
hkQueue.pop();
return r;
}