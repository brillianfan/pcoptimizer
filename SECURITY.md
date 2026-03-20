# 🔒 Security Policy

## Báo cáo Lỗ hổng Bảo mật

Nếu bạn phát hiện lỗ hổng bảo mật trong dự án này, vui lòng **KHÔNG** tạo public issue.

### Cách báo cáo:

1. **Email**: Gửi báo cáo chi tiết đến pcoptimizer.seventy907@slmail.me
2. **Tiêu đề**: `[SECURITY] PC Optimizer - [Mô tả ngắn]`
3. **Nội dung bao gồm**:
   - Mô tả lỗ hổng
   - Các bước tái hiện
   - Tác động có thể xảy ra
   - Đề xuất khắc phục (nếu có)

### Cam kết:

- ✅ Phản hồi trong vòng **48 giờ**
- ✅ Khắc phục trong vòng **7 ngày** (nếu nghiêm trọng)
- ✅ Credit cho người phát hiện (nếu bạn muốn)

---

## Chính sách Bảo mật

### ✅ Dự án này CAM KẾT:

1. **Minh bạch 100%**
   - Source code công khai
   - Không có mã ẩn hoặc obfuscated
   - Mọi thay đổi đều được commit rõ ràng

2. **Không thu thập dữ liệu**
   - Không gửi thông tin về máy chủ
   - Không tracking
   - Không analytics
   - Không telemetry

3. **Không có backdoor**
   - Không kết nối internet không rõ ràng
   - Không cài đặt phần mềm ẩn
   - Không tạo tài khoản hoặc service ẩn

4. **Quyền tối thiểu**
   - Chỉ yêu cầu quyền Administrator khi thực sự cần
   - Mỗi chức năng đều có thông báo rõ ràng
   - Người dùng có thể từ chối bất kỳ thao tác nào

### ✅ Những gì Script THỰC SỰ làm:

#### Deep Junk Clean:
```batch
del /s /f /q %temp%\*.*              # Xóa file tạm người dùng
del /s /f /q C:\Windows\Temp\*.*     # Xóa file tạm Windows
del /s /f /q C:\Windows\Prefetch\*.* # Xóa Prefetch
Clear-RecycleBin -Force              # Làm trống thùng rác
wevtutil.exe cl                      # Xóa Event Logs
cleanmgr /sagerun:1                  # Chạy Disk Cleanup
```

#### Uninstaller:
```powershell
# Desktop Apps (Registry):
Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, UninstallString

# Store Apps (PowerShell):
Get-AppxPackage | Where-Object -Property NonRemovable -eq $False | Where-Object -Property IsFramework -eq $False
```
- Liệt kê apps từ Registry và Microsoft Store.
- Chạy lệnh gỡ cài đặt tiêu chuẩn hoặc `Remove-AppxPackage`.

#### Startup Manager:
```powershell
Start-Process taskmgr; $wshell.SendKeys('^{TAB}') 
# Mở Task Manager trực tiếp tại tab Startup
```

#### Toggle Windows Update:
```batch
sc config wuauserv start= demand/disabled
net start/stop wuauserv
# Điều khiển dịch vụ Windows Update qua lệnh sc và net
```

#### Optimize Registry:
```batch
WaitToKillAppTimeout = 2000          # Giảm thời gian chờ đóng app
MenuShowDelay = 0                    # Loại bỏ độ trễ menu
AutoEndTasks = 1                     # Tự động đóng app không phản hồi
MouseHoverTime = 10                  # Tăng độ nhạy chuột
NetworkThrottlingIndex = 4294967295  # Tối ưu mạng
SystemResponsiveness = 0             # Tối ưu phản hồi hệ thống
```

#### View PC Specs:
```powershell
Get-WmiObject Win32_OperatingSystem, Win32_Processor, Win32_PhysicalMemory...
# Chỉ đọc thông tin phần cứng qua WMI, không sửa đổi
```

#### Windows & Office Info:
```powershell
# Kiểm tra bản quyền:
slmgr.vbs /xpr
```

#### Internet Boost:
```batch
netsh int tcp set global autotuninglevel=normal
netsh int tcp set global rss=enabled
netsh int tcp set global fastopen=enabled
netsh interface tcp set global timestamps=disabled
ipconfig /flushdns
```

#### Disk Check:
```batch
chkdsk C: /f
# Lên lịch kiểm tra lỗi ổ cứng hệ thống
```

#### Software Health:
```batch
winget upgrade --all
# Sử dụng Windows Package Manager chính chủ để cập nhật apps
```

#### Driver Update (NEW):
```powershell
# Sử dụng Windows Update API chính thức
$updateSession = New-Object -ComObject Microsoft.Update.Session
$updateSearcher = $updateSession.CreateUpdateSearcher()
$searchResult = $updateSearcher.Search('IsInstalled=0 and Type="Driver"')
# Chỉ tìm và cài đặt drivers từ Windows Update (Microsoft)
# KHÔNG tải drivers từ nguồn bên thứ ba
```

### ⚠️ Các thao tác CẦN QUYỀN ADMIN:

| Chức năng | Tại sao cần Admin | An toàn? |
|-----------|-------------------|----------|
| Dọn rác | Xóa file hệ thống | ✅ Có |
| Registry | Sửa HKLM keys | ✅ Có |
| Update | Quản lý dịch vụ | ✅ Có |
| Disk Check | Chạy chkdsk | ✅ Có |
| Gỡ app | Chạy uninstaller | ✅ Có |
| Winget | Cài đặt hệ thống | ✅ Có |
| **Driver Update** | Truy cập Windows Update API | ✅ Có |

---

## False Positive trên Antivirus

### Tại sao bị đánh dấu?

