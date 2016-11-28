CC = gcc
CXX = g++
CCFLAGS = -O2  -pthread
CXXFLAGS = -O2 -std=c++11
LIBS = -lc -lX11 -lspeechd -lpthread 
OBJ =\
elten.o \
minIni.o \
main.o
all: main
clean:
	rm -f *.o
.cpp.o:
	$(CXX) -c $(CXXFLAGS) $<
.c.o:
	$(CC) -c $(CCFLAGS) $<
main: $(OBJ)
	$(CC) $(OBJ) $(LIBS) -o launch
