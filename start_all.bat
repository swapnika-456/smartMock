@echo off
title smartMock Launcher
echo ========================================================
echo Launching smartMock Backend and Frontend
echo ========================================================
start "smartMock Backend" "%~dp0start_backend.bat"
timeout /t 3 /nobreak >nul
start "smartMock Frontend" "%~dp0start_frontend.bat"
echo smartMock services launched!
