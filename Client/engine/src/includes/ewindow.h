#ifndef ELTEN_FILE_WINDOW
#ifdef _WIN32
#include <windows.h>
LRESULT CALLBACK WndProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam);;
#endif
int ELTEN_WINDOW_InitThr();
#endif