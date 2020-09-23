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
}

#endif
