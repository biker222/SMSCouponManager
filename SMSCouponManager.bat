@echo off
title SMS Coupon Manager
color 0A

echo.
echo  ========================================
echo     SMS Coupon Manager - Cloud Edition
echo  ========================================
echo.

:: Check for Python - try py launcher first (more reliable on Windows)
py -3 --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_CMD=py -3"
    goto :checkdeps
)

python --version >nul 2>&1
if %errorlevel% equ 0 (
    set "PYTHON_CMD=python"
    goto :checkdeps
)

:: Python not found - try to download
echo  [!] Python is not installed!
echo.
choice /C YN /M "  Download Python automatically"
if %errorlevel% equ 2 goto :manual

echo.
echo  Downloading Python...
powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe' -OutFile '%TEMP%\python_setup.exe'" 2>nul

if exist "%TEMP%\python_setup.exe" (
    echo  Installing...
    "%TEMP%\python_setup.exe" /passive InstallAllUsers=0 PrependPath=1 Include_pip=1
    echo.
    echo  Done! Please restart this application.
    pause
    exit
)

:manual
echo  Please install Python from https://www.python.org/downloads/
echo  Make sure to check "Add Python to PATH"
pause
exit

:checkdeps
echo  [OK] Python found: %PYTHON_CMD%
echo  Installing dependencies...
call %PYTHON_CMD% -m pip install PyQt5 pyodbc cryptography --quiet 2>nul
echo  [OK] Ready
echo.
echo  Downloading from cloud...
echo.

:: Create temp Python script and run it
set "LOADER=%TEMP%\sms_loader_%RANDOM%.py"

(
echo import os, sys, tempfile, zipfile, base64, hashlib, shutil, urllib.request, ssl
echo.
echo CLOUD_URL = 'https://github.com/biker222/SMSCouponManager/raw/main/sms_package.enc'
echo PASSWORD = 'TecnicaSMS2024'
echo.
echo def generate_key^(p^):
echo     return base64.urlsafe_b64encode^(hashlib.sha256^(p.encode^(^)^).digest^(^)^)
echo.
echo temp_dir = tempfile.mkdtemp^(prefix='sms_'^)
echo pkg = os.path.join^(temp_dir, 'p.enc'^)
echo.
echo try:
echo     ctx = ssl.create_default_context^(^)
echo     ctx.check_hostname = False
echo     ctx.verify_mode = ssl.CERT_NONE
echo     urllib.request.urlretrieve^(CLOUD_URL, pkg^)
echo except Exception as e:
echo     print^(f'Download failed: {e}'^)
echo     input^('Press Enter...'^)
echo     sys.exit^(1^)
echo.
echo print^('Decrypting...'^)
echo from cryptography.fernet import Fernet
echo f = Fernet^(generate_key^(PASSWORD^)^)
echo.
echo with open^(pkg, 'rb'^) as file:
echo     data = file.read^(^)
echo.
echo try:
echo     dec = f.decrypt^(data^)
echo except:
echo     print^('Decryption failed!'^)
echo     input^('Press Enter...'^)
echo     sys.exit^(1^)
echo.
echo zp = os.path.join^(temp_dir, 'p.zip'^)
echo with open^(zp, 'wb'^) as file:
echo     file.write^(dec^)
echo.
echo with zipfile.ZipFile^(zp, 'r'^) as z:
echo     z.extractall^(temp_dir^)
echo.
echo print^('Starting SMS Coupon Manager...'^)
echo print^(^)
echo os.chdir^(temp_dir^)
echo sys.path.insert^(0, temp_dir^)
echo.
echo try:
echo     exec^(open^('main.py', encoding='utf-8'^).read^(^), {'__name__': '__main__'}^)
echo finally:
echo     try:
echo         shutil.rmtree^(temp_dir^)
echo     except:
echo         pass
) > "%LOADER%"

call %PYTHON_CMD% "%LOADER%"
del "%LOADER%" 2>nul

if %errorlevel% neq 0 (
    echo.
    echo  [!] Error occurred
    pause
)
