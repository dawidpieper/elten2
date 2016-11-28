#define MAJOR 1
#define MINOR 0
#define BUILD 79
#define REV 131
#define MVXP 1
#define DATE "28/08/2016"
#define TIME "20:38:57UTC"
#define _STR(x) #x
#define STR(x) _STR(x)
#define VNUM MAJOR,MINOR,BUILD,REV
#define VSTR STR(MAJOR) "." STR(MINOR) "." STR(BUILD) "." STR(REV)
#define VCOMP "Elten network"
#define VCOPYRIGHT "Copyright 2014-2016 Elten Network. All Rights reserved"
#define VDATE DATE " - " TIME
