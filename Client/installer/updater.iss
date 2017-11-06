#define MyAppName "ELTEN"
#define MyAppVersion "2.0"
#define MyAppPublisher "Dawid Pieper"
#define MyAppURL "https://elten-net.eu"
#define MyAppExeName "elten.exe"

[Setup]
CloseApplications=force
DisableFinishedPage=yes
ShowLanguageDialog=no
PrivilegesRequired=lowest
Uninstallable=no
DisableDirPage=yes
DisableProgramGroupPage=yes
AppId={{9FE2B24B-49F4-4D0B-A36B-31F267F9B115}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
UsePreviousAppDir=no
DefaultDirName={userappdata}\elten\bin\elten
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir=C:\Users\dawid\Documents\rpgxp\elten\installer\eltenupd
OutputBaseFilename=eltenupd
Compression=lzma2/ultra
SolidCompression=yes

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "pl"; MessagesFile: "compiler:Languages\Polish.isl"

[Tasks]

[Files]
Source: "c:\users\dawid\documents\rpgxp\elten\export\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs overwritereadonly

[Icons]

[Run]
Filename: "{app}\elten.exe"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall