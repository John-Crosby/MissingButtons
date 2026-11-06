; MissingButtons -- Windows installer (Inno Setup 6). All nine plug-ins, x64,
; VST3 + CLAP, plus AAX when compiled with /DWITH_AAX.
;
; Do not compile this file directly: run scripts\makedist-win.bat, which builds
; the plug-ins with CMake into build-win\out and then compiles this file with
; the version from common\config-common.h (/DAppVer=...).
; Output: installer\build-win\MissingButtons-<version>-win.exe
;
; Same shape as the macOS installer (scripts/makedist-mac.sh): welcome, EULA,
; one checkbox per format and per plug-in, fixed system-wide locations.
; Not code-signed (no Windows certificate), so SmartScreen shows
; "Windows protected your PC" on first run (More info -> Run anyway).

#ifndef AppVer
  #error Compile with scripts\makedist-win.bat (it passes /DAppVer from common\config-common.h)
#endif

[Setup]
; AppId identifies the product for upgrades and uninstall: never change it.
AppId={{C7838240-A119-49A2-9B04-7A90A31A4EA3}
AppName=MissingButtons
AppVersion={#AppVer}
AppPublisher=John Crosby
AppPublisherURL=https://john-crosby.com
AppSupportURL=https://john-crosby.com
AppCopyright=Copyright (C) 2024-2026 John Crosby
; Only the EULA, the changelog and the uninstaller go here; the plug-ins go to
; the standard Common Files folders below.
DefaultDirName={autopf}\JohnCrosby\MissingButtons
DefaultGroupName=MissingButtons
DisableDirPage=yes
DisableProgramGroupPage=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
LicenseFile=EULA.txt
InfoBeforeFile=readme-win.txt
OutputDir=build-win
OutputBaseFilename=MissingButtons-{#AppVer}-win
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
SetupLogging=yes
ShowComponentSizes=no
UninstallDisplayName=MissingButtons

[Messages]
SetupWindowTitle=MissingButtons installer
WelcomeLabel1=MissingButtons {#AppVer} by John Crosby
WelcomeLabel2=Nine free utility plug-ins: the buttons your mixer is missing.%n%nThis installs them for every user of this computer. After the licence, one page lists what each one does and the next lets you untick any format or plug-in you do not need.

[Types]
Name: "full"; Description: "All plug-ins in all formats"
Name: "custom"; Description: "Choose formats and plug-ins"; Flags: iscustom

[Components]
Name: "vst3"; Description: "VST3   (Common Files\VST3)"; Types: full custom
Name: "vst3\flip"; Description: "Flip"; Types: full custom
Name: "vst3\flipright"; Description: "FlipRight"; Types: full custom
Name: "vst3\left"; Description: "Left"; Types: full custom
Name: "vst3\right"; Description: "Right"; Types: full custom
Name: "vst3\mono"; Description: "Mono"; Types: full custom
Name: "vst3\midside"; Description: "MidSide"; Types: full custom
Name: "vst3\side"; Description: "Side"; Types: full custom
Name: "vst3\swap"; Description: "Swap"; Types: full custom
Name: "vst3\sidechainer"; Description: "SideChainer"; Types: full custom
Name: "clap"; Description: "CLAP   (Common Files\CLAP)"; Types: full custom
Name: "clap\flip"; Description: "Flip"; Types: full custom
Name: "clap\flipright"; Description: "FlipRight"; Types: full custom
Name: "clap\left"; Description: "Left"; Types: full custom
Name: "clap\right"; Description: "Right"; Types: full custom
Name: "clap\mono"; Description: "Mono"; Types: full custom
Name: "clap\midside"; Description: "MidSide"; Types: full custom
Name: "clap\side"; Description: "Side"; Types: full custom
Name: "clap\swap"; Description: "Swap"; Types: full custom
Name: "clap\sidechainer"; Description: "SideChainer"; Types: full custom
#ifdef WITH_AAX
Name: "aax"; Description: "AAX (Pro Tools)   (Common Files\Avid\Audio\Plug-Ins)"; Types: full custom
Name: "aax\flip"; Description: "Flip"; Types: full custom
Name: "aax\flipright"; Description: "FlipRight"; Types: full custom
Name: "aax\left"; Description: "Left"; Types: full custom
Name: "aax\right"; Description: "Right"; Types: full custom
Name: "aax\mono"; Description: "Mono"; Types: full custom
Name: "aax\midside"; Description: "MidSide"; Types: full custom
Name: "aax\side"; Description: "Side"; Types: full custom
Name: "aax\swap"; Description: "Swap"; Types: full custom
Name: "aax\sidechainer"; Description: "SideChainer"; Types: full custom
#endif

[Files]
; VST3: bundle folders (Contents\x86_64-win\<name>.vst3); build leftovers left out.
Source: "..\build-win\out\Flip.vst3\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\VST3\Flip.vst3"; Components: vst3\flip; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build-win\out\FlipRight.vst3\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\VST3\FlipRight.vst3"; Components: vst3\flipright; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build-win\out\Left.vst3\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\VST3\Left.vst3"; Components: vst3\left; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build-win\out\Right.vst3\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\VST3\Right.vst3"; Components: vst3\right; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build-win\out\Mono.vst3\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\VST3\Mono.vst3"; Components: vst3\mono; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build-win\out\MidSide.vst3\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\VST3\MidSide.vst3"; Components: vst3\midside; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build-win\out\Side.vst3\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\VST3\Side.vst3"; Components: vst3\side; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build-win\out\Swap.vst3\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\VST3\Swap.vst3"; Components: vst3\swap; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build-win\out\SideChainer.vst3\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\VST3\SideChainer.vst3"; Components: vst3\sidechainer; Flags: ignoreversion recursesubdirs createallsubdirs
; CLAP: single files.
Source: "..\build-win\out\Flip.clap"; DestDir: "{commoncf64}\CLAP"; Components: clap\flip; Flags: ignoreversion
Source: "..\build-win\out\FlipRight.clap"; DestDir: "{commoncf64}\CLAP"; Components: clap\flipright; Flags: ignoreversion
Source: "..\build-win\out\Left.clap"; DestDir: "{commoncf64}\CLAP"; Components: clap\left; Flags: ignoreversion
Source: "..\build-win\out\Right.clap"; DestDir: "{commoncf64}\CLAP"; Components: clap\right; Flags: ignoreversion
Source: "..\build-win\out\Mono.clap"; DestDir: "{commoncf64}\CLAP"; Components: clap\mono; Flags: ignoreversion
Source: "..\build-win\out\MidSide.clap"; DestDir: "{commoncf64}\CLAP"; Components: clap\midside; Flags: ignoreversion
Source: "..\build-win\out\Side.clap"; DestDir: "{commoncf64}\CLAP"; Components: clap\side; Flags: ignoreversion
Source: "..\build-win\out\Swap.clap"; DestDir: "{commoncf64}\CLAP"; Components: clap\swap; Flags: ignoreversion
Source: "..\build-win\out\SideChainer.clap"; DestDir: "{commoncf64}\CLAP"; Components: clap\sidechainer; Flags: ignoreversion
#ifdef WITH_AAX
; AAX: bundle folders, PACE-signed by makedist-win.bat.
Source: "..\build-win\out\Flip.aaxplugin\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\Avid\Audio\Plug-Ins\Flip.aaxplugin"; Components: aax\flip; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build-win\out\FlipRight.aaxplugin\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\Avid\Audio\Plug-Ins\FlipRight.aaxplugin"; Components: aax\flipright; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build-win\out\Left.aaxplugin\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\Avid\Audio\Plug-Ins\Left.aaxplugin"; Components: aax\left; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build-win\out\Right.aaxplugin\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\Avid\Audio\Plug-Ins\Right.aaxplugin"; Components: aax\right; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build-win\out\Mono.aaxplugin\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\Avid\Audio\Plug-Ins\Mono.aaxplugin"; Components: aax\mono; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build-win\out\MidSide.aaxplugin\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\Avid\Audio\Plug-Ins\MidSide.aaxplugin"; Components: aax\midside; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build-win\out\Side.aaxplugin\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\Avid\Audio\Plug-Ins\Side.aaxplugin"; Components: aax\side; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build-win\out\Swap.aaxplugin\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\Avid\Audio\Plug-Ins\Swap.aaxplugin"; Components: aax\swap; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\build-win\out\SideChainer.aaxplugin\*"; Excludes: "*.pdb,*.exp,*.lib,*.ilk"; DestDir: "{commoncf64}\Avid\Audio\Plug-Ins\SideChainer.aaxplugin"; Components: aax\sidechainer; Flags: ignoreversion recursesubdirs createallsubdirs
#endif
Source: "EULA.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "changelog.txt"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\Licence agreement"; Filename: "{app}\EULA.txt"
Name: "{group}\Changelog"; Filename: "{app}\changelog.txt"
Name: "{group}\Uninstall MissingButtons"; Filename: "{uninstallexe}"
