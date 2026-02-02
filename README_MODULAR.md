# 🚀 PC Ultimate Optimizer v1.0.2

> Công cụ tối ưu hóa và quản trị hệ thống Windows toàn diện - Modular Architecture

[![VirusTotal Scan](https://img.shields.io/badge/VirusTotal-Scanned-brightgreen)](https://www.virustotal.com/gui/url/73cf6a8d9251593ef1433a50a56de686889b906643717d74f7202c5c255d4bcd?nocache=1)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Windows](https://img.shields.io/badge/Platform-Windows%2010%2F11-0078D6)](https://www.microsoft.com/windows)
[![Version](https://img.shields.io/badge/Version-1.0.2-blue)](https://github.com/brillianfan/pcoptimizer/releases)

---

## ✨ Điểm mới trong v1.0.2

### 🏗️ **Kiến trúc Modular**
- Mỗi tính năng được tách thành file PowerShell riêng
- Code dễ bảo trì và mở rộng
- Giảm độ phức tạp của file chính
- Tối ưu hiệu suất

### 📂 **Cấu trúc dự án**

```
PCOptimizer/
├── PCOptimizer.bat              ← File batch chính (launcher)
├── Deep-JunkClean.ps1           ← Module dọn dẹp hệ thống
├── Uninstaller.ps1              ← Module gỡ cài đặt
├── Optimize-Registry.ps1        ← Module tối ưu Registry
├── Software-Health.ps1          ← Module cập nhật phần mềm
├── Driver-Update.ps1            ← Module cập nhật driver
├── Remove-BrokenShortcuts.ps1   ← Helper script
└── README.md
```

---

## 📋 Tính năng

### 🧹 **Deep Junk Clean** (Deep-JunkClean.ps1)
- Clean Temp files (User & Windows)
- Empty Recycle Bin
- Clear System Event Logs
- Run Windows Disk Cleanup
- Remove Empty Folders
- Remove Broken Shortcuts
- **Modular options**: Chọn từng chức năng hoặc ALL

**Usage:**
```powershell
# Clean all
.\Deep-JunkClean.ps1 -All

# Clean specific
.\Deep-JunkClean.ps1 -TempFiles
.\Deep-JunkClean.ps1 -RecycleBin
.\Deep-JunkClean.ps1 -EmptyFolders
```

### 🗑️ **Uninstaller** (Uninstaller.ps1)
- List installed applications from Registry
- Smart uninstall with command parsing
- Leftover scanner (AppData, ProgramData, Registry)
- Interactive cleanup confirmation
- Publisher and location detection

**Usage:**
```powershell
.\Uninstaller.ps1
```

### ⚙️ **Optimize Registry** (Optimize-Registry.ps1)
- Reduce app close timeout (2s)
- Remove menu delay (0ms)
- Auto-close unresponsive apps
- Increase mouse/keyboard responsiveness
- Optimize network throttling
- **Registry backup** before changes

**Usage:**
```powershell
.\Optimize-Registry.ps1
```

### 📦 **Software Health** (Software-Health.ps1)
- Update all software via Winget
- Update selected software
- Show installed software
- Search for software
- Auto-enable Windows Update for Winget

**Usage:**
```powershell
.\Software-Health.ps1
```

### 🔌 **Driver Update** (Driver-Update.ps1)
- Check available driver updates
- Update all drivers
- Update selected drivers
- Windows Update API integration
- **Enhanced Reliability**: Tự động quản lý dịch vụ Windows Update
- Safe and verified drivers only

**Usage:**
```powershell
.\Driver-Update.ps1
```

### ⚡ **Startup Manager**
- Open Task Manager (Startup tab)
- Keyboard shortcuts automation
- Easy management of startup apps

### 🔄 **Toggle Windows Update**
- Enable/Disable Windows Update service
- Quick control via batch commands

### 💻 **View PC Specs**
- CPU, RAM, GPU information
- Motherboard details
- Storage devices
- Operating system info

### 🔑 **Windows & Office Activation**
- Check Windows/Office versions
- Check license status
- MAS Script integration

### 🌐 **Internet Boost**
- TCP/IP optimization
- Enable RSS and Fast Open
- Flush DNS cache

### 🔧 **Disk Check**
- Schedule CHKDSK on next boot

---

## 🚀 Cách sử dụng

### Phương pháp 1: Qua file batch chính (Khuyến nghị)

```bash
# 1. Download tất cả files
git clone https://github.com/brillianfan/pcoptimizer.git
cd pcoptimizer

# 2. Chạy file batch chính
PCOptimizer.bat

# 3. Chọn chức năng từ menu
```

### Phương pháp 2: Chạy trực tiếp module PowerShell

```powershell
# Chạy Deep Clean với tất cả options
powershell -ExecutionPolicy Bypass -File "Deep-JunkClean.ps1" -All

# Chạy Uninstaller
powershell -ExecutionPolicy Bypass -File "Uninstaller.ps1"

# Optimize Registry
powershell -ExecutionPolicy Bypass -File "Optimize-Registry.ps1"

# Software Health
powershell -ExecutionPolicy Bypass -File "Software-Health.ps1"

# Driver Update
powershell -ExecutionPolicy Bypass -File "Driver-Update.ps1"
```

---

## 💡 Ưu điểm của kiến trúc Modular

### 1. **Dễ bảo trì**
- Mỗi module độc lập
- Sửa lỗi dễ dàng
- Không ảnh hưởng modules khác

### 2. **Dễ mở rộng**
- Thêm tính năng mới = Thêm file .ps1 mới
- Không cần sửa file chính nhiều

### 3. **Tái sử dụng**
- Modules có thể dùng riêng lẻ
- Tích hợp vào scripts khác

### 4. **Testing**
- Test từng module độc lập
- Debug nhanh hơn

### 5. **Performance**
- Chỉ load module cần thiết
- Tiết kiệm tài nguyên

---

## 🔧 Phát triển & Mở rộng

### Thêm module mới:

1. **Tạo file PowerShell**
```powershell
# NewFeature.ps1
<#
.SYNOPSIS
    Your new feature
.DESCRIPTION
    Detailed description
#>

Write-Host "Your feature implementation"
```

2. **Thêm vào PCOptimizer.bat**
```batch
if "!select!"=="12" goto new_feature

:new_feature
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0NewFeature.ps1"
goto menu
```

3. **Update menu**
```batch
echo [12] New Feature
```

---

## 📝 Best Practices

### Khi sử dụng modules:

1. **Luôn chạy với quyền Administrator**
```bash
# Batch file tự động yêu cầu Admin
# Hoặc chạy PowerShell as Admin:
powershell -ExecutionPolicy Bypass -File "script.ps1"
```

2. **Backup trước khi optimize**
```powershell
# Registry module tự động tạo backup
.\Optimize-Registry.ps1
```

3. **Kiểm tra kết quả**
```powershell
# Mỗi module hiển thị kết quả rõ ràng
# [OK], [ERROR], [WARNING] status
```

4. **Đọc help của từng module**
```powershell
Get-Help .\Deep-JunkClean.ps1 -Full
```

---

## ⚙️ Yêu cầu hệ thống

- 💻 **OS**: Windows 10/11 (64-bit khuyến nghị)
- 🔑 **Quyền**: Administrator
- 📦 **Dependencies**: 
  - PowerShell 5.1+ (built-in)
  - Windows Package Manager (Winget) - cho Software Health
  - Windows Update Service - cho Driver Update
  - .NET Framework 4.5+ (built-in)

---

## 🔒 Chính sách Bảo mật

### ✅ Script này KHÔNG:
- ❌ Thu thập dữ liệu cá nhân
- ❌ Kết nối internet trái phép
- ❌ Cài đặt phần mềm ẩn
- ❌ Chứa malware/virus

### ✅ Script này CHỈ:
- ✅ Sử dụng Windows built-in commands
- ✅ Source code 100% công khai
- ✅ Modular và dễ audit
- ✅ MIT License - Miễn phí mãi mãi

---

## 🤝 Đóng góp

### Cách thêm tính năng mới:

1. Fork repository
2. Tạo module .ps1 mới
3. Update PCOptimizer.bat
4. Test kỹ lưỡng
5. Tạo Pull Request

**Xem [CONTRIBUTING.md](CONTRIBUTING.md) để biết chi tiết**

---

## 📝 License

MIT License - Xem file [LICENSE](LICENSE)

---

## 📞 Liên hệ

**Brillian Pham**
- 📧 Email: pcoptimizer.seventy907@slmail.me
- 🐙 GitHub: [@brillianfan](https://github.com/brillianfan)
- 💬 Telegram: @goodlove9179

---

## 📜 Changelog

### v1.0.2 (2026-01-30)
- 🏗️ **Modular Architecture**: Tách modules thành files riêng
- 🔌 **Driver Update**: Tính năng cập nhật driver
- 📦 **Improved Uninstaller**: Smart parsing và leftover cleanup
- ⚙️ **Registry Optimizer**: Backup và restore support
- 📚 **Better Documentation**: README chi tiết hơn

### v1.0.1 (2026-01-29)
- 🧹 Thêm xóa shortcuts lỗi
- 📋 Đồng bộ documentation

### v1.0.0 (2026-01-28)
- 🎉 Phiên bản đầu tiên
- ✨ 10 chức năng cơ bản

---

## ❓ FAQ

**Q: Tại sao chia thành nhiều files?**  
A: Dễ bảo trì, mở rộng, và tái sử dụng. Mỗi module độc lập.

**Q: Có thể chạy module riêng lẻ không?**  
A: Có! Mỗi file .ps1 có thể chạy độc lập.

**Q: Cần cài thêm gì không?**  
A: Không! Chỉ cần Windows 10/11 với PowerShell built-in.

**Q: An toàn không?**  
A: 100% an toàn. Source code công khai, VirusTotal clean.

---

<div align="center">

**Made with ❤️ by Brillian Pham**

**⭐ Star nếu thấy hữu ích!**

[⬆ Back to top](#-pc-ultimate-optimizer-v102)

</div>
