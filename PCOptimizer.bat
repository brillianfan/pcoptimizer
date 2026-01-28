@echo off
title PC Ultimate Optimizer - Brillian Pham
color 0b
setlocal enabledelayedexpansion

:: ======================================================
:: TU DONG KICH HOAT QUYEN ADMIN
::    (Toi uu de khoi bi quet)
:: ======================================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~0' -Verb RunAs"
    exit /b
)
pushd "%cd%" & CD /D "%~dp0"

:menu
cls
echo ======================================================
echo           CONG CU QUAN TRI ^& TOI UU PC
echo                by Brillian Pham
echo ======================================================
echo [1] Deep Junk Clean (Don rac ^& Giai phong dung luong)
echo [2] Uninstaller (Go phan mem)
echo [3] Startup Manager (Quan ly cac ung dung khoi dong cung Windows)
echo [4] Toggle Windows Update (Bat/Tat tam thoi)
echo [5] Optimize Registry (Toi uu hoa Registry)
echo [6] View PC Specs (Xem cau hinh PC)
echo [7] Windows ^& Office Activation (Kiem tra ^& Kich hoat ban quyen)
echo [8] Internet Boost (Toi uu toc do mang ^& Ping)
echo [9] Disk Check (Quet loi o cung)
echo [10] Software Health (Cap nhat phan mem PC)
echo [0] Exit
echo ======================================================
set /p select="Chon chuc nang (0-10): "

if "%select%"=="1" goto clear_all_junk
if "%select%"=="2" goto deep_uninstall
if "%select%"=="3" goto startup_manager
if "%select%"=="4" goto toggle_update
if "%select%"=="5" goto optimize_registry
if "%select%"=="6" goto view_pc_specs
if "%select%"=="7" goto win_office_tools
if "%select%"=="8" goto internet_boost
if "%select%"=="9" goto disk_check
if "%select%"=="10" goto software_health
if "%select%"=="0" exit
goto menu

:view_pc_specs
cls
echo Dang lay thong tin cau hinh PC...
echo ------------------------------------------------------
powershell -Command ^
    "$os = Get-WmiObject Win32_OperatingSystem; " ^
    "$cpu = Get-WmiObject Win32_Processor; " ^
    "$mem = Get-WmiObject Win32_PhysicalMemory | Measure-Object Capacity -Sum; " ^
    "$gpu = Get-WmiObject Win32_VideoController; " ^
    "$disk = Get-WmiObject Win32_DiskDrive; " ^
    "$board = Get-WmiObject Win32_BaseBoard; " ^
    "Write-Host 'He dieu hanh: ' -NoNewline; Write-Host $os.Caption -ForegroundColor Cyan; " ^
    "Write-Host 'CPU:         ' -NoNewline; Write-Host $cpu.Name -ForegroundColor Cyan; " ^
    "Write-Host 'RAM:         ' -NoNewline; Write-Host \"$([Math]::Round($mem.Sum / 1GB)) GB\" -ForegroundColor Cyan; " ^
    "Write-Host 'Mainboard:   ' -NoNewline; Write-Host \"$($board.Manufacturer) $($board.Product)\" -ForegroundColor Cyan; " ^
    "Write-Host 'Do hoa (GPU):' -NoNewline; foreach($g in $gpu) { Write-Host \" $($g.Name)\" -ForegroundColor Cyan }; " ^
    "Write-Host 'O cung:      ' -NoNewline; foreach($d in $disk) { Write-Host \" $($d.Model) ($([Math]::Round($d.Size / 1GB)) GB)\" -ForegroundColor Cyan }; "
echo ------------------------------------------------------
pause
goto menu

:win_office_tools
cls
echo ======================================================
echo           CONG CU WINDOWS ^& OFFICE
echo ======================================================
echo [1] Kiem tra phien ban Windows ^& Office
echo [2] Kiem tra trang thai ban quyen (XPR)
echo [3] MO CONG CU KICH HOAT (MAS Script)
echo [0] Quay lai menu chinh
echo ======================================================
set /p wo_select="Chon chuc nang (0-3): "

