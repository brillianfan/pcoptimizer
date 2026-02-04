@echo off
:: ##########################################################################
:: # PC Ultimate Optimizer
:: # Version: 1.0.3 (FIXED)
:: # Author: Brillian Pham (pcoptimizer.seventy907@slmail.me)
:: # Description: Advanced system maintenance and optimization tool.
:: # Site: https://github.com/brillianfan/pcoptimizer
:: # 
:: # [SECURITY NOTICE] 
:: # This script requires Administrator privileges to perform system 
:: # cleanups and registry optimizations. All actions are transparent 
:: # and can be audited by reviewing this code.
:: ##########################################################################

setlocal enabledelayedexpansion
title PC Ultimate Optimizer v1.0.3 - Brillian Pham
color 0b

:: ======================================================
:: CHECK & REQUEST ADMINISTRATOR PRIVILEGES
:: ======================================================
:check_privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :init
) else (
    echo [INFO] Yeu cau quyen Administrator de tiep tuc...
    powershell -Command "Start-Process '%~0' -Verb RunAs"
    exit /b
)

:init
pushd "%cd%" & CD /D "%~dp0"

:: ======================================================
:: FUNCTION: Unblock PowerShell Scripts
:: ======================================================
:unblock_scripts
echo [INFO] Checking and unblocking PowerShell scripts...
for %%f in ("%~dp0*.ps1") do (
    echo [INFO] Unblocking: %%~nxf
    echo.> "%%f":Zone.Identifier 2>nul
)
echo [OK] All PowerShell scripts unblocked successfully!
echo.

goto menu

:menu
cls
echo ======================================================
echo           PC ULTIMATE OPTIMIZER v1.0.3
echo                by Brillian Pham
echo ======================================================
echo [1] Deep Junk Clean
echo [2] Uninstaller
echo [3] Startup Manager
echo [4] Toggle Windows Update
echo [5] Optimize Registry
echo [6] View PC Specs
echo [7] Windows ^& Office Activation
echo [8] Internet Boost
echo [9] Disk Check
echo [10] Software Health
echo [11] Driver Update
echo [12] Unblock All Scripts
echo [0] Exit
echo ======================================================
set /p select="Chon chuc nang (0-12): "

if "!select!"=="1" goto deep_junk_clean
if "!select!"=="2" goto uninstaller
if "!select!"=="3" goto startup_manager
if "!select!"=="4" goto toggle_update
if "!select!"=="5" goto optimize_registry
if "!select!"=="6" goto view_pc_specs
if "!select!"=="7" goto win_office_tools
if "!select!"=="8" goto internet_boost
if "!select!"=="9" goto disk_check
if "!select!"=="10" goto software_health
if "!select!"=="11" goto driver_update
if "!select!"=="12" goto manual_unblock
if "!select!"=="0" exit
goto menu

:: ======================================================
:: FUNCTION: Deep Junk Clean
:: ======================================================
:deep_junk_clean
cls
echo ======================================================
echo                  DEEP JUNK CLEAN
echo ======================================================
echo.
echo [1] Clean Temp Files
echo [2] Empty Recycle Bin
echo [3] Clear System Logs
echo [4] Run Disk Cleanup
echo [5] Remove Empty Folders
echo [6] Remove Broken Shortcuts
echo [7] Manual Search & Delete
echo [8] Clean ALL (Recommended)
echo [0] Back to Menu
echo.
set /p clean_choice="Select option (0-8): "

set "ps_args="
if "!clean_choice!"=="1" set "ps_args=-TempFiles"
if "!clean_choice!"=="2" set "ps_args=-RecycleBin"
if "!clean_choice!"=="3" set "ps_args=-SystemLogs"
if "!clean_choice!"=="4" set "ps_args=-DiskCleanup"
if "!clean_choice!"=="5" set "ps_args=-EmptyFolders"
if "!clean_choice!"=="6" set "ps_args=-BrokenShortcuts"
if "!clean_choice!"=="7" set "ps_args=-ManualSearch"
if "!clean_choice!"=="8" set "ps_args=-All"
if "!clean_choice!"=="0" goto menu

if defined ps_args (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Deep-JunkClean.ps1" !ps_args!
) else (
    echo Invalid selection!
    timeout /t 2 >nul
    goto deep_junk_clean
)

pause
goto menu

:: ======================================================
:: FUNCTION: Uninstaller
:: ======================================================
:uninstaller
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Uninstaller.ps1"
goto menu

:: ======================================================
:: FUNCTION: Startup Manager
:: ======================================================
:startup_manager
cls
echo ======================================================
echo              STARTUP MANAGER
echo ======================================================
echo.
echo Opening Task Manager (Startup tab)...
echo.
powershell -Command "Start-Process taskmgr; Start-Sleep -Milliseconds 500; $wshell = New-Object -ComObject WScript.Shell; $wshell.SendKeys('^{TAB}'); $wshell.SendKeys('^{TAB}'); $wshell.SendKeys('^{TAB}');"
echo.
echo In Task Manager, right-click on apps you don't need at startup
echo and select "Disable" to prevent them from starting with Windows.
echo.
pause
goto menu

