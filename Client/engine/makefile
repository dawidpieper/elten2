CC = gcc
CFLAGS = -g
TARGET = out/elten.exe
SOURCE=src/main.c
DIRS=-Iext/include -Lext/lib
LIB=ext/lib/vcruntime140-ruby260.lib ext/lib/libScreenReaderAPI.a
all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) $(DIRS) $(SOURCE) $(LIB) -o $(TARGET) 

clean:
	$(RM) $(TARGET)