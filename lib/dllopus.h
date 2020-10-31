#ifndef _DLLOPUS_H_
#define _DLLOPUS_H_
#include <windows.h>

#define DLLIMPORT __declspec(dllexport)

extern "C" {

BOOL DLLIMPORT CALLBACK OpusRecordProc(int handle, const void *buffer, DWORD length, void *user);
int DLLIMPORT OpusRecorderInit(wchar_t*, int, int, int, float, int, BOOL);
void DLLIMPORT OpusRecorderClose(int);
}
#endif