@echo off
title smartMock Backend (FastAPI)
echo ========================================================
echo Starting smartMock FastAPI Backend on http://localhost:8000
echo ========================================================
cd /d "%~dp0backend"
python run.py
pause
