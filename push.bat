@echo off
chcp 65001 >nul
cd /d "G:\マイドライブ\void_shiny"

echo ============================================
echo   TidyBlock - Git Commit and Push
echo ============================================
echo.

git add -A
git status

echo.
set /p MSG="Commit message: "
if "%MSG%"=="" set MSG=chore: update

git commit -m "%MSG%"
git push origin main

echo.
echo ============================================
echo   Done! Changes pushed to GitHub.
echo ============================================
pause
