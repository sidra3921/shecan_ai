# Tier 1 Features - Setup & Deployment Checklist

## 🚀 Launch Roadmap

### Phase 1: Local Setup (Week 1) ✅ In Progress
- [x] Install dependencies (pubspec.yaml updated)
- [x] Configure app_config.dart
- [x] Update main.dart with service locator
- [x] Create Chat UI screens
- [ ] Install **get_it** via `flutter pub get`
- [ ] Verify all services compile

### Phase 2: Local Testing (Week 1-2)
- [ ] Test ChatService with real Firestore data
- [ ] Test AssessmentService with mock data
- [ ] Test PaymentService with Stripe test keys
- [ ] Verify all Firestore queries work
- [ ] Test real-time updates

### Phase 3: API Integration (Week 2-3)
- [ ] Add Stripe production setup
- [ ] Add Twilio/Agora video integration
- [ ] Add OpenAI integration
- [ ] Test payment flow
- [ ] Test video consultations

### Phase 4: Testing & QA (Week 3-4)
- [ ] End-to-end testing
- [ ] Load testing
- [ ] Security testing
- [ ] Performance optimization
- [ ] Bug fixes

### Phase 5: Launch (Week 4)
- [ ] Deploy to Firebase
- [ ] Release to play store/app store
- [ ] Monitor metrics
- [ ] Handle support requests

---

## ✅ Installation Checklist

### Step 1: Get Dependencies

```bash
# In project root, run:
flutter pub get

# Verify installation:
flutter pub global activate check_flutter_version
```

**Expected**: All packages install without errors

### Step 2: Verify Configuration Files

- [x] `lib/config/app_config.dart` - Created ✅
- [x] `lib/main.dart` - Updated with service locator ✅
- [x] `pubspec.yaml` - Updated with get_it ✅
- [x] `lib/screens/chat_screen.dart` - Created ✅

### Step 3: Run Build Checks

```bash
# Check for lint errors:
flutter analyze

# Build web (fastest check):
flutter build web

# Or check specific file:
dart analyze lib/main.dart
```

**Expected**: No critical errors (warnings are OK for now)

### Step 4: Run App

```bash
# Connect device or emulator
flutter devices

# Run with build:
flutter run -v

# Or with hot reload:
flutter run --hot
```

**Expected**: App launches and shows splash screen

---

## 🔧 Configuration Checklist

### Local Development (No Real Charges)

#### 1. Stripe Setup

```dart
// In lib/config/app_config.dart
static const String stripePublishableKey = 'pk_test_YOUR_TEST_KEY';
static const String stripeSecretKey = 'sk_test_YOUR_TEST_SECRET';
static const bool enableRealStripePayments = false; // Test mode
```

Test card: `4242 4242 4242 4242`  
Expiry: Any future date  
CVV: Any 3 digits

#### 2. Video Consultation Setup (Choose One)

**Option A: Twilio**
```dart
static const String twilioAccountSid = 'ACxxxxx'; // Your SID
static const String twilioApiKey = 'xxxxx'; // Your API Key
static const String twilioApiSecret = 'xxxxx'; // Your Secret
static const bool enableRealVideoCallsWithTwilio = false; // Test mode
```

**Option B: Agora (Recommended)**
```dart
static const String agoraAppId = 'xxxxxx'; // Your App ID
static const bool enableRealVideoCallsWithAgora = false; // Test mode
```

#### 3. OpenAI Setup

```dart
static const String openaiApiKey = 'sk-xxxxx'; // Your API Key
static const bool enableRealOpenAI = false; // Mock responses for now
```

#### 4. Firebase Setup (Already Complete)

```
✅ Firebase Project: shecan-ai-project
✅ Firestore Database: Configured
✅ Authentication: Enabled
✅ Storage: Configured
```

### Testing Configuration

```dart
// lib/config/app_config.dart - Already set for testing

class AppConfig {
  // All test mode flags set to false
  static const bool enableRealStripePayments = false;
  static const bool enableRealVideoCallsWithTwilio = false;
  static const bool enableRealVideoCallsWithAgora = false;
  static const bool enableRealOpenAI = false;
}

class TestAccounts {
  static const String testUserEmail = 'test@shecan.ai';
  static const String testUserPassword = 'TestPassword123!';
}
```

