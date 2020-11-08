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
#include "dllwave.h"
#include <string.h>
#include <windows.h>
#include <algorithm>
#include <time.h>

typedef struct WavHeader {
char riff_header[4];
int wav_size;
char wave_header[4];
char fmt_header[4];
int fmt_chunk_size;
short audio_format;
short num_channels;
int sample_rate;
int byte_rate;
short sample_alignment;
short bit_depth;
char data_header[4];
int data_bytes; // Number of bytes in data. Number of samples * num_channels * sample byte size
} WavHeader;

typedef struct WaveRecording {
int channels;
int samplerate;
int size;
HANDLE file;
BOOL locked;
} WaveRecording;

int WaveRecorderInit(wchar_t *file, int samplerate, int channels) {
HANDLE hFile = CreateFile(file, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
if(hFile==0) return 0;

WaveRecording *wave = (WaveRecording*)malloc(sizeof(WaveRecording));
if(wave==NULL) return 0;
wave->file=hFile;
wave->locked=false;
wave->samplerate=samplerate;
wave->channels=channels;
wave->size=0;

char bytes[44];
for(int i=0; i<44; ++i) bytes[i]=0;
DWORD b;
WriteFile(wave->file, bytes, 44, &b, NULL);

return (int)wave;
}

void wave_recording_encode(WaveRecording *wave, short *pcm_buf, int size) {
if(wave==NULL) return;

wave->size+=size*2;

DWORD b;
WriteFile(wave->file, (char*)pcm_buf, size*2, &b, NULL);
}

void WaveRecorderClose(int r) {
if(r==0) return;
WaveRecording *wave = (WaveRecording*)r;
while(wave->locked);

SetFilePointer(wave->file, 0, 0, FILE_BEGIN);

WavHeader wh;
for(int i=0; i<44; ++i) ((char*)&wh)[i]=0;
memcpy(wh.riff_header, "RIFF", 4);
wh.wav_size=wave->size+36;
memcpy(wh.wave_header, "WAVE", 4);
memcpy(wh.fmt_header, "fmt ", 4);
wh.fmt_chunk_size=16;
wh.audio_format=1;
wh.num_channels=wave->channels;
wh.sample_rate=wave->samplerate;
wh.byte_rate=wh.sample_rate*wh.num_channels*2;
wh.sample_alignment = wh.num_channels*2;
wh.bit_depth=16;
memcpy(wh.data_header, "data", 4);
wh.data_bytes = wave->size;

DWORD b;
WriteFile(wave->file, &wh, 44, &b, NULL);

CloseHandle(wave->file);
free(wave);
}

BOOL CALLBACK WaveRecordProc(int handle, const void *buffer, DWORD length, void *user) {
if(user==NULL) return false;
int len = length/2;
WaveRecording *wave = (WaveRecording*)user;
if(wave==NULL) return true;
while(wave->locked);
wave->locked=true;
wave_recording_encode(wave, (short*)buffer, len);
wave->locked=false;
return true;
}