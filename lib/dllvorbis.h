#ifndef _DLLVORBIS_H_
#define _DLLVORBIS_H_
#include <windows.h>

#define DLLIMPORT __declspec(dllexport)

extern "C" {
BOOL DLLIMPORT CALLBACK VorbisRecordProc(int handle, const void *buffer, DWORD length, void *user);
int DLLIMPORT VorbisRecorderInit(wchar_t*, int, int, int);
void DLLIMPORT VorbisRecorderClose(int);
}
#endif