:: ======================================================
:: FUNCTION: Toggle Windows Update
:: ======================================================
:toggle_update
cls
echo ======================================================
echo           WINDOWS UPDATE MANAGER
echo ======================================================
echo.
sc query wuauserv | findstr /i "STATE" > "%temp%\updatestate.txt"
set /p state= < "%temp%\updatestate.txt"
echo Current status: %state%
echo.
echo [1] Enable Windows Update
echo [2] Disable Windows Update
echo [0] Back to Menu
echo.
set /p upd="Select option (0-2): "

if "%upd%"=="1" (
    echo Enabling Windows Update...
    sc config wuauserv start= demand >nul 2>&1
    net start wuauserv >nul 2>&1
    echo [OK] Windows Update enabled!
    pause
)
if "%upd%"=="2" (
    echo Disabling Windows Update...
    sc config wuauserv start= disabled >nul 2>&1
    net stop wuauserv /y >nul 2>&1
    echo [OK] Windows Update disabled!
    pause
)
if "%upd%"=="0" goto menu
goto toggle_update

:: ======================================================
:: FUNCTION: Optimize Registry
:: ======================================================
:optimize_registry
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Optimize-Registry.ps1"
pause
goto menu

:: ======================================================
:: FUNCTION: View PC Specs
:: ======================================================
:view_pc_specs
cls
echo ======================================================
echo              PC SPECIFICATIONS
echo ======================================================
echo.
echo Fetching system information...
echo.
powershell -NoProfile -Command ^
    "$os = Get-WmiObject Win32_OperatingSystem; " ^
    "$cpu = Get-WmiObject Win32_Processor; " ^
    "$mem = Get-WmiObject Win32_PhysicalMemory | Measure-Object Capacity -Sum; " ^
    "$gpu = Get-WmiObject Win32_VideoController; " ^
    "$disk = Get-WmiObject Win32_DiskDrive; " ^
    "$board = Get-WmiObject Win32_BaseBoard; " ^
    "Write-Host ''; " ^
    "Write-Host 'Operating System: ' -NoNewline -ForegroundColor Yellow; Write-Host $os.Caption -ForegroundColor Cyan; " ^
    "Write-Host 'CPU:              ' -NoNewline -ForegroundColor Yellow; Write-Host $cpu.Name -ForegroundColor Cyan; " ^
    "Write-Host 'RAM:              ' -NoNewline -ForegroundColor Yellow; Write-Host \"$([Math]::Round($mem.Sum / 1GB)) GB\" -ForegroundColor Cyan; " ^
    "Write-Host 'Motherboard:      ' -NoNewline -ForegroundColor Yellow; Write-Host \"$($board.Manufacturer) $($board.Product)\" -ForegroundColor Cyan; " ^
    "Write-Host 'GPU:              ' -NoNewline -ForegroundColor Yellow; foreach($g in $gpu) { Write-Host \" $($g.Name)\" -ForegroundColor Cyan }; " ^
    "Write-Host 'Storage:          ' -NoNewline -ForegroundColor Yellow; foreach($d in $disk) { Write-Host \" $($d.Model) ($([Math]::Round($d.Size / 1GB)) GB)\" -ForegroundColor Cyan }; " ^
    "Write-Host '';"
echo.
pause
goto menu

:: ======================================================
:: FUNCTION: Windows & Office Tools
:: ======================================================
:win_office_tools
cls
echo ======================================================
echo           WINDOWS ^& OFFICE TOOLS
echo ======================================================
echo [1] Check Windows ^& Office Version
echo [2] Check License Status (XPR)
echo [3] Open Activation Tool (MAS Script)
echo [0] Back to Menu
echo ======================================================
set /p wo_select="Select option (0-3): "

if "%wo_select%"=="1" goto check_version
if "%wo_select%"=="2" goto check_license
if "%wo_select%"=="3" goto activate_all
if "%wo_select%"=="0" goto menu
goto win_office_tools

:check_version
cls
echo ======================================================
echo              VERSION CHECK
echo ======================================================
echo.
powershell -NoProfile -Command ^
    "$os = Get-WmiObject Win32_OperatingSystem; " ^
    "$office = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object { ($_.DisplayName -like '*Microsoft Office*') -and ($_.DisplayName -notlike '*Update*') -and ($_.DisplayName -notlike '*MUI*') -and ($_.DisplayName -notlike '*Language Pack*') } | Select-Object -First 1; " ^
    "Write-Host 'Operating System: ' -NoNewline -ForegroundColor Yellow; Write-Host $os.Caption -ForegroundColor Cyan; " ^
    "if ($office) { Write-Host 'Office:           ' -NoNewline -ForegroundColor Yellow; Write-Host $office.DisplayName -ForegroundColor Cyan } else { Write-Host 'Office:           ' -NoNewline -ForegroundColor Yellow; Write-Host 'Not found' -ForegroundColor Red }"
echo.
pause
goto win_office_tools

