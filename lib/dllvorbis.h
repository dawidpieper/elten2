/*
A part of Elten - EltenLink / Elten Network desktop client.
Copyright (C) 2014-2020 Dawid Pieper
Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 
*/

#ifndef _DLLVORBIS_H_
#define _DLLVORBIS_H_
#include <windows.h>

#define DLLIMPORT __declspec(dllexport)

extern "C" {
BOOL DLLIMPORT CALLBACK VorbisRecordProc(int handle, const void *buffer, DWORD length, void *user);
int DLLIMPORT VorbisRecorderInit(wchar_t*, int, int, int);
void DLLIMPORT VorbisRecorderClose(int);
int DLLIMPORT VorbisRecorderGetOutput(int, char*, int);
}
#endif