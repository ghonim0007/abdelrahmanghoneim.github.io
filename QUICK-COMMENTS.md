# 💬 تفعيل التعليقات - خطوات سريعة

## 🚀 3 خطوات فقط!

### 1️⃣ تفعيل Discussions

اذهب إلى repository على GitHub:
```
Settings → Features → ✅ Discussions
```

### 2️⃣ تثبيت Giscus

1. افتح: https://github.com/apps/giscus
2. اضغط **Install**
3. اختر repository موقعك

### 3️⃣ الحصول على الأكواد

1. افتح: https://giscus.app/
2. املأ:
   - Repository: `abdelrahmanghoneim/abdelrahmanghoneim.github.io`
   - Mapping: `pathname`
   - Category: `Announcements`

3. **انسخ** هذين الكودين:
   ```
   data-repo-id="R_kgDOxxxxxx"
   data-category-id="DIC_kwDOxxxxxx"
   ```

4. **ضعهم** في `_config.yml`:
   ```yaml
   comments:
     provider: giscus
     giscus:
       repo: abdelrahmanghoneim/abdelrahmanghoneim.github.io
       repo_id: R_kgDOxxxxxx  # ← هنا
       category: Announcements
       category_id: DIC_kwDOxxxxxx  # ← وهنا
   ```

5. **Push**:
   ```bash
   git add _config.yml
   git commit -m "Enable comments"
   git push
   ```

## ✅ انتهى!

انتظر 2-5 دقائق وستظهر التعليقات في المقالات! 🎉

---

**للتفاصيل الكاملة:** اقرأ `COMMENTS-SETUP.md`
