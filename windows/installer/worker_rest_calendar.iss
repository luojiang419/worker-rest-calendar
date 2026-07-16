#define AppName "工作日历"
#ifndef AppVersion
#define AppVersion "0.1.10"
#endif
#define AppExeName "worker_rest_calendar.exe"
#ifndef OutputBaseFilename
#define OutputBaseFilename "工作日历-Setup-0.1.10"
#endif

[Setup]
AppId={{F483BA90-37E3-4C04-8C89-E84DCD67B487}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppName}
DefaultDirName={localappdata}\Programs\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=..\..\build\installer
OutputBaseFilename={#OutputBaseFilename}
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExeName}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes
RestartApplications=no
AllowCancelDuringInstall=no
SetupLogging=yes
VersionInfoVersion={#AppVersion}.0
VersionInfoCompany={#AppName}
VersionInfoDescription={#AppName} 安装程序
VersionInfoProductName={#AppName}
VersionInfoProductVersion={#AppVersion}

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "附加快捷方式："; Flags: unchecked

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExeName}"; WorkingDir: "{app}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "启动{#AppName}"; Flags: nowait postinstall skipifsilent

[Code]
procedure SetInstallProgress(Percent: Integer; Status: String);
begin
  WizardForm.Caption := Format('工作日历更新 - %d%%', [Percent]);
  WizardForm.StatusLabel.Caption := Format('%s %d%%', [Status, Percent]);
end;

procedure InitializeWizard;
begin
  WizardForm.PageNameLabel.Caption := '正在更新到工作日历 {#AppVersion}';
  WizardForm.PageDescriptionLabel.Caption := '正在安装新版本，请稍候。';
  SetInstallProgress(0, '正在准备安装…');
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
    SetInstallProgress(100, '正在完成安装…');
end;

procedure CurInstallProgressChanged(CurProgress, MaxProgress: Integer);
var
  Percent: Integer;
begin
  if MaxProgress <= 0 then
    Exit;
  Percent := Round((CurProgress * 100.0) / MaxProgress);
  if Percent < 0 then
    Percent := 0
  else if Percent > 100 then
    Percent := 100;
  SetInstallProgress(Percent, '正在安装和配置…');
end;
