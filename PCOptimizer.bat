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
echo [+] Xoa Temp, Prefetch ^& Cache...
set /p confirm1="Ban co muon xoa Temp, Prefetch ^& Cache? (Y/N): "
if /i "%confirm1%"=="Y" (
    del /s /f /q %temp%\*.* >nul 2>&1
    del /s /f /q C:\Windows\Temp\*.* >nul 2>&1
    del /s /f /q C:\Windows\Prefetch\*.* >nul 2>&1
    echo [OK] Da xoa Temp, Prefetch ^& Cache!
) else (
    echo [SKIP] Bo qua buoc xoa Temp, Prefetch ^& Cache.
)
echo.
echo [+] Lam trong Thung rac...
set /p confirm2="Ban co muon lam trong Thung rac? (Y/N): "
if /i "%confirm2%"=="Y" (
    powershell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
    echo [OK] Da lam trong Thung rac!
) else (
    echo [SKIP] Bo qua buoc lam trong Thung rac.
)
echo.
echo [+] Xoa System Logs (Nhat ky he thong)...
set /p confirm3="Ban co muon xoa System Logs? (Y/N): "
if /i "%confirm3%"=="Y" (
    for /F "tokens=*" %%G in ('wevtutil.exe el') do (wevtutil.exe cl "%%G") >nul 2>&1
    echo [OK] Da xoa System Logs!
) else (
    echo [SKIP] Bo qua buoc xoa System Logs.
)
echo.
echo [+] Chay Windows Disk Cleanup...
set /p confirm4="Ban co muon chay Windows Disk Cleanup? (Y/N): "
if /i "%confirm4%"=="Y" (
    cleanmgr /sagerun:1 >nul 2>&1
    echo [OK] Da chay Windows Disk Cleanup!
) else (
    echo [SKIP] Bo qua buoc Windows Disk Cleanup.
)
echo.
echo [+] Quet thu muc rong (ProgramData, AppData, Program Files)...
set "emptyDirsList=%temp%\empty_dirs_%random%.txt"
set "emptyCountFile=%temp%\empty_count_%random%.txt"
set emptyCount=0
powershell -NoProfile -Command ^
    "$roots = @('C:\ProgramData', $env:APPDATA, $env:LOCALAPPDATA, 'C:\Program Files', 'C:\Program Files (x86)'); " ^
    "$all = @(); " ^
    "foreach ($r in $roots) { " ^
    "  if (Test-Path $r) { " ^
    "    Get-ChildItem -Path $r -Directory -Recurse -Force -ErrorAction SilentlyContinue | " ^
    "    Where-Object { (Get-ChildItem $_.FullName -Force -ErrorAction SilentlyContinue).Count -eq 0 } | " ^
    "    ForEach-Object { $all += $_.FullName } " ^
    "  } " ^
    "}; " ^
    "$all = $all | Sort-Object { $_.Length } -Descending; " ^
    "if ($all.Count -gt 0) { $all | Set-Content -Path '%emptyDirsList%' -Encoding UTF8 }; " ^
    "$all.Count | Set-Content -Path '%emptyCountFile%' -Encoding ASCII"
