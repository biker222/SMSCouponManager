@echo off
title SMS Coupon Manager - GitHub Setup
color 0B

echo.
echo  =====================================================
echo     SMS Coupon Manager - GitHub Setup
echo  =====================================================
echo.
echo  This will push your encrypted app to GitHub.
echo.
echo  FIRST, create a new repository on GitHub:
echo    1. Go to https://github.com/new
echo    2. Name it: SMSCouponManager
echo    3. Make it PUBLIC
echo    4. Do NOT add README (we have one)
echo    5. Click "Create repository"
echo.
echo  =====================================================
echo.

set /p GITHUB_USER="Enter your GitHub username: "

if "%GITHUB_USER%"=="" (
    echo  ERROR: Username cannot be empty
    pause
    exit /b 1
)

echo.
echo  Setting up repository for: %GITHUB_USER%
echo.

cd /d "%~dp0"

:: Configure git
git config user.name "%GITHUB_USER%"
git config user.email "%GITHUB_USER%@users.noreply.github.com"

:: Add files
git add -A
git commit -m "Initial commit - SMS Coupon Manager"

:: Set remote
git remote remove origin 2>nul
git remote add origin https://github.com/%GITHUB_USER%/SMSCouponManager.git

:: Push
echo.
echo  Pushing to GitHub...
echo  (You may be asked to login to GitHub)
echo.

git branch -M main
git push -u origin main

if %errorlevel% neq 0 (
    echo.
    echo  =====================================================
    echo  If push failed, try:
    echo    1. Make sure the repository exists on GitHub
    echo    2. Run: git push -u origin main
    echo  =====================================================
    echo.
    pause
    exit /b 1
)

echo.
echo  =====================================================
echo     SUCCESS! Repository pushed to GitHub!
echo  =====================================================
echo.
echo  Your download URL is:
echo.
echo  https://github.com/%GITHUB_USER%/SMSCouponManager/raw/main/sms_package.enc
echo.
echo  Now updating the loader with this URL...
echo.

:: Update the loader script with the correct URL
powershell -Command "(Get-Content 'sms_loader.py') -replace 'YOUR_CLOUD_URL_HERE', 'https://github.com/%GITHUB_USER%/SMSCouponManager/raw/main/sms_package.enc' | Set-Content 'sms_loader.py'"

:: Commit the updated loader
git add sms_loader.py
git commit -m "Update cloud URL"
git push

echo.
echo  =====================================================
echo     ALL DONE!
echo  =====================================================
echo.
echo  Share these files with your users:
echo    - SMSCouponManager.bat
echo    - sms_loader.py
echo.
echo  Or tell them to download from:
echo    https://github.com/%GITHUB_USER%/SMSCouponManager
echo.
echo  =====================================================
echo.

pause
