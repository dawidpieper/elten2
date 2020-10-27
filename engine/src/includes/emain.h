#define ELTEN_ENGINE_VERSION 3.0
#include <einit.h>
#include <ewindow.h>
#ifdef __linux__
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdbool.h>
#endif
void MsgBox(char* AlertTitle, char* value, int MessageType);
