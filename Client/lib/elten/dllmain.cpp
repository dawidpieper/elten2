#include "dll.h"

BOOL WINAPI DllMain(HINSTANCE hinstDLL,DWORD fdwReason,LPVOID lpvReserved)
{
	switch(fdwReason)
	{
		case DLL_PROCESS_ATTACH:
		{
			break;
		}
		case DLL_PROCESS_DETACH:
		{
			break;
		}
		case DLL_THREAD_ATTACH:
		{
			break;
		}
		case DLL_THREAD_DETACH:
		{
			break;
		}
	}
	
	/* Return TRUE on success, FALSE on failure */
	return TRUE;
}

int KeyState(int key) {
	SHORT ef = GetAsyncKeyState(key);
	int r = 0;
	if(ef)
	r = 1;
	return r;
}


int CopyToClipboard(LPSTR data, int size) {
	        if (!OpenClipboard(0)) 
            return -1; 
            EmptyClipboard();
            if(data == NULL) {
            	CloseClipboard();
            return 0;
        }
        EmptyClipboard();
				 HGLOBAL clipBuffer = GlobalAlloc(GMEM_DDESHARE, size);
				 char * buffer = (char*) GlobalLock(clipBuffer);
				 strcpy(buffer, data);
				 GlobalUnlock(clipBuffer);
            HANDLE r = SetClipboardData(CF_TEXT,clipBuffer);
            CloseClipboard();
            return 0;
}

LPSTR PasteFromClipboard() {
LPSTR r;
if(!OpenClipboard(0))
return "\0";
r = (LPSTR)GetClipboardData(CF_TEXT);
CloseClipboard();
if(r == NULL)
r = "\0";
return r;
}

LPSTR FilesInDir(LPSTR DIRNAME) {
	struct dirent * plik;
	DIR * sciezka;
	if(!( sciezka = opendir( DIRNAME ) ) ) {
		return "|||";
	}
	char pliki[65536];
	ZeroMemory(pliki,8192);
	strcpy(pliki,"");
	while(( plik = readdir( sciezka ) ) ) {
		strcat(pliki,plik->d_name);
		strcat(pliki,"\n");
	}
	closedir( sciezka );
	return pliki;
}

int WindowsVersion() {
	    DWORD dwVersion = 0; 
    DWORD dwMajorVersion = 0;
    DWORD dwMinorVersion = 0; 
    DWORD dwBuild = 0;
        dwVersion = GetVersion();
            dwMajorVersion = (DWORD)(LOBYTE(LOWORD(dwVersion)));
    dwMinorVersion = (DWORD)(HIBYTE(LOWORD(dwVersion)));
            dwBuild = (DWORD)(HIWORD(dwVersion));
            return dwBuild;
}

int PasteFromClipboardToPointer(LPSTR pointer) {
LPSTR r;
if(!OpenClipboard(0))
return 0;
r = (LPSTR)GetClipboardData(CF_TEXT);
CloseClipboard();
if(r == NULL)
r = "\0";
strcpy(pointer,r);
return 1;
}
