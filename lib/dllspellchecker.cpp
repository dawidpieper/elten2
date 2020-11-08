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
#include "dllspellchecker.h"
#include <string.h>
#include <windows.h>
#include <time.h>
#include <atlbase.h>
#include <spellcheck.h>
#include <string>

int SpellCheck(wchar_t *language, wchar_t *text, SpellCheckResult *results, int size) {
CComPtr<ISpellCheckerFactory> factory;
HRESULT hr;
hr = CoCreateInstance(__uuidof(SpellCheckerFactory), nullptr, CLSCTX_INPROC_SERVER, __uuidof(factory), reinterpret_cast<void **>(&factory));
if(!SUCCEEDED(hr)) return -1;
BOOL supported;
hr = factory->IsSupported(language, &supported);
if(!SUCCEEDED(hr)) return -1;
if(!supported) return -2;
CComPtr<ISpellChecker> checker;
hr = factory->CreateSpellChecker(language, &checker);
if(!SUCCEEDED(hr)) return -1;
CComPtr<IEnumSpellingError> errors;
hr = checker->Check(text, &errors);
CComPtr<ISpellingError> error;
int i=0;
while(errors->Next(&error)==S_OK) {
if(i<size) {
ULONG startIndex=0, length=0;
error->get_StartIndex(&startIndex);
error->get_Length(&length);
results[i].index=(int)startIndex;
results[i].length=(int)length;
CORRECTIVE_ACTION action;
results[i].suggestionsCount=0;
results[i].suggestions=(wchar_t**)malloc(0);
if(SUCCEEDED(error->get_CorrectiveAction(&action))) {
if(action==CORRECTIVE_ACTION_DELETE) {
int index = results[i].suggestionsCount;
if(!(results[i].suggestions=(wchar_t**)realloc(results[i].suggestions, sizeof(wchar_t*)*(index+1)))) return 1;
results[i].suggestions[index]=(wchar_t*)malloc(sizeof(wchar_t)*1);
results[i].suggestions[index][0]=0;
++results[i].suggestionsCount;
}
else if(action==CORRECTIVE_ACTION_REPLACE) {
wchar_t * replacement;
if(SUCCEEDED(error->get_Replacement(&replacement))) {
int index = results[i].suggestionsCount;
if(!(results[i].suggestions=(wchar_t**)realloc(results[i].suggestions, sizeof(wchar_t*)*(index+1)))) return 1;
results[i].suggestions[index]=(wchar_t*)malloc(sizeof(wchar_t)*wcslen(replacement+1));
wcscpy(results[i].suggestions[index], replacement);
++results[i].suggestionsCount;
CoTaskMemFree(replacement);
}
}
else if(action == CORRECTIVE_ACTION_GET_SUGGESTIONS) {
CComPtr<IEnumString> suggestions;
wchar_t *word = (wchar_t*)malloc(sizeof(wchar_t)*(length+1));
wcsncpy(word, text+startIndex, length);
if(SUCCEEDED(checker->Suggest(word, &suggestions))) {
wchar_t *suggestion;
while(suggestions->Next(1, &suggestion, NULL)==S_OK) {
int index = results[i].suggestionsCount;
if(!(results[i].suggestions=(wchar_t**)realloc(results[i].suggestions, sizeof(wchar_t*)*(index+1)))) return 1;
int len = wcslen(suggestion);
results[i].suggestions[index]=(wchar_t*)malloc(sizeof(wchar_t)*(len+1));
wcscpy(results[i].suggestions[index], suggestion);
++results[i].suggestionsCount;
CoTaskMemFree(suggestion);

}
suggestions.Release();
}
free(word);
}
}
}
++i;
}
factory.Release();
return i;
}

void SpellCheckFree(SpellCheckResult* results, int size) {
if(results==0) return;
for(int i=0; i<size; ++i) {
for(int j=0; j<results[i].suggestionsCount; ++j)
free(results[i].suggestions[j]);
}
return;
}

int SpellCheckLanguages(wchar_t **languages, int size) {
CComPtr<ISpellCheckerFactory> factory;
HRESULT hr;
hr = CoCreateInstance(__uuidof(SpellCheckerFactory), nullptr, CLSCTX_INPROC_SERVER, __uuidof(factory), reinterpret_cast<void **>(&factory));
if(!SUCCEEDED(hr)) return -1;
CComPtr<IEnumString> langs;
if(!SUCCEEDED(factory->get_SupportedLanguages(&langs))) return -1;
wchar_t *lang;
int i=0;
while(langs->Next(1, &lang, NULL)==S_OK) {
if(i<size) {
languages[i] = (wchar_t*)malloc(sizeof(wchar_t)*(wcslen(lang)+1));
wcscpy(languages[i], lang);
}
i+=1;
CoTaskMemFree(lang);
}
langs.Release();
factory.Release();
return i;
}

void SpellCheckLanguagesFree(wchar_t **languages, int size) {
for(int i=0; i<size; ++i)
free(languages[i]);
}