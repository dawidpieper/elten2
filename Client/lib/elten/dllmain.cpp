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
#include <shlobj.h>
#include <process.h>
#include <time.h>
#include <opus/opus.h>
#include <opus/opus_multistream.h>
#include <ogg/ogg.h>
#include <vorbis/codec.h>
#include <vorbis/vorbisenc.h>

HWND ewnd=0, hwnd;
int autostart=0;

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
	switch(fdwReason) {
case DLL_PROCESS_ATTACH:
srand((unsigned int)time(NULL));
break;
case DLL_PROCESS_DETACH:
if(hwnd!=0) hideTray();
break;
case DLL_THREAD_ATTACH:
break;
case DLL_THREAD_DETACH:
break;
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
if(wParam==VK_F2) {
if(lParam&(1<<31))
keys[VK_F2]|=2;
else
keys[VK_F2]|=1;
return 1;
}
if(wParam==VK_F12) {
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

int GetShaFile(wchar_t *file, char digest[SHA_DIGEST_LENGTH]) {
HANDLE f = CreateFile((LPCWSTR)file, GENERIC_READ, FILE_SHARE_DELETE|FILE_SHARE_WRITE|FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
if(f==INVALID_HANDLE_VALUE) return NULL;
int sz = GetFileSize(f,NULL);
if(sz==0xFFFFFFFF||sz==0) {
CloseHandle(f);
	return NULL;
}
LPSTR b = (LPSTR) GlobalAlloc(GPTR, sz+1);
DWORD read;
if(!ReadFile(f, b, sz, &read, NULL)) {
	CloseHandle(f);
	return NULL;
}
CloseHandle(f);
b[sz]=0;
SHA1((unsigned char*)b, read, (unsigned char*)digest);
GlobalFree(b);
return 1;
}

int CryptMessage(LPSTR msg, LPSTR buf, int size) {
wchar_t file[MAX_PATH];
GetModuleFileName(NULL,(LPWSTR)file,MAX_PATH);
char digest[SHA_DIGEST_LENGTH];
GetShaFile(file,digest);
if(msg==NULL) {
memcpy(buf,digest,size);
return SHA_DIGEST_LENGTH;
}
if(strncmp(digest,SHA_SIG4,SHA_DIGEST_LENGTH)!=0 && strncmp(digest,SHA_SIG3,SHA_DIGEST_LENGTH)!=0 && strncmp(digest,SHA_SIG2,SHA_DIGEST_LENGTH)!=0 && strncmp(digest,SHA_SIG1,SHA_DIGEST_LENGTH)!=0) return 0;
wchar_t inifile[MAX_PATH];
int lbs=0;
for(int i=0; i<MAX_PATH; ++i)
if(file[i]=='\\') lbs=i+1;
else if(file[i]==NULL) break;
wcsncpy_s(inifile,MAX_PATH,file,lbs);
inifile[lbs]=0;
wcscat_s(inifile,MAX_PATH,L"elten.ini");
inifile[lbs+14]=0;
wchar_t db[MAX_PATH];
GetPrivateProfileString(L"Elten",L"DB",L"",db,MAX_PATH,inifile);
if(wcscmp(db,L"Data/elten.edb")!=0) return 0;
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
LPSTR b=(LPSTR) GlobalAlloc(GPTR,strlen(msg));
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

bool Exist(const wchar_t *file) {
HANDLE hFile = CreateFile(file,GENERIC_READ,FILE_SHARE_READ, NULL, OPEN_EXISTING,0,NULL);
if (hFile == INVALID_HANDLE_VALUE)
return false;
CloseHandle(hFile);
return true;
 }

void showElten(void) {
if((autostart==0) && (ewnd!=0)) {
ShowWindow(ewnd,5);
SetForegroundWindow(ewnd);
SetActiveWindow(ewnd);
SetFocus(ewnd);
ShowWindow(ewnd,3);
} else {
wchar_t startdir[MAX_PATH];
wchar_t szFile[MAX_PATH];
#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable : 4996)
#endif
if(Exist(L"elten.exe")) {
wcscpy(szFile,L"elten.exe /silentstart");
wcscpy(startdir,L".");
} else if(Exist(L"..\\elten.exe")) {
wcscpy(szFile,L"..\\elten.exe /silentstart");
wcscpy(startdir,L"..");
} else
return;
#ifdef _MSC_VER
#pragma warning(pop)
#endif
STARTUPINFO si;
    PROCESS_INFORMATION pi;
    ZeroMemory( &si, sizeof(si) );
    si.cb = sizeof(si);
    ZeroMemory( &pi, sizeof(pi) );
if( !CreateProcess( NULL, szFile, NULL, NULL, FALSE, 0, NULL, startdir, &si, &pi)) MessageBeep(0);
else if(autostart==1) hideTray();
}
}

LRESULT CALLBACK TrayWndProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam) {
switch(Message) {
case WM_HOTKEY:
if(wParam == 0x8003)
showElten();
case 0x8002:
if( lParam == WM_LBUTTONDOWN )
showElten();
break;
case WM_DESTROY:
hideTray();
break;
default:
return DefWindowProc(hwnd, Message, wParam, lParam);
}
return 0;
}

void TrayProcessor() {
MSG Msg;
if(GetMessage(&Msg, NULL, 0, 0) > 0) {
TranslateMessage(&Msg);
DispatchMessage(&Msg);
}
}

void __cdecl ThreadWindowProc(void *Args) {
WNDCLASSEX wc;
memset(&wc,0,sizeof(wc));
wc.cbSize		 = sizeof(WNDCLASSEX);
wc.lpfnWndProc	 = TrayWndProc;
wc.hInstance	 = GetModuleHandle(NULL);
wc.hCursor		 = LoadCursor(NULL, IDC_ARROW);
wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
wc.lpszClassName = L"EltenTray";
wc.hIcon		 = LoadIcon(NULL, IDI_APPLICATION);
wc.hIconSm		 = LoadIcon(NULL, IDI_APPLICATION);
if(!RegisterClassEx(&wc)) return;
hwnd = CreateWindowEx(0, L"EltenTray", L"EltenTray", 0 , CW_USEDEFAULT, CW_USEDEFAULT, 0, 0, NULL, NULL, GetModuleHandle(NULL), NULL);
if(hwnd==NULL) return;
NOTIFYICONDATA nid;
nid.cbSize = sizeof( NOTIFYICONDATA );
nid.hWnd = hwnd;
nid.uID = 0x8001;
nid.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP;
nid.uCallbackMessage = 0x8002;
nid.hIcon = LoadIcon( NULL, IDI_APPLICATION );
#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable : 4996)
#endif
wcscpy(nid.szTip, L"ELTEN");
#ifdef _MSC_VER
#pragma warning(pop)
#endif
BOOL r = Shell_NotifyIcon( NIM_ADD, & nid );
if(!r) return;
RegisterHotKey(hwnd, 0x8003, MOD_ALT|MOD_CONTROL|MOD_SHIFT, 'T');
MSG Msg;
while(GetMessage(&Msg, hwnd, 0, 0)) {
TranslateMessage(&Msg);
DispatchMessage(&Msg);
if(hwnd==0) break;
}
}

int showTray(HWND window) {
if(hwnd!=0) return -1;
ewnd = window;
if(window==0) autostart=1;
HANDLE hThread =(HANDLE) _beginthread(ThreadWindowProc, 0, 0);
return 0;
}

void hideTray() {
NOTIFYICONDATA nid;
nid.cbSize = sizeof( NOTIFYICONDATA );
nid.hWnd = hwnd;
nid.uID = 0x8001;
nid.uFlags = 0;
Shell_NotifyIcon( NIM_DELETE, & nid );
UnregisterHotKey(hwnd, 0x8003);
DestroyWindow(hwnd);
hwnd=0;
}

typedef struct OpusHeader {
int version;
int channel_count;
int preskip;
ogg_uint32_t input_samplerate;
int output_gain;
int mapping_family;
int stream_count;
int coupled_count;
unsigned char mapping[255];
} OpusHeader;

typedef struct OpusRecording {
ogg_stream_state os;
ogg_page og;
ogg_packet op;
OpusEncoder *encoder;
OpusHeader *header;
unsigned char header_data[1024];
unsigned char *tags;
int tags_size;
int header_size;
int packetno;
ogg_int64_t granulepos;
int last_bitrate;
int bitrate;
unsigned char *buffer;
HANDLE file;
int framesize;
short pcm_buf[16777216];
int pcm_pos;
BOOL locked;
} OpusRecording;

typedef struct OpusPacket {
unsigned char *data;
int size;
int pos;
} OpusPacket;

int opus_recording_write_uint32(OpusPacket *p, ogg_uint32_t val) {
if (p->pos>p->size-4) return 0;
p->data[p->pos ] = (val ) & 0xFF;
p->data[p->pos+1] = (val>> 8) & 0xFF;
p->data[p->pos+2] = (val>>16) & 0xFF;
p->data[p->pos+3] = (val>>24) & 0xFF;
p->pos += 4;
return 1;
}

int opus_recording_write_uint16(OpusPacket *p, ogg_uint16_t val) {
if (p->pos>p->size-2) return 0;
p->data[p->pos ] = (val ) & 0xFF;
p->data[p->pos+1] = (val>> 8) & 0xFF;
p->pos += 2;
return 1;
}

int opus_recording_write_chars(OpusPacket *p, const unsigned char *str, int nb_chars) {
if (p->pos>p->size-nb_chars) return 0;
for (int i=0;i<nb_chars;++i)
p->data[p->pos++] = str[i];
return 1;
}

OpusPacket opus_fill_header(const OpusHeader *h, unsigned char *packet, int len) {
OpusPacket op;
op.data=packet;
op.size=len;
op.pos=0;
if (len<19)return op;

if (!opus_recording_write_chars(&op, (const unsigned char*)"OpusHead", 8)) return op;
unsigned char ch = 1;
if (!opus_recording_write_chars(&op, &ch, 1)) return op;

ch = h->channel_count;
if (!opus_recording_write_chars(&op, &ch, 1)) return op;
if (!opus_recording_write_uint16(&op, h->preskip)) return op;
if (!opus_recording_write_uint32(&op, h->input_samplerate)) return op;
if (!opus_recording_write_uint16(&op, h->output_gain)) return op;

ch = h->mapping_family;
if (!opus_recording_write_chars(&op, &ch, 1)) return op;

if (h->mapping_family != 0) {
ch = h->stream_count;
if (!opus_recording_write_chars(&op, &ch, 1)) return op;

ch = h->coupled_count;
if (!opus_recording_write_chars(&op, &ch, 1)) return op;

if (!opus_recording_write_chars(&op, h->mapping, h->channel_count)) return op;
}

op.size=op.pos;
op.pos=0;
return op;
}

OpusPacket opus_fill_tags() {
const char *encinfo = "ENCODER=ELTEN";
int sz = 8 + 4 + strlen(opus_get_version_string()) + 4 + 4 + strlen(encinfo);
OpusPacket op;
op.size=0;
op.data=(unsigned char*)malloc(sizeof(char)*sz);
if(op.data==NULL) return op;
op.size=sz;
op.pos=0;

if (!opus_recording_write_chars(&op, (const unsigned char*)"OpusTags", 8)) return op;

int sl = strlen(opus_get_version_string());
if (!opus_recording_write_uint32(&op, sl)) return op;
if(!opus_recording_write_chars(&op, (const unsigned char*)opus_get_version_string(), sl)) return op;

if(!opus_recording_write_uint32(&op, 1)) return op;

sl = strlen(encinfo);
if (!opus_recording_write_uint32(&op, sl)) return op;
if(!opus_recording_write_chars(&op, (const unsigned char*)encinfo, sl)) return op;

op.size=op.pos;
op.pos=0;
return op;
}

int OpusRecorderInit(wchar_t *file, int samplerate, int channels, int bitrate=64000, float framesize=60, int application=OPUS_APPLICATION_AUDIO, BOOL useVBR=true) {
if(framesize!=2.5 && framesize!=5 && framesize!=10 && framesize!=20 && framesize!=40 && framesize!=60 && framesize!=80 && framesize!=100 && framesize!=120) framesize=60;
if(bitrate<4000 || bitrate>524000) bitrate=64000;
if(application<2048 || application>2050) application=2048;

HANDLE hFile = CreateFile(file, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
if(hFile==0) return 0;

OpusRecording *opus = (OpusRecording*)malloc(sizeof(OpusRecording));
if(opus==NULL) return 0;
opus->file=hFile;
opus->header = (OpusHeader *)malloc(sizeof(OpusHeader));
if(opus->header==NULL) return 0;
opus->buffer = (unsigned char *)malloc(16384);
if(opus->buffer==NULL) return 0;

opus->framesize = (int)(framesize * samplerate / 1000.0f);
opus->locked=false;

if(ogg_stream_init(&opus->os, rand())==-1)
return 0;
opus->header->version = 1;
opus->header->channel_count = channels;
opus->header->preskip = 0;
opus->header->input_samplerate = samplerate;
opus->header->output_gain = 0;
opus->header->mapping_family = 0;
opus->header->stream_count = 1;
opus->header->coupled_count = 0;
opus->bitrate=bitrate;

int err;
opus->encoder = opus_encoder_create(samplerate, channels, application, &err);
if(err!=OPUS_OK) return 0;
int ret = opus_encoder_ctl (opus->encoder, OPUS_SET_BITRATE(bitrate));
if(ret!=OPUS_OK) return 0;
opus_encoder_ctl (opus->encoder, OPUS_SET_VBR(useVBR));

opus->packetno = 0;
opus->granulepos = 0;
opus->pcm_pos=0;

opus->last_bitrate = opus->bitrate;
opus_encoder_ctl (opus->encoder, OPUS_GET_LOOKAHEAD (&opus->header->preskip));

OpusPacket opp = opus_fill_header (opus->header, opus->header_data, 1024);;
ogg_packet op;
op.bytes=opp.size;
op.b_o_s = 1;
op.e_o_s = 0;
op.packet = opp.data;
op.granulepos = 0;
op.packetno = opus->packetno++;
opus->header_size = opp.size;
ogg_stream_packetin (&opus->os, &op);

opp = opus_fill_tags();
op.bytes=opp.size;
op.b_o_s = 0;
op.e_o_s = 0;
op.packet = opp.data;
op.granulepos = 0;
op.packetno = opus->packetno++;
opus->tags=opp.data;
opus->tags_size = opp.size;
ogg_stream_packetin (&opus->os, &op);

return (int)opus;
}

void opus_write_page(OpusRecording *opus) {
DWORD b;
WriteFile(opus->file, opus->og.header, opus->og.header_len, &b, NULL);
WriteFile(opus->file, opus->og.body, opus->og.body_len, &b, NULL);
}

void opus_recording_encode(OpusRecording *opus, short *pcm_buf) {
if(opus==NULL || opus->encoder == NULL) return;

if(opus->op.bytes>0)
ogg_stream_packetin (&opus->os, &opus->op);

while(ogg_stream_pageout(&opus->os, &opus->og) != 0)
opus_write_page(opus);

if (opus->last_bitrate != opus->bitrate) {
opus_encoder_ctl (opus->encoder, OPUS_SET_BITRATE(opus->bitrate));
opus->last_bitrate = opus->bitrate;
}

int ret = opus_encode(opus->encoder, pcm_buf, opus->framesize, opus->buffer, 16384);
if(ret<=0)  return;

ogg_packet op;
op.b_o_s = 0;
op.e_o_s = 0;
opus->granulepos += opus->framesize;
op.granulepos = opus->granulepos;
op.packetno = opus->packetno++;
op.packet = opus->buffer;
op.bytes = ret;
opus->op=op;
}

void OpusRecorderClose(int r) {
if(r==0) return;
OpusRecording *opus = (OpusRecording*)r;
while(opus->locked);

ogg_packet op = opus->op;
op.e_o_s=1;
ogg_stream_packetin (&opus->os, &op);
while(ogg_stream_pageout(&opus->os, &opus->og) != 0)
opus_write_page(opus);

ogg_stream_clear (&opus->os);
opus_encoder_destroy (opus->encoder);

free(opus->header);
free(opus->tags);
free(opus->buffer);
free(opus->pcm_buf);

CloseHandle(opus->file);
free(opus);
}

BOOL CALLBACK OpusRecordProc(int handle, const void *buffer, DWORD length, void *user) {
if(length>2097152) return 1;
if(user==NULL) return false;
int len = length/2;
OpusRecording *opus = (OpusRecording*)user;
if(opus==NULL) return true;
while(opus->locked);
opus->locked=true;
memcpy(&opus->pcm_buf[opus->pcm_pos], buffer, length);
opus->pcm_pos+=len;
int bsize = opus->header->channel_count * opus->framesize;
while(opus->pcm_pos>=bsize) {
opus_recording_encode(opus, (short*)opus->pcm_buf);
opus->pcm_pos-=bsize;
//for(int i=0; i<opus->pcm_pos; ++i)
//opus->pcm_buf[i] = opus->pcm_buf[bsize+i];
memcpy(opus->pcm_buf, &opus->pcm_buf[bsize], opus->pcm_pos*2);
}
opus->locked=false;
return true;
}

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
} VorbisRecording;

void vorbis_write_page(VorbisRecording *vorbis) {
DWORD b;
WriteFile(vorbis->file, vorbis->og.header, vorbis->og.header_len, &b, NULL);
WriteFile(vorbis->file, vorbis->og.body, vorbis->og.body_len, &b, NULL);
}

int VorbisRecorderInit(wchar_t *file, int samplerate, int channels, int bitrate=64000) {
if(bitrate<48000||bitrate>500000) bitrate=64000;
HANDLE hFile = CreateFile(file, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
if(hFile==0) return 0;

VorbisRecording *vorbis = (VorbisRecording*)malloc(sizeof(VorbisRecording));
if(vorbis==NULL) return 0;
vorbis->file=hFile;
vorbis->locked=false;

vorbis_info_init(&vorbis->vi);
int ret = (vorbis_encode_setup_managed(&vorbis->vi, channels, samplerate, -1, bitrate, -1)||
vorbis_encode_ctl(&vorbis->vi, OV_ECTL_RATEMANAGE2_SET, NULL) ||
vorbis_encode_setup_init(&vorbis->vi));
if(ret) return 0;
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

void VorbisRecorderClose(int r) {
if(r==0) return;
VorbisRecording *vorbis = (VorbisRecording*)r;
while(vorbis->locked);

vorbis_recording_encode(vorbis, NULL, 0);

ogg_stream_clear (&vorbis->os);
vorbis_block_clear(&vorbis->vb);
vorbis_dsp_clear(&vorbis->vd);
vorbis_comment_clear(&vorbis->vc);
vorbis_info_clear(&vorbis->vi);

CloseHandle(vorbis->file);
free(vorbis);
}

BOOL CALLBACK VorbisRecordProc(int handle, const void *buffer, DWORD length, void *user) {
if(user==NULL) return false;
int len = length/4;
VorbisRecording *vorbis = (VorbisRecording*)user;
if(vorbis==NULL) return true;
while(vorbis->locked);
vorbis->locked=true;
vorbis_recording_encode(vorbis, (float*)buffer, len);
vorbis->locked=false;
return true;
}

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