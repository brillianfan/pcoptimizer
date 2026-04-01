# 🚀 PC Ultimate Optimizer

> Công cụ tối ưu hóa và quản trị hệ thống Windows toàn diện

[![VirusTotal Scan](https://img.shields.io/badge/VirusTotal-Scanned-brightgreen)](https://www.virustotal.com/gui/url/73cf6a8d9251593ef1433a50a56de686889b906643717d74f7202c5c255d4bcd?nocache=1)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Windows](https://img.shields.io/badge/Platform-Windows%2010%2F11-0078D6)](https://www.microsoft.com/windows)
[![Version](https://img.shields.io/badge/Version-2.1.0-blue)](https://github.com/brillianfan/pcoptimizer/releases)

---

## ⚠️ THÔNG BÁO QUAN TRỌNG VỀ ANTIVIRUS

**Tại sao Antivirus có thể cảnh báo?**

Script này là **HOÀN TOÀN AN TOÀN** nhưng sử dụng các quyền quản trị để:
- ✅ Dọn dẹp file tạm và cache hệ thống
- ✅ Tối ưu hóa Registry Windows
- ✅ Quản lý dịch vụ Windows Update
- ✅ Thực thi lệnh PowerShell với quyền Admin
- ✅ Cập nhật drivers thông qua Windows Update

Đây là **hành vi bình thường** của mọi công cụ tối ưu hệ thống (CCleaner, Glary Utilities, etc.)

### 🛡️ Bằng chứng An toàn:
- 📂 **Source code mở 100%** - Bạn có thể đọc và kiểm tra từng dòng code
- 🔍 **VirusTotal scan**: [Xem kết quả quét](https://www.virustotal.com/gui/url/73cf6a8d9251593ef1433a50a56de686889b906643717d74f7202c5c255d4bcd?nocache=1)
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

### 🗑️ **Advanced Uninstaller**
- Liệt kê danh sách ứng dụng từ Registry và **Microsoft Store**.
- Giao diện chọn ứng dụng trực quan.
- Tự động quét và xóa tàn dư (AppData, ProgramData, Registry) sau khi gỡ cài đặt.

### ⚡ **Startup Manager**
- Mở Task Manager (tab Startup) để quản lý ứng dụng khởi động cùng Windows
- Hướng dẫn Disable các ứng dụng không cần thiết

### 🔄 **Toggle Windows Update**
- Bật/Tắt tạm thời Windows Update
- Hữu ích khi cần kiểm soát cập nhật

### ⚙️ **Optimize Registry**
- Giảm thời gian chờ đóng ứng dụng (20s -> 2s)
- Loại bỏ độ trễ Menu (400ms -> 0ms)
- Tự động tắt ứng dụng không phản hồi
- Tăng tốc độ phản hồi chuột/bàn phím
- Tối ưu hóa Network Throttling

### 💻 **View PC Specs**
- Hiển thị thông tin cấu hình chi tiết
- CPU, RAM, GPU, Mainboard, Ổ cứng

### 🔑 **Windows & Office Info**
- Kiểm tra phiên bản Windows & Office
- Kiểm tra trạng thái bản quyền (slmgr /xpr, ospp.vbs)

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

### 🔌 **Driver Update** ✨ MỚI
- **Kiểm tra drivers** cần cập nhật qua Windows Update
- **Update All**: cập nhật tất cả drivers tự động
- **Update Selected**: chọn từng driver để cập nhật
- Hiển thị thông tin chi tiết: tên driver, kích thước, ngày phát hành
- Thông báo nếu cần khởi động lại sau khi cập nhật

---

## 🚀 Cách sử dụng

### Bước 1: Tải về
```bash
git clone https://github.com/brillianfan/pcoptimizer.git
cd pcoptimizer
```

Hoặc tải file ZIP: [Download](https://github.com/brillianfan/pcoptimizer/archive/refs/heads/main.zip)

### Bước 2: Chạy ứng dụng
1. Giải nén file và truy cập vào thư mục.
2. Chạy file `PCOptimizer.bat` (Launcher) hoặc `main_gui.py` (Script).
3. Hệ thống sẽ tự động yêu cầu quyền **"Run as Administrator"** - chọn **Yes** để tiếp tục.
4. Giao diện GUI sẽ hiện lên, bạn chỉ cần chọn tính năng muốn sử dụng từ menu bên trái.

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
[+] Dashboard (He thong)
[+] Deep Clean (Don rac)
[+] Tools & Optimization (Cong cu toi uu)
[+] Uninstaller (Go ung dung + Store Apps)
[+] Software Update (Cap nhat phan mem)
[+] Driver Update (Cap nhat Drivers)
[+] Windows & Office Info (Kiem tra ban quyen)
======================================================
```

---

## ⚙️ Yêu cầu hệ thống

- 💻 **OS**: Windows 10/11 (64-bit khuyến nghị)
- 🔑 **Quyền**: Administrator
- 📦 **Dependencies**: 
  - PowerShell 5.1+ (có sẵn trong Windows)
  - Windows Package Manager (Winget) - cho chức năng Software Health
  - Windows Update Service - cho chức năng Driver Update

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
- ✅ Sử dụng công cụ tích hợp sẵn (cleanmgr, chkdsk, winget, Windows Update)
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
- 📧 Email: pcoptimizer.seventy907@slmail.me
- 🐙 GitHub: [@brillianfan](https://github.com/brillianfan)
- 💬 Telegram: @goodlove9179

---

## 📜 Changelog

### v2.1.0 (2026-04-01) ✨ NEW
- 🖼️ **Uninstaller Icons**: Hiển thị icon ứng dụng trong danh sách bộ gỡ.
- 📦 **Enhanced Store Logos**: Cải thiện nhận dạng logo cho ứng dụng Microsoft Store.
- ⚡ **Asynchronous Scan**: Tăng tốc độ quét ứng dụng mượt mà hơn.
- 📂 **Auto-Open Folder**: Tự động mở thư mục sau khi lưu file thành công.

### v2.0.0 (2026-03-20)
- 🎨 **Giao diện GUI**: Chuyển đổi hoàn toàn sang giao diện đồ họa hiện đại.
- 🗑️ **Store Apps Support**: Hỗ trợ gỡ ứng dụng từ Microsoft Store.
- 📊 **Dashboard**: Hiển thị thông số PC trực quan.
- 🔧 **Tự động Admin**: Tự động yêu cầu quyền quản trị khi chạy.

### v1.0.5 (2026-02-23)
- 🗑️ **Loại bỏ Activation**: Gỡ bỏ tính năng kích hoạt Windows/Office để tuân thủ GitHub TOS.
- 🔑 **Windows & Office Info**: Chuyển thành công cụ kiểm tra thông tin bản quyền.

### v1.0.4 (2026-02-06)
- 🗑️ **Advanced Leftover Cleanup**: Nâng cấp bộ quét tàn dư bằng wildcard và pattern matching.
- 🔧 Đồng bộ hóa thông tin và sửa các lỗi nhỏ trong toàn bộ project.

### v1.0.2 (2026-01-30)
- 🔌 **Driver Update**: Tính năng mới - Kiểm tra và cập nhật drivers
  - Kiem tra drivers can cap nhat qua Windows Update
  - Cap nhat tat ca drivers hoac chon tung driver
  - Hien thi thong tin chi tiet (ten, kich thuoc, ngay phat hanh)
  - Thong bao neu can khoi dong lai sau khi cap nhat
- 📋 Đồng bộ thông tin giữa các files documentation
- 🔧 Cải thiện UI/UX trong menu chính


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
A: Để có thể xóa file hệ thống, chỉnh sửa Registry, quản lý dịch vụ Windows, và cập nhật drivers.

**Q: Có an toàn không?**  
A: Hoàn toàn an toàn. Source code mở 100% để bạn kiểm tra.

**Q: Có tương thích với Windows 11?**  
A: Có, hoàn toàn tương thích với cả Windows 10 và 11.

**Q: Có cần Internet không?**  
A: Không bắt buộc. Chỉ cần Internet cho chức năng Software Health (cập nhật phần mềm) và Driver Update (cập nhật drivers).

**Q: Driver Update có an toàn không?**  
A: Có, chức năng này sử dụng Windows Update chính thức của Microsoft để tìm và cài đặt drivers. Không tải drivers từ nguồn bên thứ ba.

---

<div align="center">

**Made with ❤️ by Brillian Pham**

[⬆ Back to top](#-pc-ultimate-optimizer)

</div>
