#include <windows.h>
#include <stdio.h>
#include <io.h>
#include <conio.h>
#include <fmod.hpp>
#include <fmod_errors.h>

void ERRCHECK(FMOD_RESULT result)
{
    if (result != FMOD_OK)
    {
        printf("FMOD error! (%d) %s\n", result, FMOD_ErrorString(result));
        exit(-1);
    }
}

#if defined(WIN32) || defined(__WATCOMC__) || defined(_WIN32) || defined(__WIN32__)
    #define __PACKED
#else
    #define __PACKED __attribute__((packed))
#endif


void WriteWavHeader(FILE *fp, FMOD::Sound *sound, int length)
{
    int             channels, bits;
    float           rate;

    if (!sound)
    {
        return;
    }

    fseek(fp, 0, SEEK_SET);

    sound->getFormat  (0, 0, &channels, &bits);
    sound->getDefaults(&rate, 0, 0, 0);

    {
        #if defined(WIN32) || defined(_WIN64) || defined(__WATCOMC__) || defined(_WIN32) || defined(__WIN32__)
        #pragma pack(1)
        #endif
        
        typedef struct
        {
	        signed char id[4];
	        int 		size;
        } RiffChunk;
    
        struct
        {
            RiffChunk       chunk           __PACKED;
            unsigned short	wFormatTag      __PACKED;
            unsigned short	nChannels       __PACKED;
            unsigned int	nSamplesPerSec  __PACKED;
            unsigned int	nAvgBytesPerSec __PACKED;
            unsigned short	nBlockAlign     __PACKED;
            unsigned short	wBitsPerSample  __PACKED;
        } FmtChunk  = { {{'f','m','t',' '}, sizeof(FmtChunk) - sizeof(RiffChunk) }, 1, channels, (int)rate, (int)rate * channels * bits / 8, 1 * channels * bits / 8, bits } __PACKED;

        struct
        {
            RiffChunk   chunk;
        } DataChunk = { {{'d','a','t','a'}, length } };

        struct
        {
            RiffChunk   chunk;
	        signed char rifftype[4];
        } WavHeader = { {{'R','I','F','F'}, sizeof(FmtChunk) + sizeof(RiffChunk) + length }, {'W','A','V','E'} };

        #if defined(WIN32) || defined(_WIN64) || defined(__WATCOMC__) || defined(_WIN32) || defined(__WIN32__)
        #pragma pack()
        #endif
      
        fwrite(&WavHeader, sizeof(WavHeader), 1, fp);
        fwrite(&FmtChunk, sizeof(FmtChunk), 1, fp);
        fwrite(&DataChunk, sizeof(DataChunk), 1, fp);
    }
}


