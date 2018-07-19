#ifndef ELTEN_ENGINE_VERSION
#include "main.c"
#endif
#ifndef ELTEN_FILE_INIT
#define ELTEN_FILE_INIT
#include <stdlib.h>
#include <stdio.h>
#ifdef WIN32
#include <winsock2.h>
#include <windows.h>
#include "screenreaderapi.h"
#include <process.h>
#endif
    	#include <ruby.h>
    	    			#include "api/api.c"

int ELTEN_ENGINE_INIT(int argc, char **argv) {
	
ruby_sysinit(&argc,&argv);
RUBY_INIT_STACK;
ruby_init();
rb_define_global_const("ELTEN_ENGINE",TRUE);
rb_define_global_const("ELTEN_ENGINE_VERSION", DBL2NUM(ELTEN_ENGINE_VERSION));
ruby_script("Elten_Init");
ELTENAPI_INIT();
ruby_script("Elten_Main");
}
#endif