if exist "%emptyCountFile%" for /f "delims=" %%N in ('type "%emptyCountFile%"') do set emptyCount=%%N
del /f /q "%emptyCountFile%" >nul 2>&1
echo So thu muc rong tim thay: !emptyCount!
if !emptyCount! gtr 0 (
    echo Vi du mot so duong dan:
    powershell -NoProfile -Command "Get-Content '%emptyDirsList%' -ErrorAction SilentlyContinue | Select-Object -First 8 | ForEach-Object { Write-Host '  ' $_ }"
)
echo.
set /p confirm5="Ban co muon xoa cac thu muc rong nay? (Y/N): "
if /i "!confirm5!"=="Y" (
    if exist "%emptyDirsList%" (
        powershell -NoProfile -Command "Get-Content '%emptyDirsList%' -ErrorAction SilentlyContinue | ForEach-Object { if (Test-Path $_ -PathType Container) { Remove-Item $_ -Force -Recurse -ErrorAction SilentlyContinue } }"
        echo [OK] Da xu ly xong cac thu muc rong!
    ) else (
        echo [SKIP] Khong co thu muc rong de xoa.
    )
) else (
    echo [SKIP] Bo qua buoc xoa thu muc rong.
)
if exist "%emptyDirsList%" del /f /q "%emptyDirsList%" >nul 2>&1
echo.
echo [+] Xoa shortcuts loi (lien ket tro toi file/thu muc da bi xoa)...
set /p confirm6="Ban co muon xoa cac shortcuts loi? (Y/N): "
if /i "!confirm6!"=="Y" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Remove-BrokenShortcuts.ps1"
) else (
    echo [SKIP] Bo qua buoc xoa shortcuts loi.
)
echo.
echo ------------------------------------------------------
echo === DA DON DEP XONG! ===
pause
goto menu

:deep_uninstall
chcp 65001 >nul
cls
echo ======================================================
echo        GO BO PHAN MEM (Uninstaller)
echo ======================================================
echo.
echo Dang squet danh sach cac ung dung tren he thong...
echo Vui long cho doi...
echo.

:: Tao file tam thoi de luu danh sach ung dung
set tempAppList=%temp%\applist_%random%.txt
set tempAppIndex=%temp%\appindex_%random%.txt

:: Su dung PowerShell de quyet danh sach ung dung tu Registry va sap xep A-Z
powershell -Command ^
    "$apps = @(); " ^
    "$paths = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'); " ^
    "foreach($path in $paths) { " ^
    "    Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName } | ForEach-Object { " ^
    "        if(-not ($apps | Where-Object { $_.Name -eq $_.DisplayName })) { " ^
    "            $apps += New-Object PSObject -Property @{ Name = $_.DisplayName; UninstallString = $_.UninstallString; QuietUninstallString = $_.QuietUninstallString; InstallLocation = $_.InstallLocation; Publisher = $_.Publisher }; " ^
    "        } " ^
    "    } " ^
    "}; " ^
    "$apps = $apps | Sort-Object { $_.Name } -Unique; " ^
    "$apps | ForEach-Object { [PSCustomObject]@{ DisplayName = $_.Name; UninstallString = $_.UninstallString; QuietUninstallString = $_.QuietUninstallString; InstallLocation = $_.InstallLocation; Publisher = $_.Publisher } } | Export-Csv -Path '%tempAppList%' -NoTypeInformation -Encoding UTF8"

:: Kiem tra neu ko co ung dung nao
if not exist "%tempAppList%" (
    echo Khong tim thay ung dung nao hoac loi trong qua trinh quet.
    pause
    goto menu
)

:: Hien thi danh sach ung dung voi so thu tu
cls
echo ======================================================
echo              DANH SACH CAC UNG DUNG
echo ======================================================
echo.

powershell -Command ^
    "$csv = Import-Csv '%tempAppList%' -Encoding UTF8; " ^
    "$index = 1; " ^
    "if($csv -is [array]) { " ^
    "    foreach($app in $csv) { Write-Host \"[$index] $($app.DisplayName)\"; $index++ } " ^
    "} elseif($csv) { " ^
    "    Write-Host \"[1] $($csv.DisplayName)\"; " ^
    "} else { " ^
    "    Write-Host 'Khong co ung dung nao de hien thi.'; " ^
    "}; " ^
    "Write-Host \"\"; Write-Host \"[0] Quay lai Menu chinh\""

echo.
set /p appChoice="Chon so thu tu cua ung dung de go bo (0 de quay lai): "

if "%appChoice%"=="0" (
    del /f /q "%tempAppList%" >nul 2>&1
    del /f /q "%tempAppIndex%" >nul 2>&1
    goto menu
)

