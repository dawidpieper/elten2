CPP      = "c:\program files (x86)\mingw-w64\i686-8.1.0-win32-dwarf-rt_v6-rev0\mingw32\bin\g++.exe"
CC       = gcc.exe
WINDRES  = windres.exe
OBJ      = dllmain.o
LINKOBJ  = dllmain.o
LIBS     = -lwsock32 -lws2_32 -L"C:/OpenSSL-Win32/lib/MinGW" -lcrypto-1_1 -lssl-1_1 -m32
INCS     = -I"C:/Program Files (x86)/mingw-w64/i686-8.1.0-win32-dwarf-rt_v6-rev0/mingw32/include" -I"C:/Program Files (x86)/mingw-w64/i686-8.1.0-win32-dwarf-rt_v6-rev0/mingw32/i686-w64-mingw32/include" -I"C:/mingw-w64/x86_64-8.1.0-win32-seh-rt_v6-rev0/mingw32/lib/gcc/i686-w64-mingw32/8.1.0/include" -I"C:/OpenSSL-Win32/include"
CXXINCS     = -I"C:/Program Files (x86)/mingw-w64/i686-8.1.0-win32-dwarf-rt_v6-rev0/mingw32/include" -I"C:/Program Files (x86)/mingw-w64/i686-8.1.0-win32-dwarf-rt_v6-rev0/mingw32/i686-w64-mingw32/include" -I"C:/mingw-w64/x86_64-8.1.0-win32-seh-rt_v6-rev0/mingw32/lib/gcc/i686-w64-mingw32/8.1.0/include" -I"C:/mingw-w64/x86_64-8.1.0-win32-seh-rt_v6-rev0/mingw32/lib/gcc/i686-w64-mingw32/8.1.0/include/c++" -I"C:/OpenSSL-Win32/include"
BIN      = elten.dll
CXXFLAGS = $(CXXINCS) -m32 -DBUILDING_DLL=1
CFLAGS   = $(INCS) -m32 -DBUILDING_DLL=1
RM       = rm.exe -f
DEF      = libelten.def
STATIC   = libelten.a

.PHONY: all all-before all-after clean clean-custom

all: all-before $(BIN) all-after

clean: clean-custom
	${RM} $(OBJ) $(BIN) $(DEF) $(STATIC)

$(BIN): $(LINKOBJ)
	$(CPP) -shared $(LINKOBJ) -o $(BIN) $(LIBS) -Wl,--output-def,$(DEF),--out-implib,$(STATIC),--add-stdcall-alias

dllmain.o: dllmain.cpp
	$(CPP) -c dllmain.cpp -o dllmain.o $(CXXFLAGS)
