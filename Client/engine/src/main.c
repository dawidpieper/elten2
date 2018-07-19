// Elten Engine Version 3.0
// Copyright (C) Dawid Pieper
// All rights reserved
// This code is published under Open Public License
// The terms of modification or redistribution of the following code are detailed in a separate document

#define ELTEN_ENGINE_VERSION 3.0
#include "init.c"
#include "window.c"

void MsgBox(char * name, char * text, int type) {
#ifdef Win32
//MessageBox(hwnd,text,name,16*type);
#endif
}

int main(int argc, char **argv) {
ELTEN_ENGINE_INIT(argc,argv);
#ifdef WIN32
ELTEN_WINDOW_InitThr();
#endif
rb_eval_string("begin;p eval(STDIN.gets) while true;rescue SystemExit;rescue Exception;p $!;retry;end");
return 0;
}