int main(int argc, char *argv[])
{
	DeleteFileA("record_stop.tmp");
    FMOD::System          *system  = 0;
    FMOD::Sound           *sound   = 0;
    FMOD_RESULT            result;
    FMOD_CREATESOUNDEXINFO exinfo;
	exinfo.numchannels=2;
    int                    key, recorddriver, numdrivers, count;
    unsigned int           version;    
    FILE                  *fp;
    unsigned int           datalength = 0, soundlength;

    result = FMOD::System_Create(&system);
    ERRCHECK(result);

    result = system->getVersion(&version);
    ERRCHECK(result);

    if (version < FMOD_VERSION)
    {
        printf("Error!  You are using an old version of FMOD %08x.  This program requires %08x\n", version, FMOD_VERSION);
        return 0;
    }

if(argc<2) {
    printf("---------------------------------------------------------\n");    
    printf("Select OUTPUT type\n");    
    printf("---------------------------------------------------------\n");    
    printf("1 :  DirectSound\n");
    printf("2 :  Windows Multimedia WaveOut\n");
    printf("3 :  ASIO\n");
    printf("---------------------------------------------------------\n");
    printf("Press a corresponding number or ESC to quit\n");

    do
    {
        key = _getch();
    } while (key != 27 && key < '1' && key > '5');
    
    switch (key)
    {
        case '1' :  result = system->setOutput(FMOD_OUTPUTTYPE_DSOUND);
                    break;
        case '2' :  result = system->setOutput(FMOD_OUTPUTTYPE_WINMM);
                    break;
        case '3' :  result = system->setOutput(FMOD_OUTPUTTYPE_ASIO);
                    break;
        default  :  return 1; 
    }  
}
else {
	if(argv[1][0] == 49)  result = system->setOutput(FMOD_OUTPUTTYPE_DSOUND);
        if(argv[1][0] == 50)  result = system->setOutput(FMOD_OUTPUTTYPE_WINMM);
        if(argv[1][0] == 51)  result = system->setOutput(FMOD_OUTPUTTYPE_ASIO);
		if((argv[1][0]<49)||(argv[1][0]>51)) {printf("Error: No Driver Specified");return 1;}
}
    ERRCHECK(result);
    

    result = system->getRecordNumDrivers(&numdrivers);
    ERRCHECK(result);

    if(argc<3) {
	printf("---------------------------------------------------------\n");    
    printf("Choose a RECORD driver\n");
    printf("---------------------------------------------------------\n");    
    for (count=0; count < numdrivers; count++)
    {
        char name[256];

        result = system->getRecordDriverInfo(count, name, 256, 0);
        ERRCHECK(result);

        printf("%d : %s\n", count + 1, name);
    }
    printf("---------------------------------------------------------\n");
    printf("Press a corresponding number or ESC to quit\n");

	recorddriver = 0;
    do
    {
        		key = _getch();
        if (key == 27)
        {
            return 0;
        }
        recorddriver = key - '1';
    }
	while (recorddriver < 0 || recorddriver >= numdrivers);
	}
	else {
		recorddriver = argv[2][0]-0x31;
	}

    	if(argc<3) printf("\n");
    result = system->init(32, FMOD_INIT_NORMAL, 0);
    ERRCHECK(result);

    memset(&exinfo, 0, sizeof(FMOD_CREATESOUNDEXINFO));

    exinfo.cbsize           = sizeof(FMOD_CREATESOUNDEXINFO);
    exinfo.numchannels      = 2;
    exinfo.format           = FMOD_SOUND_FORMAT_PCM16;
    exinfo.defaultfrequency = 44100;
    exinfo.length           = exinfo.defaultfrequency * sizeof(short) * exinfo.numchannels * 2;
    
    result = system->createSound(0, FMOD_2D | FMOD_SOFTWARE | FMOD_OPENUSER, &exinfo, &sound);
    ERRCHECK(result);

    printf("========================================================================\n");
    printf("Elten Sound Recorder\n");
    printf("========================================================================\n");
    printf("\n");
    if(argc<3) {
	printf("Press a key to start recording to record.wav\n");
    printf("\n");
	    _getch();
	}

    result = system->recordStart(recorddriver, sound, true);
    ERRCHECK(result);

    if(argc<5) {
	printf("Press 'Esc' to quit\n");
    printf("\n");
	}

	int maxduration=0;
	if(argc>4) {
		maxduration=atoi(argv[4]);
	}

    char * filename = "record.wav";
	if(argc>=3) filename=argv[3];
	fp = fopen(filename, "wb");
    if (!fp)
    {
        printf("ERROR : could not open for writing.\n");
        return 1;
    }

    WriteWavHeader(fp, sound, datalength);

    result = sound->getLength(&soundlength, FMOD_TIMEUNIT_PCM);
    ERRCHECK(result);

	    do
    {
        static unsigned int lastrecordpos = 0;
        unsigned int recordpos = 0;

        if (_kbhit())
        {
            key = _getch();
        }

        system->getRecordPosition(recorddriver, &recordpos);
        ERRCHECK(result);

        if (recordpos != lastrecordpos)        
        {
            void *ptr1, *ptr2;
            int blocklength;
            unsigned int len1, len2;
            
            blocklength = (int)recordpos - (int)lastrecordpos;
            if (blocklength < 0)
            {
                blocklength += soundlength;
            }

            sound->lock(lastrecordpos * exinfo.numchannels * 2, blocklength * exinfo.numchannels * 2, &ptr1, &ptr2, &len1, &len2);

            if (ptr1 && len1)
            {
                datalength += fwrite(ptr1, 1, len1, fp);
            }
            if (ptr2 && len2)
            {
                datalength += fwrite(ptr2, 1, len2, fp);
            }

            sound->unlock(ptr1, ptr2, len1, len2);
        }

        lastrecordpos = recordpos;

        printf("%-23s. Record buffer pos = %6d : Record time = %02d:%02d\r", (timeGetTime() / 500) & 1 ? "Recording" : "", recordpos, datalength / exinfo.defaultfrequency / exinfo.numchannels / 2 / 60, (datalength / exinfo.defaultfrequency / exinfo.numchannels / 2) % 60, filename);

        system->update();

        Sleep(10);

    } while (key != 27&&access("record_stop.tmp", 0)&&(datalength / exinfo.defaultfrequency / exinfo.numchannels / 2<maxduration||maxduration==0));
	DeleteFileA("record_stop.tmp");

    printf("\n");

    WriteWavHeader(fp, sound, datalength);

    fclose(fp);

    result = sound->release();
    ERRCHECK(result);

    result = system->release();
    ERRCHECK(result);

    return 0;
}