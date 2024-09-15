@echo off

:: Check if correct number of arguments are provided
if "%~1"=="" (
    echo Usage: setup_windows.bat <username> <password>
    exit /b 1
)

:: Define variables from arguments
set USERNAME=%~1
set PASSWORD=%~2

rem Check if the user already exists
net user %USERNAME% >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo User %USERNAME% already exists.
) else (
    echo Creating user %USERNAME%...
    net user %USERNAME% %PASSWORD% /add
    net localgroup Administrators %USERNAME% /add
)

echo User %USERNAME% created and configured.
