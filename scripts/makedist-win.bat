@echo off
rem makedist-win.bat -- build the nine MissingButtons plug-ins (x64) with CMake and
rem compile the Inno Setup installer.
rem
rem   scripts\makedist-win.bat         VST3 + CLAP
rem   scripts\makedist-win.bat aax     VST3 + CLAP + AAX (PACE-signed, see below)
rem
rem Needs: Visual Studio 2022 (Desktop C++), CMake (comes with VS), Inno Setup 6.
rem Output: installer\build-win\MissingButtons-<version>-win.exe
rem
rem AAX (not tested yet): needs the AAX SDK in iPlug2\Dependencies\IPlug\AAX_SDK,
rem PACE wraptool (set WRAPTOOL=...\wraptool.exe if it is not on PATH) and the
rem PACE password in the PACE_PASSWORD environment variable. If PACE asks for a
rem Windows code-signing certificate, set WIN_SIGNID to its name.

setlocal
cd /d "%~dp0.."

set "FORMATS=VST3;CLAP"
set "ISCCDEFS="
if /i "%~1"=="aax" (
  set "FORMATS=VST3;CLAP;AAX"
  set "ISCCDEFS=/DWITH_AAX"
)

for /f "tokens=3" %%v in ('findstr /b /c:"#define PLUG_VERSION_STR" common\config-common.h') do set "VERSION=%%~v"
if "%VERSION%"=="" ( echo PLUG_VERSION_STR not found in common\config-common.h & exit /b 1 )
echo === MissingButtons %VERSION% Windows distribution (%FORMATS%) ===

if exist build-win rmdir /s /q build-win
cmake -S . -B build-win -G "Visual Studio 17 2022" -A x64 "-DMB_FORMATS=%FORMATS%" -DIPLUG_DEPLOY_PLUGINS=OFF || goto :fail
cmake --build build-win --config Release --parallel || goto :fail

if /i not "%~1"=="aax" goto :installer
if "%WRAPTOOL%"=="" set "WRAPTOOL=wraptool"
if "%PACE_PASSWORD%"=="" ( echo set PACE_PASSWORD first & goto :fail )
set "SIGNOPT="
if not "%WIN_SIGNID%"=="" set SIGNOPT=--signid "%WIN_SIGNID%"
for %%G in (
  Flip:70DA6F30-3598-11F0-9A88-005056928F3B
  FlipRight:BF0CE5C0-3598-11F0-9A88-005056928F3B
  Left:1CAC7CE0-3599-11F0-9A88-005056928F3B
  MidSide:6751AE00-3599-11F0-BC08-005056920FF7
  Mono:B3E5DDE0-3599-11F0-BC08-005056920FF7
  Right:FDC48AB0-3599-11F0-AB63-00505692AD3E
  Side:49967C00-359A-11F0-88CE-00505692C25A
  SideChainer:93B14770-359A-11F0-9A88-005056928F3B
  Swap:DB668490-359A-11F0-88CE-00505692C25A
) do for /f "tokens=1,2 delims=:" %%a in ("%%G") do (
  echo === PACE sign %%a ===
  "%WRAPTOOL%" sign --verbose --account krizaj.janez@gmail.com --password "%PACE_PASSWORD%" --wcguid %%b %SIGNOPT% --in "build-win\out\%%a.aaxplugin" --out "build-win\out\%%a.aaxplugin" || goto :fail
)

:installer
set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if not exist "%ISCC%" set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if not exist "%ISCC%" ( echo Inno Setup 6 not found & goto :fail )
"%ISCC%" /DAppVer=%VERSION% %ISCCDEFS% installer\MissingButtons.iss || goto :fail

echo === done: installer\build-win\MissingButtons-%VERSION%-win.exe ===
exit /b 0

:fail
echo === FAILED ===
exit /b 1
