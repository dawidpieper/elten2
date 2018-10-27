#ifndef ELTEN_ENGINE_VERSION
#include <emain.h>
#endif
#include <eapi.h>
void ELTENAPI_INIT() {
VALUE mElten = rb_define_module("Elten");
VALUE mEltenEngine = rb_define_module_under(mElten, "Engine");
EAPISpeech_INIT(mEltenEngine);
EAPIKernel_INIT(mEltenEngine);
}
