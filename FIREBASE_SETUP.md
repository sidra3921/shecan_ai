# Firebase Backend Setup Instructions

## ⚠️ Manual Steps Required

Since PowerShell 6+ is not available, please complete these manual steps:

### 1. Create Services Directory
Run this in Command Prompt:
```cmd
cd e:\shecan_ai
mkdir lib\services
```

### 2. Install Firebase Packages
Run this in Command Prompt:
```cmd
cd e:\shecan_ai
flutter pub get
```

This will install the following packages already added to pubspec.yaml:
- cloud_firestore: ^5.7.0
- firebase_storage: ^12.5.0
- firebase_messaging: ^15.2.0
- firebase_analytics: ^11.5.0

### 3. Firebase Console Setup

#### a) Go to Firebase Console
1. Visit: https://console.firebase.google.com
2. Select your existing project (or create new one)

#### b) Enable Firestore Database
1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (we'll add security rules later)
4. Select your preferred location
5. Click "Enable"

#### c) Enable Firebase Storage
1. Go to "Storage" in Firebase Console
2. Click "Get Started"
3. Start in test mode
4. Click "Done"

#### d) Enable Cloud Messaging (FCM)
1. Go to "Cloud Messaging" in Firebase Console
2. Click "Get Started"
3. Follow the setup wizard

#### e) Download Configuration Files (iOS)
If you need iOS support:
1. Go to Project Settings > General
2. Under "Your apps", find the iOS app
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

### 4. Initialize Firestore Collections

The app will automatically create collections when first used, but you can manually create them:

**Collections to create in Firestore:**
- users
- projects
- chats (with subcollection: messages)
- notifications
- payments
- disputes
- reviews

### 5. Update Firebase Security Rules

In Firebase Console > Firestore Database > Rules, replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }
    
    // Projects collection
    match /projects/{projectId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && (
        isOwner(resource.data.clientId) || 
        isOwner(resource.data.mentorId)
      );
      allow delete: if isOwner(resource.data.clientId);
    }
    
    // Chats collection
    match /chats/{chatId} {
      allow read, write: if isAuthenticated() && 
        request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read, write: if isAuthenticated() && 
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
      }
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      allow read, update: if isOwner(resource.data.userId);
      allow create: if isAuthenticated();
    }
    
    // Payments collection
    match /payments/{paymentId} {
      allow read: if isAuthenticated() && (
        isOwner(resource.data.fromUserId) || 
        isOwner(resource.data.toUserId)
      );
      allow create: if isAuthenticated();
      allow update: if isAuthenticated(); // Admins only in production
    }
    
    // Disputes collection
    match /disputes/{disputeId} {
      allow read: if isAuthenticated() && 
        request.auth.uid in resource.data.participants;
      allow create: if isAuthenticated();
      allow update: if isAuthenticated(); // Admins only in production
    }
    
    // Reviews collection
    match /reviews/{reviewId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && isOwner(request.resource.data.reviewerId);
      allow update, delete: if isOwner(resource.data.reviewerId);
    }
  }
}
```

### 6. Update Firebase Storage Rules

In Firebase Console > Storage > Rules, replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // User profile images
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Project files
    match /projects/{projectId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Chat media
    match /messages/{chatId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📝 Files Created

### Models (Already Created ✓)
- ✓ lib/models/user_model.dart
- ✓ lib/models/project_model.dart
- ✓ lib/models/message_model.dart
- ✓ lib/models/notification_model.dart
- ✓ lib/models/payment_model.dart
- ✓ lib/models/dispute_model.dart
- ✓ lib/models/review_model.dart

### Services (To Be Created After Directory Setup)
- lib/services/firestore_service.dart
- lib/services/storage_service.dart
- lib/services/notification_service.dart
- lib/services/auth_service.dart

## 🧪 Testing

After setup, test the connection:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

void testFirestoreConnection() async {
  try {
    await FirebaseFirestore.instance.collection('users').limit(1).get();
    print('✓ Firestore connection successful');
  } catch (e) {
    print('✗ Firestore connection failed: $e');
  }
}
```

## 🔄 Next Steps

Once manual steps are complete, I will:
1. Create all service files
2. Update authentication to create user documents
3. Connect UI screens to Firestore
4. Implement real-time features
5. Add offline support
6. Set up Cloud Functions (optional)

## 📞 Support

If you encounter any issues:
1. Check Firebase Console for errors
2. Verify all configuration files are in place
3. Ensure Firebase packages are installed
4. Check Firebase security rules are deployed
