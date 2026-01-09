[Setup]
AppName=Dapurmamma
AppVersion=1.0.0
AppId={{9D9B5D6E-6B4F-4C3E-9A0B-7D0B9C7A9E55}}
DefaultDirName={pf}\Dapurmamma
DefaultGroupName=Dapurmamma
OutputDir=.
OutputBaseFilename=DapurmammaSetup
Compression=lzma
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
DisableProgramGroupPage=yes
CloseApplications=yes
CloseApplicationsFilter=myapp.exe
RestartApplications=yes
AppMutex=Dapurmamma

[Files]
Source: "build\windows\x64\runner\Release\myapp.exe"; DestDir: "{app}"; Flags: ignoreversion restartreplace
Source: "build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion restartreplace
Source: "build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; Optional (recommended): bundle VC++ Runtime so app doesn't immediately exit on fresh PCs.
; Download "Visual C++ Redistributable for Visual Studio 2015-20Start-Process "C:\Cakemamma\Dapurmamma\build\windows\x64\runner\Release\myapp.exe"22 (x64)" and place it as:
;   installer\vcredist_x64.exe
; Then uncomment the line below.
Source: "installer\vcredist_x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Icons]
Name: "{group}\Dapurmamma"; Filename: "{app}\myapp.exe"; WorkingDir: "{app}"
Name: "{commondesktop}\Dapurmamma"; Filename: "{app}\myapp.exe"; WorkingDir: "{app}"

[Run]
; If you bundled vc_redist.x64.exe above, enable the line below too.
Filename: "{tmp}\vcredist_x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Installing Microsoft VC++ Runtime..."; Flags: waituntilterminated skipifsilent; Check: not IsVCRuntimeInstalled

Filename: "{app}\myapp.exe"; Description: "Run Dapurmamma"; WorkingDir: "{app}"; Flags: nowait postinstall skipifsilent

[Code]
function IsVCRuntimeInstalled: Boolean;
var
	Installed: Cardinal;
begin
	// VS 2015-2022 runtime (v14) registry key.
	// If target PC doesn't have it, Flutter Windows apps may fail to launch.
	Result := RegQueryDWordValue(
		HKLM,
		'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64',
		'Installed',
		Installed
	) and (Installed = 1);
end;