:: Lay thong tin ung dung duoc chon
for /f "tokens=*" %%A in ('powershell -Command "try { $csv = Import-Csv '%tempAppList%' -Encoding UTF8; if($csv -is [array]) { $app = $csv[%appChoice% - 1] } else { $app = $csv }; if($app) { Write-Host $app.DisplayName } } catch { Write-Host 'Lua chon khong hop le' }"') do set "selectedApp=%%A"

:: Lay them InstallLocation va Publisher
for /f "tokens=*" %%A in ('powershell -Command "try { $csv = Import-Csv '%tempAppList%' -Encoding UTF8; if($csv -is [array]) { $app = $csv[%appChoice% - 1] } else { $app = $csv }; if($app) { Write-Host $app.InstallLocation } } catch { }"') do set "installLocation=%%A"

for /f "tokens=*" %%A in ('powershell -Command "try { $csv = Import-Csv '%tempAppList%' -Encoding UTF8; if($csv -is [array]) { $app = $csv[%appChoice% - 1] } else { $app = $csv }; if($app) { Write-Host $app.Publisher } } catch { }"') do set "publisher=%%A"

if "%selectedApp%"=="" (
    echo Lua chon khong hop le. Vui long thu lai.
    pause
    goto deep_uninstall
)

cls
echo ======================================================
echo XAC NHAN GO BO UNG DUNG
echo ======================================================
echo.
echo Ung dung: %selectedApp%
echo Publisher: %publisher%
echo Duong dan: %installLocation%
echo.
set /p confirmUninstall="Ban co chac chan muon go bo ung dung nay? (Y/N): "

if /i not "%confirmUninstall%"=="Y" (
    echo Huy thao tac.
    pause
    goto deep_uninstall
)

echo.
echo Dang go bo %selectedApp%...
echo.

:: Go bo ung dung
powershell -Command ^
    "try { " ^
    "    $csv = Import-Csv '%tempAppList%' -Encoding UTF8; " ^
    "    if($csv -is [array]) { $app = $csv[%appChoice% - 1] } else { $app = $csv }; " ^
    "    if($app.UninstallString -or $app.QuietUninstallString) { " ^
    "        $uninstallCmd = if($app.QuietUninstallString) { $app.QuietUninstallString } else { $app.UninstallString }; " ^
    "        Write-Host \"Thuc hien: $uninstallCmd\"; " ^
    "        cmd /c $uninstallCmd; " ^
    "        Write-Host 'Go bo hoan tat.'; " ^
    "    } else { " ^
    "        Write-Host 'Khong tim thay lenh go bo cho ung dung nay.'; " ^
    "    } " ^
    "} catch { " ^
    "    Write-Host \"Loi: $_\"; " ^
    "}"

echo.
set /p checkLeftovers="Ban co muon xoa cac leftover (tan du) cua ung dung nay? (Y/N): "

if /i "%checkLeftovers%"=="Y" (
    call :clean_app_leftovers "%selectedApp%" "%installLocation%" "%publisher%"
) else (
    echo Bo qua xoa tan du.
)

del /f /q "%tempAppList%" >nul 2>&1
del /f /q "%tempAppIndex%" >nul 2>&1

echo.
pause
goto deep_uninstall

:clean_app_leftovers
setlocal enabledelayedexpansion
set "appName=%~1"
set "installPath=%~2"
set "appPublisher=%~3"
set foundLeftovers=0
set tempScanResult=%temp%\scanresult_%random%.txt

cls
echo ======================================================
echo       QUYET SCAN TAN DU CUA UNG DUNG
echo ======================================================
echo.
echo Ung dung: %appName%
echo Publisher: %appPublisher%
echo Duong dan cai dat: %installPath%
echo.
echo Dang tim kiem cac tan du lien quan...
echo.

:: Xoa file ket qua cu
if exist "%tempScanResult%" del /f /q "%tempScanResult%"

