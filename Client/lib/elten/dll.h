#ifndef _DLL_H_
#define _DLL_H_


//#if BUILDING_DLL
#define DLLIMPORT __declspec(dllexport)
//#else
//#define DLLIMPORT __declspec(dllimport)
//#endif

extern "C" {
		int DLLIMPORT CopyToClipboard(LPSTR data, int size);
	LPSTR DLLIMPORT PasteFromClipboard();
 int DLLIMPORT WindowsVersion();
LRESULT DLLIMPORT CALLBACK messageHandling(int nCode, WPARAM wParam, LPARAM lParam);
int DLLIMPORT hook(void);
HINSTANCE DLLIMPORT GetInstance(void);
int DLLIMPORT CryptMessage(LPSTR msg, LPSTR buf, int size);
	}

#endif
