@echo off
title Grand Fantasia Raizes - Update Compiler
color 0A

echo ===================================================
echo      Grand Fantasia Raizes - Auto Updater
echo ===================================================
echo.

:: Check if Node.js is installed
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Node.js is not installed or not in PATH.
    echo Please install Node.js to use this tool.
    pause
    exit /b
)

:: Run the update script
echo Starting update process...
node "%~dp0publish_update.cjs"

echo.
echo ===================================================
echo      Process Completed
echo ===================================================
pause