if "%wo_select%"=="1" goto check_version
if "%wo_select%"=="2" goto check_license
if "%wo_select%"=="3" goto activate_all
if "%wo_select%"=="0" goto menu
goto win_office_tools

:check_version
cls
echo KIEM TRA PHIEN BAN:
echo ------------------------------------------------------
echo Dang lay thong tin...
powershell -Command ^
    "$os = Get-WmiObject Win32_OperatingSystem; " ^
    "$office = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object { ($_.DisplayName -like '*Microsoft Office*') -and ($_.DisplayName -notlike '*Update*') -and ($_.DisplayName -notlike '*MUI*') -and ($_.DisplayName -notlike '*Language Pack*') } | Select-Object -First 1; " ^
    "Write-Host 'He dieu hanh: ' -NoNewline; Write-Host $os.Caption -ForegroundColor Cyan; " ^
    "if ($office) { Write-Host 'Office:       ' -NoNewline; Write-Host $office.DisplayName -ForegroundColor Cyan } else { Write-Host 'Office:       ' -NoNewline; Write-Host 'Khong tim thay Office' -ForegroundColor Red }"
echo ------------------------------------------------------
pause
goto win_office_tools

:check_license
cls
echo KIEM TRA BAN QUYEN WINDOWS:
echo ------------------------------------------------------
cscript //nologo %systemroot%\system32\slmgr.vbs /xpr
echo ------------------------------------------------------
echo.
echo KIEM TRA BAN QUYEN OFFICE:
echo ------------------------------------------------------
powershell -Command ^
    "$ospp = Get-ChildItem -Path 'C:\Program Files\Microsoft Office', 'C:\Program Files (x86)\Microsoft Office' -Filter 'ospp.vbs' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1; " ^
    "if ($ospp) { " ^
    "   $status = cscript //nologo \"$($ospp.FullName)\" /dstatus; " ^
    "   $status | Select-String 'LICENSE NAME', 'LICENSE STATUS' | ForEach-Object { Write-Host $_.ToString().Trim() -ForegroundColor Cyan }; " ^
    "} else { " ^
    "   Write-Host 'Khong tim thay thong tin ban quyen Office.' -ForegroundColor Red; " ^
    "}"
echo ------------------------------------------------------
pause
goto win_office_tools

:activate_all
cls
echo Ket noi den may chu kich hoat (get.activated.win)...
echo ------------------------------------------------------
echo.
echo Lam theo huong dan trong cua so Microsoft Activation Script (MAS)
:: Chay lenh kich hoat moi qua PowerShell
powershell -Command "irm https://get.activated.win | iex"
echo ------------------------------------------------------

pause
goto win_office_tools

:clear_all_junk
cls
echo ======================================================
echo                     DEEP JUNK CLEAN
echo ======================================================
echo.
echo Dang thuc hien Deep Clean...
echo ------------------------------------------------------
echo [+] Dang xoa Temp, Prefetch ^& Cache...
del /s /f /q %temp%\*.* >nul 2>&1
del /s /f /q C:\Windows\Temp\*.* >nul 2>&1
del /s /f /q C:\Windows\Prefetch\*.* >nul 2>&1
echo [+] Dang lam trong Thung rac...
powershell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
echo [+] Dang xoa System Logs (Nhat ky he thong)...
for /F "tokens=*" %%G in ('wevtutil.exe el') do (wevtutil.exe cl "%%G") >nul 2>&1
echo [+] Dang chay Windows Disk Cleanup...
cleanmgr /sagerun:1 >nul 2>&1
echo ------------------------------------------------------
echo === DA DON DEP TRIET DE! ===
pause
goto menu

:deep_uninstall
cls
echo ======================================================
echo        GO BO PHAN MEM (Uninstaller)
echo ======================================================
echo.
echo Dang mo cua so "Programs and Features" trong Control Panel...
echo Vui long tu tim va go bo phan mem ban muon trong cua so moi.
echo.
start appwiz.cpl
echo.
pause
goto menu


