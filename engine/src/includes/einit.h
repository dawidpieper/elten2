#ifndef ELTEN_FILE_INIT
#define ELTEN_FILE_INIT
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#ifdef _WIN32
#include <winsock2.h>
#include <windows.h>
#include "screenreaderapi.h"
#include <process.h>
#endif
    	#include <ruby.h>
    	    			#include <eapi.h>
int ELTEN_ENGINE_INIT(int argc, char **argv);
#endif