:: Xoa thu muc cai dat chinh (neu ton tai va khac Program Files mac dinh)
if defined installPath (
    if exist "%installPath%" (
        echo [FOUND - Install Dir] %installPath%
        echo %installPath%>>"%tempScanResult%"
        set foundLeftovers=1
    )
)

:: Tao danh sach cac ten co the tim kiem (chinh xac hon)
:: Loai bo cac tu chung: "Microsoft", "Windows", "System", etc.
set "searchExact=%appName%"
set "searchPublisher=%appPublisher%"

:: Scan AppData\Roaming - chi tim thu muc CHINH XAC hoac bat dau bang ten app
echo Dang squet trong AppData\Roaming...
if exist "%appdata%" (
    for /d %%D in ("%appdata%\%searchExact%") do (
        echo [FOUND - AppData] %%D
        echo %%D>>"%tempScanResult%"
        set foundLeftovers=1
    )
    if defined searchPublisher (
        for /d %%D in ("%appdata%\%searchPublisher%") do (
            echo [FOUND - AppData] %%D
            echo %%D>>"%tempScanResult%"
            set foundLeftovers=1
        )
    )
)

:: Scan AppData\Local - chi tim thu muc CHINH XAC
echo Dang squet trong AppData\Local...
set "appDataLocal=%localappdata%"
if exist "%appDataLocal%" (
    for /d %%D in ("%appDataLocal%\%searchExact%") do (
        echo [FOUND - Local AppData] %%D
        echo %%D>>"%tempScanResult%"
        set foundLeftovers=1
    )
    if defined searchPublisher (
        for /d %%D in ("%appDataLocal%\%searchPublisher%") do (
            echo [FOUND - Local AppData] %%D
            echo %%D>>"%tempScanResult%"
            set foundLeftovers=1
        )
    )
)

:: Scan ProgramData - chi tim thu muc CHINH XAC
echo Dang squet trong ProgramData...
if exist "C:\ProgramData" (
    for /d %%D in ("C:\ProgramData\%searchExact%") do (
        echo [FOUND - ProgramData] %%D
        echo %%D>>"%tempScanResult%"
        set foundLeftovers=1
    )
    if defined searchPublisher (
        for /d %%D in ("C:\ProgramData\%searchPublisher%") do (
            echo [FOUND - ProgramData] %%D
            echo %%D>>"%tempScanResult%"
            set foundLeftovers=1
        )
    )
)

:: Scan Program Files - chi neu khong phai la duong dan cai dat chinh
echo Dang squet trong Program Files...
if exist "C:\Program Files" (
    for /d %%D in ("C:\Program Files\%searchExact%") do (
        if /i not "%%D"=="%installPath%" (
            echo [FOUND - Program Files] %%D
            echo %%D>>"%tempScanResult%"
            set foundLeftovers=1
        )
    )
    if defined searchPublisher (
        for /d %%D in ("C:\Program Files\%searchPublisher%") do (
            echo [FOUND - Program Files] %%D
            echo %%D>>"%tempScanResult%"
            set foundLeftovers=1
        )
    )
)

:: Scan Program Files (x86)
echo Dang squet trong Program Files (x86)...
if exist "C:\Program Files (x86)" (
    for /d %%D in ("C:\Program Files (x86)\%searchExact%") do (
        if /i not "%%D"=="%installPath%" (
            echo [FOUND - Program Files x86] %%D
            echo %%D>>"%tempScanResult%"
            set foundLeftovers=1
        )
    )
    if defined searchPublisher (
        for /d %%D in ("C:\Program Files (x86)\%searchPublisher%") do (
            echo [FOUND - Program Files x86] %%D
            echo %%D>>"%tempScanResult%"
            set foundLeftovers=1
        )
    )
)

echo.
echo ======================================================
echo           KET QUA QUET TAN DU
echo ======================================================
echo.

