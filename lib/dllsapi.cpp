/*
A part of Elten - EltenLink / Elten Network desktop client.
Copyright (C) 2014-2020 Dawid Pieper
Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 
*/

#ifndef UNICODE
#define UNICODE
#define _UNICODE
#endif
#include "dllsapi.h"
#include <string.h>
#include <windows.h>
#include <algorithm>
#include <time.h>
#include <atlbase.h>
#include <sapi.h>
#include <sphelper.h>

ISpVoice* pVoice=NULL;
BOOL voiceIsPaused=false;

int SapiInit(void) {
HRESULT hr;
hr = CoCreateInstance(CLSID_SpVoice, NULL, CLSCTX_ALL, IID_ISpVoice, (void **)&pVoice);
if( SUCCEEDED( hr ) )
pVoice->SetPriority(SPVPRI_OVER);
return 0;
return 1;
}

int SapiSpeak(wchar_t *text) {
HRESULT hr;
if(pVoice == NULL) SapiInit();
if(pVoice!=NULL) {
voiceIsPaused=false;
hr = pVoice->Speak(text, SPF_ASYNC | SPF_IS_NOT_XML | SPF_PURGEBEFORESPEAK, NULL);
}
return 0;
}

int SapiListVoices(SapiVoice *voices, int size) {
if(pVoice==NULL) SapiInit();
if(pVoice==NULL) return 0;
HRESULT hr = S_OK;
CComPtr<ISpObjectTokenCategory> cpSpCategory = NULL; 
if(!SUCCEEDED(hr = SpGetCategoryFromId(SPCAT_VOICES, &cpSpCategory))) return -0;
CComPtr<IEnumSpObjectTokens> cpSpEnumTokens;
if(!SUCCEEDED(hr = cpSpCategory->EnumTokens(NULL, NULL, &cpSpEnumTokens))) return 0;
CComPtr<ISpObjectToken> pSpTok;
ULONG i=0;
while(SUCCEEDED(hr = cpSpEnumTokens->Next(1, &pSpTok, NULL))) {
if((int)i<size) {
wchar_t *ch = NULL;
int siz=0;
if(SUCCEEDED(hr = pSpTok->GetId(&ch))) {
siz = wcslen(ch)+1;
voices[i].id = (wchar_t*)malloc(sizeof(wchar_t)*siz);
if(voices[i].id!=NULL) wcscpy_s(voices[i].id, siz, ch);
}
if(SUCCEEDED(hr = pSpTok->GetStringValue(NULL, &ch))) {
siz = wcslen(ch)+1;
voices[i].name = (wchar_t*)malloc(sizeof(wchar_t)*siz);
if(voices[i].name!=NULL) wcscpy_s(voices[i].name, siz, ch);
}
CComPtr<ISpDataKey> attributes;
if(SUCCEEDED(hr = pSpTok->OpenKey(L"Attributes", &attributes))) {
if(SUCCEEDED(hr = attributes->GetStringValue(L"Language", &ch))) {
siz = wcslen(ch)+1;
voices[i].language = (wchar_t*)malloc(sizeof(wchar_t)*siz);
if(voices[i].language!=NULL) wcscpy_s(voices[i].language, siz, ch);
}
if(SUCCEEDED(hr = attributes->GetStringValue(L"Age", &ch))) {
siz = wcslen(ch)+1;
voices[i].age = (wchar_t*)malloc(sizeof(wchar_t)*siz);
if(voices[i].age!=NULL) wcscpy_s(voices[i].age, siz, ch);
}
if(SUCCEEDED(hr = attributes->GetStringValue(L"Gender", &ch))) {
siz = wcslen(ch)+1;
voices[i].gender = (wchar_t*)malloc(sizeof(wchar_t)*siz);
if(voices[i].gender!=NULL) wcscpy_s(voices[i].gender, siz, ch);
}
if(SUCCEEDED(hr = attributes->GetStringValue(L"Vendor", &ch))) {
siz = wcslen(ch)+1;
voices[i].vendor = (wchar_t*)malloc(sizeof(wchar_t)*siz);
if(voices[i].vendor!=NULL) wcscpy_s(voices[i].vendor, siz, ch);
}
}
attributes.Release();
}
pSpTok.Release(); 
++i;
ULONG count;
cpSpEnumTokens->GetCount(&count);
if(i>=count) break;
}
return i;
}

