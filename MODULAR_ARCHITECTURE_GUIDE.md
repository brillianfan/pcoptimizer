# 📚 HƯỚNG DẪN KIẾN TRÚC MODULAR - PC ULTIMATE OPTIMIZER v1.0.3

## 🎯 Tổng quan

Dự án đã được tái cấu trúc hoàn toàn từ 1 file batch lớn (~900 dòng) thành kiến trúc modular với các modules PowerShell độc lập.

---

## 📂 CẤU TRÚC DỰ ÁN MỚI

```
PCOptimizer/
│
├── PCOptimizer.bat                 ← File batch chính (launcher) - 300 dòng
│   └── Chức năng: Menu và điều hướng đến các modules
│
├── Deep-JunkClean.ps1             ← Module dọn dẹp - 200 dòng
│   ├── Clear-TempFiles
│   ├── Clear-RecycleBin
│   ├── Clear-SystemLogs
│   ├── Start-DiskCleanup
│   ├── Remove-EmptyFolders
│   └── Remove-BrokenShortcuts
│
├── Uninstaller.ps1                ← Module gỡ cài đặt - 350 dòng
│   ├── Get-InstalledApplications
│   ├── Show-ApplicationList
│   ├── Invoke-Uninstall
│   └── Remove-Leftovers
│
├── Optimize-Registry.ps1          ← Module tối ưu Registry - 250 dòng
│   ├── Set-RegistryValue
│   ├── Optimize-SystemResponsiveness
│   ├── Show-CurrentSettings
│   └── Backup-RegistrySettings
│
├── Software-Health.ps1            ← Module cập nhật phần mềm - 300 dòng
│   ├── Test-WingetInstalled
│   ├── Update-AllSoftware
│   ├── Update-SelectedSoftware
│   ├── Show-InstalledSoftware
│   └── Search-Software
│
├── Driver-Update.ps1              ← Module cập nhật driver - 350 dòng
│   ├── Get-AvailableDrivers
│   ├── Show-AvailableDrivers
│   ├── Install-AllDrivers
│   └── Install-SelectedDrivers
│
└── Remove-BrokenShortcuts.ps1    ← Helper script (giữ nguyên)
    └── Xóa shortcuts lỗi
```

---

## 🔄 SO SÁNH TRƯỚC VÀ SAU

### TRƯỚC (Monolithic):
```
PCOptimizer.bat
├── 900+ dòng code
├── Tất cả logic trong 1 file
├── Khó bảo trì
├── Khó debug
└── Khó mở rộng
```

### SAU (Modular):
```
PCOptimizer.bat (300 dòng)
├── Deep-JunkClean.ps1 (200 dòng)
├── Uninstaller.ps1 (350 dòng)
├── Optimize-Registry.ps1 (250 dòng)
├── Software-Health.ps1 (300 dòng)
└── Driver-Update.ps1 (350 dòng)

Tổng: 1,750 dòng (có thêm comments và structure)
```

---

## ✨ ƯU ĐIỂM CỦA KIẾN TRÚC MỚI

### 1. **Separation of Concerns**
- Mỗi module chỉ làm 1 việc
- Không bị lẫn lộn logic
- Dễ hiểu và maintain

### 2. **Reusability**
```powershell
# Có thể dùng module độc lập
.\Deep-JunkClean.ps1 -TempFiles
.\Uninstaller.ps1
.\Optimize-Registry.ps1
```

### 3. **Easier Testing**
```powershell
# Test từng module riêng
Pester Deep-JunkClean.ps1
Pester Uninstaller.ps1
```

### 4. **Better Error Handling**
- Lỗi trong 1 module không ảnh hưởng modules khác
- Try-catch blocks cụ thể
- Error messages rõ ràng

### 5. **Scalability**
```
Thêm tính năng mới:
1. Tạo file .ps1 mới
2. Thêm 3-4 dòng vào PCOptimizer.bat
3. Done!
```

---

## 🛠️ CÁCH HOẠT ĐỘNG

### Flow chính:

```
User chạy PCOptimizer.bat
         ↓
    Check Admin
         ↓
    Show Menu
         ↓
User chọn [1] Deep Clean
         ↓
Batch gọi: powershell -File Deep-JunkClean.ps1 -All
         ↓
    Module thực thi
         ↓
    Trả kết quả
         ↓
    Back to Menu
```

### Code example trong PCOptimizer.bat:

