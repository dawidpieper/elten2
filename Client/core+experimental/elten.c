#include "elten.h"
#ifndef _WIN32
void eos(size_t msgid, size_t cid, SPDNotificationType t)
{
sem_post(&sem);
}
#endif
const char* u2a(const wchar_t* u)
{
	if (!u) return NULL;
	int len = wcslen(u);
	if (convlen<len*sizeof(char)) {
		conv = realloc(conv, (len + 2) * sizeof(char));
		convlen = len*sizeof(char);
	}
	len = wcstombs(conv, u, len + 1);
	if (len<0) return NULL;
	((char*)conv)[len] = 0;
	return conv;
}
const wchar_t* a2u(const char* a)
{
	if (!a) return NULL;
	int len = strlen(a);
	if (convlen<len*sizeof(wchar_t)) {
		conv = realloc(conv, (len + 2) * sizeof(wchar_t));
		convlen = sizeof(wchar_t)*len;
	}
	len = mbstowcs(conv, a, len + 1);
	if (len<0) return NULL;
	((wchar_t*)conv)[len] = 0;
	return conv;
}
int GetScreenResolution(int *w, int *h)
{
#ifdef _WIN32
	RECT d;
	const HWND hd = GetDesktopWindow();
	GetWindowRect(hd, &d);
	*w = d.bottom;
	*h = d.right;
#else
Display* disp = XOpenDisplay(NULL);
Screen* scr = DefaultScreenOfDisplay(disp);
*w = scr->width;
*h = scr->height;
XCloseDisplay(disp);
#endif
return 0;
}
int key_pressed(int key)
{
#ifdef _WIN32
	if(IsKeyDown(key))
	{
		return 1;
	}
	else
	{
		return 0;
	}
		#else
	XNextEvent(display, &event);
if(event.type == KeyPress && event.xkey.keycode == key)
{
return 1;
}
else
{
return 0;
}
#endif
return 0;
}
int key_released(int key)
{
#ifdef _WIN32
	if(IsKeyUp(key))
	{
		return 1;
	}
else
{
	return 0;
}
	#else
	XNextEvent(display, &event);
if(event.type == KeyRelease && event.xkey.keycode == key)
{
return 1;
}
else
{
return 0;
}
#endif
return 0;
}
int rbprint(char* txt)
{
#ifdef _WIN32
MessageBox(NULL, txt, "Elten", MB_ICONERROR);
#else

#endif
}
int speech(char* msg)
{
#ifdef _WIN32
	int size = MultiByteToWideChar(CP_ACP, 0, msg, -1, NULL, 0);
	LPWSTR converted[65536];
	memset(converted, 0, sizeof(LPWSTR)*size);
	MultiByteToWideChar(CP_ACP, 0, msg, strlen(msg), converted, size);
	wchar_t* message;
	message = a2u(msg);
	sayString(message, true);
#else
if(spd_sayf(conn, SPD_MESSAGE, msg))
{
return 1;
}
else
{
return 0;
}
#endif
return 0;
}
void speech_wait()
{
#ifdef _WIN32
while(sapiIsSpeaking()) Sleep(1);
#else
sem_wait(&sem);
#endif
}
int speechStop()
{
#ifdef _WIN32
	return stopspeech();

	#else
	return spd_stop(conn);
#endif
}
#ifndef _WIN32
int stopAll()
{
	return spd_stop_all(conn);
}
int stopUid(int uid)
{
	return spd_stop_uid(conn, uid);
}
#endif
int pauseSpeech()
{
#ifdef _WIN32
	return sapisetpaused(1);
#else
	return spd_pause(conn);
#endif
}
#ifndef _WIN32
int pauseAll()
{
return spd_pause_all(conn);
}
int pauseUid(int uid)
{
return spd_pause_uid(conn, uid);
}
#endif
int resumeSpeech()
{
#ifdef _WIN32
	return sapisetpaused(0);
#else
	return spd_resume(conn);
#endif
}
#ifndef _WIN32
int resumeAll()
{
return spd_resume_all(conn);
}
int resumeUid(int uid)
{
return spd_resume_uid(conn, uid);
}
#endif
int setLng(char* lng)
{
#ifdef _WIN32
	//tej funkcji to chyba nie ma
#else
	return spd_set_language(conn, lng);
#endif
}
#ifndef _WIN32
/* Nie sądzę, żebym podobną funkcjonalnosć znalazł w bazie funkcji ScreenReaderAPI*/
int setPunctuation(SPDPunctuation type)
{
return spd_set_punctuation(conn, type);
}
#endif
int setRate(int rate)
{
#ifdef _WIN32
	return sapiSetRate(rate);
#else
	return spd_set_voice_rate(conn, rate);
#endif
}
int getRate()
{
#ifdef _WIN32
	return sapiGetRate();
#else
	return spd_get_voice_rate(conn);
#endif
}
int setPitch(int pitch)
{
#ifndef _WIN32
	return spd_set_voice_pitch(conn, pitch);
#endif
}
int getPitch()
{
#ifndef _WIN32
	return spd_get_voice_pitch(conn);
#endif
}
int setVolume(int v)
{
#ifdef _WIN32
	return sapiSetVolume(v);
#else
	return spd_set_volume(conn, v);
#endif
}
int getVolume()
{
#ifdef _WIN32
	return sapiGetVolume();
#else
	return spd_get_volume(conn);
#endif
}
char* getUser()
{
#ifdef _WIN32

#else
char* p = getenv("USER");
if(p != NULL)
{
return p;
}
#endif
}
char* getSynthesizer()
{
#ifdef _WIN32
	int vid = sapigetvoice();
	return sapigetvoicename(vid);
#endif
}
int setSynthesizer(char* synth)
{
#ifdef _WIN32
	int s = atoi(synth);
	return sapisetvoice(s);
#else
	return spd_set_synthesis_voice(conn, synth);
#endif
}
int readIni(char* path, char* section, char* key, char* *dump)
{
	int r = ini_gets(section, key, NULL, *dump, sizearray(*dump), path);
	return r;
}