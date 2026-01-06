# 06. VẬN HÀNH & BẢO TRÌ (OPERATIONS)

---

## MỤC LỤC

- [6.1. Quy trình Vận hành Hàng ngày](#61-quy-trình-vận-hành-hàng-ngày)
- [6.2. Monitoring & Alerting](#62-monitoring--alerting)
- [6.3. Backup & Recovery](#63-backup--recovery)
- [6.4. Troubleshooting](#64-troubleshooting)
- [6.5. SLA & KPIs](#65-sla--kpis)
- [6.6. Bảo trì Định kỳ](#66-bảo-trì-định-kỳ)

---

## 6.1. QUY TRÌNH VẬN HÀNH HÀNG NGÀY

### 6.1.1. Daily Operations Checklist

**Mỗi sáng (8:00 AM):**

- [ ] Kiểm tra **Firebase Console** - Health status
- [ ] Xem **Crashlytics** - Có crash mới không?
- [ ] Kiểm tra **AI Service** uptime
  ```bash
  curl https://your-ai-service.railway.app/api/v1/health
  ```
- [ ] Review **SOS pending** trong Admin Dashboard
- [ ] Kiểm tra **Storage usage** (Firebase Storage)
- [ ] Review **user feedback** (if any)

**Mỗi chiều (5:00 PM):**

- [ ] Export **daily statistics**
  - Số SOS mới
  - Số donations
  - Số users đăng ký
  - AI predictions count
- [ ] Kiểm tra **notification delivery rate**
- [ ] Review **error logs**

---

### 6.1.2. Admin Dashboard Usage

**Login:**
```
URL: https://your-app-url/admin
Email: admin@example.com
Password: [From secure vault]
```

**Daily Tasks:**

**1. Quản lý SOS Requests:**

```
Dashboard → SOS Tab
- Filter: Status = "pending"
- Sort by: CreatedAt DESC, Severity DESC
- Action:
  1. Xem chi tiết SOS
  2. Kiểm tra vị trí trên bản đồ
  3. Gán cho tình nguyện viên phù hợp
  4. Cập nhật trạng thái
```

**2. Quản lý Alerts:**

```
Dashboard → Alerts Tab
- Kiểm tra alerts đang active
- Tạo alert mới nếu cần (dựa trên tin tức/AI prediction)
- Xóa alerts đã hết hạn
```

**3. Quản lý Distribution Points:**

```
Dashboard → Điểm phân phối
- Cập nhật số lượng còn trống
- Thêm/sửa/xóa điểm theo nhu cầu
- Tạm dừng điểm khi hết hàng
```

---

## 6.2. MONITORING & ALERTING

### 6.2.1. Firebase Monitoring

**Firebase Console → Analytics:**

```
Metrics to track:
- Daily Active Users (DAU)
- Retention rate (Day 1, Day 7, Day 30)
- Screen views distribution
- Crash-free users %
- Average session duration
```

**Firebase Console → Crashlytics:**

```
Priority handling:
1. Fatal crashes (app won't start) → P0, fix ASAP
2. Common crashes (affecting >5% users) → P1, fix in 24h
3. Rare crashes (<1% users) → P2, fix in next release
```

**Set up Alerts:**

```
Firebase Console → Alerts
- Crash-free users < 99% → Email to team
- Active users drop > 20% → SMS to PM
- Storage usage > 80% → Email to admin
```

---

### 6.2.2. AI Service Monitoring

**Health Check Endpoint:**

```bash
# Setup cron job to ping every 5 minutes
*/5 * * * * curl https://your-ai-service.railway.app/api/v1/health || echo "AI Service DOWN" | mail -s "Alert" admin@example.com
```

**Railway Dashboard:**

```
https://railway.app/dashboard
→ Check metrics:
  - CPU usage (should be < 80%)
  - Memory usage (should be < 90%)
  - Request rate
  - Error rate
```

**Logs:**

```bash
# View live logs (Railway CLI)
railway logs

# Filter errors
railway logs | grep ERROR

# Export logs
railway logs > logs_$(date +%Y%m%d).txt
```

---

### 6.2.3. Custom Monitoring Dashboard

**Google Sheets Integration (Simple):**

Tạo Cloud Function để ghi metrics vào Google Sheets mỗi ngày:

```javascript
// functions/index.js
exports.dailyMetrics = functions.pubsub
  .schedule('0 0 * * *')  // Midnight every day
  .onRun(async (context) => {
    const db = admin.firestore();
    
    // Count SOS requests today
    const sosCount = await db.collection('sos_requests')
      .where('CreatedAt', '>=', startOfDay)
      .get().then(snap => snap.size);
    
    // Count donations
    const donationsCount = await db.collection('donations')
      .where('CreatedAt', '>=', startOfDay)
      .get().then(snap => snap.size);
    
    // Write to Sheets (via API or service account)
    await appendToSheet({
      date: new Date().toISOString(),
      sos_count: sosCount,
      donations_count: donationsCount,
      ...
    });
  });
```

---

## 6.3. BACKUP & RECOVERY

### 6.3.1. Firestore Backup

**Automated Backup (Recommended):**

```bash
# Setup với gcloud CLI
gcloud firestore export gs://your-backup-bucket/firestore-$(date +%Y%m%d)

# Cron job (mỗi ngày 2:00 AM)
0 2 * * * gcloud firestore export gs://your-backup-bucket/firestore-$(date +\%Y\%m\%d)
```

**Manual Backup:**

```bash
# Export all collections
gcloud firestore export gs://your-backup-bucket/manual-backup-$(date +%Y%m%d)

# Export specific collection
gcloud firestore export gs://your-backup-bucket/sos-backup-$(date +%Y%m%d) \
  --collection-ids=sos_requests
```

**Retention Policy:**

- Daily backups: Keep 7 days
- Weekly backups: Keep 4 weeks
- Monthly backups: Keep 12 months

---

### 6.3.2. Firebase Storage Backup

**Using gsutil:**

```bash
# Sync to local backup
gsutil -m rsync -r gs://your-storage-bucket /path/to/local/backup

# Sync to another bucket (for redundancy)
gsutil -m rsync -r gs://your-storage-bucket gs://your-backup-bucket
```

---

### 6.3.3. Recovery Procedures

**Scenario 1: Accidental Data Deletion**

```bash
# List available backups
gcloud firestore export --list-databases

# Restore from backup
gcloud firestore import gs://your-backup-bucket/firestore-20260105

# Note: Import does NOT delete existing data, it merges
```

**Scenario 2: Collection Corrupted**

```bash
# Option 1: Restore specific collection
# 1. Delete corrupted collection (careful!)
# 2. Import from backup

# Option 2: Selective restore
# Write script to copy only affected documents from backup
```

**Scenario 3: Complete Disaster**

```
1. Create new Firebase project (or use backup project)
2. Restore Firestore from latest backup
3. Restore Storage from backup
4. Update app config to new Firebase project
5. Deploy new app version
```

---

### 6.3.4. AI Models Backup

**Backup trained models:**

```bash
cd ai_service/data/models

# Zip models
zip -r models-backup-$(date +%Y%m%d).zip *.pkl

# Upload to cloud storage
# - Google Drive
# - AWS S3
# - Google Cloud Storage

# Example with gsutil:
gsutil cp models-backup-$(date +%Y%m%d).zip gs://your-backup-bucket/ai-models/
```

**Recovery:**

```bash
# Download backup
gsutil cp gs://your-backup-bucket/ai-models/models-backup-20260105.zip .

# Extract
unzip models-backup-20260105.zip -d data/models/

# Redeploy AI service
railway up
```

---

## 6.4. TROUBLESHOOTING

### 6.4.1. Common Issues & Solutions

#### Issue 1: App crash khi mở

**Symptoms:**
- App crashes ngay sau splash screen
- Crashlytics shows Firebase initialization error

**Diagnosis:**

```bash
# Check Firebase config
flutter run
# Look for errors like:
# "com.google.firebase.FirebaseException: Firebase not initialized"
```

**Solutions:**

1. **Kiểm tra `google-services.json` / `GoogleService-Info.plist`**
   ```bash
   # Android
   ls android/app/google-services.json
   
   # iOS
   ls ios/Runner/GoogleService-Info.plist
   ```

2. **Re-download từ Firebase Console**
3. **Clean & rebuild**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

#### Issue 2: Firestore permission denied

**Symptoms:**
- Users can't read/write data
- Error: `permission-denied`

**Diagnosis:**

```bash
# Check Firestore Rules in Firebase Console
# Rules tab
```

**Solutions:**

1. **Review Security Rules**
   ```javascript
   // TOO OPEN (for testing only):
   allow read, write: if true;
   
   // PRODUCTION (recommended):
   allow read: if request.auth != null;
   allow write: if isOwner() || isAdmin();
   ```

2. **Deploy correct rules**
   ```bash
   firebase deploy --only firestore:rules
   ```

---

#### Issue 3: AI Service timeout

**Symptoms:**
- Predictions take > 30s
- DioException: Connection timeout

**Diagnosis:**

```bash
# Check AI service health
curl -w "@curl-format.txt" https://your-ai-service.railway.app/api/v1/health

# curl-format.txt content:
time_total:  %{time_total}\n
```

**Solutions:**

1. **Increase timeout in app**
   ```dart
   final dio = Dio(BaseOptions(
     connectTimeout: Duration(seconds: 30),
     receiveTimeout: Duration(seconds: 30),
   ));
   ```

2. **Optimize AI service**
   ```python
   # Cache predictions
   from functools import lru_cache
   
   @lru_cache(maxsize=1000)
   def predict(province, hazard_type):
       ...
   ```

3. **Scale AI service** (Railway dashboard → Scale to higher plan)

---

#### Issue 4: Push notifications không nhận được

**Symptoms:**
- Users không nhận FCM notifications

**Diagnosis:**

```dart
// Check FCM token
final token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');

// Check if token được lưu trong Firestore
```

**Solutions:**

1. **Verify FCM setup**
   - Android: `google-services.json` correct
   - iOS: APNs certificate uploaded to Firebase

2. **Request permission (iOS)**
   ```dart
   await FirebaseMessaging.instance.requestPermission(
     alert: true,
     badge: true,
     sound: true,
   );
   ```

3. **Test with Firebase Console**
   ```
   Firebase Console → Cloud Messaging → Send test message
   ```

---

### 6.4.2. Emergency Procedures

#### P0: Service Down (Complete Outage)

**Detection:**
- Multiple users report can't access app
- Health check fails

**Immediate Actions:**

1. **Check service status**
   ```bash
   # Firebase
   https://status.firebase.google.com/
   
   # AI Service (Railway)
   railway status
   ```

2. **If Firebase issue:**
   - Wait for Google to fix (usually < 30 min)
   - Post status on social media
   - Send push notification when back online

3. **If AI Service issue:**
   ```bash
   # Restart service
   railway restart
   
   # Check logs
   railway logs
   
   # If not fixed, rollback
   railway rollback
   ```

4. **Communication:**
   ```
   - Email users về downtime
   - Post on Facebook/Twitter
   - Update in-app banner (if possible)
   ```

---

#### P1: Data Corruption

**Detection:**
- Reports of wrong data shown
- Database integrity check fails

**Immediate Actions:**

1. **Isolate affected data**
   ```bash
   # Mark as corrupted
   gcloud firestore indexes field-overrides list
   ```

2. **Stop writes to affected collection** (if possible)

3. **Restore from backup**
   ```bash
   # Restore specific collection
   gcloud firestore import gs://backup/firestore-20260105 \
     --collection-ids=sos_requests
   ```

4. **Notify affected users**

---

## 6.5. SLA & KPIs

### 6.5.1. Service Level Agreement (SLA)

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Uptime** | 99.5% | (Total time - Downtime) / Total time |
| **Response Time** | < 2s (95th percentile) | Firebase Performance Monitoring |
| **Crash-free Users** | > 99% | Firebase Crashlytics |
| **Push Notification Delivery** | > 95% | FCM reports |
| **AI Service Uptime** | > 99% | Railway metrics |
| **Data Loss** | 0 | Backup verification |

**Monthly SLA Report Template:**

```markdown
# SLA Report - January 2026

## Uptime
- App: 99.8% ✅ (Target: 99.5%)
- AI Service: 99.2% ✅ (Target: 99%)

## Performance
- Average response time: 1.2s ✅ (Target: <2s)
- 95th percentile: 1.8s ✅

## Reliability
- Crash-free users: 99.7% ✅ (Target: >99%)
- Total crashes: 15 (down from 23 last month)

## Incidents
- 1 minor outage (AI service, 45 min, resolved)
- 0 data loss incidents ✅

## Actions Taken
- Optimized AI model loading → reduced latency 30%
- Fixed 3 critical bugs
```

---

### 6.5.2. Key Performance Indicators (KPIs)

**Growth Metrics:**

- **DAU** (Daily Active Users)
- **MAU** (Monthly Active Users)
- **Retention Rate** (Day 1, 7, 30)
- **Churn Rate**

**Engagement Metrics:**

- **SOS submitted/day**
- **Donations/day** (count & total amount)
- **Volunteer registrations/day**
- **Average session duration**
- **Screens per session**

**Technical Metrics:**

- **API response time (p50, p95, p99)**
- **Error rate (%)**
- **Crash rate**
- **App size** (APK/IPA)

**Dashboard:**

```
Use Firebase Analytics + Google Data Studio
→ Create real-time dashboard với tất cả KPIs
```

---

## 6.6. BẢO TRÌ ĐỊNH KỲ

### 6.6.1. Hàng tuần

- [ ] Review crash reports, fix critical bugs
- [ ] Update dependencies nếu có security patches
  ```bash
  flutter pub outdated
  flutter pub upgrade
  ```
- [ ] Verify backups thành công
- [ ] Clean up old data (nếu có policy xóa data cũ)

---

### 6.6.2. Hàng tháng

- [ ] **Retrain AI models** với data mới
  ```bash
  cd ai_service
  python train_hazard_model.py
  railway deploy
  ```
- [ ] Review Firestore usage & costs
  ```
  Firebase Console → Usage & Billing
  ```
- [ ] Optimize Firestore indexes
  ```bash
  # Remove unused indexes
  firebase firestore:indexes
  ```
- [ ] Update documentation
- [ ] Security audit (check Firebase rules)
- [ ] Performance testing

---

### 6.6.3. Hàng quý (3 tháng)

- [ ] Major dependency upgrades
  ```bash
  flutter upgrade
  flutter pub upgrade --major-versions
  ```
- [ ] Database optimization
  ```bash
  # Analyze slow queries
  # Add/remove indexes as needed
  ```
- [ ] User survey (feedback collection)
- [ ] Capacity planning (storage, compute)
- [ ] Disaster recovery drill (test backup restore)

---

### 6.6.4. Hàng năm

- [ ] Major version upgrade (if needed)
- [ ] Renew SSL certificates (if self-hosted)
- [ ] Renew Apple Developer / Google Play accounts
- [ ] Security penetration testing
- [ ] Infrastructure cost review & optimization
- [ ] Roadmap planning for next year

---

**[Tiếp tục ở file 07_TESTING.md]**
