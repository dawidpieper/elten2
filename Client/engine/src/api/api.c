#ifndef ELTEN_ENGINE_VERSION
#include "main.c"
#endif
#ifndef ELTEN_ELTENAPI
#define ELTEN_ELTENAPI
#include "kernel.c"

void ELTENAPI_INIT() {
VALUE mElten = rb_define_module("Elten");
VALUE mEltenEngine = rb_define_module_under(mElten, "Engine");
EAPISpeech_INIT(mEltenEngine);
EAPIKernel_INIT(mEltenEngine);
}
#endif
