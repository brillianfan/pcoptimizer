# 🔍 HƯỚNG DẪN QUÉT VIRUSTOTAL

## Bước 1: Truy cập VirusTotal

1. Mở trình duyệt và truy cập: **https://www.virustotal.com**
2. Hoặc click vào đây: [VirusTotal.com](https://www.virustotal.com/gui/home/upload)

---

## Bước 2: Upload file .bat

### Cách 1: Kéo thả file
1. Kéo file `optimizer.bat` vào vùng "Choose file"
2. Chờ upload hoàn tất

### Cách 2: Chọn file thủ công
1. Click nút **"Choose file"**
2. Tìm và chọn file `optimizer.bat`
3. Click **"Open"**

![Upload file](https://i.imgur.com/example.png)

---

## Bước 3: Chờ quét

- VirusTotal sẽ quét file với **70+ antivirus engines**
- Thời gian: ~2-5 phút
- **KHÔNG ĐÓNG TAB** trong khi quét

![Scanning process](https://i.imgur.com/example2.png)

---

## Bước 4: Xem kết quả

### Kết quả mong đợi:

```
✅ 0/70+ detections  (HOÀN TOÀN AN TOÀN)
⚠️ 1-3/70+ detections (An toàn - False Positive)
❌ 10+/70+ detections (Cần xem xét)
```

### Giải thích:
- **0 detections**: Hoàn hảo, không antivirus nào cảnh báo
- **1-3 detections**: Bình thường - do hành vi yêu cầu Admin và chỉnh Registry
- **Phổ biến nhất**: Windows Defender có thể đánh dấu "PUA:Win32/Optimizer"
  - PUA = Potentially Unwanted Application (Không phải virus!)

---

## Bước 5: Lấy link kết quả

1. Sau khi quét xong, copy URL từ thanh địa chỉ
2. URL sẽ có dạng: 
   ```
   https://www.virustotal.com/gui/file/[HASH]/detection
   ```

3. **QUAN TRỌNG**: Copy toàn bộ URL này

### Ví dụ:
```
https://www.virustotal.com/gui/file/e10c0ded8685a0b0972d62dca79d4e34b0ea0e3bd4092ce79fa67ae48167a5bf/detection
```

---

## Bước 6: Cập nhật vào README.md

### Thay thế dòng này:
```markdown
[![VirusTotal Scan](https://img.shields.io/badge/VirusTotal-Clean-brightgreen)](LINK_VIRUSTOTAL_O_DAY)
```

### Bằng:
```markdown
[![VirusTotal Scan](https://img.shields.io/badge/VirusTotal-0%2F71-brightgreen)](https://www.virustotal.com/gui/file/e10c0ded8685a0b0972d62dca79d4e34b0ea0e3bd4092ce79fa67ae48167a5bf/detection)
```

**Lưu ý**: Thay `YOUR_HASH` bằng link thực tế bạn vừa copy.

---

## Bước 7: Cập nhật README.md (tiếp)

Tìm đoạn này:
```markdown
- 🔍 **VirusTotal scan**: [Xem kết quả quét](LINK_VIRUSTOTAL_O_DAY)
```

Thay bằng:
```markdown
- 🔍 **VirusTotal scan**: [Xem kết quả quét](https://www.virustotal.com/gui/file/e10c0ded8685a0b0972d62dca79d4e34b0ea0e3bd4092ce79fa67ae48167a5bf/detection)
```

---

## Bước 8: Commit và Push lên GitHub

```bash
# Di chuyển vào thư mục dự án
cd PC-Ultimate-Optimizer

# Thêm file README.md đã cập nhật
git add README.md

# Commit
git commit -m "Add VirusTotal scan results"

# Push lên GitHub
git push origin main
```

---

## 📸 Screenshots minh họa

### 1. Trang chủ VirusTotal:
```
┌─────────────────────────────────────────┐
│  VirusTotal                             │
│  ┌───────────────────────────────────┐  │
│  │   Choose file or drag & drop      │  │
│  │                                   │  │
│  │   [optimizer.bat]                 │  │
│  └───────────────────────────────────┘  │
│          [Confirm upload]               │
└─────────────────────────────────────────┘
```

### 2. Kết quả quét:
```
┌─────────────────────────────────────────┐
│  Detection ratio: 0 / 71                │
│                                         │
│  ✅ No security vendors flagged this   │
│     file as malicious                   │
│                                         │
│  Details  Behavior  Community  Relations│
└─────────────────────────────────────────┘
```

---

## ⚠️ Lưu ý quan trọng

### Nếu có 1-3 detections:

1. **Kiểm tra tên detection**:
   - `PUA` = Potentially Unwanted App (không phải virus)
   - `Generic` = Phát hiện dựa trên hành vi chung
   - `Heuristic` = Phát hiện dựa trên pattern

2. **Các antivirus có thể báo nhầm**:
   - Windows Defender
   - McAfee
   - Avast
   - AVG

3. **Giải thích trong README**:
   ```markdown
   ### Về cảnh báo False Positive:
   
   Một số antivirus có thể đánh dấu script này do:
   - Yêu cầu quyền Administrator
   - Chỉnh sửa Registry
   - Thực thi PowerShell
   
   Đây là **FALSE POSITIVE** - script hoàn toàn an toàn.
   ```

---

## 🎯 Checklist hoàn thành

- [ ] Upload file lên VirusTotal
- [ ] Chờ quét xong (2-5 phút)
- [ ] Copy link kết quả
- [ ] Cập nhật badge trong README.md
- [ ] Cập nhật link "Xem kết quả quét"
- [ ] Commit và push lên GitHub
- [ ] Kiểm tra link có hoạt động không

---

## 📌 Mẹo thêm

### Tạo badge động:

Nếu kết quả là **0/70**:
```markdown
![VirusTotal](https://img.shields.io/badge/VirusTotal-0%2F70%20Clean-brightgreen)
```

Nếu có **2/70**:
```markdown
![VirusTotal](https://img.shields.io/badge/VirusTotal-2%2F70%20False%20Positive-yellow)
```

### Re-scan định kỳ:

VirusTotal cho phép re-scan file:
1. Vào link kết quả cũ
2. Click nút **"Reanalyze"**
3. Cập nhật link mới (nếu có thay đổi)

---

## 🆘 Hỗ trợ

Nếu gặp vấn đề:
1. Đảm bảo file .bat không bị nén (.zip)
2. File phải < 650MB
3. Sử dụng trình duyệt Chrome/Firefox/Edge

---

**Chúc bạn thành công! 🎉**