Script này có thể bị một số antivirus cảnh báo vì:

1. **Yêu cầu quyền Administrator**
   ```batch
   powershell -Command "Start-Process '%~0' -Verb RunAs"
   ```

2. **Chỉnh sửa Registry**
   ```batch
   reg add "HKCU\Control Panel\Desktop" ...
   ```

3. **Tắt dịch vụ Windows**
   ```batch
   sc config wuauserv start= disabled
   ```

4. **Xóa file hệ thống**
   ```batch
   del /s /f /q C:\Windows\Temp\*.*
   ```

5. **Truy cập Windows Update API** (NEW)
   ```powershell
   New-Object -ComObject Microsoft.Update.Session
   ```

### Đây là **FALSE POSITIVE**

- ✅ Tất cả lệnh đều là Windows built-in commands
- ✅ Không có mã độc
- ✅ Không tải file từ internet (trừ khi bạn chọn)
- ✅ Source code mở để kiểm tra
- ✅ Driver Update chỉ dùng Windows Update chính thức

### Antivirus thường báo nhầm:

| Antivirus | Detection Name | Lý do |
|-----------|----------------|-------|
| Windows Defender | `PUA:Win32/Optimizer` | Hành vi chỉnh sửa hệ thống |
| McAfee | `Artemis!` | Heuristic detection |
| Avast | `Win32:Evo-gen` | Generic pattern |
| AVG | `Generic` | Hành vi yêu cầu Admin |
| Kaspersky | `not-a-virus:HEUR:RiskTool` | Truy cập Windows Update |

---

## Hướng dẫn Xác minh An toàn

### 1. Kiểm tra Source Code

```bash
# Clone repo
git clone https://github.com/brillianfan/pcoptimizer.git

# Đọc toàn bộ code
notepad PCOptimizer.bat

# Tìm kiếm từ khóa nguy hiểm
findstr /i "download upload send http" PCOptimizer.bat
# Ngoại trừ: Windows Update API
```

### 2. Quét VirusTotal

- Link quét: [VirusTotal Scan Results](https://www.virustotal.com/gui/url/73cf6a8d9251593ef1433a50a56de686889b906643717d74f7202c5c255d4bcd?nocache=1)
- Engines: 60+ antivirus
- Kết quả: Chấp nhận được với < 5 detections (False Positive)

### 3. Chạy trong Sandbox (nâng cao)

```powershell
# Sử dụng Windows Sandbox
# 1. Bật Windows Sandbox
# 2. Copy file vào Sandbox
# 3. Chạy và quan sát
```

---

## Phiên bản An toàn được hỗ trợ

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

---

## Best Practices

### Trước khi chạy:

1. ✅ Đọc README.md
2. ✅ Kiểm tra source code
3. ✅ Tạo System Restore Point
4. ✅ Backup Registry (nếu lo lắng)
5. ✅ Đóng các ứng dụng quan trọng
6. ✅ Backup drivers quan trọng (nếu dùng Driver Update)

### Sau khi chạy:

1. ✅ Restart máy tính (đặc biệt sau Driver Update)
2. ✅ Kiểm tra hệ thống hoạt động bình thường
3. ✅ Kiểm tra devices hoạt động đúng (sau Driver Update)
4. ✅ Báo cáo nếu có vấn đề

---

## Driver Update - An toàn như thế nào?

### ✅ Nguồn drivers:
- Chỉ sử dụng **Windows Update** chính thức của Microsoft
- KHÔNG tải drivers từ bên thứ ba
- KHÔNG cài đặt drivers không được Microsoft xác minh

### ✅ Quy trình:
1. Kết nối Windows Update API
2. Tìm kiếm drivers được Microsoft phê duyệt
3. Tải về từ máy chủ Microsoft
4. Xác minh chữ ký số
5. Cài đặt với quyền Administrator

### ✅ Kiểm soát:
- Hiển thị đầy đủ thông tin driver trước khi cài
- Cho phép chọn lựa drivers cụ thể
- Thông báo khi cần khởi động lại
- Có thể rollback drivers qua Device Manager

### ⚠️ Lưu ý:
- Nên backup drivers hiện tại trước khi update
- Đọc kỹ tên driver trước khi cài
- Khởi động lại sau khi update để áp dụng đầy đủ

---

## Liên hệ

- **Email**: pcoptimizer.seventy907@slmail.me
- **GitHub Issues**: [Create Issue](https://github.com/brillianfan/pcoptimizer/issues)
- **Telegram**: @goodlove9179

---

## Changelog Bảo mật

### v2.0.0 (2026-03-20)
- ✅ Added Microsoft Store Apps uninstallation support
- ✅ Uses standard `Remove-AppxPackage` PowerShell command
- ✅ No additional third-party dependencies for Store apps
- ✅ Full synchronization of security documentation

### v1.0.5 (2026-02-23)
- ✅ Removed Windows & Office Activation to comply with GitHub TOS
- ✅ Windows & Office Info: Restricted to status checking only
- ✅ Synchronized documentation across all files

### v1.0.3 (2026-02-03)
- ✅ Added Offline Activation Fallback
- ✅ Advanced Leftover Cleanup using wildcards
- ✅ Synchronized documentation across all files

### v1.0.2 (2026-01-30)
- ✅ Added Driver Update feature
- ✅ Uses official Windows Update API only
- ✅ No third-party driver sources
- ✅ Full transparency in driver information
- ✅ User control over driver selection

### v1.0.0 (2026-01-28)
- ✅ Initial release
- ✅ Full source code transparency
- ✅ No network connections (except opt-in features)
- ✅ No data collection
- ✅ MIT License

---

**Last updated**: March 20, 2026
