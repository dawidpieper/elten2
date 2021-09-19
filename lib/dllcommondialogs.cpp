 /*
A part of Elten - EltenLink / Elten Network desktop client.
Copyright (C) 2014-2021 Dawid Pieper
Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 
*/

#include <windows.h>
#include <process.h>
#include <commctrl.h>
#include "dllcommondialogs.h"

typedef struct MessagerState {
BOOL registered=FALSE;
HWND focus=NULL;
HANDLE hThread;
HWND hwnd, hRecipientLabel, hRecipientField, hSubjectLabel, hSubjectField, hTextLabel, hTextField, hSendButton, hCancelButton;
wchar_t *label, *recipientFieldLabel, *subjectFieldLabel, *textFieldLabel, *sendButtonLabel, *cancelButtonLabel;
BOOL shown, accepted;
wchar_t *recipientFieldValue, *subjectFieldValue, *textFieldValue;
} MessagerState;

MessagerState messagerWND;

LRESULT CALLBACK MessagerWndProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam) {
switch(Message) {
case WM_SETFOCUS:
SetFocus(messagerWND.focus);
break;
case WM_COMMAND:
if((HWND)lParam == messagerWND.hCancelButton) {
hideMessager();
}
else if((HWND)lParam == messagerWND.hSendButton) {
if(GetWindowTextLength(messagerWND.hRecipientField)>0 && GetWindowTextLength(messagerWND.hTextField)>0)
messagerWND.accepted=true;
}
break;
case WM_KEYDOWN:
if(wParam==VK_ESCAPE) {
SendMessage(messagerWND.hwnd, WM_COMMAND, MAKEWPARAM(0, BN_CLICKED), (LPARAM)messagerWND.hCancelButton);
}
break;
case WM_DESTROY:
hideMessager();
break;
default:
return DefWindowProc(hwnd, Message, wParam, lParam);
}
return 0;
}

LRESULT CALLBACK MessagerEditSubclassProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam, UINT_PTR uIdSubclass, DWORD_PTR dwRefData) {
switch (uMsg) {
case WM_GETDLGCODE:
return DLGC_WANTCHARS|DLGC_HASSETSEL|DLGC_WANTALLKEYS|DLGC_WANTARROWS;
break;
case WM_NCDESTROY:
RemoveWindowSubclass(hWnd, MessagerEditSubclassProc, uIdSubclass);
break;
case WM_SETFOCUS:
messagerWND.focus = hWnd;
break;
case WM_KEYDOWN:
if(wParam==VK_ESCAPE) {
SendMessage(messagerWND.hwnd, WM_COMMAND, MAKEWPARAM(0, BN_CLICKED), (LPARAM)messagerWND.hCancelButton);
return 0;
}
break;
case WM_CHAR:
if(wParam==VK_TAB) {
HWND nextctl = GetNextDlgTabItem(messagerWND.hwnd, hWnd, GetKeyState(VK_SHIFT)&0x8000);
SetFocus(nextctl);
return 0;
}
if(wParam==VK_RETURN) {
if(!(GetKeyState(VK_SHIFT)&0x8000)) {
SendMessage(messagerWND.hwnd, WM_COMMAND, MAKEWPARAM(0, BN_CLICKED), (LPARAM)messagerWND.hSendButton);
return 0;
}
}
break;
}
return DefSubclassProc(hWnd, uMsg, wParam, lParam);
}

