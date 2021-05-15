/*
A part of Elten - EltenLink / Elten Network desktop client.
Copyright (C) 2014-2021 Dawid Pieper
Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 
*/

#ifndef _DLLCOMMONDIALOGS_H_
#define _DLLCOMMONDIALOGS_H_
#include <windows.h>

#define DLLIMPORT __declspec(dllexport)

extern "C" {
int DLLIMPORT showMessager(wchar_t *label, wchar_t *recipientFieldLabel, wchar_t *subjectFieldLabel, wchar_t *textFieldLabel, wchar_t *sendButtonLabel, wchar_t *cancelButtonLabel, wchar_t *recipientFieldValue, wchar_t *subjectFieldValue, wchar_t *textFieldValue);
void DLLIMPORT hideMessager();
int DLLIMPORT getMessager(wchar_t *recipientValue, int recipientValueSize, wchar_t *subjectValue, int subjectValueSize, wchar_t *textValue, int textValueSize);
int DLLIMPORT showWriter(wchar_t *label, wchar_t *textFieldLabel, wchar_t *sendButtonLabel, wchar_t *cancelButtonLabel, wchar_t *textFieldValue, int textFieldSize);
void DLLIMPORT hideWriter();
int DLLIMPORT getWriter(wchar_t *textValue, int textValueSize);
int DLLIMPORT showFileOpen(wchar_t *label, wchar_t *filter, int filterSize);
void DLLIMPORT hideFileOpen();
int DLLIMPORT getFileOpen(wchar_t *, int);
}
#endif