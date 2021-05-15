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
#include "dllvorbis.h"
#include <string.h>
#include <windows.h>
#include <algorithm>
#include <time.h>
#include <vorbis/codec.h>
#include <vorbis/vorbisenc.h>
#include <ogg/ogg.h>

typedef struct VorbisRecording {
ogg_stream_state os;
ogg_page og;
ogg_packet op;
vorbis_info vi;
vorbis_comment   vc;
vorbis_dsp_state vd;
vorbis_block     vb;
int samplerate;
int channels;
HANDLE file;
BOOL locked;
BOOL completed;
int output_size;
int output_pos;
char *output;
} VorbisRecording;

void vorbis_write_page(VorbisRecording *vorbis) {
if(vorbis->file!=0) {
DWORD b;
WriteFile(vorbis->file, vorbis->og.header, vorbis->og.header_len, &b, NULL);
WriteFile(vorbis->file, vorbis->og.body, vorbis->og.body_len, &b, NULL);
}
if(vorbis->output!=NULL) {
int reqsize = vorbis->og.header_len+vorbis->og.body_len;
while(vorbis->output_size-vorbis->output_pos < reqsize) {
vorbis->output_size+=1048576;
if(!(vorbis->output = (char*)realloc(vorbis->output, sizeof(char*)*vorbis->output_size))) return;
}
memcpy(vorbis->output+vorbis->output_pos, vorbis->og.header, vorbis->og.header_len);
vorbis->output_pos+=vorbis->og.header_len;
memcpy(vorbis->output+vorbis->output_pos, vorbis->og.body, vorbis->og.body_len);
vorbis->output_pos+=vorbis->og.body_len;
}
}

int VorbisRecorderInit(wchar_t *file, int samplerate, int channels, int bitrate=64000) {
if(bitrate<48000||bitrate>500000) bitrate=64000;
HANDLE hFile=0;
if(file!=NULL) {
hFile = CreateFile(file, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
if(hFile==0) return 0;
}

VorbisRecording *vorbis = (VorbisRecording*)malloc(sizeof(VorbisRecording));
if(vorbis==NULL) return 0;
vorbis->file=hFile;
vorbis->locked=false;
vorbis->completed=false;

vorbis->output_size=0;
vorbis->output_pos=0;
vorbis->output=NULL;

if(file==NULL) {
vorbis->output_size=1048576;
vorbis->output = (char*)malloc(sizeof(char*)*vorbis->output_size);
}

vorbis_info_init(&vorbis->vi);
int ret = (vorbis_encode_setup_managed(&vorbis->vi, channels, samplerate, -1, bitrate, -1) ||
vorbis_encode_ctl(&vorbis->vi, OV_ECTL_RATEMANAGE2_SET, NULL) ||
vorbis_encode_setup_init(&vorbis->vi));
if(ret) {

return 0;
}
vorbis_comment_init(&vorbis->vc);
vorbis_comment_add_tag(&vorbis->vc, "ENCODER", "ELTEN");
vorbis_analysis_init(&vorbis->vd, &vorbis->vi);
vorbis_block_init(&vorbis->vd, &vorbis->vb);

vorbis->samplerate=samplerate;
vorbis->channels=channels;

if(ogg_stream_init(&vorbis->os, rand())==-1)
return 0;

ogg_packet header;
ogg_packet header_comm;
ogg_packet header_code;
vorbis_analysis_headerout(&vorbis->vd, &vorbis->vc, &header, &header_comm, &header_code);
ogg_stream_packetin(&vorbis->os, &header);
ogg_stream_packetin(&vorbis->os, &header_comm);
ogg_stream_packetin(&vorbis->os, &header_code);
do {
ret=ogg_stream_flush(&vorbis->os, &vorbis->og);
if(ret!=0) vorbis_write_page(vorbis);
} while(ret!=0);

vorbis->op.bytes=0;

return (int)vorbis;
}

void vorbis_recording_encode(VorbisRecording *vorbis, float *pcm_buf, int size) {

if(vorbis==NULL) return;

if(vorbis->op.bytes>0)
ogg_stream_packetin (&vorbis->os, &vorbis->op);

while(ogg_stream_pageout(&vorbis->os, &vorbis->og) != 0)
vorbis_write_page(vorbis);

if(size==0)
vorbis_analysis_wrote(&vorbis->vd, 0);
else {

float **buffer=vorbis_analysis_buffer(&vorbis->vd, size/vorbis->channels);

for(int i=0; i<size/vorbis->channels; ++i)
for(int j=0; j<vorbis->channels; ++j)
buffer[j][i]=pcm_buf[i*vorbis->channels+j];

vorbis_analysis_wrote(&vorbis->vd, size/vorbis->channels);
}

while(vorbis_analysis_blockout(&vorbis->vd, &vorbis->vb)==1) {
vorbis_analysis(&vorbis->vb, NULL);
vorbis_bitrate_addblock(&vorbis->vb);
while(vorbis_bitrate_flushpacket(&vorbis->vd, &vorbis->op)) {
ogg_stream_packetin(&vorbis->os, &vorbis->op);
int eos=0;
while(!eos) {
int result=ogg_stream_pageout(&vorbis->os, &vorbis->og);
if(result==0)break;
vorbis_write_page(vorbis);
if(ogg_page_eos(&vorbis->og)) eos=1;
}
}
}
}

void vorbis_recording_complete(VorbisRecording *vorbis) {
if(!vorbis->completed) {
while(vorbis->locked);

vorbis_recording_encode(vorbis, NULL, 0);

ogg_stream_clear (&vorbis->os);
vorbis_block_clear(&vorbis->vb);
vorbis_dsp_clear(&vorbis->vd);
vorbis_comment_clear(&vorbis->vc);
vorbis_info_clear(&vorbis->vi);
vorbis->completed=true;
}
}

int VorbisRecorderGetOutput(int r, char* buf, int size) {
if(r==0) return 0;
VorbisRecording *vorbis = (VorbisRecording*)r;
if(!vorbis->completed) vorbis_recording_complete(vorbis);
if(buf==0) return vorbis->output_pos;
int sz=size;
if(sz<vorbis->output_pos) sz=vorbis->output_pos;
memcpy(buf, vorbis->output, sz);
return sz;
}

void VorbisRecorderClose(int r) {
if(r==0) return;
VorbisRecording *vorbis = (VorbisRecording*)r;
if(!vorbis->completed) vorbis_recording_complete(vorbis);

if(vorbis->file!=0) CloseHandle(vorbis->file);
if(vorbis->output!=NULL) free(vorbis->output);
free(vorbis);
}

BOOL CALLBACK VorbisRecordProc(int handle, const void *buffer, DWORD length, void *user) {
if(user==NULL) return false;
int len = length/4;
VorbisRecording *vorbis = (VorbisRecording*)user;
if(vorbis==NULL) return true;
if(vorbis->completed) return true;
while(vorbis->locked);
vorbis->locked=true;
vorbis_recording_encode(vorbis, (float*)buffer, len);
vorbis->locked=false;
return true;
}