void __cdecl MessagerThreadWindowProc(void *Args) {
if(!messagerWND.registered) {
WNDCLASSEX wc;
memset(&wc,0,sizeof(wc));
wc.cbSize		 = sizeof(WNDCLASSEX);
wc.lpfnWndProc	 = MessagerWndProc;
wc.hInstance	 = GetModuleHandle(NULL);
wc.hCursor		 = LoadCursor(NULL, IDC_ARROW);
wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
wc.lpszClassName = L"EltenMessager";
wc.hIcon		 = LoadIcon(NULL, IDI_APPLICATION);
wc.hIconSm		 = LoadIcon(NULL, IDI_APPLICATION);
if(!RegisterClassEx(&wc)) return;
} messagerWND.registered=TRUE;
messagerWND.hwnd = CreateWindowEx(WS_EX_DLGMODALFRAME, L"EltenMessager", messagerWND.label, WS_VISIBLE|WS_OVERLAPPED|WS_CAPTION, CW_USEDEFAULT, CW_USEDEFAULT, 640, 480, NULL, NULL, GetModuleHandle(NULL), NULL);
if(messagerWND.hwnd==NULL) return;
messagerWND.hRecipientLabel = CreateWindowEx(0, L"STATIC", messagerWND.recipientFieldLabel, WS_CHILD|WS_VISIBLE|SS_LEFT, 20, 20, 200, 100, messagerWND.hwnd, NULL, GetModuleHandle(NULL), NULL);
messagerWND.hRecipientField = CreateWindowEx(0, L"EDIT", messagerWND.recipientFieldValue, WS_CHILD|WS_VISIBLE|WS_TABSTOP|ES_LEFT, 220, 20, 400, 100, messagerWND.hwnd, NULL, GetModuleHandle(NULL), NULL);
messagerWND.hSubjectLabel = CreateWindowEx(0, L"STATIC", messagerWND.subjectFieldLabel, WS_CHILD|WS_VISIBLE|SS_LEFT, 20, 140, 200, 100, messagerWND.hwnd, NULL, GetModuleHandle(NULL), NULL);
messagerWND.hSubjectField = CreateWindowEx(0, L"EDIT", messagerWND.subjectFieldValue, WS_CHILD|WS_VISIBLE|WS_TABSTOP|ES_LEFT, 220, 140, 400, 100, messagerWND.hwnd, NULL, GetModuleHandle(NULL), NULL);
messagerWND.hTextLabel = CreateWindowEx(0, L"STATIC", messagerWND.textFieldLabel, WS_CHILD|WS_VISIBLE|SS_LEFT, 20, 160, 200, 230, messagerWND.hwnd, NULL, GetModuleHandle(NULL), NULL);
messagerWND.hTextField = CreateWindowEx(0, L"EDIT", messagerWND.textFieldValue, WS_CHILD|WS_VISIBLE|WS_TABSTOP|ES_LEFT|ES_MULTILINE|ES_AUTOVSCROLL|WS_VSCROLL, 220, 140, 400, 230, messagerWND.hwnd, NULL, GetModuleHandle(NULL), NULL);
messagerWND.hSendButton = CreateWindowEx(0, L"BUTTON", messagerWND.sendButtonLabel, WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_DEFPUSHBUTTON, 20, 410, 300, 50, messagerWND.hwnd, NULL, GetModuleHandle(NULL), NULL);
messagerWND.hCancelButton = CreateWindowEx(0, L"BUTTON", messagerWND.cancelButtonLabel, WS_CHILD|WS_VISIBLE|WS_TABSTOP, 320, 410, 300, 50, messagerWND.hwnd, NULL, GetModuleHandle(NULL), NULL);
SetWindowSubclass(messagerWND.hRecipientField, MessagerEditSubclassProc, 0, 0);
SetWindowSubclass(messagerWND.hSubjectField, MessagerEditSubclassProc, 0, 0);
SetWindowSubclass(messagerWND.hTextField, MessagerEditSubclassProc, 0, 0);
ShowWindow(messagerWND.hwnd, SW_MAXIMIZE);
HWND hCurWnd = ::GetForegroundWindow();
DWORD dwMyID = ::GetCurrentThreadId();
DWORD dwCurID = ::GetWindowThreadProcessId(hCurWnd, NULL);
AttachThreadInput(dwCurID, dwMyID, TRUE);
SetWindowPos(messagerWND.hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
SetWindowPos(messagerWND.hwnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW | SWP_NOSIZE | SWP_NOMOVE);
SetForegroundWindow(messagerWND.hwnd);
::SetFocus(messagerWND.hwnd);
SetActiveWindow(messagerWND.hwnd);
AttachThreadInput(dwCurID, dwMyID, FALSE);
if(messagerWND.recipientFieldValue!=NULL)
messagerWND.focus=messagerWND.hTextField;
else
messagerWND.focus=messagerWND.hRecipientField;
SendMessage(messagerWND.hwnd, WM_SETFOCUS, NULL, NULL);
MSG Msg;
while(GetMessage(&Msg, messagerWND.hwnd, 0, 0)) {
if(!IsDialogMessage(messagerWND.hwnd, &Msg)) {
TranslateMessage(&Msg);
DispatchMessage(&Msg);
}
}
}

int showMessager(wchar_t *label, wchar_t *recipientFieldLabel, wchar_t *subjectFieldLabel, wchar_t *textFieldLabel, wchar_t *sendButtonLabel, wchar_t *cancelButtonLabel, wchar_t *recipientFieldValue, wchar_t *subjectFieldValue, wchar_t *textFieldValue) {
hideMessager();
messagerWND.label = (wchar_t*)malloc(sizeof(wchar_t)*(wcslen(label)+1));
wcscpy(messagerWND.label, label);
messagerWND.recipientFieldLabel = (wchar_t*)malloc(sizeof(wchar_t)*(wcslen(recipientFieldLabel)+1));
wcscpy(messagerWND.recipientFieldLabel, recipientFieldLabel);
messagerWND.subjectFieldLabel = (wchar_t*)malloc(sizeof(wchar_t)*(wcslen(subjectFieldLabel)+1));
wcscpy(messagerWND.subjectFieldLabel, subjectFieldLabel);
messagerWND.textFieldLabel = (wchar_t*)malloc(sizeof(wchar_t)*(wcslen(textFieldLabel)+1));
wcscpy(messagerWND.textFieldLabel, textFieldLabel);
messagerWND.sendButtonLabel = (wchar_t*)malloc(sizeof(wchar_t)*(wcslen(sendButtonLabel)+1));
wcscpy(messagerWND.sendButtonLabel, sendButtonLabel);
messagerWND.cancelButtonLabel = (wchar_t*)malloc(sizeof(wchar_t)*(wcslen(cancelButtonLabel)+1));
wcscpy(messagerWND.cancelButtonLabel, cancelButtonLabel);
messagerWND.recipientFieldValue = messagerWND.subjectFieldValue = messagerWND.textFieldValue = NULL;
if(recipientFieldValue!=NULL) {
messagerWND.recipientFieldValue = (wchar_t*)malloc(sizeof(wchar_t)*(wcslen(recipientFieldValue)+1));
wcscpy(messagerWND.recipientFieldValue, recipientFieldValue);
}
if(subjectFieldValue!=NULL) {
messagerWND.subjectFieldValue = (wchar_t*)malloc(sizeof(wchar_t)*(wcslen(subjectFieldValue)+1));
wcscpy(messagerWND.subjectFieldValue, subjectFieldValue);
}
if(textFieldValue!=NULL) {
messagerWND.textFieldValue = (wchar_t*)malloc(sizeof(wchar_t)*(wcslen(textFieldValue)+1));
wcscpy(messagerWND.textFieldValue, textFieldValue);
}
messagerWND.shown=TRUE;
messagerWND.hThread =(HANDLE) _beginthread(MessagerThreadWindowProc, 0, 0);
return 0;
}

void hideMessager() {
if(messagerWND.hThread!=NULL) {
messagerWND.shown = messagerWND.accepted = FALSE;
DestroyWindow(messagerWND.hwnd);
if(messagerWND.label!=NULL) free(messagerWND.label);
if(messagerWND.recipientFieldLabel!=NULL) free(messagerWND.recipientFieldLabel);
if(messagerWND.subjectFieldLabel!=NULL) free(messagerWND.subjectFieldLabel);
if(messagerWND.textFieldLabel!=NULL) free(messagerWND.textFieldLabel);
if(messagerWND.sendButtonLabel!=NULL) free(messagerWND.sendButtonLabel);
if(messagerWND.cancelButtonLabel!=NULL) free(messagerWND.cancelButtonLabel);
if(messagerWND.recipientFieldValue!=NULL) free(messagerWND.recipientFieldValue);
if(messagerWND.subjectFieldValue!=NULL) free(messagerWND.subjectFieldValue);
if(messagerWND.textFieldValue!=NULL) free(messagerWND.textFieldValue);
messagerWND.label = messagerWND.recipientFieldLabel = messagerWND.subjectFieldLabel = messagerWND.textFieldLabel = messagerWND.sendButtonLabel = messagerWND.cancelButtonLabel = messagerWND.recipientFieldValue = messagerWND.subjectFieldValue = messagerWND.textFieldValue = NULL;
messagerWND.hwnd=0;
HANDLE hThread = messagerWND.hThread;
messagerWND.hThread=NULL;
TerminateThread(hThread, 0);
}
}

int getMessager(wchar_t *recipientValue, int recipientValueSize, wchar_t *subjectValue, int subjectValueSize, wchar_t *textValue, int textValueSize) {
if(messagerWND.shown==FALSE) return 0;
GetWindowText(messagerWND.hRecipientField, recipientValue, recipientValueSize);
GetWindowText(messagerWND.hSubjectField, subjectValue, subjectValueSize);
GetWindowText(messagerWND.hTextField, textValue, textValueSize);
if(messagerWND.accepted) return 1;
else return 2;
}


typedef struct WriterState {
BOOL registered=FALSE;
HWND focus=NULL;
HANDLE hThread;
HWND hwnd, hTextLabel, hTextField, hSendButton, hCancelButton;
wchar_t *label, *textFieldLabel, *sendButtonLabel, *cancelButtonLabel;
BOOL shown, accepted;
wchar_t *textFieldValue;
int textFieldSize;
} WriterState;

WriterState writerWND;

LRESULT CALLBACK WriterWndProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam) {
switch(Message) {
case WM_SETFOCUS:
SetFocus(writerWND.focus);
break;
case WM_COMMAND:
if((HWND)lParam == writerWND.hCancelButton) {
hideWriter();
}
else if((HWND)lParam == writerWND.hSendButton) {
if(GetWindowTextLength(writerWND.hTextField)>0)
writerWND.accepted=true;
}
break;
case WM_KEYDOWN:
if(wParam==VK_ESCAPE) {
SendMessage(writerWND.hwnd, WM_COMMAND, MAKEWPARAM(0, BN_CLICKED), (LPARAM)writerWND.hCancelButton);
}
break;
case WM_DESTROY:
hideWriter();
break;
default:
return DefWindowProc(hwnd, Message, wParam, lParam);
}
return 0;
}

