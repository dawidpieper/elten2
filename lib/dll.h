/*
A part of Elten - EltenLink / Elten Network desktop client.
Copyright (C) 2014-2021 Dawid Pieper
Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 
*/

#ifndef _DLL_H_
#define _DLL_H_


#define DLLIMPORT __declspec(dllexport)

extern "C" {
LRESULT DLLIMPORT CALLBACK messageHandling(int nCode, WPARAM wParam, LPARAM lParam);
LRESULT DLLIMPORT CALLBACK keyFiltering(int nCode, WPARAM wParam, LPARAM lParam);
int DLLIMPORT hook(void);
int DLLIMPORT getkeys(char *);
char DLLIMPORT setkey(char, char);
HINSTANCE DLLIMPORT GetInstance(void);
int DLLIMPORT CryptMessage(LPSTR msg, LPSTR buf, int size);
LPSTR DLLIMPORT GetShaFile(char *file);
int DLLIMPORT GetSha1(wchar_t *str, int size, char digest[SHA_DIGEST_LENGTH]);
int DLLIMPORT GetSha256(wchar_t *str, int size, unsigned char digest[SHA256_DIGEST_LENGTH]);
int DLLIMPORT GetSha512(wchar_t *str, int size, unsigned char digest[SHA512_DIGEST_LENGTH]);
void DLLIMPORT S16LEToF32LE(short*, int, float*);
void DLLIMPORT F32LEToS16LE(float*, int, short*);
}

#endif