```batch
:deep_junk_clean
cls
echo [1] Clean Temp Files
echo [2] Empty Recycle Bin
echo [7] Clean ALL
set /p clean_choice="Select: "

if "!clean_choice!"=="1" set "ps_args=-TempFiles"
if "!clean_choice!"=="7" set "ps_args=-All"

powershell -ExecutionPolicy Bypass -File "%~dp0Deep-JunkClean.ps1" !ps_args!
pause
goto menu
```

---

## 📋 CHI TIẾT TỪNG MODULE

### 1. Deep-JunkClean.ps1

**Parameters:**
```powershell
-TempFiles         # Xóa file tạm
-RecycleBin        # Làm trống thùng rác
-SystemLogs        # Xóa event logs
-DiskCleanup       # Chạy cleanmgr
-EmptyFolders      # Xóa thư mục rỗng
-BrokenShortcuts   # Xóa shortcuts lỗi
-All               # Làm tất cả
```

**Functions:**
- `Clear-TempFiles`: Xóa temp với protection cho current directory
- `Clear-RecycleBin`: PowerShell built-in
- `Clear-SystemLogs`: Dùng wevtutil
- `Start-DiskCleanup`: Gọi cleanmgr
- `Remove-EmptyFolders`: Scan và interactive delete
- `Remove-BrokenShortcuts`: Call helper script

### 2. Uninstaller.ps1

**Functions:**
- `Get-InstalledApplications`: Query registry cho apps
- `Show-ApplicationList`: Hiển thị indexed list
- `Invoke-Uninstall`: Parse và execute uninstall command
- `Remove-Leftovers`: Scan AppData, ProgramData, Registry

**Features:**
- Smart install location inference
- Safe uninstall command parsing
- Interactive leftover cleanup
- Registry key cleanup

### 3. Optimize-Registry.ps1

**Functions:**
- `Set-RegistryValue`: Safe registry modification
- `Optimize-SystemResponsiveness`: Apply all optimizations
- `Show-CurrentSettings`: Display current vs optimal
- `Backup-RegistrySettings`: Auto backup before changes

**Optimizations:**
```
WaitToKillAppTimeout: 20000 → 2000
MenuShowDelay: 400 → 0
AutoEndTasks: 0 → 1
MouseHoverTime: 400 → 10
NetworkThrottlingIndex: → 4294967295
SystemResponsiveness: → 0
```

### 4. Software-Health.ps1

**Functions:**
- `Test-WingetInstalled`: Check Winget availability
- `Update-AllSoftware`: Winget upgrade --all
- `Update-SelectedSoftware`: Interactive selection
- `Show-InstalledSoftware`: Winget list
- `Search-Software`: Winget search

**Features:**
- Auto-enable Windows Update for Winget
- Retry mechanism on failure
- Force update option
- Clear error messages

### 5. Driver-Update.ps1

**Functions:**
- `Get-AvailableDrivers`: Query Windows Update API
- `Show-AvailableDrivers`: Display driver list with details
- `Install-AllDrivers`: Batch install all drivers
- `Install-SelectedDrivers`: Interactive selection

**Features:**
- Windows Update API integration
- Download progress
- Install status
- Reboot detection
- Safe and verified drivers only

---

## 🚀 CÁCH SỬ DỤNG

### Phương pháp 1: Qua Batch Launcher (Recommended)

```batch
1. Double-click PCOptimizer.bat
2. Chọn chức năng từ menu
3. Module tương ứng sẽ chạy
```

### Phương pháp 2: Chạy trực tiếp Module

```powershell
# Chạy với parameters
powershell -ExecutionPolicy Bypass -File "Deep-JunkClean.ps1" -All

# Chạy interactive
powershell -ExecutionPolicy Bypass -File "Uninstaller.ps1"

# Chạy với options
powershell -ExecutionPolicy Bypass -File "Optimize-Registry.ps1"
```

---

## 🔧 PHÁT TRIỂN & MỞ RỘNG

### Thêm Module Mới:

**Bước 1: Tạo file PowerShell**

```powershell
# NewFeature.ps1
<#
.SYNOPSIS
    Your new feature description
.AUTHOR
    Your Name
#>

param(
    [switch]$Option1,
    [switch]$Option2
)

function Do-Something {
    Write-Host "Doing something..." -ForegroundColor Cyan
    # Your code here
}

# Main execution
if ($Option1) { Do-Something }
```

**Bước 2: Update PCOptimizer.bat**

```batch
# Thêm vào menu
echo [12] New Feature

# Thêm condition
if "!select!"=="12" goto new_feature

# Thêm function
:new_feature
cls
powershell -ExecutionPolicy Bypass -File "%~dp0NewFeature.ps1"
pause
goto menu
```