LRESULT CALLBACK WriterEditSubclassProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam, UINT_PTR uIdSubclass, DWORD_PTR dwRefData) {
switch (uMsg) {
case WM_GETDLGCODE:
return DLGC_WANTCHARS|DLGC_HASSETSEL|DLGC_WANTALLKEYS|DLGC_WANTARROWS;
break;
case WM_NCDESTROY:
RemoveWindowSubclass(hWnd, WriterEditSubclassProc, uIdSubclass);
break;
case WM_SETFOCUS:
writerWND.focus = hWnd;
break;
case WM_KEYDOWN:
if(wParam==VK_ESCAPE) {
SendMessage(writerWND.hwnd, WM_COMMAND, MAKEWPARAM(0, BN_CLICKED), (LPARAM)writerWND.hCancelButton);
return 0;
}
break;
case WM_CHAR:
if(wParam==VK_TAB) {
HWND nextctl = GetNextDlgTabItem(writerWND.hwnd, hWnd, GetKeyState(VK_SHIFT)&0x8000);
SetFocus(nextctl);
return 0;
}
if(wParam==VK_RETURN) {
if(!(GetKeyState(VK_SHIFT)&0x8000)) {
SendMessage(writerWND.hwnd, WM_COMMAND, MAKEWPARAM(0, BN_CLICKED), (LPARAM)writerWND.hSendButton);
return 0;
}
}
break;
}
return DefSubclassProc(hWnd, uMsg, wParam, lParam);
}