void SapiFreeVoices(SapiVoice *voices, int size) {
if(voices==NULL) return;
for(int i=0; i<size; ++i) {
if(voices[i].id!=NULL) free(voices[i].id);
if(voices[i].name!=NULL) free(voices[i].name);
if(voices[i].language!=NULL) free(voices[i].language);
if(voices[i].age!=NULL) free(voices[i].age);
if(voices[i].gender!=NULL) free(voices[i].gender);
if(voices[i].vendor!=NULL) free(voices[i].vendor);
voices[i].id=voices[i].name=voices[i].language=voices[i].age=voices[i].gender=voices[i].vendor=NULL;
}
}

int SapiSetVoice(int num) {
HRESULT hr = S_OK;
if(pVoice == NULL) SapiInit();
if(pVoice==NULL) return 1;
CComPtr<ISpObjectTokenCategory> cpSpCategory = NULL; 
if(!SUCCEEDED(hr = SpGetCategoryFromId(SPCAT_VOICES, &cpSpCategory))) return -0;
CComPtr<IEnumSpObjectTokens> cpSpEnumTokens;
if(!SUCCEEDED(hr = cpSpCategory->EnumTokens(NULL, NULL, &cpSpEnumTokens))) return 0;
CComPtr<ISpObjectToken> pSpTok;
ULONG i=0;
while(SUCCEEDED(hr = cpSpEnumTokens->Next(1, &pSpTok, NULL))) {
wchar_t *ch = NULL;
hr = pSpTok->GetStringValue(NULL, &ch);
if(i==num) {
pVoice->SetVoice(pSpTok);
return 0;
}
pSpTok.Release(); 
++i;
ULONG count;
cpSpEnumTokens->GetCount(&count);
if(i>=count) break;
}
return 2;
}

int SapiGetVoice() {
HRESULT hr = S_OK;
if(pVoice == NULL) SapiInit();
if(pVoice==NULL) return -1;
CComPtr<ISpObjectToken> curVoiceTok;
pVoice->GetVoice(&curVoiceTok);
LPWSTR voiceId = NULL;
hr = curVoiceTok->GetId(&voiceId);
curVoiceTok.Release();
CComPtr<ISpObjectTokenCategory> cpSpCategory = NULL; 
if(!SUCCEEDED(hr = SpGetCategoryFromId(SPCAT_VOICES, &cpSpCategory))) return -0;
CComPtr<IEnumSpObjectTokens> cpSpEnumTokens;
if(!SUCCEEDED(hr = cpSpCategory->EnumTokens(NULL, NULL, &cpSpEnumTokens))) return 0;
CComPtr<ISpObjectToken> pSpTok;
ULONG i=0;
while(SUCCEEDED(hr = cpSpEnumTokens->Next(1, &pSpTok, NULL))) {
wchar_t *ch = NULL;
hr = pSpTok->GetStringValue(NULL, &ch);
LPWSTR vId = NULL;
hr = pSpTok->GetId(&vId);
if(wcscmp(voiceId, vId)==0) {
pSpTok.Release(); 
return i;
}
pSpTok.Release(); 
++i;
ULONG count;
cpSpEnumTokens->GetCount(&count);
if(i>=count) break;
}
return -1;
}

int DLLIMPORT SapiSetRate(int rate) {
if(pVoice==NULL) SapiInit();
if(pVoice==NULL) return -1;
pVoice->SetRate((rate/5-10));
return 0;
}

int DLLIMPORT SapiGetRate(void) {
if(pVoice==NULL) SapiInit();
if(pVoice==NULL) return -1;
LONG rate;
pVoice->GetRate(&rate);
return ((rate+10)*5);
}

int DLLIMPORT SapiSetVolume(USHORT volume) {
if(pVoice==NULL) SapiInit();
if(pVoice==NULL) return -1;
pVoice->SetVolume(volume);
return 0;
}

USHORT DLLIMPORT SapiGetVolume(void) {
if(pVoice==NULL) SapiInit();
if(pVoice==NULL) return -1;
USHORT volume;
pVoice->GetVolume(&volume);
return volume;
}

BOOL SapiIsSpeaking() {
if(pVoice==NULL) SapiInit();
if(pVoice==NULL) return 0;
SPVOICESTATUS pStatus;
pVoice->GetStatus(&pStatus, NULL);
return (pStatus.dwRunningState == SPRS_IS_SPEAKING);
}

