/*
A part of Elten - EltenLink / Elten Network desktop client.
Copyright (C) 2014-2020 Dawid Pieper
Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 
*/

#ifndef _DLLSAPI_H_
#define _DLLSAPI_H_
#include <windows.h>

#define DLLIMPORT __declspec(dllexport)

typedef struct SapiVoice {
wchar_t *id;
wchar_t *name;
wchar_t *language;
wchar_t *age;
wchar_t *gender;
wchar_t *vendor;
} SapiVoice;

extern "C" {
int DLLIMPORT SapiInit(void);
int DLLIMPORT SapiSpeak(wchar_t *text);
int DLLIMPORT SapiListVoices(SapiVoice *, int);
void DLLIMPORT SapiFreeVoices(SapiVoice *, int);
int DLLIMPORT SapiSetVoice(int);
int DLLIMPORT SapiGetVoice(void);
int DLLIMPORT SapiSetRate(int rate);
int DLLIMPORT SapiGetRate(void);
int DLLIMPORT SapiSetVolume(USHORT volume);
USHORT DLLIMPORT SapiGetVolume(void);
BOOL DLLIMPORT SapiIsSpeaking(void);
wchar_t DLLIMPORT *SapiGetVoiceName(void);
int DLLIMPORT SapiSetPaused(BOOL);
BOOL DLLIMPORT SapiIsPaused(void);
int DLLIMPORT SapiStop(void);
int DLLIMPORT SapiSpeakSSML(wchar_t *text);
wchar_t DLLIMPORT *SapiGetBookmark(void);
int DLLIMPORT SapiListDevices(wchar_t **, int);
void DLLIMPORT SapiFreeDevices(wchar_t **, int);
int DLLIMPORT SapiSetDevice(int);
}
#endif