# 🤝 Contributing to PC Ultimate Optimizer

Cảm ơn bạn đã quan tâm đến việc đóng góp cho dự án! 🎉

## 📋 Code of Conduct

- Tôn trọng tất cả mọi người
- Sử dụng ngôn ngữ lịch sự
- Chấp nhận phê bình mang tính xây dựng
- Tập trung vào điều tốt nhất cho cộng đồng

## 🚀 Cách đóng góp

### 1. Fork Repository

```bash
# Click nút "Fork" trên GitHub
# Hoặc dùng GitHub CLI:
gh repo fork brillianfan/pcoptimizer
```

### 2. Clone về máy

```bash
git clone https://github.com/brillianfan/pcoptimizer.git
cd pcoptimizer
```

### 3. Tạo Branch mới

```bash
# Đặt tên branch theo format: feature/ten-tinh-nang
git checkout -b feature/amazing-feature

# Hoặc: fix/ten-loi
git checkout -b fix/bug-fix
```

### 4. Thực hiện thay đổi

- Viết code rõ ràng, có comment
- Tuân thủ coding style hiện tại
- Test kỹ trước khi commit

### 5. Commit

```bash
git add .
git commit -m "Add: Mô tả ngắn gọn thay đổi"
```

**Commit message format:**
- `Add: Thêm chức năng mới`
- `Fix: Sửa lỗi X`
- `Update: Cập nhật chức năng Y`
- `Refactor: Tái cấu trúc code Z`
- `Docs: Cập nhật documentation`

### 6. Push lên GitHub

```bash
git push origin feature/amazing-feature
```

### 7. Tạo Pull Request

1. Vào repo trên GitHub
2. Click **"Compare & pull request"**
3. Điền thông tin:
   - Tiêu đề rõ ràng
   - Mô tả chi tiết
   - Liệt kê thay đổi
   - Thêm screenshots (nếu có)

---

## 💡 Ý tưởng đóng góp

### Chức năng mới:
- [ ] Tối ưu SSD (TRIM, Optimize)
- [ ] Quản lý Driver (Update drivers)
- [ ] Privacy tweaks (Tắt telemetry)
- [ ] GPU Optimization
- [ ] RAM Cleaner
- [ ] Scheduled Tasks Manager
- [ ] System Backup & Restore

### Cải tiến:
- [ ] Thêm Progress Bar
- [ ] Multi-language support (English)
- [ ] GUI version (HTML/CSS/JS)
- [ ] Undo feature (Rollback registry)
- [ ] Logging system
- [ ] Config file support

### Bug fixes:
- [ ] Sửa lỗi encoding tiếng Việt
- [ ] Tối ưu tốc độ thực thi
- [ ] Xử lý lỗi khi không có quyền Admin

---

## 📝 Coding Guidelines

### Batch Script Style:

```batch
:: Comment rõ ràng cho mỗi đoạn code
:: Sử dụng tiếng Việt hoặc tiếng Anh đều được

:: 1. Đặt tên biến rõ ràng
set "USER_CHOICE=1"
set "TEMP_DIR=%temp%"

:: 2. Indent code đúng cách
if "%USER_CHOICE%"=="1" (
    echo Chon chuc nang 1
    call :function_name
)

:: 3. Thêm error handling
command >nul 2>&1
if %errorlevel% neq 0 (
    echo Loi: Khong the thuc hien lenh
    pause
    goto menu
)

:: 4. Comment cho function
:function_name
:: Mô tả: Chức năng này làm gì
:: Input: Tham số đầu vào
:: Output: Kết quả đầu ra
echo Doing something...
goto :eof
```

### PowerShell Style:

```powershell
# Comment rõ ràng
$VariableName = "Value"  # CamelCase cho biến

# Error handling
try {
    # Code có thể lỗi
    Get-Process -Name "test"
} catch {
    Write-Host "Lỗi: $_" -ForegroundColor Red
}
```

---

## 🧪 Testing

Trước khi submit PR, hãy test:

### 1. Test trên Windows 10
```
- [ ] Chức năng A hoạt động
- [ ] Chức năng B hoạt động
- [ ] Không có lỗi
```

### 2. Test trên Windows 11
```
- [ ] Chức năng A hoạt động
- [ ] Chức năng B hoạt động
- [ ] Không có lỗi
```

### 3. Test với/không có Admin
```
- [ ] Script yêu cầu Admin đúng cách
- [ ] Hiển thị lỗi rõ ràng khi không có quyền
```

### 4. Test antivirus
```
- [ ] Upload lên VirusTotal
- [ ] Kết quả 0 hoặc ít detections
```

---

## 📚 Documentation

Khi thêm chức năng mới:

1. **Cập nhật README.md**
   - Thêm vào mục "Tính năng"
   - Giải thích cách sử dụng

2. **Comment trong code**
   - Giải thích logic phức tạp
   - Thêm ví dụ nếu cần

3. **Update CHANGELOG.md**
   - Ghi lại thay đổi theo version

---

## 🐛 Báo cáo Bug

### Template Issue:

```markdown
**Mô tả lỗi:**
Giải thích ngắn gọn lỗi là gì.

**Cách tái hiện:**
1. Mở script
2. Chọn chức năng X
3. Nhập Y
4. Thấy lỗi Z

**Kết quả mong đợi:**
Nên xảy ra điều gì.

**Kết quả thực tế:**
Đã xảy ra điều gì.

**Môi trường:**
- OS: Windows 10/11
- Version: 1.0.0
- Antivirus: Windows Defender

**Screenshots:**
(Nếu có)

**Thông tin thêm:**
Bất kỳ thông tin nào khác.
```

---

## 🎨 Pull Request Template:

```markdown
## Mô tả thay đổi
Giải thích ngắn gọn bạn đã làm gì.

## Loại thay đổi
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Checklist:
- [ ] Code đã được test
- [ ] Code tuân thủ coding style
- [ ] Comment đầy đủ
- [ ] Documentation đã cập nhật
- [ ] Không có warning/error
- [ ] VirusTotal scan (nếu thay đổi code)

## Screenshots (nếu có):
[Paste screenshots here]

## Related Issues:
Closes #123
```

---

## 🏆 Contributors

Danh sách những người đóng góp sẽ được hiển thị trong README.md:

```markdown
## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START -->
- [@brillianfan](https://github.com/brillianfan) - Creator
- [@yourname](https://github.com/yourname) - Feature X
<!-- ALL-CONTRIBUTORS-LIST:END -->
```

---

## 📧 Liên hệ

Có câu hỏi? Liên hệ:
- **Email**: [your-email@example.com]
- **GitHub Discussions**: [Start Discussion](https://github.com/brillianfan/pcoptimizer/discussions)
- **Issues**: [Create Issue](https://github.com/brillianfan/pcoptimizer/issues)

---

**Cảm ơn bạn đã đóng góp! 🎉**
