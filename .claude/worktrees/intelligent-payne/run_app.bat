@echo off
echo =========================================
echo Starting TidyBlock Shiny App...
echo =========================================

cd /d "%~dp0"
call conda activate void
if errorlevel 1 (
    echo [Error] Conda environment 'void' not found or conda is not properly configured.
    pause
    exit /b 1
)

echo Running Shiny App on port 5100...
Rscript -e "shiny::runApp(port=5100, launch.browser=TRUE)"

pause
