#ifndef UNICODE
#define UNICODE
#define _UNICODE
#endif
#include "dllopus.h"
#include <string.h>
#include <windows.h>
#include <algorithm>
#include <time.h>
#include <opus/opus.h>
#include <opus/opus.h>
#include <opus/opus_multistream.h>
#include <ogg/ogg.h>

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