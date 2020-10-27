#ifndef ELTEN_ENGINE_VERSION
#include <emain.h>
#endif
VALUE EltenEngineKernel_getmodulefilename(VALUE self) {
				 		#ifdef _WIN32
TCHAR path[1024];
GetModuleFileName(NULL, path, 1024);
return rb_str2_new(path);
#endif
}

VALUE EltenEngineKernel_getexitcodeprocess(VALUE self, VALUE prochandle) {
				 		#ifdef _WIN32
TCHAR extc[1024];
GetExitCodeProcess(prochandle, extc);
return rb_str2_new(extc);
#endif
}

VALUE EltenEngineKernel_copyfile(VALUE self, VALUE source, VALUE destination, VALUE method) {
				 		#ifdef _WIN32
CopyFile(StringValuePtr(source), StringValuePtr(destination), method);
#endif
}

VALUE EltenEngineKernel_movefile(VALUE self, VALUE source, VALUE destination) {
				 		#ifdef _WIN32
MoveFile(StringValuePtr(source), StringValuePtr(destination));
#endif
}

VALUE EltenEngineKernel_deletefile(VALUE self, VALUE source) {
				 		#ifdef _WIN32
DeleteFile(StringValuePtr(source));
#endif
}

VALUE EltenEngineKernel_removedirectory(VALUE self, VALUE source) {
				 		#ifdef _WIN32
RemoveDirectory(StringValuePtr(source));
#endif
}

VALUE EltenEngineKernel_getmodulehandle(VALUE self, VALUE module) {
#ifdef _WIN32
return GetModuleHandle(module);
#endif
}

VALUE EltenEngineKernel_getcurrentprocess(VALUE self) {
#ifdef _WIN32
return GetCurrentProcess();
#endif
}

VALUE EltenEngineKernel_getcomputername(VALUE self) {
				 		#ifdef _WIN32
TCHAR cmpname[1024];
GetComputerName(cmpname, 1024);
return rb_Str2_new(cmpname);
#endif
}

VALUE EltenEngineKernel_getcommandline(VALUE self) {
#ifdef _WIN32
return rb_str2_new(GetCommandLine());
#endif
}

VALUE EltenEngineKernel_getuserdefaultuilanguage(VALUE self) {
#ifdef _WIN32
return GetUserDefaultUILanguage();
#endif
}

VALUE EltenEngineKernel_getphysicallyinstalledsystemmemory(VALUE self) {
#ifdef _WIN32
LONG mem;
GetPhysicallyInstalledSystemMemory(&mem);
return mem;
#endif
}

void EAPIKernel_INIT(VALUE mMod) {
	VALUE mEltenEngineKernel = rb_define_module_under(mMod, "Kernel");
rb_define_module_function(mEltenEngineKernel, "getmodulefilename", EltenEngineKernel_getmodulefilename, 0);
rb_define_module_function(mEltenEngineKernel, "getexitcodeprocess", EltenEngineKernel_getexitcodeprocess, 1);
rb_define_module_function(mEltenEngineKernel, "copyfile", EltenEngineKernel_copyfile, 3);
rb_define_module_function(mEltenEngineKernel, "movefile", EltenEngineKernel_movefile, 2);
rb_define_module_function(mEltenEngineKernel, "deletefile", EltenEngineKernel_deletefile, 1);
rb_define_module_function(mEltenEngineKernel, "removedirectory", EltenEngineKernel_removedirectory, 1);
rb_define_module_function(mEltenEngineKernel, "getmodulehandle", EltenEngineKernel_getmodulehandle, 1);
rb_define_module_function(mEltenEngineKernel, "getcurrentprocess", EltenEngineKernel_getcurrentprocess, 0);
rb_define_module_function(mEltenEngineKernel, "getcomputername", EltenEngineKernel_getcomputername, 0);
rb_define_module_function(mEltenEngineKernel, "getcommandline", EltenEngineKernel_getcommandline, 0);
rb_define_module_function(mEltenEngineKernel, "getuserdefaultuilanguage", EltenEngineKernel_getuserdefaultuilanguage, 0);
rb_define_module_function(mEltenEngineKernel, "getphysicallyinstalledsystemmemory", EltenEngineKernel_getphysicallyinstalledsystemmemory, 0);
}

