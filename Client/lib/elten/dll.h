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
	}

#endif