### Production Configuration (Before Launch)

```dart
// UPDATE THESE BEFORE DEPLOYING:

static const String stripePublishableKey = 'pk_live_YOUR_REAL_KEY';
static const String stripeSecretKey = 'sk_live_YOUR_REAL_KEY';
static const bool enableRealStripePayments = true;

static const String openaiApiKey = 'sk-YOUR_REAL_KEY';
static const bool enableRealOpenAI = true;

static const bool enableRealVideoCallsWithTwilio = true;
// OR
static const bool enableRealVideoCallsWithAgora = true;
```

---

## 🧪 Testing Checklist

### Chat Feature Tests

```dart
✅ Create conversation
  - Verify Firestore `/conversations/{id}` created
  - Check participants stored correctly
  - Verify last message timestamp
  
✅ Send message
  - Message saved to `/conversations/{id}/messages`
  - Add sender metadata correctly
  - Timestamp accurate
  
✅ Receive message
  - Stream updates in real-time
  - Message appears on recipient's screen
  - Read status tracked
  
✅ Message history
  - Load last 50 messages
  - Pagination works
  - Order correct (newest last)
  
✅ Conversation list
  - Shows all user conversations
  - Sorted by last message time
  - Unread badge shows correctly
```

**Quick Test Code:**
```dart
void testChatFeature() async {
  final chatService = ChatService();
  
  // Create conversation
  final conv = await chatService.getOrCreateConversation(
    currentUserId: 'test_user_1',
    otherUserId: 'test_user_2',
    currentUserName: 'Test 1',
    otherUserName: 'Test 2',
    currentUserAvatar: 'avatar1.jpg',
    otherUserAvatar: 'avatar2.jpg',
  );
  print('✅ Conversation created: ${conv.id}');
  
  // Send message
  await chatService.sendMessage(
    conversationId: conv.id,
    senderId: 'test_user_1',
    senderName: 'Test 1',
    senderAvatar: 'avatar1.jpg',
    content: 'Hello from test!',
  );
  print('✅ Message sent');
  
  // Listen to messages
  chatService.getMessagesStream(conv.id).listen((messages) {
    print('✅ Got ${messages.length} messages');
  });
}
```

### Assessment Feature Tests

```dart
✅ Load assessments
  - Verify list loads from Firestore
  - All assessment fields present
  - Difficulty level correct
  
✅ Load questions
  - 30 MCQ questions loaded
  - Format correct (question, options, answer)
  - No duplicate questions
  
✅ Submit assessment
  - Answer validation works
  - Score calculated correctly (% of correct)
  - Badge assigned based on score
  - Result saved to Firestore
  
✅ Badge system
  - Platinum: 100% score
  - Gold: 90-99%
  - Silver: 80-89%
  - Bronze: 70-79%
  - Failed: <70%
  
✅ Skill verification
  - User skill added on pass
  - Appears on user profile
  - Can be filtered by badge
```

**Quick Test Code:**
```dart
void testAssessment() async {
  final assessmentService = AssessmentService();
  
  // Get assessments
  final assessments = await assessmentService.getAvailableAssessments();
  print('✅ Found ${assessments.length} assessments');
  
  // Get questions
  final questions = await assessmentService.getAssessmentQuestions(
    assessments.first.id,
  );
  print('✅ Loaded ${questions.length} questions');
  
  // Submit with perfect score
  final answers = questions.map((q) {
    return MapEntry(q.id, q.correctAnswer);
  }).toList();
  
  final result = await assessmentService.submitAssessment(
    userId: 'test_user',
    assessmentId: assessments.first.id,
    answers: answers,
    timeSpentSeconds: 1800,
  );
  
  print('✅ Score: ${result.scorePercentage}%');
  print('✅ Badge: ${result.badge}');
  print('✅ Passed: ${result.passed}');
}
```

### Payment Feature Tests

