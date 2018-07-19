#ifndef ELTEN_ENGINE_VERSION
#include "../main.c"
#endif
#ifndef ELTEN_API_KERNEL
#define ELTEN_API_KERNEL
VALUE EltenEngineKernel_getmodulefilename(VALUE self) {
				 		#ifdef WIN32
TCHAR path[1024];
GetModuleFileName(NULL, path, 1024);
return rb_str2_new(path);
#endif
}

VALUE EltenEngineKernel_getexitcodeprocess(VALUE self, VALUE prochandle) {
				 		#ifdef WIN32
TCHAR extc[1024];
GetExitCodeProcess(prochandle, extc);
return rb_str2_new(extc);
#endif
}

VALUE EltenEngineKernel_copyfile(VALUE self, VALUE source, VALUE destination, VALUE method) {
				 		#ifdef WIN32
CopyFile(StringValuePtr(source), StringValuePtr(destination), method);
#endif
}

VALUE EltenEngineKernel_movefile(VALUE self, VALUE source, VALUE destination) {
				 		#ifdef WIN32
MoveFile(StringValuePtr(source), StringValuePtr(destination));
#endif
}

VALUE EltenEngineKernel_deletefile(VALUE self, VALUE source) {
				 		#ifdef WIN32
DeleteFile(StringValuePtr(source));
#endif
}


void EAPISpeech_INIT(VALUE mMod) {
	VALUE mEltenEngineKernel = rb_define_module_under(mMod, "Kernel");
rb_define_module_function(mEltenEngineKernel, "getmodulefilename", EltenEngineSpeech_getmodulefilename, 0);
rb_define_module_function(mEltenEngineKernel, "getexitcodeprocess", EltenEngineSpeech_getexitcodeprocess, 1);
rb_define_module_function(mEltenEngineKernel, "copyfile", EltenEngineSpeech_copyfile, 3);
rb_define_module_function(mEltenEngineKernel, "movefile", EltenEngineSpeech_movefile, 2);
rb_define_module_function(mEltenEngineKernel, "deletefile", EltenEngineSpeech_deletefile, 1);
}
#endif

