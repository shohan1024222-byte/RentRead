# Google Drive Book Integration Tutorial (বাংলা)

## ধাপ ১: Google Drive এ PDF আপলোড করুন

1. Google Drive এ যান (drive.google.com)
2. আপনার PDF/PPTX বই file টি upload করুন
3. File এর উপর right click করুন
4. "Get link" বা "শেয়ার করুন" এ click করুন
5. "Anyone with the link" permission দিন
6. Link copy করুন

## ধাপ ২: Admin Panel এ Link যোগ করুন

1. RentRead admin panel এ যান (http://localhost:5000/admin.html)
2. কোন book edit করুন অথবা নতুন book add করুন
3. "Google Drive Link" field এ আপনার Google Drive shareable link paste করুন
   
   **উদাহরণ:**
   ```
   https://drive.google.com/file/d/1AbCdEfGhIjKlMnOpQrStUvWxYz123456/view?usp=sharing
   ```

4. Book save করুন

## ধাপ ৩: Database Update করুন

1. XAMPP এর phpMyAdmin খুলুন
2. এই SQL query টি run করুন:

```sql
-- Add drive_link column to books table
ALTER TABLE books ADD COLUMN drive_link VARCHAR(500) DEFAULT NULL COMMENT 'Google Drive shareable link for the book';

-- Optional: Update existing books with sample drive links
UPDATE books SET drive_link = 'YOUR_GOOGLE_DRIVE_LINK_HERE' WHERE id = 1;
```

## ধাপ ৪: Test করুন

1. User হিসেবে login করুন
2. কোন book rent করুন (যাতে drive_link আছে)
3. Dashboard অথবা My Account page এ যান
4. "Open (Drive)" button এ click করুন
5. Book Google Drive থেকে খুলবে!

## Google Drive Link Format

**Shareable Link:**
```
https://drive.google.com/file/d/FILE_ID/view?usp=sharing
```

**Auto-converted to Preview Link:**
```
https://drive.google.com/file/d/FILE_ID/preview
```

## Priority System

1. **Google Drive Link** (যদি available থাকে) - First priority
2. **Local PDF File** (server এ upload করা) - Fallback

## Features

- ✅ Google Drive integration
- ✅ Automatic link conversion for better viewing  
- ✅ Priority-based file opening (Drive first, then local)
- ✅ Visual indicators ((Drive) vs (Local))
- ✅ Admin panel support for Drive links
- ✅ Database column added
- ✅ API endpoints updated

## Benefits

- 📚 Books hosted on Google Drive (unlimited storage)
- 🔒 Shareable links with permission control
- ⚡ Fast loading from Google's CDN
- 💾 No server storage needed for large files
- 🌐 Works from anywhere with internet

## How It Works

1. Admin uploads PDF to Google Drive
2. Admin adds Drive link in RentRead admin panel
3. Customer rents the book
4. Customer clicks "Open (Drive)" button
5. Book opens directly from Google Drive in new tab
6. Access is tracked in database

এখন আপনার customers Google Drive থেকে directly books পড়তে পারবে! 🎉