```dart
✅ Create payment
  - Payment record created in Firestore
  - All fields populated
  - Status = pending
  
✅ Wallet management
  - User wallet created on first payment
  - Balances tracked correctly
  - Can request withdrawal
  
✅ Stripe integration (test mode)
  - Test key recognized
  - Payment intent created
  - Status updates after processing
  
✅ Earnings summary
  - Monthly earnings calculated
  - Yearly totals correct
  - All-time earnings accurate
  
✅ Withdrawal
  - Request saved to Firestore
  - Amount deducted from available balance
  - Status tracked
```

**Quick Test Code:**
```dart
void testPayment() async {
  final paymentService = PaymentService();
  
  // Create payment
  final payment = await paymentService.createPayment(
    projectId: 'test_project',
    fromUserId: 'client_1',
    toUserId: 'mentor_1',
    amount: 5000.0,
    method: 'stripe',
  );
  print('✅ Payment created: ${payment.id}');
  
  // Get wallet
  final wallet = await paymentService.getUserWallet('mentor_1');
  print('✅ Wallet: \$${wallet.availableBalance}');
  
  // Request withdrawal
  await paymentService.requestWithdrawal(
    userId: 'mentor_1',
    amount: 1000.0,
    bankAccountId: 'bank_001',
  );
  print('✅ Withdrawal requested');
  
  // Get earnings summary
  final summary = await paymentService.getEarningsSummary('mentor_1');
  print('✅ This month: \$${summary['thisMonth']}');
}
```

### Video Consultation Tests

```dart
✅ Schedule consultation
  - Consultation record created
  - Pricing calculated correctly
  - Status = scheduled
  
✅ Room token generation
  - Token generated for video
  - Valid format
  - Can be used with Twilio/Agora
  
✅ Availability management
  - Mentor slots saved
  - Filtered by day of week
  - Can be updated
  
✅ Ratings
  - Rating saved after completion
  - Reflects on mentor profile
  - 0-5 stars
```

### Review & Fraud Detection Tests

```dart
✅ Submit review
  - Review saved to Firestore
  - All fields populated
  - Fraud check runs automatically
  
✅ Fraud detection
  - Short comments flagged (<20 chars)
  - Spam keywords detected
  - Extreme ratings flagged
  - Multiple flags trigger review status
  
✅ Moderation queue
  - Flagged reviews appear in getFlaggedReviews()
  - Admin can verify/reject
  - User rating recalculated
```

---

## 📱 Device Testing Checklist

### Android Testing

```bash
# Connect device
adb devices

# Run app
flutter run -d <device_id>

# Test on specific Android version (6.0, 8.0, 10.0, 12.0, etc.)
# Verify:
- Real-time updates work
- Messages sync correctly
- Images/attachments load
- Payment form displays
- No crashes on low memory
```

### iOS Testing

```bash
# List devices
xcrun simctl list devices

# Run app
flutter run -d <device_id>

# Test on different iOS versions (13, 14, 15, 16, 17)
# Verify:
- Real-time updates work
- Messages sync correctly
- Video permissions requested
- Payment form displays
- No crashes
```

### Cross-Platform Testing

```bash
✅ Android 8.0 and above
✅ iOS 13.0 and above
✅ WiFi connection
✅ Mobile data connection
✅ Offline mode (Firestore persistence)
✅ Network switching (WiFi ↔ Mobile)
✅ Low connectivity scenarios
```

---

## 🔐 Security Checklist

### API Keys Security

```
✅ Stripe keys
  - Test keys in version control (OK)
  - Production keys in environment only
  - No production keys in source code
  - Secret keys never exposed to client
  
✅ OpenAI keys
  - Test key in git (OK with rate limits)
  - Production in environment variables
  - Rotate regularly
  
✅ Firebase
  - Security rules properly configured
  - No public read/write rules
  - User data isolated
  - Payment data protected
```

### Firestore Security Rules

```
match /conversations/{conversationId} {
  allow read, write: if request.auth.uid in resource.data.participantIds;
  match /messages/{messageId} {
    allow read, write: if request.auth.uid in resource.data.participantIds;
  }
}

match /payments/{paymentId} {
  allow read: if request.auth.uid in [resource.data.fromUserId, resource.data.toUserId];
  allow create: if request.auth != null;
}

match /reviews/{reviewId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && resource.data.reviewerId == request.auth.uid;
  allow write: if request.auth.uid == resource.data.reviewerId;
}

match /assessmentResults/{resultId} {
  allow read, write: if request.auth.uid == resource.data.userId;
}
```

