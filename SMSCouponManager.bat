@echo off
title SMS Coupon Manager - Cloud Edition
color 0A

echo.
echo  ========================================
echo     SMS Coupon Manager - Cloud Edition
echo  ========================================
echo.

:: Check for Python
where python >nul 2>&1
if %errorlevel% equ 0 (
    set PYTHON_CMD=python
    goto :checkdeps
)

where py >nul 2>&1
if %errorlevel% equ 0 (
    set PYTHON_CMD=py -3
    goto :checkdeps
)

:: Python not found - try to download
echo  [!] Python is not installed!
echo.
echo  Python is required to run this application.
echo.
choice /C YN /M "  Would you like to download Python automatically"
if %errorlevel% equ 2 goto :manual

echo.
echo  Downloading Python installer...
powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe' -OutFile '%TEMP%\python_setup.exe'" 2>nul

if exist "%TEMP%\python_setup.exe" (
    echo  Installing Python...
    "%TEMP%\python_setup.exe" /passive InstallAllUsers=0 PrependPath=1 Include_pip=1
    echo.
    echo  Python installed! Please restart this application.
    echo.
    pause
    exit
)

:manual
echo.
echo  Please install Python manually:
echo    1. Go to https://www.python.org/downloads/
echo    2. Download Python 3.12 or newer
echo    3. IMPORTANT: Check "Add Python to PATH"
echo    4. Run this application again
echo.
pause
exit

:checkdeps
echo  [OK] Python found
echo.
echo  Checking dependencies...
%PYTHON_CMD% -m pip install PyQt5 pyodbc cryptography --quiet 2>nul
echo  [OK] Dependencies ready
echo.
echo  Loading from cloud...
echo.

:: Run the loader
%PYTHON_CMD% "%~dp0sms_loader.py"

if %errorlevel% neq 0 (
    echo.
    echo  [!] Application exited with an error
    echo.
    pause
)
