[Setup]
AppId={{9FE2B24B-49F4-4D0B-A36B-31F267F9B114}
AppName=ELTEN
AppVersion=2.3.6
AppVerName=Elten 2.3.6
AppPublisher=Dawid Pieper
AppPublisherURL=https://elten-net.eu
AppSupportURL=https://elten-net.eu/
AppUpdatesURL=https://elten-net.eu/download
DefaultDirName={pf}\ELTEN
DefaultGroupName=ELTEN
AllowNoIcons=yes
OutputDir=C:\Users\dawid\Documents\rpgxp\elten\installer
OutputBaseFilename=elten_setup
Compression=lzma2/max
SolidCompression=yes
RestartIfNeededByRun=no
PrivilegesRequiredOverridesAllowed=commandline dialog

#define Use_UninsHs_Default_CustomMessages

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"; LicenseFile: "elten\license_en.txt"
Name: "pl"; MessagesFile: "compiler:Languages\Polish.isl"; LicenseFile: "elten\license_pl.txt"
Name: "de"; MessagesFile: "compiler:Languages\German.isl"; LicenseFile: "elten\license_de.txt"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";
Name: "ext_update"; Description: "{cm:EltenUpdate}"; GroupDescription: "{cm:EltenUpdate}";
Name: "ext_vc"; Description: "{cm:VCInstall}"; GroupDescription: "{cm:VCInstall}";

[Files]
Source: "elten\eltenc\*"; DestDir: "{app}"; Flags: "ignoreversion createallsubdirs recursesubdirs"
Source: "{tmp}\elten.7z"; DestDir: "{app}"; Tasks: ext_update; \
  Flags: external; Check: DwinsHs_Check(ExpandConstant('{tmp}\elten.7z'), \
    'http://elten-net.eu/bin/download/elten.7z', 'INSTELTEN', 'get', 0, 0) 
Source: "7za.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall;
Source: "elten/vcredist_x86.exe"; Tasks: ext_vc; DestDir: {tmp}; Flags: deleteafterinstall

[Icons]
Name: "{group}\ELTEN"; Filename: "{app}\elten.exe"
Name: "{group}\{cm:ProgramOnTheWeb,ELTEN}"; Filename: "https://elten-net.eu"
Name: "{group}\{cm:UninstallProgram,ELTEN}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\ELTEN"; Filename: "{app}\elten.exe"; Tasks: desktopicon

[Run]
Filename: "{tmp}\7za.exe"; Parameters: "x {userappdata}\elten\bin\elten.7z -oelten -y"; WorkingDir: "{userappdata}\elten\bin"; StatusMsg: "{cm:extractingelten}"; Flags: runhidden; tasks: ext_update
Filename: {tmp}\vcredist_x86.exe; Parameters: "/passive /norestart "; Tasks: ext_vc; StatusMsg: "Installing VC++ 2008 Redistributables..."
Filename: "{app}\elten.exe"; Description: "{cm:LaunchProgram,{#StringChange("ELTEN", '&', '&&')}}"; Flags: nowait postinstall

[INI]
Filename: "{userappdata}\elten\elten.ini"; Section: "Interface"; Key: "Language"; String: "en_GB"; Languages: en
Filename: "{userappdata}\elten\elten.ini"; Section: "Interface"; Key: "Language"; String: "de_DE"; Languages: de

[Code]

#IFDEF UNICODE
  #DEFINE AW "W"
#ELSE
  #DEFINE AW "A"
#ENDIF
type
  INSTALLSTATE = Longint;
const
  INSTALLSTATE_INVALIDARG = -2;  { An invalid parameter was passed to the function. }
  INSTALLSTATE_UNKNOWN = -1;     { The product is neither advertised or installed. }
  INSTALLSTATE_ADVERTISED = 1;   { The product is advertised but not installed. }
  INSTALLSTATE_ABSENT = 2;       { The product is installed for a different user. }
  INSTALLSTATE_DEFAULT = 5;      { The product is installed for the current user. }

  VC_2008 = '{AA783A14-A7A3-3D33-95F0-9A351D530011}';
  VC_2008_5677 = '{DE2C306F-A067-38EF-B86C-03DE4B0312F9}';
  VC_2008_SP1 = '{9a25302d-30c0-39d9-bd6f-21e6ec160475}';


function MsiQueryProductState(szProduct: string): INSTALLSTATE; 
  external 'MsiQueryProductState{#AW}@msi.dll stdcall';

function VCVersionInstalled(const ProductID: string): Boolean;
begin
  Result := MsiQueryProductState(ProductID) = INSTALLSTATE_DEFAULT;
end;

function VCRedistNeedsInstall: Boolean;
begin
  Result := not (VCVersionInstalled(VC_2008) and VCVersionInstalled(VC_2008_SP1) and VCVersionInstalled(VC_2008_5677));
end;

#define DwinsHs_Use_Predefined_Downloading_WizardPage
#define DwinsHs_Auto_Continue
#include "dwinshs.iss"

procedure InitializeWizard();
begin
  DwinsHs_InitializeWizard(wpPreparing);
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  DwinsHs_CurPageChanged(CurPageID, nil, nil);
end;

function ShouldSkipPage(CurPageId: Integer): Boolean;
begin
  Result := False;
  DwinsHs_ShouldSkipPage(CurPageId, Result);
end;

function BackButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  DwinsHs_BackButtonClick(CurPageID);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  DwinsHs_NextButtonClick(CurPageID, Result);
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  DwinsHs_CancelButtonClick(CurPageID, Cancel, Confirm);
end;

[CustomMessages]
pl.DwinsHs_PageCaption =Pobieranie aktualizacji
en.DwinsHs_PageCaption =Downloading the update
de.DwinsHs_PageCaption =Das Update herunterladen
pl.DwinsHs_PageDescription =Proszê czekaæ, trwa konfigurowanie programu Elten...  Instalator pobiera dodatkowe pliki...
en.DwinsHs_PageDescription =Please wait while Elten is being preconfigured ... The installer is downloading additional files ...
de.DwinsHs_PageDescription =Bitte warten Sie, während der Elten vorkonfiguriert ist ... Der Installer lädt weitere Dateien ...
pl.DwinsHs_TotalProgress =Postêp:
pl.DwinsHs_CurrentFile =Bierz¹cy plik:
pl.DwinsHs_File =Plik:
pl.DwinsHs_Speed =Szybkoœæ:
pl.DwinsHs_Status =Status:
pl.DwinsHs_ElapsedTime =Minê³o:
pl.DwinsHs_RemainingTime =Pozosta³o:
pl.DwinsHs_Status_ButtonRetry =Spróbuj &ponownie
pl.DwinsHs_Status_ButtonNext =&Dalej >
pl.DwinsHs_SizeInBytes =%d B
pl.DwinsHs_SizeInKB =%.2f KB
pl.DwinsHs_SizeInMB =%.2f MB
pl.DwinsHs_ProgressValue = %s z %s (%d%%%)
pl.DwinsHs_SpeedInBytes =%d B/s
pl.DwinsHs_SpeedInKB =%.2f KB/s
pl.DwinsHs_SpeedInMB =%.2f MB/s
pl.DwinsHs_TimeInHour =%d godzin, %d minut, %d sekund
pl.DwinsHs_TimeInMinute =%d minut, %d sekund
pl.DwinsHs_TimeInSecond =%d sekund
pl.DwinsHs_Status_GetFileInformation =Okreœlam rozmiar pliku
pl.DwinsHs_Status_StartingDownload =Rozpoczynam pobieranie
pl.DwinsHs_Status_Downloading =Pobieranie
pl.DwinsHs_Status_DownlaodComplete =Pobieranie zakoñczone
pl.DwinsHs_Error_Network =Brak po³¹czenia z Internetem
pl.DwinsHs_Error_Offline =Komputer znajduje siê w trybie offline
pl.DwinsHs_Error_Initialize =B³¹d inicjalizacji konfiguracji
pl.DwinsHs_Error_OpenSession =Nie uda³o siê otworzyæ sesji HTTP
pl.DwinsHs_Error_CreateRequest =B³¹d http
pl.DwinsHs_Error_SendRequest =Nie uda³o siê wys³aæ rz¹dania do serwera HTTP
pl.DwinsHs_Error_DeleteFile =Stary plik nie mo¿e byæ usuniêty
pl.DwinsHs_Error_SaveFile =Nie mo¿na zapisaæ danych
pl.DwinsHs_Error_Canceled =Pobieranie anulowane
pl.DwinsHs_Error_ReadData =Nie mo¿na odczytaæ danych
pl.DwinsHs_Status_HTTPError =B³¹d HTTP %d: %s
pl.DwinsHs_Status_HTTP400 =B³êdne zapytanie
pl.DwinsHs_Status_HTTP401 =Odmowa dostêpu
pl.DwinsHs_Status_HTTP404 =Plik nie istnieje
pl.DwinsHs_Status_HTTP407 =Wymagane jest uwierzytelnianie serwera proxy
pl.DwinsHs_Status_HTTP500 =B³¹d wewnêtrzny
pl.DwinsHs_Status_HTTP502 =Bad gateway
pl.DwinsHs_Status_HTTP503 =Us³uga nie jest dostêpna
pl.DwinsHs_Status_HTTPxxx =Nieznany b³¹d
pl.EltenUpdate =Pobierz najnowsz¹ wersjê programu z serwera
en.EltenUpdate =Download the newest Elten version from the server
de.EltenUpdate =Neueste Elten-Version vom Server laden
pl.extractingelten =Proszê czekaæ, trwa przygotowywanie programu Elten do pierwszego uruchomienia
en.extractingelten =Please wait, preparing Elten for the first run
de.extractingelten =Bitte warten Sie, der Installateur bereitet Elten auf den ersten Lauf vor
pl.VCInstall =Zainstaluj komponenty niezbêdne do poprawnego dzia³ania programu (Microsoft Visual C++ Redistributable 2008)
en.VCInstall =Install required components (Microsoft Visual C++ Redistributable 2008)