wchar_t *SapiGetVoiceName() {
HRESULT hr = S_OK;
if(pVoice == NULL) SapiInit();
if(pVoice==NULL) return NULL;
CComPtr<ISpObjectToken> curVoiceTok;
pVoice->GetVoice(&curVoiceTok);
LPWSTR voiceId = NULL;
hr = curVoiceTok->GetId(&voiceId);
curVoiceTok.Release();
CComPtr<ISpObjectTokenCategory> cpSpCategory = NULL; 
if(!SUCCEEDED(hr = SpGetCategoryFromId(SPCAT_VOICES, &cpSpCategory))) return -0;
CComPtr<IEnumSpObjectTokens> cpSpEnumTokens;
if(!SUCCEEDED(hr = cpSpCategory->EnumTokens(NULL, NULL, &cpSpEnumTokens))) return NULL;
CComPtr<ISpObjectToken> pSpTok;
ULONG i=0;
while(SUCCEEDED(hr = cpSpEnumTokens->Next(1, &pSpTok, NULL))) {
wchar_t *ch = NULL;
hr = pSpTok->GetStringValue(NULL, &ch);
LPWSTR vId = NULL;
hr = pSpTok->GetId(&vId);
if(wcscmp(voiceId, vId)==0) {
wchar_t *ch = NULL;
hr = pSpTok->GetStringValue(NULL, &ch);
pSpTok.Release(); 
return ch;
}
pSpTok.Release(); 
++i;
ULONG count;
cpSpEnumTokens->GetCount(&count);
if(i>=count) break;
}
return NULL;
}

int SapiSetPaused(BOOL paused) {
if(pVoice==NULL) SapiInit();
if(pVoice==NULL) return 1;
if(paused==0)
pVoice->Resume();
else
pVoice->Pause();
voiceIsPaused=paused;
return 0;
}

BOOL SapiIsPaused() {
return voiceIsPaused;
}

int SapiStop() {
if(pVoice==NULL) SapiInit();
if(pVoice==NULL) return 1;
voiceIsPaused=false;
pVoice->Speak(NULL, SPF_ASYNC | SPF_IS_NOT_XML | SPF_PURGEBEFORESPEAK, NULL);
return 0;
}

int SapiSpeakSSML(wchar_t *text) {
HRESULT hr;
if(pVoice == NULL) SapiInit();
if(pVoice!=NULL) {
voiceIsPaused=false;
hr = pVoice->Speak(text, SPF_ASYNC | SPF_IS_XML | SPF_PURGEBEFORESPEAK, NULL);
}
return 0;
}

wchar_t *SapiGetBookmark() {
if(pVoice==NULL) SapiInit();
if(pVoice==NULL) return NULL;
wchar_t *bookmark;
pVoice->GetStatus(NULL, &bookmark);
return bookmark;
}

int SapiListDevices(wchar_t **devices, int size) {
if(pVoice==NULL) SapiInit();
if(pVoice==NULL) return 0;
HRESULT hr = S_OK;
CComPtr<IEnumSpObjectTokens> cpSpEnumTokens;
if(!SUCCEEDED(hr = SpEnumTokens(SPCAT_AUDIOOUT, NULL, NULL, &cpSpEnumTokens))) return 0;
CComPtr<ISpObjectToken> pSpTok;
ULONG i=0;
while(SUCCEEDED(hr = cpSpEnumTokens->Next(1, &pSpTok, NULL))) {
wchar_t *ch = NULL;
hr = pSpTok->GetStringValue(NULL, &ch);
if((int)i<size) {
int siz = wcslen(ch)+1;
devices[i] = (wchar_t*)malloc(sizeof(wchar_t)*siz);
if(devices[i]!=NULL)
wcscpy_s(devices[i], siz, ch);
}
pSpTok.Release(); 
++i;
ULONG count;
cpSpEnumTokens->GetCount(&count);
if(i>=count) break;
}
return i;
}

void SapiFreeDevices(wchar_t **devices, int size) {
if(devices==NULL) return;
for(int i=0; i<size; ++i) {
if(devices[i]!=0) {
free(devices[i]);
devices[i]=0;
}
}
}

int SapiSetDevice(int num) {
HRESULT hr = S_OK;
if(pVoice == NULL) SapiInit();
if(pVoice==NULL) return 1;
CComPtr<IEnumSpObjectTokens> cpSpEnumTokens;
if(!SUCCEEDED(hr = SpEnumTokens(SPCAT_AUDIOOUT, NULL, NULL, &cpSpEnumTokens))) return 0;
CComPtr<ISpObjectToken> pSpTok;
if(num==-1) {
pVoice->SetOutput(NULL, FALSE);
return 0;
}
ULONG i=0;
while(SUCCEEDED(hr = cpSpEnumTokens->Next(1, &pSpTok, NULL))) {
wchar_t *ch = NULL;
hr = pSpTok->GetStringValue(NULL, &ch);
if(i==num) {
pVoice->SetOutput(pSpTok, TRUE);
return 0;
}
pSpTok.Release(); 
++i;
ULONG count;
cpSpEnumTokens->GetCount(&count);
if(i>=count) break;
}
return 2;
}