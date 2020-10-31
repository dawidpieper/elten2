#ifndef _DLL_H_
#define _DLL_H_


#define DLLIMPORT __declspec(dllexport)

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
}

#endif