if %foundLeftovers%==0 (
    echo Khong tim thay tan du nao cua ung dung.
    echo.
) else (
    echo Da tim thay cac thu muc lien quan:
    echo.
    type "%tempScanResult%"
    echo.
    echo ======================================================
    echo.
    set /p deleteAll="Ban co muon XOA TAT CA cac thu muc tren? (Y/N): "
    
    if /i "!deleteAll!"=="Y" (
        echo.
        echo Dang xoa cac thu muc...
        for /f "usebackq delims=" %%F in ("%tempScanResult%") do (
            if exist "%%F" (
                echo Xoa: %%F
                rmdir /s /q "%%F" >nul 2>&1
                if exist "%%F" (
                    echo [!] Khong the xoa: %%F ^(co the dang duoc su dung^)
                ) else (
                    echo [OK] Da xoa: %%F
                )
            )
        )
    ) else (
        echo Da huy thao tac xoa.
    )
)

:: Scan Registry (chi hien thi, khong xoa)
echo.
echo ======================================================
echo Dang squet Registry keys lien quan...
echo ======================================================
powershell -Command ^
    "$found = $false; " ^
    "$appName = '%appName%'; " ^
    "$regPaths = @('HKLM:\SOFTWARE', 'HKLM:\SOFTWARE\WOW6432Node', 'HKCU:\Software'); " ^
    "foreach($path in $regPaths) { " ^
    "    try { " ^
    "        Get-ChildItem $path -ErrorAction Stop | Where-Object { $_.PSChildName -eq $appName } | ForEach-Object { " ^
    "            Write-Host \"[FOUND] $($_.PSPath)\"; " ^
    "            $found = $true; " ^
    "        } " ^
    "    } catch { } " ^
    "}; " ^
    "if(-not $found) { Write-Host 'Khong tim thay Registry key chinh xac.' }"

echo.
echo [!] Registry entries chi hien thi, khong tu dong xoa.
echo Ban co the xoa bang cach: Start ^> regedit va tim kiem theo ten ung dung.
echo.

:: Xoa file ket qua tam
if exist "%tempScanResult%" del /f /q "%tempScanResult%"

echo.
endlocal
goto :eof


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
    echo [OK] Da bat Windows Update thanh cong!
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
echo             TUY CHON PHAN MEM DE CAP NHAT
echo ======================================================
echo.
echo Dang ket noi den he thong Windows Package Manager...
echo Vui long doi trong giay lat...
echo.

:: Hien thi danh sach phan mem co ban cap nhat
winget list --upgrade-available
if %errorlevel% neq 0 (
    echo.
    echo LOI: Khong the ket noi den may chu Winget hoac khong co ban cap nhat nao.
    pause
    goto software_health
)

echo.
echo ------------------------------------------------------
echo Huong dan: Copy "ID" o cot thu 2 va Paste vao day.
echo Vi du: Google.Chrome
echo.
echo 0 - Quay lai Menu chinh
echo 1 - Thoat
echo.

set "sw_id="
set /p sw_id="Nhap ID phan mem: "

if "%sw_id%"=="" (
    echo Hay nhap ID hop le!
    timeout /t 2 >nul
    goto sw_update_select
)

if /i "%sw_id%"=="0" goto menu
if /i "%sw_id%"=="1" goto software_health

echo.
echo Dang tai va cai dat ban cap nhat cho: %sw_id%
echo.
:: Them --silent de cai dat ngam neu ho tro
winget upgrade --id "%sw_id%" --accept-package-agreements --accept-source-agreements
if %errorlevel% equ 0 (
    echo.
    echo THANH CONG: Cap nhat %sw_id% hoan tat!
    pause
) else (
    echo.
    echo LOI: Khong the cap nhat %sw_id%.
    echo.
    echo [1] Thu lai
    echo [2] Bo qua kiem tra hash (--force)
    echo [3] Quay lai
    set /p re_choice="Lua chon cua ban: "
    if "%re_choice%"=="2" winget upgrade --id "%sw_id%" --force --accept-package-agreements --accept-source-agreements
    goto sw_update_select
)