#include <windows.h>
#include <dirent.h>
#ifndef _DLL_H_
#define _DLL_H_

#if BUILDING_DLL
#define DLLIMPORT __declspec(dllexport)
#else
#define DLLIMPORT __declspec(dllimport)
#endif

extern "C" {
	int DLLIMPORT KeyState(int key);
	int DLLIMPORT CopyToClipboard(LPSTR data, int size);
	LPSTR DLLIMPORT PasteFromClipboard();
 LPSTR DLLIMPORT FilesInDir(LPSTR DIRNAME);
 int DLLIMPORT WindowsVersion();
 int DLLIMPORT PasteFromClipboardToPointer(LPSTR pointer);
	}

#endif
