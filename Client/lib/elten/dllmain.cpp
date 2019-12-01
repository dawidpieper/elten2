#ifndef UNICODE
#define UNICODE
#define _UNICODE
#endif
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

char keys[256];

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

LRESULT CALLBACK messageHandling(int nCode, WPARAM wParam, LPARAM lParam) {
if(nCode<0)
return CallNextHookEx(0, nCode, wParam, lParam);
MSG *msg = (MSG*) lParam;
if(msg->message>=0x100 && msg->message<=0x108) {
char k=0;
if(msg->message==WM_KEYDOWN || msg->message==WM_SYSKEYDOWN)
k|=1;
if(msg->message==WM_KEYUP || msg->message==WM_SYSKEYUP)
k|=2;
if(msg->lParam&(1<<30))
k|=4;
if(k!=0) keys[msg->wParam]|=k;
}
	return CallNextHookEx(0, nCode, wParam, lParam);
}

LRESULT CALLBACK keyFiltering(int nCode, WPARAM wParam, LPARAM lParam) {
if(nCode<0)
	return CallNextHookEx(0, nCode, wParam, lParam);
if(wParam==VK_F1) {
if(lParam&(1<<31))
keys[VK_F1]|=2;
else
keys[VK_F1]|=1;
return 1;
}
if(0&&wParam==VK_F12) {
if(lParam&(1<<31))
keys[VK_F12]|=2;
else
keys[VK_F12]|=1;
return 1;
}
if(wParam==VK_RETURN && lParam&(1<<29))
return 1;
	return CallNextHookEx(0, nCode, wParam, lParam);
}

char setkey(char id, char val) {
return keys[id]=val;
}

int DLLIMPORT getkeys(char *k) {
memcpy(k,keys,256);
for(int i=0; i<256; ++i) keys[i]=0;
return 0;
}

int hook(void) {
	HOOKPROC hookProc = (HOOKPROC)GetProcAddress(hinstanceDLL, "_messageHandling@12");
	if (hookProc == NULL)
		return 1;
	static HHOOK hhook = SetWindowsHookEx(WH_GETMESSAGE, hookProc, hinstanceDLL, GetCurrentThreadId());
	if (hhook == NULL)
return 2;
	HOOKPROC khookProc = (HOOKPROC)GetProcAddress(hinstanceDLL, "_keyFiltering@12");
	if (khookProc == NULL)
		return 3;
	static HHOOK khhook = SetWindowsHookEx(WH_KEYBOARD, khookProc, hinstanceDLL, GetCurrentThreadId());
	if (khhook == NULL)
return 4;
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

if((unsigned int)size<(unsigned int)AES_BLOCK_SIZE+2+strlen(msg)) return 0;

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
for(unsigned int i=0; i<(unsigned int)strlen(msg); ++i) {
if(i+AES_BLOCK_SIZE+2>(unsigned int)size)
return 0;
buf[i+AES_BLOCK_SIZE+2]=b[i];
}
GlobalFree(b);
return strlen(msg)+2+AES_BLOCK_SIZE;
}
