#ifndef _DLLWAVE_H_
#define _DLLWAVE_H_
#include <windows.h>

#define DLLIMPORT __declspec(dllexport)

extern "C" {
BOOL DLLIMPORT CALLBACK WaveRecordProc(int handle, const void *buffer, DWORD length, void *user);
int DLLIMPORT WaveRecorderInit(wchar_t*, int, int);
void DLLIMPORT WaveRecorderClose(int);
}
#endif