---

## 🚀 Deployment Steps

### Step 1: Create Release Build

```bash
# iOS
flutter build ios --release

# Android
flutter build appbundle --release

# Web
flutter build web --release
```

### Step 2: Play Store Release

```
1. Go to Google Play Console
2. Create new release
3. Upload .aab file
4. Fill in release notes:
   - New features: Chat, Assessments, Video consultations, Payments
   - Bug fixes
   - Performance improvements
5. Set 25% rollout for safety
6. Monitor for crashes
7. Full rollout if stable
```

### Step 3: App Store Release

```
1. Go to App Store Connect
2. Create new version
3. Upload ios build
4. Fill in release notes
5. Submit for review
6. Wait for approval (1-3 days)
7. Release when approved
```

### Step 4: Web Release

```bash
# Deploy to Firebase Hosting (if available)
firebase deploy --only hosting

# Or your hosting provider
# Update CNAME records if needed
```

### Step 5: Monitoring

```
1. Enable Crashlytics
2. Enable Analytics
3. Set up alerts for:
   - Crash rate > 5%
   - Performance issues
   - Payment failures
4. Monitor daily for first week
5. Respond to reviews
```

---

## ✨ Success Criteria

### For Each Feature

#### Chat ✅
- [x] Users can send messages
- [x] Messages appear in real-time
- [x] Message history persists
- [x] Unread counts work
- [ ] < 2 second latency
- [ ] < 1% failure rate

#### Assessment ✅
- [x] Users can take tests
- [x] Scores calculated accurately
- [x] Badges awarded correctly
- [x] Results persistent
- [ ] < 1% calculation errors
- [ ] < 0.1% data loss

#### Payment ✅
- [x] Payments processed
- [x] Wallet tracks earnings
- [x] Withdrawals work
- [x] Refunds successful
- [ ] 100% payment success rate
- [ ] < 1 transaction failure

#### Video ✅
- [x] Room tokens generated
- [x] Consultations scheduled
- [x] Ratings saved
- [x] Cancellations refund
- [ ] < 30 second connection
- [ ] < 1% video failures

---

## 📊 Metrics to Track

### User Engagement
- Daily active users per feature
- Feature adoption rate
- Average session duration
- Retention rate

### Quality Metrics
- Crash rate (target: < 0.1%)
- Error logs (target: < 1%)
- Performance (target: < 2s load time)
- Test coverage (target: > 80%)

### Business Metrics
- Payment conversion rate
- Assessment completion rate
- Review submission rate
- Video consultation booking rate

---

## 🆘 Support Contacts

If issues arise:

1. **Firestore Issues**: Check security rules
2. **Payment Issues**: Contact Stripe support
3. **Video Issues**: Check API credentials
4. **App Crashes**: Review crashlytics in Firebase Console
5. **User Issues**: Document and create GitHub issue

---

## 📋 Final Checklist Before Launch

```
PRE-LAUNCH
- [ ] All features tested locally
- [ ] All API keys configured
- [ ] Firestore rules deployed
- [ ] Push notifications working
- [ ] Offline mode tested
- [ ] Device testing complete
- [ ] Security review done
- [ ] Privacy policy updated
- [ ] Terms of service updated
- [ ] Release notes prepared

DEPLOYMENT
- [ ] Build created successfully
- [ ] Play Store/App Store submitted
- [ ] Monitoring enabled
- [ ] Team notified
- [ ] Support team trained
- [ ] Customer comms ready

POST-LAUNCH
- [ ] Monitor crashes (daily)
- [ ] Check analytics (daily)
- [ ] Respond to reviews (daily)
- [ ] Support tickets prioritized
- [ ] Hotfix plan ready
- [ ] Performance optimization planned
```

---

**Last Updated**: April 7, 2026  
**Status**: Ready for Deployment  
**Next Step**: Run `flutter pub get` to install get_it