void __cdecl WriterThreadWindowProc(void *Args) {
if(!writerWND.registered) {
WNDCLASSEX wc;
memset(&wc,0,sizeof(wc));
wc.cbSize		 = sizeof(WNDCLASSEX);
wc.lpfnWndProc	 = WriterWndProc;
wc.hInstance	 = GetModuleHandle(NULL);
wc.hCursor		 = LoadCursor(NULL, IDC_ARROW);
wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
wc.lpszClassName = L"EltenWriter";
wc.hIcon		 = LoadIcon(NULL, IDI_APPLICATION);
wc.hIconSm		 = LoadIcon(NULL, IDI_APPLICATION);
if(!RegisterClassEx(&wc)) return;
} writerWND.registered=TRUE;
writerWND.hwnd = CreateWindowEx(WS_EX_DLGMODALFRAME, L"EltenWriter", writerWND.label, WS_VISIBLE|WS_OVERLAPPED|WS_CAPTION, CW_USEDEFAULT, CW_USEDEFAULT, 640, 480, NULL, NULL, GetModuleHandle(NULL), NULL);
if(writerWND.hwnd==NULL) return;
writerWND.hTextLabel = CreateWindowEx(0, L"STATIC", writerWND.textFieldLabel, WS_CHILD|WS_VISIBLE|SS_LEFT, 20, 20, 200, 350, writerWND.hwnd, NULL, GetModuleHandle(NULL), NULL);
writerWND.hTextField = CreateWindowEx(0, L"EDIT", writerWND.textFieldValue, WS_CHILD|WS_VISIBLE|WS_TABSTOP|ES_LEFT|ES_MULTILINE|ES_AUTOVSCROLL|WS_VSCROLL, 220, 0, 400, 350, writerWND.hwnd, NULL, GetModuleHandle(NULL), NULL);
if(writerWND.textFieldValue!=NULL) {
SendMessage (writerWND.hTextField, EM_SETSEL, -1, -1);
SendMessage (writerWND.hTextField, EM_SETSEL, wcslen(writerWND.textFieldValue), -1);
}
if(writerWND.textFieldSize>0) SendMessage (writerWND.hTextField, EM_SETLIMITTEXT, writerWND.textFieldSize, 0);
writerWND.hSendButton = CreateWindowEx(0, L"BUTTON", writerWND.sendButtonLabel, WS_CHILD|WS_VISIBLE|WS_TABSTOP|BS_DEFPUSHBUTTON, 20, 410, 300, 50, writerWND.hwnd, NULL, GetModuleHandle(NULL), NULL);
writerWND.hCancelButton = CreateWindowEx(0, L"BUTTON", writerWND.cancelButtonLabel, WS_CHILD|WS_VISIBLE|WS_TABSTOP, 320, 410, 300, 50, writerWND.hwnd, NULL, GetModuleHandle(NULL), NULL);
SetWindowSubclass(writerWND.hTextField, WriterEditSubclassProc, 0, 0);
ShowWindow(writerWND.hwnd, SW_MAXIMIZE);
HWND hCurWnd = ::GetForegroundWindow();
DWORD dwMyID = ::GetCurrentThreadId();
DWORD dwCurID = ::GetWindowThreadProcessId(hCurWnd, NULL);
AttachThreadInput(dwCurID, dwMyID, TRUE);
SetWindowPos(writerWND.hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
SetWindowPos(writerWND.hwnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW | SWP_NOSIZE | SWP_NOMOVE);
SetForegroundWindow(writerWND.hwnd);
::SetFocus(writerWND.hwnd);
SetActiveWindow(writerWND.hwnd);
AttachThreadInput(dwCurID, dwMyID, FALSE);
writerWND.focus=writerWND.hTextField;
SendMessage(writerWND.hwnd, WM_SETFOCUS, NULL, NULL);
MSG Msg;
while(GetMessage(&Msg, writerWND.hwnd, 0, 0)) {
if(!IsDialogMessage(writerWND.hwnd, &Msg)) {
TranslateMessage(&Msg);
DispatchMessage(&Msg);
}
}
}

int showWriter(wchar_t *label, wchar_t *textFieldLabel, wchar_t *sendButtonLabel, wchar_t *cancelButtonLabel, wchar_t *textFieldValue, int textFieldSize) {
hideWriter();
writerWND.label = (wchar_t*)malloc(sizeof(wchar_t)*(wcslen(label)+1));
wcscpy(writerWND.label, label);
writerWND.textFieldLabel = (wchar_t*)malloc(sizeof(wchar_t)*(wcslen(textFieldLabel)+1));
wcscpy(writerWND.textFieldLabel, textFieldLabel);
writerWND.sendButtonLabel = (wchar_t*)malloc(sizeof(wchar_t)*(wcslen(sendButtonLabel)+1));
wcscpy(writerWND.sendButtonLabel, sendButtonLabel);
writerWND.cancelButtonLabel = (wchar_t*)malloc(sizeof(wchar_t)*(wcslen(cancelButtonLabel)+1));
wcscpy(writerWND.cancelButtonLabel, cancelButtonLabel);
if(textFieldValue!=NULL) {
writerWND.textFieldValue = (wchar_t*)malloc(sizeof(wchar_t)*(wcslen(textFieldValue)+1));
wcscpy(writerWND.textFieldValue, textFieldValue);
}
writerWND.textFieldSize=textFieldSize;
writerWND.shown=TRUE;
writerWND.hThread =(HANDLE) _beginthread(WriterThreadWindowProc, 0, 0);
return 0;
}

void hideWriter() {
if(writerWND.hThread!=NULL) {
writerWND.shown = writerWND.accepted = FALSE;
DestroyWindow(writerWND.hwnd);
if(writerWND.label!=NULL) free(writerWND.label);
if(writerWND.textFieldLabel!=NULL) free(writerWND.textFieldLabel);
if(writerWND.sendButtonLabel!=NULL) free(writerWND.sendButtonLabel);
if(writerWND.cancelButtonLabel!=NULL) free(writerWND.cancelButtonLabel);
if(writerWND.textFieldValue!=NULL) free(writerWND.textFieldValue);
writerWND.label = writerWND.textFieldLabel = writerWND.sendButtonLabel = writerWND.cancelButtonLabel = writerWND.textFieldValue = NULL;
writerWND.hwnd=0;
HANDLE hThread = writerWND.hThread;
writerWND.hThread=NULL;
TerminateThread(hThread, 0);
}
}

int getWriter(wchar_t *textValue, int textValueSize) {
if(writerWND.shown==FALSE) return 0;
GetWindowText(writerWND.hTextField, textValue, textValueSize);
if(writerWND.accepted) return 1;
else return 2;
}

typedef struct FileOpenState {
OPENFILENAME ofn;
wchar_t fileName[MAX_PATH];
wchar_t *filter;
wchar_t *label;
int status;
HANDLE hThread;
} FileOpenState;

FileOpenState fileOpenWND;

void __cdecl FileOpenThreadWindowProc(void *Args) {
if(GetOpenFileName(&fileOpenWND.ofn))
fileOpenWND.status=2;
else {
fileOpenWND.status=0;
hideFileOpen();
}
}

int showFileOpen(wchar_t *label, wchar_t *filter, int filterSize) {
hideFileOpen();
fileOpenWND.filter = (wchar_t*)malloc(sizeof(wchar_t)*(filterSize+1));
MoveMemory(fileOpenWND.filter, filter, sizeof(wchar_t)*filterSize);
if(label!=NULL) {
int sz = wcslen(label);
fileOpenWND.label = (wchar_t*)malloc(sizeof(wchar_t)*(sz+1));
wcscpy(fileOpenWND.label, label);
}
ZeroMemory(&fileOpenWND.ofn, sizeof(fileOpenWND.ofn));
fileOpenWND.ofn.lStructSize = sizeof(fileOpenWND.ofn);
fileOpenWND.ofn.lpstrFilter = fileOpenWND.filter;
fileOpenWND.ofn.nMaxFile = MAX_PATH;
fileOpenWND.ofn.lpstrFile = fileOpenWND.fileName;
if(label!=NULL) fileOpenWND.ofn.lpstrTitle = fileOpenWND.label;
fileOpenWND.ofn.Flags = OFN_FILEMUSTEXIST | OFN_HIDEREADONLY;
fileOpenWND.status=1;
fileOpenWND.hThread =(HANDLE) _beginthread(FileOpenThreadWindowProc, 0, 0);
return (int)fileOpenWND.hThread;
}

void hideFileOpen() {
HANDLE hThread = fileOpenWND.hThread;
fileOpenWND.hThread=NULL;
TerminateThread(hThread, 0);
if(fileOpenWND.filter!=NULL) free(fileOpenWND.filter);
fileOpenWND.filter=NULL;
if(fileOpenWND.label!=NULL) free(fileOpenWND.label);
fileOpenWND.label=NULL;
fileOpenWND.status=0;
}

int getFileOpen(wchar_t *s, int size) {
if(s!=NULL)
wcscpy_s(s, size, fileOpenWND.fileName);
return fileOpenWND.status;
}

typedef struct EmptyWindowState {
BOOL registered=FALSE;
BOOL created=FALSE;
BOOL shown=false;
HWND hwnd;
wchar_t *label;
} EmptyWindowState;

EmptyWindowState emptyWindowWND;

LRESULT CALLBACK emptyWindowWNDProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam) {
switch(Message) {
case WM_DESTROY:
destroyEmptyWindow();
break;
default:
return DefWindowProc(hwnd, Message, wParam, lParam);
}
return 0;
}