:startup_manager
cls
echo ======================================================
echo    QUAN LY CAC UNG DUNG KHOI DONG CUNG HE THONG
echo ======================================================
echo.
echo [1] Mo Task Manager (Startup) va chinh sua
echo.
echo [2] Quay ve Menu chinh
echo.
set /p sm_select="Chon chuc nang (1-2): "

if "%sm_select%"=="1" goto startup_manager_run
if "%sm_select%"=="2" goto menu
goto startup_manager

:startup_manager_run
:: Lenh mo Task Manager va tu dong chuyen sang tab Startup (Tab so 4)
powershell -Command "Start-Process taskmgr; Start-Sleep -Milliseconds 500; $wshell = New-Object -ComObject WScript.Shell; $wshell.SendKeys('^{TAB}'); $wshell.SendKeys('^{TAB}'); $wshell.SendKeys('^{TAB}');"
cls
echo Huong dan: Sau khi Task Manager (Tab Startup) mo ra, click chuot phai vao ung dung khong can thiet va chon Disable.
echo.
echo [!] Nhan bat ky phim nao de quay lai menu chinh...
pause
goto menu


:toggle_update
cls
echo ======================================================
echo           QUAN LY WINDOWS UPDATE (HIEN TAI)
echo ======================================================
echo.

:: Kiem tra trang thai dich vu
sc query wuauserv | findstr /i "STATE" > "%temp%\updatestate.txt"
set /p state= < "%temp%\updatestate.txt"

echo Trang thai he thong: %state%
echo ------------------------------------------------------
echo [1] Bat Update (Enable ^& Start)
echo [2] Tat Update (Disable ^& Stop)
echo [0] Quay lai Menu
echo.

set /p upd="Lua chon cua ban: "

if "%upd%"=="1" (
    echo Dang bat Windows Update...
    sc config wuauserv start= demand >nul 2>&1
    net start wuauserv >nul 2>&1
    echo [OK] Da bat Windows Update thành cong!
    pause
)
if "%upd%"=="2" (
    echo Dang tat Windows Update...
    sc config wuauserv start= disabled >nul 2>&1
    net stop wuauserv /y >nul 2>&1
    echo [OK] Da vo hieu hoa Windows Update!
    pause
)
if "%upd%"=="0" goto menu
goto toggle_update

:optimize_registry
cls
echo ======================================================
echo          DANG TOI UU HOA REGISTRY HE THONG
echo ======================================================
echo.

:: 1. Giam thoi gian cho de tat cac ung dung bi treo (Giam tu 20s xuong 2s)
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "2000" /f >nul
echo Giam thoi gian cho de tat cac ung dung bi treo...

:: 2. Loai bo do tre khi mo Menu (Mac dinh 400ms -> 0ms)
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f >nul
echo Loai bo do tre khi mo Menu...

:: 3. Tu dong tat cac ung dung khong phan hoi khi Shutdown
reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f >nul
echo Tu dong tat cac ung dung khong phan hoi khi Shutdown...

:: 4. Tang toc do phan hoi cua chuot va ban phim
reg add "HKCU\Control Panel\Mouse" /v "MouseHoverTime" /t REG_SZ /d "10" /f >nul
echo Tang toc do phan hoi cua chuot va ban phim...

:: 5. Toi uu hoa luu luong mang (Network Throttling Index)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f >nul
echo Toi uu hoa luu luong mang (Network Throttling Index)...

:: 6. Toi uu hoa he thong phan hoi (System Responsiveness)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul
echo Toi uu hoa he thong phan hoi (System Responsiveness)...
echo.
echo [THANH CONG] Da toi uu hoa xong cac thong so Registry!
echo Luu y: Ban nen Restart lai may tinh de thay doi co hieu luc.
echo.
pause
goto menu