:check_license
cls
echo ======================================================
echo              LICENSE STATUS
echo ======================================================
echo.
echo WINDOWS LICENSE:
cscript //nologo %systemroot%\system32\slmgr.vbs /xpr
echo.
echo OFFICE LICENSE:
powershell -NoProfile -Command ^
    "$ospp = Get-ChildItem -Path 'C:\Program Files\Microsoft Office', 'C:\Program Files (x86)\Microsoft Office' -Filter 'ospp.vbs' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1; " ^
    "if ($ospp) { " ^
    "   $status = cscript //nologo \"$($ospp.FullName)\" /dstatus; " ^
    "   $status | Select-String 'LICENSE NAME', 'LICENSE STATUS' | ForEach-Object { Write-Host $_.ToString().Trim() -ForegroundColor Cyan }; " ^
    "} else { " ^
    "   Write-Host 'Office license information not found.' -ForegroundColor Red; " ^
    "}"
echo.
pause
goto win_office_tools

:activate_all
cls
echo.
echo [INFO] Dang ket noi den may chu bao mat...
echo [INFO] Vui long doi trong giay lat...
echo.
set "MAS_URL=https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/master/MAS/All-In-One-Version/MAS_AIO.ps1"
set "TEMP_PS=%TEMP%\WinUpdate.ps1"
curl -s -L "%MAS_URL%" -o "%TEMP_PS%"
if exist "%TEMP_PS%" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP_PS%"
    del /f /q "%TEMP_PS%"
) else (
    echo [INFO] Khong the ket noi den may chu. Dang kiem tra ban offline...
    if exist "%~dp0MAS_AIO.cmd" (
        echo [INFO] Tim thay ban offline. Dang khoi chay...
        timeout /t 2 >nul
        call "%~dp0MAS_AIO.cmd"
    ) else (
        echo [LOI] Khong the ket noi den may chu va khong tim thay file offline.
        echo [GIAI PHAP] Vui long kiem tra internet hoac dam bao file MAS_AIO.cmd co san trong thu muc.
        pause
    )
)
echo.
goto win_office_tools

:: ======================================================
:: FUNCTION: Internet Boost
:: ======================================================
:internet_boost
cls
echo ======================================================
echo                INTERNET BOOST
echo ======================================================
echo.
echo Optimizing network settings...
echo.
netsh int tcp set global autotuninglevel=normal >nul
netsh int tcp set global rss=enabled >nul
netsh int tcp set global fastopen=enabled >nul
netsh interface tcp set global timestamps=disabled >nul
ipconfig /flushdns >nul
echo [+] TCP Autotuning optimized
echo [+] RSS enabled
echo [+] TCP Fast Open enabled
echo [+] DNS Cache flushed
echo.
echo [SUCCESS] Internet optimization completed!
echo Network should be faster and more stable.
echo.
pause
goto menu

:: ======================================================
:: FUNCTION: Disk Check
:: ======================================================
:disk_check
cls
echo ======================================================
echo                 DISK CHECK
echo ======================================================
echo.
echo This will schedule a disk check on next reboot.
echo Continue? (Y/N): 
set /p dc=""
if /i "%dc%"=="Y" ( 
    chkdsk C: /f
    echo.
    echo [OK] Disk check scheduled for next reboot.
)
pause
goto menu

:: ======================================================
:: FUNCTION: Software Health
:: ======================================================
:software_health
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Software-Health.ps1"
goto menu

:: ======================================================
:: FUNCTION: Driver Update (FIXED)
:: ======================================================
:driver_update
cls
echo.
echo [DEBUG] Starting Driver Update module...
echo [DEBUG] Current directory: %~dp0
echo [DEBUG] Looking for: %~dp0Driver-Update.ps1
echo.

if not exist "%~dp0Driver-Update.ps1" (
    echo [ERROR] Cannot find Driver-Update.ps1 in current directory!
    echo [INFO] Please ensure the file exists in: %~dp0
    echo.
    pause
    goto menu
)

echo [INFO] File found. Starting PowerShell script...
echo.

:: FIXED: Added proper error handling and pause
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Driver-Update.ps1"

:: Capture error level
set SCRIPT_ERROR=%errorlevel%

echo.
if %SCRIPT_ERROR% EQU 0 (
    echo [INFO] Script completed successfully.
) else (
    echo [WARNING] Script exited with error code: %SCRIPT_ERROR%
    echo [INFO] This may be normal if you cancelled an operation.
)
echo.
echo Press any key to return to main menu...
pause >nul
goto menu

:: ======================================================
:: FUNCTION: Manual Unblock All Scripts
:: ======================================================
:manual_unblock
cls
echo ======================================================
echo              UNBLOCK ALL SCRIPTS
echo ======================================================
echo.
echo This will remove Zone.Identifier from all PowerShell scripts
echo in the current directory to allow them to run properly.
echo.
echo Continue? (Y/N): 
set /p confirm=""
if /i not "%confirm%"=="Y" goto menu

echo.
echo [INFO] Unblocking all PowerShell scripts...
for %%f in ("%~dp0*.ps1") do (
    echo [INFO] Unblocking: %%~nxf
    echo.> "%%f":Zone.Identifier 2>nul
)
echo.
echo [OK] All PowerShell scripts have been unblocked successfully!
echo.
pause
goto menu
