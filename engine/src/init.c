#ifndef ELTEN_ENGINE_VERSION
#include <emain.h>
#endif
#include <einit.h>
int ELTEN_ENGINE_INIT(int argc, char **argv) {
	
ruby_sysinit(&argc,&argv);
RUBY_INIT_STACK;
ruby_init();
rb_define_global_const("ELTEN_ENGINE",1);
rb_define_global_const("ELTEN_ENGINE_VERSION", DBL2NUM(ELTEN_ENGINE_VERSION));
ruby_script("Elten_Init");
ELTENAPI_INIT();
ruby_script("Elten_Main");
}
