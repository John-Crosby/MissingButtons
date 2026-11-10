@echo off
rem makedist-win.bat -- build, sign and package the Windows installer (all nine plug-ins).
rem Runs scripts\makedist-win.ps1; see the notes at its top.
rem
rem   scripts\makedist-win.bat                     VST3 + CLAP + AAX
rem   scripts\makedist-win.bat -NoAax              without AAX
rem   scripts\makedist-win.bat -NoBuild            sign + package what is already in build-win\out
rem   scripts\makedist-win.bat -SavePacePassword   store the PACE password (once)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0makedist-win.ps1" %*
exit /b %ERRORLEVEL%
