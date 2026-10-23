@echo off
title smartMock Frontend (Flutter Web)
echo ========================================================
echo Starting smartMock Flutter Frontend on Chrome
echo ========================================================
cd /d "%~dp0frontend"
flutter run -d chrome
pause
