#ifndef ELTEN_FILE_WINDOW
#ifdef _WIN32
#include <windows.h>
LRESULT CALLBACK WndProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam);;
#endif
#ifdef __linux__
#include <X11/Xlib.h>
Display *display;
Window window;
XEvent event;
int screen;
#endif
int ELTEN_WINDOW_InitThr();
#endif