#ifndef _DLLSAPI_H_
#define _DLLSAPI_H_
#include <windows.h>

#define DLLIMPORT __declspec(dllexport)

extern "C" {
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
int DLLIMPORT SapiListDevices(wchar_t **, int);
int DLLIMPORT SapiSetDevice(int);

}
#endif