**Bước 3: Test**

```batch
# Test module riêng
powershell -File NewFeature.ps1 -Option1

# Test qua batch
PCOptimizer.bat → Chọn [12]
```

---

## 📝 CODING STANDARDS

### PowerShell Modules:

```powershell
# 1. File header với synopsis
<#
.SYNOPSIS
    Module name
.DESCRIPTION
    Detailed description
.VERSION
    1.0.2
.AUTHOR
    Brillian Pham
#>

# 2. Parameters nếu cần
param(
    [switch]$Option1,
    [string]$StringParam
)

# 3. Functions với Verb-Noun naming
function Get-Something { }
function Set-Something { }
function Remove-Something { }

# 4. Main execution
Write-Host "Module starting..."
# Logic here
```

### Batch File:

```batch
:: Clear commenting
:: Function naming: :function_name

:function_name
cls
echo Description
set /p choice="Select: "
if "%choice%"=="1" goto action
goto menu
```

---

## 🐛 DEBUGGING

### PowerShell Modules:

```powershell
# Enable verbose
$VerbosePreference = 'Continue'
Write-Verbose "Debug info"

# Add try-catch
try {
    # Code
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test individually
.\Module.ps1 -Verbose
```

### Batch Debugging:

```batch
:: Add echo for variables
echo Debug: choice=%choice%

:: Pause để xem output
pause

:: Redirect errors
command 2>error.log
```

---

## 📊 PERFORMANCE

### Measurements:

**Old Monolithic:**
- Load time: ~2s (load toàn bộ 900 dòng)
- Memory: ~15MB
- Khó optimize

**New Modular:**
- Load time: ~0.5s (chỉ load launcher)
- Module load: ~0.3s mỗi module
- Memory: ~8MB (launcher) + ~5-10MB (module)
- Dễ optimize từng module

---

## 🔒 SECURITY

### Module Isolation:
- Mỗi module chạy trong scope riêng
- Lỗi không lan sang module khác
- Dễ audit code

### Execution Policy:
```powershell
# Recommended
powershell -ExecutionPolicy Bypass -File "script.ps1"

# Or set globally (as Admin)
Set-ExecutionPolicy RemoteSigned
```

---

## 📚 TÀI LIỆU THAM KHẢO

### PowerShell Best Practices:
- https://docs.microsoft.com/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines
- https://github.com/PoshCode/PowerShellPracticeAndStyle

### Batch Scripting:
- https://ss64.com/nt/
- https://stackoverflow.com/questions/tagged/batch-file

---

## 🎯 ROADMAP

### v1.1.0 (Kế hoạch):
- [ ] Thêm logging system module
- [ ] Thêm config file support
- [ ] Thêm undo/rollback module
- [ ] GUI wrapper (optional)

### v1.2.0:
- [ ] SSD optimization module
- [ ] Privacy tweaks module
- [ ] GPU optimization module
- [ ] Scheduled tasks module

---

## 💡 TIPS & TRICKS

### 1. Chạy module với elevated privileges:

```powershell
Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSScriptRoot\Module.ps1`""
```

### 2. Pass variables giữa batch và PowerShell:

```batch
set "MY_VAR=value"
powershell -Command "$env:MY_VAR"
```

### 3. Return codes từ PowerShell:

```powershell
exit 0  # Success
exit 1  # Error
```

```batch
if %errorlevel% equ 0 (
    echo Success
) else (
    echo Failed
)
```

---

## 🆘 TROUBLESHOOTING

### Module không chạy:
```powershell
# Check execution policy
Get-ExecutionPolicy

# Set to bypass
Set-ExecutionPolicy Bypass -Scope Process
```

### Parameters không hoạt động:
```powershell
# Check parameter syntax
Get-Help .\Module.ps1 -Full

# Run with explicit params
.\Module.ps1 -ParameterName "Value"
```

### Encoding issues:
```powershell
# Add to top of .ps1 file
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

---

## 📞 HỖ TRỢ

Có câu hỏi về kiến trúc modular?

- 📧 Email: pcoptimizer.seventy907@slmail.me
- 🐙 GitHub Issues: https://github.com/brillianfan/pcoptimizer/issues
- 💬 Telegram: @goodlove9179

---

**Tạo bởi: Brillian Pham**  
**Ngày: February 03, 2026**  
**Version: 1.0.3 - Modular Architecture**
