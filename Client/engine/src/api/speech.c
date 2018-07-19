#ifndef ELTEN_ENGINE_VERSION
#include "../main.c"
#endif
#ifndef ELTEN_API_SPEECH
#define ELTEN_API_SPEECH
VALUE EltenEngineSpeech_say(VALUE self, VALUE saytext, VALUE outputtype, VALUE alter) {
				 		#ifdef WIN32
	if(outputtype==0)
sayString(StringValuePtr(saytext),alter);
	else
	sapiSayString(StringValuePtr(saytext),alter);
#endif
}

VALUE EltenEngineSpeech_stop(VALUE self, VALUE outputtype) {
	#ifdef WIN32
	if(outputtype==0)
	stopSpeech();
	else
	sapiStopSpeech();
	#endif
}

VALUE EltenEngineSpeech_isspeaking(VALUE self) {
#ifdef WIN32
return sapiIsSpeaking();
#endif
}

VALUE EltenEngineSpeech_getnumvoices(VALUE self) {
#ifdef WIN32
return sapiGetNumVoices();
#endif
}

VALUE EltenEngineSpeech_getvoice(VALUE self) {
#ifdef WIN32
return sapiGetVoice();
#endif
}

VALUE EltenEngineSpeech_setvoice(VALUE self, VALUE voiceid) {
#ifdef WIN32
return sapiSetVoice(voiceid);
#endif
}

VALUE EltenEngineSpeech_getrate(VALUE self) {
#ifdef WIN32
return sapiGetRate();
#endif
}

VALUE EltenEngineSpeech_setrate(VALUE self, VALUE vol) {
#ifdef WIN32
return sapiSetRate(vol);
#endif
}
VALUE EltenEngineSpeech_getvolume(VALUE self) {
#ifdef WIN32
return sapiGetVolume();
#endif
}

VALUE EltenEngineSpeech_setvolume(VALUE self, VALUE vol) {
#ifdef WIN32
return sapiSetVolume(vol);
#endif
}

VALUE EltenEngineSpeech_getvoicename(VALUE self, VALUE id) {
#ifdef WIN32
return rb_str2_new(sapiGetVoiceName(id));
#endif
}

VALUE EltenEngineSpeech_getoutputmethod(VALUE self) {
#ifdef WIN32
return GetCurrentScreenReader();
#endif
}

VALUE EltenEngineSpeech_ispaused(VALUE self) {
#ifdef WIN32
return sapiIsPaused();
#endif
}

VALUE EltenEngineSpeech_setpaused(VALUE self, VALUE s) {
#ifdef WIN32
return sapiSetPaused(s);
#endif
}

void EAPISpeech_INIT(VALUE mMod) {
	VALUE mEltenEngineSpeech = rb_define_module_under(mMod, "Speech");
rb_define_module_function(mEltenEngineSpeech, "say", EltenEngineSpeech_say, 3);
rb_define_module_function(mEltenEngineSpeech, "stop",EltenEngineSpeech_stop,1);
rb_define_module_function(mEltenEngineSpeech, "isspeaking",EltenEngineSpeech_isspeaking,0);
rb_define_module_function(mEltenEngineSpeech, "getnumvoices",EltenEngineSpeech_getnumvoices,0);
rb_define_module_function(mEltenEngineSpeech, "getvoice",EltenEngineSpeech_getvoice,0);
rb_define_module_function(mEltenEngineSpeech, "setvoice",EltenEngineSpeech_setvoice,1);
rb_define_module_function(mEltenEngineSpeech, "getrate",EltenEngineSpeech_getrate,0);
rb_define_module_function(mEltenEngineSpeech, "setrate",EltenEngineSpeech_setrate,1);
rb_define_module_function(mEltenEngineSpeech, "getvolume",EltenEngineSpeech_getvolume,0);
rb_define_module_function(mEltenEngineSpeech, "setvolume",EltenEngineSpeech_setvolume,1);
rb_define_module_function(mEltenEngineSpeech, "getvoicename",EltenEngineSpeech_setvoicename,1);
rb_define_module_function(mEltenEngineSpeech, "getoutputmethod",EltenEngineSpeech_getoutputmethod,0);
rb_define_module_function(mEltenEngineSpeech, "ispaused",EltenEngineSpeech_ispaused,0);
rb_define_module_function(mEltenEngineSpeech, "setpaused",EltenEngineSpeech_setpaused,1);
}
#endif

