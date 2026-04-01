# Changelog

Tất cả các thay đổi đáng chú ý của dự án PC Ultimate Optimizer sẽ được ghi lại trong file này.

Định dạng dựa trên [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
và dự án này tuân theo [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.1.0] - 2026-04-01

### ✨ Added
- **Uninstaller Icons**: Hiển thị icon ứng dụng trong danh sách bộ gỡ (Uninstaller).
- **Enhanced Store App Logos**: Cải thiện nhận dạng logo cho ứng dụng từ Microsoft Store (hỗ trợ scale-aware assets).
- **Asynchronous Icon Loading**: Tăng tốc độ quét ứng dụng và trải nghiệm người dùng mượt mà hơn.
- **Tự động mở thư mục**: Tự động mở thư mục sau khi lưu file thành công.

---

## [2.0.0] - 2026-03-20

### ✨ Added
- **Giao diện GUI Hoàn chỉnh**: Chuyển đổi từ giao diện dòng lệnh (CLI) sang giao diện đồ họa (GUI) hiện đại sử dụng `customtkinter`.
- **Advanced Uninstaller**:
  - Hỗ trợ liệt kê và gỡ bỏ ứng dụng từ **Microsoft Store**.
  - Tự động quét và dọn dẹp tàn dư (AppData, Registry) sau khi gỡ cài đặt.
- **Driver Update**: Tích hợp trình quản lý Driver cho phép quét và cập nhật trực tiếp qua Windows Update API.
- **Software Health**: Tích hợp Winget để quản lý và cập nhật toàn bộ phần mềm trên máy tính.
- **Dashboard Hệ thống**: Hiển thị thông số cấu hình PC (CPU, RAM, GPU, Disk) ngay khi khởi động.
- **Tự động Yêu cầu Quyền Admin**: Ứng dụng tự động yêu cầu quyền Quản trị viên khi khởi chạy để đảm bảo các tính năng hoạt động ổn định.

### 🔄 Changed
- Nâng cấp toàn bộ logic từ script đơn lẻ sang kiến trúc mô-đun (Modular Architecture).
- Cập nhật số phiên bản lên 2.0.0 trong toàn bộ hệ thống.
- Làm mới toàn bộ hệ thống tài liệu hướng dẫn (README, User Guide, Security).

---

## [1.0.5] - 2026-02-23

### 🗑️ Removed
- **Windows & Office Activation**: Loại bỏ hoàn toàn tính năng kích hoạt bản quyền để tuân thủ Điều khoản dịch vụ (TOS) của GitHub.
- **MAS Script Integration**: Gỡ bỏ mã nguồn kết nối và thực thi Microsoft Activation Scripts (MAS).
- **Offline Activation Fallback**: Xóa bỏ các file và logic liên quan đến kích hoạt offline.

### 🔄 Changed
- **Windows & Office Info**: Chuyển đổi mục "Activation" thành "Info", chỉ giữ lại chức năng kiểm tra phiên bản và trạng thái bản quyền hiện tại.
- Cập nhật phiên bản lên 1.0.5 trong toàn bộ hệ thống.

---

## [1.0.4] - 2026-02-06

### ✨ Added
- **Manual Search & Delete**: Thêm tùy chọn nhập '0' để quay lại menu trước
  - Hiển thị hướng dẫn "Type '0' to return to menu"
  - Kiểm tra input rỗng và tự động quay lại menu
  - Cải thiện trải nghiệm người dùng

### 🔄 Changed
- **Deep Junk Clean**: Tối ưu hóa chức năng Manual Search & Delete
  - Thay thế logic tìm kiếm từ toàn bộ ổ C: sang các thư mục mục tiêu cụ thể
  - Tìm kiếm trong Program Files, AppData, ProgramData, Start Menu, Documents, Desktop
  - Sử dụng `reg query` để tìm kiếm Registry hiệu quả hơn
  - Loại bỏ vòng lặp tìm kiếm lặp lại, chỉ tìm kiếm một lần mỗi phiên

### 🐛 Fixed
- **PCOptimizer.bat**: Sửa lỗi "'Delete' is not recognized" trong menu Deep Junk Clean
  - Escape ký tự `&` trong "Manual Search & Delete" bằng `^&`

---

## [1.0.3] - 2026-02-03

- **Offline Activation Fallback**: Tự động sử dụng file `MAS_AIO.cmd` cục bộ nếu không thể kết nối tới máy chủ GitHub (masgravel).
- **Advanced Leftover Cleanup**: Nâng cấp bộ quét tàn dư cho Uninstaller với tìm kiếm Folder/Registry bằng wildcard và pattern matching.

### 🐛 Fixed
- **Deep Junk Clean**: Sửa lỗi đệ quy vô hạn và lỗi "Path not found" khi dọn dẹp Recycle Bin.
- **Optimize Registry**: Thay thế ký tự Unicode mũi tên (`→`) bằng ASCII (`->`) để tránh lỗi Parser.
- **Driver Update**: Cải thiện quản lý dịch vụ `wuauserv` và thêm thông báo trạng thái chi tiết.

### 🔄 Changed
- Đồng bộ thông tin và cập nhật phiên bản lên 1.0.3 trong toàn bộ hệ thống.

---

## [1.0.2] - 2026-01-30

### ✨ Added
- **Driver Update** - Tính năng mới hoàn toàn
  - Kiểm tra drivers cần cập nhật qua Windows Update API
  - Cập nhật tất cả drivers (Update All) hoặc Selected
  - Chỉ sử dụng nguồn drivers chính thức từ Microsoft
- **Uninstaller Analytics**: Cải thiện trí tuệ nhân tạo của bộ gỡ ứng dụng
  - Tự động suy luận đường dẫn cài đặt (`InstallLocation`) từ lệnh gỡ nếu thiếu
  - Thêm fallback cho thông tin `Publisher` (hiển thị 'Unknown' thay vì rỗng)
- **Stability Fixes**: Sửa các lỗi nghiêm trọng trong Batch/PowerShell
  - Sửa lỗi ParserError do here-strings trong PowerShell
  - Sửa lỗi mất đường dẫn khi thư mục chứa dấu ngoặc `()`
  - Chuyển đổi an toàn kiểu dữ liệu Registry sang String để tránh lỗi UI



### 🔄 Changed
- Cập nhật menu chính từ 10 chức năng lên 11 chức năng
- Đồng bộ thông tin giữa README.md, SECURITY.md, CONTRIBUTING.md
- Cập nhật version number lên 1.0.2 trong tất cả files

### 📚 Documentation
- Thêm hướng dẫn sử dụng Driver Update vào README.md
- Cập nhật SECURITY.md với thông tin an toàn về Driver Update
- Thêm Driver Update vào danh sách ý tưởng đã hoàn thành trong CONTRIBUTING.md

### 🔒 Security
- Driver Update chỉ sử dụng Windows Update API chính thức
- Không tải drivers từ nguồn bên thứ ba
- Tất cả drivers đều được Microsoft xác minh

---

## [1.0.1] - 2026-01-29

### ✨ Added
- **Deep Junk Clean**: Thêm chức năng xóa shortcuts lỗi
  - Xóa các liên kết (.lnk, .url) trỏ tới file/thư mục đã bị xóa
  - Quét Desktop, Start Menu, Quick Launch, Taskbar pins
  - Sử dụng PowerShell script riêng: Remove-BrokenShortcuts.ps1

### 🔄 Changed
- Cải thiện hiển thị trong menu Deep Junk Clean
- Thêm xác nhận cho từng bước trong Deep Clean

### 📚 Documentation
- Cập nhật README.md với tính năng xóa shortcuts lỗi
- Đồng bộ danh sách tính năng giữa các files

### 🐛 Fixed
- Sửa lỗi encoding tiếng Việt trong một số phần
- Sửa lỗi hiển thị menu trong Windows Terminal

---

## [1.0.0] - 2026-01-28

### 🎉 Initial Release

#### ✨ Features
1. **Deep Junk Clean**
   - Xóa Temp, Prefetch, Cache
   - Làm trống Recycle Bin
   - Xóa System Event Logs
   - Chạy Windows Disk Cleanup
   - Quét và xóa thư mục rỗng

2. **Uninstaller**
   - Liệt kê ứng dụng từ Registry
   - Gỡ bỏ phần mềm
   - Quét và xóa tàn dư (AppData, ProgramData)

3. **Startup Manager**
   - Mở Task Manager tab Startup
   - Hướng dẫn quản lý ứng dụng khởi động

4. **Toggle Windows Update**
   - Bật/Tắt Windows Update
   - Quản lý dịch vụ wuauserv

5. **Optimize Registry**
   - Giảm WaitToKillAppTimeout
   - Loại bỏ MenuShowDelay
   - Tự động đóng ứng dụng không phản hồi
   - Tăng tốc độ phản hồi chuột/bàn phím
   - Tối ưu Network Throttling

6. **View PC Specs**
   - Hiển thị thông tin CPU, RAM, GPU
   - Hiển thị Mainboard, Ổ cứng
   - Sử dụng WMI để lấy thông tin

7. **Windows & Office Activation**
   - Kiểm tra phiên bản Windows & Office
   - Kiểm tra trạng thái bản quyền
   - Tích hợp MAS Script (get.activated.win)

8. **Internet Boost**
   - Tối ưu TCP/IP settings
   - Bật RSS, FastOpen
   - Flush DNS Cache

9. **Disk Check**
   - Lên lịch CHKDSK cho lần khởi động tiếp theo

10. **Software Health**
    - Cập nhật phần mềm qua Winget
    - Update All hoặc Update Selected

#### 🔒 Security
- Source code 100% công khai
- Không thu thập dữ liệu
- Không kết nối internet không rõ ràng
- MIT License

#### 📚 Documentation
- README.md đầy đủ
- LICENSE (MIT)
- SECURITY.md
- CONTRIBUTING.md
- .gitignore

---

## Cách đọc Changelog

### Các loại thay đổi:
- **Added**: Tính năng mới
- **Changed**: Thay đổi trong tính năng hiện có
- **Deprecated**: Tính năng sắp bị loại bỏ
- **Removed**: Tính năng đã bị loại bỏ
- **Fixed**: Sửa lỗi
- **Security**: Cập nhật bảo mật

### Version Numbering:
- **MAJOR.MINOR.PATCH** (Semantic Versioning)
- MAJOR: Thay đổi lớn, không tương thích ngược
- MINOR: Thêm tính năng mới, tương thích ngược
- PATCH: Sửa lỗi, tương thích ngược

---

## Liên kết

- **Repository**: https://github.com/brillianfan/pcoptimizer
- **Issues**: https://github.com/brillianfan/pcoptimizer/issues
- **Releases**: https://github.com/brillianfan/pcoptimizer/releases

---

**Maintained by**: Brillian Pham  
**Contact**: pcoptimizer.seventy907@slmail.me  
**Telegram**: @goodlove9179
