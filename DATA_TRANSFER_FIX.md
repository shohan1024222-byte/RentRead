# 🔧 Database Data Transfer Issue - Complete Solution

## 🚨 Problem: Books table এর image_url ও drive_link user_book table এ আসছে না

## 🛠️ Solution Steps (ধাপে ধাপে করুন):

### Step 1: Debug Current Database State
phpMyAdmin এ গিয়ে `sql/debug_data_transfer.sql` script run করুন:

```sql
-- এই query গুলো run করে current state check করুন
SELECT 'BOOKS WITH IMAGE_URL OR DRIVE_LINK:' as info;
SELECT id, title, image_url, drive_link 
FROM books 
WHERE image_url IS NOT NULL OR drive_link IS NOT NULL
LIMIT 10;

SELECT 'USER_BOOK CURRENT STATE:' as info;
SELECT book_name, image_url, drive_link, created_at
FROM user_book 
ORDER BY created_at DESC 
LIMIT 10;
```

### Step 2: Add Missing Columns (if needed)
যদি user_book table এ image_url বা drive_link columns না থাকে:

```sql
-- Columns add করুন
ALTER TABLE `user_book` 
ADD COLUMN `image_url` VARCHAR(500) DEFAULT NULL;

ALTER TABLE `user_book` 
ADD COLUMN `drive_link` VARCHAR(500) DEFAULT NULL;
```

### Step 3: Manual Data Transfer
Existing records এর জন্য manual data transfer করুন:

```sql
-- Exact match দিয়ে update
UPDATE `user_book` ub
JOIN `books` b ON ub.book_name = b.title
SET 
  ub.image_url = COALESCE(ub.image_url, b.image_url),
  ub.drive_link = COALESCE(ub.drive_link, b.drive_link)
WHERE (b.image_url IS NOT NULL OR b.drive_link IS NOT NULL);

-- Partial match দিয়ে update (যদি exact match না হয়)
UPDATE `user_book` ub
JOIN `books` b ON b.title LIKE CONCAT('%', ub.book_name, '%') 
SET 
  ub.image_url = COALESCE(ub.image_url, b.image_url),
  ub.drive_link = COALESCE(ub.drive_link, b.drive_link)
WHERE (b.image_url IS NOT NULL OR b.drive_link IS NOT NULL)
  AND ub.image_url IS NULL AND ub.drive_link IS NULL;
```

### Step 4: Add Sample Data (if books table empty)
যদি books table এ image_url বা drive_link data না থাকে:

```sql
-- Sample data add করুন books table এ
UPDATE books 
SET image_url = '/img/covers/default-book.jpg',
    drive_link = 'https://drive.google.com/file/d/sample123/view?usp=sharing'
WHERE id = 1;

UPDATE books 
SET image_url = '/img/covers/programming.jpg',
    drive_link = 'https://drive.google.com/file/d/sample456/view?usp=sharing'
WHERE title LIKE '%programming%' OR title LIKE '%code%';
```

### Step 5: Test New Rentals
এখন নতুন rental করুন এবং console log check করুন:

1. Browser এ যান: `http://localhost:5000`
2. Login করুন
3. একটা book rent করুন
4. Server console এ এই log দেখুন:
```
Storing book data to user_book: {
  title: 'Book Name',
  image_url: '/img/covers/book.jpg',
  drive_link: 'https://drive.google.com/...',
  user_email: 'user@email.com'
}
```

### Step 6: Verify Data Transfer
Database তে check করুন:

```sql
-- Latest rental check করুন
SELECT book_name, image_url, drive_link, price, days, created_at
FROM user_book 
ORDER BY created_at DESC 
LIMIT 5;
```

## 🔍 Common Issues & Solutions:

### Issue 1: Books table এ image_url/drive_link নেই
**Solution**: Admin panel দিয়ে books এ image_url ও drive_link add করুন

### Issue 2: Column already exists error
**Solution**: Migration script এ IF NOT EXISTS check আছে, safely run করতে পারেন

### Issue 3: Book name mismatch
**Solution**: 
```sql
-- Manual matching করুন
SELECT ub.book_name, b.title 
FROM user_book ub
LEFT JOIN books b ON ub.book_name = b.title
WHERE b.title IS NULL;
```

### Issue 4: Debug logs দেখা যাচ্ছে না
**Solution**: 
1. Server restart করুন
2. Browser console check করুন
3. Network tab এ API calls দেখুন

## 🎯 Expected Results:

### After Fix:
1. ✅ New rentals store complete book data
2. ✅ User rental APIs return image_url and drive_link
3. ✅ Book covers display in frontend
4. ✅ Google Drive links work for reading

### Database State:
```sql
-- এইরকম data দেখা যাবে
SELECT * FROM user_book ORDER BY created_at DESC LIMIT 3;
/*
| book_name | image_url | drive_link | price | days |
|-----------|-----------|------------|-------|------|
| Book 1    | /img/...  | https://... | 22.00 | 7    |
| Book 2    | /img/...  | https://... | 15.00 | 3    |
*/
```

## 🚀 Quick Fix Commands:

### In phpMyAdmin, run these one by one:

```sql
-- 1. Add columns
ALTER TABLE `user_book` ADD COLUMN IF NOT EXISTS `image_url` VARCHAR(500) DEFAULT NULL;
ALTER TABLE `user_book` ADD COLUMN IF NOT EXISTS `drive_link` VARCHAR(500) DEFAULT NULL;

-- 2. Transfer existing data
UPDATE `user_book` ub
JOIN `books` b ON ub.book_name = b.title
SET ub.image_url = b.image_url, ub.drive_link = b.drive_link
WHERE b.image_url IS NOT NULL OR b.drive_link IS NOT NULL;

-- 3. Verify
SELECT book_name, image_url, drive_link FROM user_book WHERE image_url IS NOT NULL OR drive_link IS NOT NULL;
```

---

**এই steps follow করলে books table থেকে user_book table এ image_url ও drive_link proper ভাবে transfer হবে!** 🎉