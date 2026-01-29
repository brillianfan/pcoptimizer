# 🚀 PC Ultimate Optimizer

> Công cụ tối ưu hóa và quản trị hệ thống Windows toàn diện

[![VirusTotal Scan](https://img.shields.io/badge/VirusTotal-Scanned-brightgreen)](https://www.virustotal.com/gui/url/571e95a4c0e63bf5165352d304b72aab6d2c46394bc0cbbd1648167fe519ab56/detection)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Windows](https://img.shields.io/badge/Platform-Windows%2010%2F11-0078D6)](https://www.microsoft.com/windows)

---

## ⚠️ THÔNG BÁO QUAN TRỌNG VỀ ANTIVIRUS

**Tại sao Antivirus có thể cảnh báo?**

Script này là **HOÀN TOÀN AN TOÀN** nhưng sử dụng các quyền quản trị để:
- ✅ Dọn dẹp file tạm và cache hệ thống
- ✅ Tối ưu hóa Registry Windows
- ✅ Quản lý dịch vụ Windows Update
- ✅ Thực thi lệnh PowerShell với quyền Admin

Đây là **hành vi bình thường** của mọi công cụ tối ưu hệ thống (CCleaner, Glary Utilities, etc.)

### 🛡️ Bằng chứng An toàn:
- 📂 **Source code mở 100%** - Bạn có thể đọc và kiểm tra từng dòng code
- 🔍 **VirusTotal scan**: [Xem kết quả quét](https://www.virustotal.com/gui/url/571e95a4c0e63bf5165352d304b72aab6d2c46394bc0cbbd1648167fe519ab56/detection)
- 👤 **Tác giả**: Brillian Pham
- 📧 **Liên hệ**: pcoptimizer.seventy907@slmail.me

---

## 📋 Tính năng

### 🧹 **Deep Junk Clean**
- Xóa file tạm (Temp, Prefetch)
- Dọn Windows Cache
- Làm trống Recycle Bin (Thùng rác)
- Xóa System Event Logs (Nhật ký hệ thống)
- Chạy Windows Disk Cleanup
- Quét và xóa thư mục rỗng (ProgramData, AppData, Program Files…)
- **Xóa shortcuts lỗi** – các liên kết (.lnk) trỏ tới file/thư mục đã bị xóa (Desktop, Start Menu, Quick Launch)

### 🗑️ **Uninstaller**
- Liệt kê danh sách ứng dụng từ Registry (sắp xếp A–Z)
- Chọn theo số thứ tự để gỡ bỏ phần mềm
- Tuỳ chọn quét và xóa tàn dư (AppData, ProgramData, Registry) sau khi gỡ

### ⚡ **Startup Manager**
- Mở Task Manager (tab Startup) để quản lý ứng dụng khởi động cùng Windows
- Hướng dẫn Disable các ứng dụng không cần thiết

### 🔄 **Toggle Windows Update**
- Bật/Tắt tạm thời Windows Update
- Hữu ích khi cần kiểm soát cập nhật

### ⚙️ **Optimize Registry**
- Giảm thời gian chờ đóng ứng dụng (20s → 2s)
- Loại bỏ độ trễ Menu (400ms → 0ms)
- Tự động tắt ứng dụng không phản hồi
- Tăng tốc độ phản hồi chuột/bàn phím
- Tối ưu hóa Network Throttling

### 💻 **View PC Specs**
- Hiển thị thông tin cấu hình chi tiết
- CPU, RAM, GPU, Mainboard, Ổ cứng

### 🔑 **Windows & Office Activation**
- Kiểm tra phiên bản Windows & Office
- Kiểm tra trạng thái bản quyền (slmgr /xpr, ospp.vbs)
- Mở công cụ kích hoạt MAS (Microsoft Activation Scripts – get.activated.win)

### 🌐 **Internet Boost**
- Tối ưu TCP/IP settings
- Bật RSS, FastOpen
- Flush DNS Cache

### 🔧 **Disk Check**
- Lên lịch kiểm tra lỗi ổ cứng
- Chạy CHKDSK tại lần khởi động tiếp theo

### 📦 **Software Health**
- Cập nhật phần mềm qua Windows Package Manager (Winget)
- **Update All**: cập nhật tất cả phần mềm có bản mới
- **Update Selected**: nhập ID (ví dụ Google.Chrome) để cập nhật từng phần mềm

---

## 🚀 Cách sử dụng

### Bước 1: Tải về
```bash
git clone https://github.com/brillianfan/pcoptimizer.git
cd pcoptimizer
```

Hoặc tải file ZIP: [Download](https://github.com/brillianfan/pcoptimizer/archive/refs/heads/main.zip)

### Bước 2: Chạy script
1. Double Click vào `PCOptimizer.bat` để chạy
2. Chọn Yes để cho phép công cụ chạy với quyền quản trị **"Run as Administrator"**
3. Chọn chức năng từ menu

### Bước 3: Xử lý cảnh báo Antivirus (nếu có)

#### **Windows Defender:**
1. Mở **Windows Security**
2. **Virus & threat protection** → **Manage settings**
3. **Exclusions** → **Add or remove exclusions**
4. Thêm file `PCOptimizer.bat` hoặc thư mục chứa script

#### **Antivirus khác:**
- Thêm vào **Whitelist/Exclusions/Trusted Files**
- Hoặc tạm thời tắt Real-time Protection trước khi chạy

---

## 📸 Screenshots

```
======================================================
          CONG CU QUAN TRI & TOI UU PC
               by Brillian Pham
======================================================
[1] Deep Junk Clean (Don rac & Giai phong dung luong)
[2] Uninstaller (Go phan mem)
[3] Startup Manager (Quan ly cac ung dung khoi dong cung Windows)
[4] Toggle Windows Update (Bat/Tat tam thoi)
[5] Optimize Registry (Toi uu hoa Registry)
[6] View PC Specs (Xem cau hinh PC)
[7] Windows & Office Activation (Kiem tra & Kich hoat ban quyen)
[8] Internet Boost (Toi uu toc do mang & Ping)
[9] Disk Check (Quet loi o cung)
[10] Software Health (Cap nhat phan mem PC)
[0] Exit
======================================================
```

---

## ⚙️ Yêu cầu hệ thống

- 💻 **OS**: Windows 10/11 (64-bit khuyến nghị)
- 🔑 **Quyền**: Administrator
- 📦 **Dependencies**: 
  - PowerShell 5.1+ (có sẵn trong Windows)
  - Windows Package Manager (Winget) - cho chức năng Software Health

---

## 🔒 Chính sách Bảo mật

### ✅ Script này KHÔNG:
- ❌ Thu thập dữ liệu cá nhân
- ❌ Kết nối internet (trừ khi bạn chọn chức năng cập nhật)
- ❌ Cài đặt phần mềm ẩn
- ❌ Thay đổi hệ thống mà không thông báo
- ❌ Chứa malware/virus/trojan

### ✅ Script này CHỈ:
- ✅ Thực hiện các lệnh Windows chuẩn
- ✅ Sử dụng công cụ tích hợp sẵn (cleanmgr, chkdsk, winget)
- ✅ Chỉnh sửa Registry để tối ưu hiệu suất
- ✅ Hoàn toàn minh bạch - mã nguồn mở

---

## 🤝 Đóng góp

Mọi đóng góp đều được hoan nghênh!

1. Fork repo này
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit thay đổi (`git commit -m 'Add some AmazingFeature'`)
4. Push lên branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

---

## 📝 License

Dự án này được phân phối dưới giấy phép MIT License. Xem file [LICENSE](LICENSE) để biết thêm chi tiết.

---

## 📞 Liên hệ

**Brillian Pham**
- 📧 Email: [pcoptimizer.seventy907@slmail.me]
- 🐙 GitHub: [@brillianfan](https://github.com/brillianfan)
- Telegram: @goodlove9179
---

## 📜 Changelog

### v1.0.1 (2026-01-29)
- 🧹 **Deep Junk Clean**: Thêm xóa shortcuts lỗi (Desktop, Start Menu, Quick Launch)
- 📋 README đồng bộ với danh sách tính năng thực tế
- 🔧 Sửa một số lỗi

### v1.0.0 (2026-01-28)
- 🎉 Phiên bản đầu tiên
- ✨ 10 chức năng tối ưu hệ thống
- 🔧 Hỗ trợ Windows 10/11

---

## ❓ FAQ

**Q: Tại sao cần quyền Administrator?**  
A: Để có thể xóa file hệ thống, chỉnh sửa Registry, và quản lý dịch vụ Windows.

**Q: Có an toàn không?**  
A: Hoàn toàn an toàn. Source code mở 100% để bạn kiểm tra.

**Q: Có tương thích với Windows 11?**  
A: Có, hoàn toàn tương thích với cả Windows 10 và 11.

**Q: Có cần Internet không?**  
A: Không bắt buộc. Chỉ cần Internet cho chức năng Software Health (cập nhật phần mềm).

---

<div align="center">

**Made by ❤️ Brillian Pham**

[⬆ Back to top](#-pc-ultimate-optimizer)

</div>
