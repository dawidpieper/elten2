#define UNICODE
#define _UNICODE
//#define _WIN32_WINNT 0x0501
//#ifdef VS
//#include "stdafx.h"
//#endif

#include <string.h>
#include <windows.h>
#include <algorithm>


#include <openssl/rand.h>
#include <openssl/aes.h>
#include <openssl/sha.h>

#include "dll.h"

#include "autogen_sig.h"
#include "autogen_secr.h"



HINSTANCE hinstanceDLL;

BOOL WINAPI DllMain(HINSTANCE hinstDLL,DWORD fdwReason,LPVOID lpvReserved)
{
	hinstanceDLL=hinstDLL;
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


int CopyToClipboard(LPSTR 	data, int size) {
	        if (!OpenClipboard(0)) 
            return -1; 
            EmptyClipboard();
            if(data == NULL) {
            	CloseClipboard();
            return 0;
        }
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
return (LPSTR)"";
r = (LPSTR)GetClipboardData(CF_TEXT);
CloseClipboard();
if(r == NULL)
r = (LPSTR)"\0";
return r;
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

LRESULT CALLBACK messageHandling(int nCode, WPARAM wParam, LPARAM lParam) {
	BYTE keyboardState[256];
	GetKeyboardState(keyboardState);
		if (wParam == VK_F1)
			return 1;
//		if (wParam == VK_RETURN && keyboardState[VK_MENU] != 0)
//			return 1;
	return CallNextHookEx(0, nCode, wParam, lParam);
}

int hook(void) {
	HOOKPROC hookProc;
	static HHOOK hhook;;
	
	hookProc = (HOOKPROC)GetProcAddress(hinstanceDLL, "_messageHandling@12");
	if (hookProc == NULL) {
		LPVOID lpMsgBuf;
		LPVOID lpDisplayBuf;
		DWORD dw = GetLastError();
		FormatMessage(
			FORMAT_MESSAGE_ALLOCATE_BUFFER |
			FORMAT_MESSAGE_FROM_SYSTEM |
			FORMAT_MESSAGE_IGNORE_INSERTS,
			NULL,
			dw,
			MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
			(LPTSTR)&lpMsgBuf,
			0, NULL);
		return 1;;
	}
	hhook = SetWindowsHookEx(WH_KEYBOARD, hookProc, hinstanceDLL, GetCurrentThreadId());
	if (hhook == NULL) {
		LPVOID lpMsgBuf;
		LPVOID lpDisplayBuf;
		DWORD dw = GetLastError();
		FormatMessage(
			FORMAT_MESSAGE_ALLOCATE_BUFFER |
			FORMAT_MESSAGE_FROM_SYSTEM |
			FORMAT_MESSAGE_IGNORE_INSERTS,
			NULL,
			dw,
			MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
			(LPTSTR)&lpMsgBuf,
			0, NULL);
return 2;;
			}
return 0;
}

HINSTANCE GetInstance(void) {
	return hinstanceDLL;
}

int CryptMessage(LPSTR msg, LPSTR buf, int size) {
	
char file[MAX_PATH];
GetModuleFileName(NULL,(LPWSTR)file,MAX_PATH);
//HANDLE f = CreateFile((LPCWSTR)file, GENERIC_READ, FILE_SHARE_DELETE|FILE_SHARE_WRITE|FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
HANDLE f = CreateFile(L"C:\\Users\\dawid\\Documents\\rpgxp\\ELTEN\\Game.exe", GENERIC_READ, FILE_SHARE_DELETE|FILE_SHARE_WRITE|FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
if(f==INVALID_HANDLE_VALUE) return 0;
int sz = GetFileSize(f,NULL);
if(sz==0xFFFFFFFF) {
	CloseHandle(f);
	return 0;
}
LPSTR b = (LPSTR) GlobalAlloc(GPTR, sz+1);
DWORD read;
if(!ReadFile(f, b, sz, &read, NULL)) {
	CloseHandle(f);
	return 0;
}
CloseHandle(f);
b[sz]=0;

char digest[SHA_DIGEST_LENGTH];
SHA1((unsigned char*)b, read, (unsigned char*)&digest);
if(msg==NULL) {
memcpy(buf,digest,size);
return SHA_DIGEST_LENGTH;
}
GlobalFree(b);

if(strncmp(digest,SHA_SIG4,SHA_DIGEST_LENGTH)!=0 && strncmp(digest,SHA_SIG3,SHA_DIGEST_LENGTH)!=0 && strncmp(digest,SHA_SIG2,SHA_DIGEST_LENGTH)!=0 && strncmp(digest,SHA_SIG1,SHA_DIGEST_LENGTH)!=0) return 0;

if(size<AES_BLOCK_SIZE+2+strlen(msg)) return 0;

unsigned char IV[AES_BLOCK_SIZE];
do {
RAND_bytes(IV, AES_BLOCK_SIZE);
} while(strstr((char*)IV,":")!=NULL);
unsigned char IVc[AES_BLOCK_SIZE];
memcpy(IVc,IV,AES_BLOCK_SIZE);
AES_KEY* AesKey = new AES_KEY();
char key[32];
const char *k=SECR;
genkey(k,key);
AES_set_encrypt_key((unsigned char*)key, 256, AesKey);
b=(LPSTR) GlobalAlloc(GPTR,strlen(msg));
AES_cfb8_encrypt((const unsigned char*)msg, (unsigned char*)b, (size_t)strlen(msg), (const AES_KEY*)AesKey, (unsigned char*)IV, (int*)AES_ENCRYPT, AES_ENCRYPT);
memcpy(buf,(char*)IVc,AES_BLOCK_SIZE);
buf[AES_BLOCK_SIZE]=58;
buf[AES_BLOCK_SIZE+1]=58;
for(int i=0; i<strlen(msg); ++i) {
if(i+AES_BLOCK_SIZE+2>size)
return 0;
buf[i+AES_BLOCK_SIZE+2]=b[i];
}
GlobalFree(b);
return strlen(msg)+2+AES_BLOCK_SIZE;
}
