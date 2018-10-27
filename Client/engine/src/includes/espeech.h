#ifndef ELTEN_API_SPEECH
#define ELTEN_API_SPEECH
#include <einit.h>
#ifdef __linux__
#include <speech-dispatcher/libspeechd.h>
#include <semaphore.h>
SPDConnection *sp;
sem_t sem;
void eos(size_t msgid, size_t cid, SPDNotificationType t);
#endif
void EAPISpeech_INIT(VALUE m);
#endif