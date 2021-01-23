[Setup]
AppId={{9FE2B24B-49F4-4D0B-A36B-31F267F9B114}
AppName=ELTEN
AppVersion=2.4
AppVerName=Elten 2.4
AppPublisher=Dawid Pieper
AppPublisherURL=https://elten-net.eu
AppSupportURL=https://elten-net.eu/
AppUpdatesURL=https://elten-net.eu/download
AppCopyright=Copyright (C) 2014-2021 Dawid Pieper
DefaultDirName={pf}\ELTEN
DefaultGroupName=ELTEN
AllowNoIcons=yes
OutputDir=.
OutputBaseFilename=elten_portablesetup
RestartIfNeededByRun=no
PrivilegesRequiredOverridesAllowed=commandline dialog
LicenseFile=elten/gpl-3.0.txt
WizardStyle=modern
Compression=none
InternalCompressLevel=max

[InstallDelete]
Type: filesandordirs; Name: "{app}\*"

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "pl"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "de"; MessagesFile: "compiler:Languages\German.isl"
Name: "fr"; MessagesFile: "compiler:Languages\French.isl"
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "es"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "tr"; MessagesFile: "compiler:Languages\Turkish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";

[Files]
Source: "{src}\..\*"; DestDir: "{app}"; Flags: "ignoreversion createallsubdirs recursesubdirs external"

[Icons]
Name: "{group}\ELTEN"; Filename: "{app}\elten.exe"
Name: "{group}\{cm:ProgramOnTheWeb,ELTEN}"; Filename: "https://elten-net.eu"
Name: "{group}\{cm:UninstallProgram,ELTEN}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\ELTEN"; Filename: "{app}\elten.exe"; Tasks: desktopicon

[Run]
//Filename: "{app}\bin\7z.exe"; Parameters: "x {userappdata}\elten\bin\elten.7z -oelten -y"; WorkingDir: "{userappdata}\elten\bin"; StatusMsg: "{cm:extractingelten}"; Flags: runhidden; tasks: ext_update
Filename: "{app}\elten.exe"; Description: "{cm:LaunchProgram,{#StringChange("ELTEN", '&', '&&')}}"; Flags: nowait postinstall

[INI]
Filename: "{userappdata}\elten\elten.ini"; Section: "Interface"; Key: "Language"; String: "de-DE"; Languages: de
Filename: "{userappdata}\elten\elten.ini"; Section: "Interface"; Key: "Language"; String: "pl-PL"; Languages: pl
Filename: "{userappdata}\elten\elten.ini"; Section: "Interface"; Key: "Language"; String: "fr-FR"; Languages: fr
Filename: "{userappdata}\elten\elten.ini"; Section: "Interface"; Key: "Language"; String: "ru-RU"; Languages: ru
Filename: "{userappdata}\elten\elten.ini"; Section: "Interface"; Key: "Language"; String: "es-PA"; Languages: es
Filename: "{userappdata}\elten\elten.ini"; Section: "Interface"; Key: "Language"; String: "tr-TR"; Languages: tr
