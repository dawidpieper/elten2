#include "elten.h"
#ifdef _WIN32
LPSTR wclass = "Elten";
MSG message;
LRESULT CALLBACK m_window_proc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lParam);


void windows_procedure()
{


}
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	int w, h;
	GetScreenResolution(&w, &h);
WNDCLASSEX wc;
	wc.cbSize = sizeof(WNDCLASSEX);
	wc.style = 0;
	wc.lpfnWndProc = m_window_proc;
	wc.cbClsExtra = 0;
	wc.cbWndExtra = 0;
	wc.hInstance = hInstance;
	wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
	wc.hCursor = LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
	wc.lpszMenuName = NULL;
	wc.lpszClassName = wclass;
	wc.hIconSm = LoadIcon(NULL, IDI_APPLICATION);
	if (!RegisterClassEx(&wc))
	{
		MessageBox(NULL, "Komisja odmówiła rejestracji okna", "niestety", MB_ICONEXCLAMATION | MB_OK);
		return 1;
	}
	HWND hwnd;
	hwnd = CreateWindowEx(WS_EX_CLIENTEDGE, wclass, "Elten", WS_TABSTOP | WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, w, h, NULL, NULL, hInstance, NULL);
	if (hwnd == NULL)
	{
		MessageBox(NULL, "Okno odmówiło przyjścia na świat!", "mamy problem", MB_ICONEXCLAMATION);
		return 1;
	}
	ShowWindow(hwnd, nCmdShow);
	UpdateWindow(hwnd);
scr = LoadLibrary("plugins/ScreenReaderAPI");
	if (!scr)
	{
		rbprint("Failed to load plugins/ScreenReaderAPI.dll");
	}
	sayString = (TP)GetProcAddress(scr, "sayStringW");
	sapiIsSpeaking = (ZPI)GetProcAddress(scr, "sapiIsSpeaking");
	sapiIsEnabled = (ZPI)GetProcAddress(scr, "sapiIsEnabled");
	sapiEnable = (OPI)GetProcAddress(scr, "sapiEnable");
	stopspeech = (ZPI)GetProcAddress(scr, "stopSpeech");
	sapiSetRate = (OPI)GetProcAddress(scr, "sapiSetRate");
	sapiGetRate = (ZPI)GetProcAddress(scr, "sapiGetRate");
	sapiSetVolume = (OPI)GetProcAddress(scr, "sapiSetVolume");
	sapiGetVolume = (ZPI)GetProcAddress(scr, "sapiGetVolume");
	sapisetpaused = (OPI)GetProcAddress(scr, "sapiSetPaused");
	sapiIsPaused = (ZPI)GetProcAddress(scr, "sapiIsPaused");
	sapigetnumvoices = (ZPI)GetProcAddress(scr, "sapiGetNumVoices");
	sapisetvoice = (OPI)GetProcAddress(scr, "sapiSetVoice");
	sapigetvoice = (ZPI)GetProcAddress(scr, "sapiGetVoice");
	sapigetvoicename = (COP)GetProcAddress(scr, "sapiGetVoiceNameA");
	getCurrentScreenReader = (ZPI)GetProcAddress(scr, "getCurrentScreenReader");
	setScreenReader = (OPI)GetProcAddress(scr, "setCurrentScreenReader");
	getCurrentScreenReaderName = (CZP)GetProcAddress(scr, "getCurrentScreenReaderNameA");
	getScreenReaderName = (COP)GetProcAddress(scr, "getScreenReaderNameA");
	if (!sayString || !stopspeech || !sapiIsSpeaking || !sapiGetRate || !sapiSetRate || !sapiSetVolume || !sapiGetVolume || !sapisetpaused || !sapiIsPaused || !sapigetnumvoices || !sapisetvoice || !sapigetvoicename || !sapisetvoice || !sapiEnable || !sapiIsEnabled || !getCurrentScreenReader || !setScreenReader || !getCurrentScreenReaderName || !getScreenReaderName)
	{
		rbprint("Failed to load speech functions.");
	}
	sapiEnable(1);
	while (1)
	{
		Sleep(1000);
		speech(L"Inicjalizacja zakończona kompletną inicjalizacją.");
	}
	windows_procedure();
while (GetMessage(&message, NULL, 0, 0))
	{
		TranslateMessage(&message);
		DispatchMessage(&message);
	}
//FreeLibrary(scr);
return message.wParam;
}
LRESULT CALLBACK m_window_proc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lParam)
{
	switch (msg)
	{
	case WM_CLOSE:
		DestroyWindow(hwnd);
				break;
	case WM_DESTROY:
			PostQuitMessage(0);
			break;
		default:
			return DefWindowProc(hwnd, msg, wparam, lParam);
	}
	return 0;
}
#else
void linux_procedure()
{
/*
Tutaj dekompresja silnika eltena dla systemu Linux
W innym przypadku, umieszczając go w funkcji main, program się raczej nie uruchomi
Sprawdzane funkcją rbprint
*/
speech("Elten");
while(1)
{
if(key_pressed(0x09)) break;
}
}
int main(int argc, char** argv)
{
display = XOpenDisplay(NULL);
screen = DefaultScreen(display);
int w, h;
GetScreenResolution(&w, &h);
window = XCreateSimpleWindow(display, RootWindow(display, screen), 10, 10, w, h, 1, BlackPixel(display, screen), WhitePixel(display, screen));
XSelectInput(display, window, KeyPressMask | KeyReleaseMask);
XStoreName(display, window, "Elten");
XMapWindow(display, window);
conn = spd_open("Launch", "main", NULL, SPD_MODE_THREADED);
sem_init(&sem, 0, 0);
conn->callback_end = conn->callback_cancel = eos;
spd_set_notification_on(conn, SPD_END);
spd_set_notification_on(conn, SPD_CANCEL);
char lang[128];
char voicepath[128];
memset(&lang, 0, sizeof(lang));
memset(&voicepath, 0, sizeof(voicepath));
sprintf(voicepath, "/home/%s/.elten/settings/voice.ini", getUser());
ini_gets("settings", "lang", "en", lang, sizearray(lang), voicepath);
setLng(lang);
linux_procedure();
XCloseDisplay(display);
return 0;

}
#endif