:internet_boost
cls
echo ======================================================
echo                       INTERNET BOOST
echo ======================================================
echo.
echo Dang toi uu thong so mang (TCP/IP Optimization)...
echo ------------------------------------------------------
netsh int tcp set global autotuninglevel=normal >nul
netsh int tcp set global rss=enabled >nul
netsh int tcp set global fastopen=enabled >nul
netsh interface tcp set global timestamps=disabled >nul
ipconfig /flushdns >nul
echo [+] Da toi uu Autotuning ^& RSS
echo [+] Da lam moi DNS Cache
echo ------------------------------------------------------
echo Da xong! Internet se on dinh va nhanh hon.
pause
goto menu

:disk_check
cls
echo He thong se kiem tra loi o cung vao lan khoi dong ke tiep.
echo Ban co muon tiep tuc? (Y/N)
set /p dc="Lua chon: "
if /i "%dc%"=="Y" ( chkdsk C: /f )
goto menu

:software_health
cls
:: Tu dong kich hoat Update de Winget hoat dong
sc config wuauserv start= demand >nul 2>&1
net start wuauserv >nul 2>&1

echo ======================================================
echo           CAP NHAT PHAN MEM (SOFTWARE HEALTH)
echo ======================================================
echo.
echo [1] Update All (Cap nhat tat ca phan mem)
echo [2] Update Selected (Tu chon phan mem de cap nhat)
echo [0] Quay lai Menu chinh
echo.
set /p sw_choice="Chon chuc nang (0/1/2): "

if "%sw_choice%"=="1" goto sw_update_all
if "%sw_choice%"=="2" goto sw_update_select
if "%sw_choice%"=="0" goto menu
goto software_health

:sw_update_all
cls
echo Dang kiem tra va cap nhat tat ca phan mem...
echo ------------------------------------------------------
winget upgrade --all
echo.
echo === HOAN TAT CAP NHAT TAT CA! ===
pause
goto software_health

:sw_update_select
chcp 65001 >nul
cls
echo ======================================================
echo             TÙY CHỌN PHẦN MỀM ĐỂ CẬP NHẬT
echo ======================================================
echo.
echo Đang kết nối đến hệ thống Windows Package Manager...
echo Vui lòng đợi trong giây lát...
echo.

:: Hiển thị danh sách phần mềm có bản cập nhật
winget list --upgrade-available
if %errorlevel% neq 0 (
    echo.
    echo LỖI: Không thể kết nối đến máy chủ Winget hoặc không có bản cập nhật nào.
    pause
    goto software_health
)

echo.
echo ------------------------------------------------------
echo Hướng dẫn: Copy "ID" ở cột thứ 2 và Paste vào đây.
echo Ví dụ: Google.Chrome
echo.
echo 0 - Quay lại Menu chính
echo 1 - Thoát
echo.

set "sw_id="
set /p sw_id="Nhập ID phần mềm: "

if "%sw_id%"=="" (
    echo Hãy nhập ID hợp lệ!
    timeout /t 2 >nul
    goto sw_update_select
)

if /i "%sw_id%"=="0" goto menu
if /i "%sw_id%"=="1" goto software_health

echo.
echo Đang tải và cài đặt bản cập nhật cho: %sw_id%
echo.
:: Thêm --silent để cài đặt ngầm nếu hỗ trợ
winget upgrade --id "%sw_id%" --accept-package-agreements --accept-source-agreements
if %errorlevel% equ 0 (
    echo.
    echo THÀNH CÔNG: Cập nhật %sw_id% hoàn tất!
    pause
) else (
    echo.
    echo LỖI: Không thể cập nhật %sw_id%.
    echo.
    echo [1] Thử lại
    echo [2] Bỏ qua kiểm tra hash (--force)
    echo [3] Quay lại
    set /p re_choice="Lựa chọn của bạn: "
    if "%re_choice%"=="2" winget upgrade --id "%sw_id%" --force --accept-package-agreements --accept-source-agreements
    goto sw_update_select
)