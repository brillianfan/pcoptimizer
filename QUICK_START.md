# 🚀 HƯỚNG DẪN NHANH - QUICK START

## 📁 Files bạn vừa nhận được:

1.  **README.md** - File mô tả chính
2.  **PCOptimizer.bat** - Launcher chính (Batch)
3.  **Deep-JunkClean.ps1** - Module dọn rác
4.  **Optimize-Registry.ps1** - Module tối ưu Registry
5.  **Driver-Update.ps1** - Module cập nhật Driver
6.  **Software-Health.ps1** - Module cập nhật phần mềm
7.  **Uninstaller.ps1** - Module gỡ ứng dụng
8.  **Remove-BrokenShortcuts.ps1** - Helper xóa shortcut lỗi
9.  **CHANGELOG.md**, **SECURITY.md**, **LICENSE** - Tài liệu đi kèm


---

## ⚡ HÀNH ĐỘNG NGAY BÂY GIỜ:

### Bước 1: Upload lên GitHub (5 phút)

```bash
# 1. Mở thư mục dự án của bạn
cd /path/to/pcoptimizer

# 2. Copy tất cả files vừa tải vào thư mục này
# (Copy các files ở trên vào thư mục dự án)

# 3. Thêm file PCOptimizer.bat và Remove-BrokenShortcuts.ps1 vào

# 4. Git commands:
git add .
git commit -m "Initial release with complete documentation"
git push origin main
```

---

### Bước 2: Quét VirusTotal (3 phút)

**QUAN TRỌNG: Làm ngay bước này!**

1. 🌐 Truy cập: https://www.virustotal.com
2. 📤 Click "Choose file" và chọn `PCOptimizer.bat`
3. ⏳ Đợi 2-5 phút quét
4. 📋 Copy link kết quả (dạng: https://www.virustotal.com/gui/file/[HASH]/detection)

---

### Bước 3: Cập nhật README (2 phút)

Mở file **README.md** và thay thế:

**TÌM:**
```markdown
[![VirusTotal Scan](https://img.shields.io/badge/VirusTotal-Clean-brightgreen)](LINK_VIRUSTOTAL_O_DAY)
```

**THAY BẰNG** (ví dụ nếu kết quả là 0/60):
```markdown
[![VirusTotal Scan](https://img.shields.io/badge/VirusTotal-0%2F60%20Clean-brightgreen)](LINK_BẠN_VỪA_COPY_Ở_BƯỚC_2)
```

**TÌM:**
```markdown
- 🔍 **VirusTotal scan**: [Xem kết quả quét](LINK_VIRUSTOTAL_O_DAY)
```

**THAY BẰNG:**
```markdown
- 🔍 **VirusTotal scan**: [Xem kết quả quét](LINK_BẠN_VỪA_COPY_Ở_BƯỚC_2)
```

**Lưu file và commit:**
```bash
git add README.md
git commit -m "Add VirusTotal scan results"
git push origin main
```

---

### Bước 4: Tùy chỉnh thông tin (5 phút)

**Tìm và thay trong TẤT CẢ các files:**

| Tìm | Thay bằng |
|-----|-----------|
| `[your-email@example.com]` | Email thật của bạn |
| `YOUR_USERNAME` | brillianfan (hoặc username GitHub của bạn) |
| `[Your LinkedIn]` | Link LinkedIn của bạn |
| `[@your-username]` | @brillianpham |

**Các file cần sửa:**
- README.md
- SECURITY.md
- CONTRIBUTING.md

**Sau đó commit:**
```bash
git add .
git commit -m "Update personal information"
git push origin main
```

---

## ✅ CHECKLIST 10 PHÚT

- [ ] Upload tất cả files lên GitHub
- [ ] Quét VirusTotal và copy link
- [ ] Cập nhật link VirusTotal vào README
- [ ] Thay email và username
- [ ] Tạo Release v1.0.3 với file đính kèm
- [ ] Kiểm tra repo trên GitHub xem đã đẹp chưa

---

## 🎯 SAU KHI HOÀN THÀNH

### Repo của bạn sẽ có:

```
PC-Ultimate-Optimizer/
├── PCOptimizer.bat          ← File chính của bạn
├── Remove-BrokenShortcuts.ps1 ← Helper script
├── README.md                ← Mô tả dự án đẹp mắt
├── LICENSE                  ← Giấy phép MIT
├── SECURITY.md              ← Chính sách bảo mật
├── CONTRIBUTING.md          ← Hướng dẫn đóng góp
├── .gitignore               ← Git ignore file
└── (screenshots/)           ← Thư mục ảnh (tùy chọn)
```

### Repo sẽ hiển thị:

- ✅ Badges đẹp mắt (VirusTotal, License, Platform)
- ✅ Mô tả đầy đủ và chuyên nghiệp
- ✅ Hướng dẫn sử dụng chi tiết
- ✅ Chính sách bảo mật rõ ràng
- ✅ Hướng dẫn đóng góp

---

## 🔥 BONUS: Tạo Release

1. Vào GitHub repo → **Releases** tab
2. Click **"Create a new release"**
3. Điền:
   - Tag: `v1.0.0`
   - Title: `PC Ultimate Optimizer v2.1.0`
   - Description: (Lấy thông tin từ CHANGELOG.md cho bản 1.0.3)
4. Upload file `PCOptimizer.bat` và `Remove-BrokenShortcuts.ps1`
5. Click **"Publish release"**

---

## 📸 THÊM ẢNH (Tùy chọn - 5 phút)

1. Chụp màn hình khi chạy script
2. Tạo thư mục `screenshots/` trong repo
3. Upload ảnh vào đó
4. Thêm vào README:

```markdown
## 📸 Screenshots

![Main Menu](screenshots/main-menu.png)
![PC Specs](screenshots/specs.png)
```

---

## 🎉 XEM KẾT QUẢ

Truy cập: `https://github.com/brillianfan/pcoptimizer`

Bạn sẽ thấy một repo chuyên nghiệp với:
- Badge VirusTotal màu xanh
- README đẹp mắt
- Documentation đầy đủ
- Sẵn sàng chia sẻ!

---

## 📞 CẦN TRỢ GIÚP?

**Xem file chi tiết:**
- VIRUSTOTAL_GUIDE.md - Hướng dẫn quét VirusTotal từng bước

**Vấn đề thường gặp:**

1. **Git push bị lỗi?**
   ```bash
   git pull origin main --rebase
   git push origin main
   ```

2. **VirusTotal báo detections?**
   - Đọc SECURITY.md để hiểu về False Positive
   - Cập nhật badge: `0%2F60%20Clean` → `2%2F60%20False%20Positive`

3. **README không hiển thị đẹp?**
   - Kiểm tra markdown syntax
   - Preview trên GitHub trước khi push

---

## 🚀 TIẾP THEO

Sau khi hoàn thành:

1. **Chia sẻ dự án:**
   - Facebook groups
   - Reddit (r/windows, r/software)
   - Vietnamese tech forums

2. **Theo dõi:**
   - Star count
   - Issues
   - Pull requests

3. **Cải thiện:**
   - Nhận feedback
   - Fix bugs
   - Thêm features
   - Release v1.1.0

---

**Thời gian hoàn thành: ~15-20 phút**

**Kết quả: Repo GitHub chuyên nghiệp, sẵn sàng chia sẻ! 🎉**

---

**Made with ❤️ by Brillian Pham**  
**Date: February 03, 2026**
