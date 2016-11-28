#ifdef _WIN32
#define _CRT_SECURE_NO_WARNINGS
#include <windows.h>
#include <wtypes.h>
#else
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <speech-dispatcher/libspeechd.h>
#include <semaphore.h>
#include <X11/Xlib.h>
#endif
#include "defs.h"
#include "minIni.h"
#include <time.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <wchar.h>
#define sizearray(a) (sizeof(a) / sizeof((a)[0]))
static void* conv = NULL;
static int convlen = 0;
int GetScreenResolution(int *w, int *h);
int rbprint(char* txt);
int key_pressed(int key);
int speech(char* msg);
void speech_wait(void);
int stopSpeech(void);
int stopAll(void);
int stopUid(int uid);
int pauseSpeech(void);
int pauseAll(void);
int pauseUid(int uid);
int resumeSpeech(void);
int resumeAll(void);
int resumeUid(int uid);
int setRate(int rate);
int setVolume(int v);
int setPitch(int p);
int setLng(char* language);
int getRate(void);
int getPitch(void);
int getVolume(void);
char* getUser(void);
char** getSynthesizers(void);
int setSynthesizer(char* synth);
int readIni(char* path, char* section, char* key, char* *dump);
const char* u2a(const wchar_t* u);
const wchar_t* a2u(const char* a);
#ifdef _WIN32
HMODULE scr;
typedef void(__stdcall *ZPV)();
typedef int(__stdcall *ZPI)();
typedef int(__stdcall *OPI)(int);
typedef int(__stdcall *OPS)(LPWSTR);
typedef int(__stdcall *TP)(LPWSTR, BOOL);
typedef char*(__stdcall *CZP)();
typedef char*(__stdcall *COP)(int);
TP sayString; 
ZPI sapiIsSpeaking; 
ZPI stopspeech; 
OPI sapiSetRate; 
ZPI sapiGetRate; 
OPI sapiSetVolume; 
ZPI sapiGetVolume; 
OPI sapisetpaused; 
ZPI sapiIsPaused; 
ZPI sapigetnumvoices; 
OPI sapisetvoice; 
ZPI sapigetvoice; 
COP sapigetvoicename; 
ZPI sapiIsEnabled;
OPI sapiEnable;
ZPI getCurrentScreenReader;
OPI setScreenReader;
CZP getCurrentScreenReaderName;
COP getScreenReaderName;
ZPI GetScreenReaders;
#else
void eos(size_t msgid, size_t cid, SPDNotificationType t);
Display *display;
Window window;
XEvent event;
int screen;
sem_t sem;
SPDConnection *conn ;
#endif
