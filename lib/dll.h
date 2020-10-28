#ifndef _DLL_H_
#define _DLL_H_


//#if BUILDING_DLL
#define DLLIMPORT __declspec(dllexport)
//#else
//#define DLLIMPORT __declspec(dllimport)
//#endif

extern "C" {
LRESULT DLLIMPORT CALLBACK messageHandling(int nCode, WPARAM wParam, LPARAM lParam);
LRESULT DLLIMPORT CALLBACK keyFiltering(int nCode, WPARAM wParam, LPARAM lParam);
int DLLIMPORT hook(void);
int DLLIMPORT getkeys(char *);
char DLLIMPORT setkey(char, char);
HINSTANCE DLLIMPORT GetInstance(void);
int DLLIMPORT CryptMessage(LPSTR msg, LPSTR buf, int size);
LPSTR DLLIMPORT GetShaFile(char *file);
void DLLIMPORT showElten(void);
int DLLIMPORT showTray(HWND);
void DLLIMPORT hideTray(void);
BOOL DLLIMPORT CALLBACK OpusRecordProc(int handle, const void *buffer, DWORD length, void *user);
int DLLIMPORT OpusRecorderInit(wchar_t*, int, int, int, float, int, BOOL);
void DLLIMPORT OpusRecorderClose(int);
BOOL DLLIMPORT CALLBACK VorbisRecordProc(int handle, const void *buffer, DWORD length, void *user);
int DLLIMPORT VorbisRecorderInit(wchar_t*, int, int, int);
void DLLIMPORT VorbisRecorderClose(int);
BOOL DLLIMPORT CALLBACK WaveRecordProc(int handle, const void *buffer, DWORD length, void *user);
int DLLIMPORT WaveRecorderInit(wchar_t*, int, int);
void DLLIMPORT WaveRecorderClose(int);
int DLLIMPORT SapiInit(void);
int DLLIMPORT SapiSpeak(wchar_t *text);
int DLLIMPORT SapiListVoices(wchar_t **, int);
int DLLIMPORT SapiSetVoice(int);
int DLLIMPORT SapiGetVoice(void);
int DLLIMPORT SapiSetRate(int rate);
int DLLIMPORT SapiGetRate(void);
int DLLIMPORT SapiSetVolume(USHORT volume);
USHORT DLLIMPORT SapiGetVolume(void);
BOOL DLLIMPORT SapiIsSpeaking(void);
wchar_t DLLIMPORT *SapiGetVoiceName(void);
int DLLIMPORT SapiSetPaused(BOOL);
BOOL DLLIMPORT SapiIsPaused(void);
int DLLIMPORT SapiStop(void);
int DLLIMPORT SapiSpeakSSML(wchar_t *text);
wchar_t DLLIMPORT *SapiGetBookmark(void);
}

#endif