int createEmptyWindow(wchar_t *label) {
destroyEmptyWindow();
emptyWindowWND.label = (wchar_t*)malloc(sizeof(wchar_t)*(wcslen(label)+1));
wcscpy(emptyWindowWND.label, label);
emptyWindowWND.shown=TRUE;
if(!emptyWindowWND.registered) {
WNDCLASSEX wc;
memset(&wc,0,sizeof(wc));
wc.cbSize		 = sizeof(WNDCLASSEX);
wc.lpfnWndProc	 = emptyWindowWNDProc;
wc.hInstance	 = GetModuleHandle(NULL);
wc.hCursor		 = LoadCursor(NULL, IDC_ARROW);
wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
wc.lpszClassName = L"EltenEmptyWindow";
wc.hIcon		 = LoadIcon(NULL, IDI_APPLICATION);
wc.hIconSm		 = LoadIcon(NULL, IDI_APPLICATION);
if(!RegisterClassEx(&wc)) return 0;
}
emptyWindowWND.registered=TRUE;
emptyWindowWND.hwnd = CreateWindowEx(WS_EX_DLGMODALFRAME, L"EltenEmptyWindow", emptyWindowWND.label, WS_OVERLAPPED|WS_CAPTION, CW_USEDEFAULT, CW_USEDEFAULT, 640, 480, NULL, NULL, GetModuleHandle(NULL), NULL);
if(emptyWindowWND.hwnd==NULL) return 0;
ShowWindow(emptyWindowWND.hwnd, SW_HIDE);
emptyWindowWND.created=TRUE;
emptyWindowWND.shown=FALSE;
return (int)emptyWindowWND.hwnd;
}

