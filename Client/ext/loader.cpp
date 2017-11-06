#include <windows.h>
#include <shlobj.h>;
bool Exist(const char *file) {
HANDLE hFile = CreateFileA(file,GENERIC_READ,FILE_SHARE_READ, NULL, OPEN_EXISTING,0,NULL);
if (hFile == INVALID_HANDLE_VALUE)
return false;
CloseHandle(hFile);
return true;
 }
int main(int argc, char * argv) {
TCHAR appdatadir[MAX_PATH];
if(!SUCCEEDED(SHGetFolderPath(NULL, 26, NULL, 0, appdatadir))) {
	GetEnvironmentVariable("appdata",appdatadir,MAX_PATH);
}
TCHAR eltendatadir[MAX_PATH];
strcpy(eltendatadir,appdatadir);
strcat(eltendatadir,"\\elten");
TCHAR bindatadir[MAX_PATH];
strcpy(bindatadir,eltendatadir);
strcat(bindatadir,"\\bin");
TCHAR eltenexe[MAX_PATH];
strcpy(eltenexe,bindatadir);
strcat(eltenexe,"\\elten\\elten.exe");
TCHAR szFile[MAX_PATH];
if(Exist(eltenexe))
strcpy(szFile,eltenexe);
else {
strcpy(szFile,eltenexe);
strcat(szFile,"\\download_elten.exe");
}
    STARTUPINFO si;
    PROCESS_INFORMATION pi;
    ZeroMemory( &si, sizeof(si) );
    si.cb = sizeof(si);
    ZeroMemory( &pi, sizeof(pi) );
TCHAR startdir[MAX_PATH];
strcpy(startdir,bindatadir);
strcat(startdir,"\\elten");
    if( !CreateProcess( NULL, eltenexe, NULL, NULL, FALSE, 0, NULL, startdir, &si, &pi)) {
MessageBox(NULL,"Unknown error occurred.\r\nPlease contact author of Elten:\r\ndawidpieper@o2.pl","Unknown error",MB_ICONERROR);
        return 1;
    }
return 0;
}