void showEmptyWindow() {
ShowWindow(emptyWindowWND.hwnd, SW_MAXIMIZE);
HWND hCurWnd = ::GetForegroundWindow();
DWORD dwMyID = ::GetCurrentThreadId();
DWORD dwCurID = ::GetWindowThreadProcessId(hCurWnd, NULL);
AttachThreadInput(dwCurID, dwMyID, TRUE);
SetWindowPos(emptyWindowWND.hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
SetWindowPos(emptyWindowWND.hwnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW | SWP_NOSIZE | SWP_NOMOVE);
SetForegroundWindow(emptyWindowWND.hwnd);
::SetFocus(emptyWindowWND.hwnd);
SetActiveWindow(emptyWindowWND.hwnd);
AttachThreadInput(dwCurID, dwMyID, FALSE);
SendMessage(emptyWindowWND.hwnd, WM_SETFOCUS, NULL, NULL);
emptyWindowWND.shown=TRUE;
}

void updateEmptyWindow() {
MSG Msg;
while(PeekMessage(&Msg, emptyWindowWND.hwnd, 0, 0, PM_REMOVE)) {
if(!IsDialogMessage(emptyWindowWND.hwnd, &Msg)) {
TranslateMessage(&Msg);
DispatchMessage(&Msg);
}
}
}

HWND getEmptyWindow() {
return emptyWindowWND.hwnd;
}

void hideEmptyWindow() {
ShowWindow(emptyWindowWND.hwnd, SW_HIDE);
emptyWindowWND.shown=FALSE;
}

void destroyEmptyWindow() {
if(emptyWindowWND.created) {
emptyWindowWND.shown=false;
emptyWindowWND.created=FALSE;
DestroyWindow(emptyWindowWND.hwnd);
if(emptyWindowWND.label!=NULL) free(emptyWindowWND.label);
emptyWindowWND.label = NULL;
emptyWindowWND.hwnd=0;
}
}