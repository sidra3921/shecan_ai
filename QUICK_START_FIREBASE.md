# Firebase Backend - Quick Start Guide

## 🚀 Quick Setup Steps

### Step 1: Create Required Directories

Open Command Prompt and run:
```cmd
cd e:\shecan_ai
mkdir lib\services
```

### Step 2: Copy Service Files

Copy the following files from the root directory to `lib\services\`:

1. **firestore_service_CODE.txt** → **lib/services/firestore_service.dart**
2. **storage_service_CODE.txt** → **lib/services/storage_service.dart**
3. **notification_service_CODE.txt** → **lib/services/notification_service.dart**
4. **auth_service_CODE.txt** → **lib/services/auth_service.dart**

*Remove the `// SAVE THIS FILE AS:` comment from the top of each file after copying.*

### Step 3: Install Packages

```cmd
cd e:\shecan_ai
flutter pub get
```

This will install:
- ✅ cloud_firestore: ^5.7.0
- ✅ firebase_storage: ^12.5.0
- ✅ firebase_messaging: ^15.2.0
- ✅ firebase_analytics: ^11.5.0

### Step 4: Firebase Console Setup

1. **Go to Firebase Console**: https://console.firebase.google.com
2. **Select your project** (SheCan AI)
3. **Enable Firestore Database**:
   - Click "Firestore Database" → "Create database"
   - Start in "test mode"
   - Choose location
4. **Enable Firebase Storage**:
   - Click "Storage" → "Get Started"
   - Start in "test mode"
5. **Enable Cloud Messaging**:
   - Click "Cloud Messaging" → Configure

### Step 5: Initialize Firebase in Your App

Update **lib/main.dart**:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/notification_service.dart';

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize FCM background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const MyApp());
}
```

## 📱 Usage Examples

### Example 1: Create User Profile After Sign Up

```dart
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

Future<void> signUpUser() async {
  final authService = AuthService();
  final firestoreService = FirestoreService();
  
  // Sign up
  final credential = await authService.signUpWithEmail(
    email: 'user@example.com',
    password: 'password123',
    displayName: 'Jane Doe',
    userType: 'client', // or 'mentor'
  );
  
  print('User created: ${credential?.user?.uid}');
}
```

### Example 2: Create a Project

```dart
import '../services/firestore_service.dart';
import '../models/project_model.dart';

Future<void> createProject() async {
  final firestoreService = FirestoreService();
  
  final project = ProjectModel(
    id: '', // Firestore will generate
    title: 'Build a Mobile App',
    description: 'Need a Flutter developer to build an app',
    budget: 50000.0,
    deadline: DateTime.now().add(Duration(days: 30)),
    status: 'pending',
    clientId: AuthService().currentUserId!,
    skills: ['Flutter', 'Dart', 'Firebase'],
  );
  
  final projectId = await firestoreService.createProject(project);
  print('Project created with ID: $projectId');
}
```

### Example 3: Stream User Projects (Real-time)

```dart
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class MyProjectsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final userId = AuthService().currentUserId!;
    
    return StreamBuilder(
      stream: firestoreService.streamClientProjects(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        
        final projects = snapshot.data ?? [];
        
        return ListView.builder(
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return ListTile(
              title: Text(project.title),
              subtitle: Text('Budget: PKR ${project.budget}'),
              trailing: Text(project.status),
            );
          },
        );
      },
    );
  }
}
```

### Example 4: Upload Profile Photo

```dart
import '../services/storage_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

Future<void> uploadProfilePhoto() async {
  final storageService = StorageService();
  final firestoreService = FirestoreService();
  final userId = AuthService().currentUserId!;
  
  // Pick and upload photo
  final photoURL = await storageService.pickAndUploadProfilePhoto(userId);
  
  if (photoURL != null) {
    // Update user profile
    final user = await firestoreService.getUser(userId);
    if (user != null) {
      final updatedUser = user.copyWith(photoURL: photoURL);
      await firestoreService.saveUser(updatedUser);
      print('Profile photo updated!');
    }
  }
}
```

### Example 5: Send and Receive Messages

```dart
import '../services/firestore_service.dart';
import '../models/message_model.dart';

Future<void> sendMessage(String receiverId, String text) async {
  final firestoreService = FirestoreService();
  final senderId = AuthService().currentUserId!;
  
  // Create chat ID (consistent for both users)
  final chatId = senderId.hashCode < receiverId.hashCode
      ? '${senderId}_$receiverId'
      : '${receiverId}_$senderId';
  
  final message = MessageModel(
    id: '', // Firestore will generate
    senderId: senderId,
    receiverId: receiverId,
    text: text,
    type: 'text',
  );
  
  await firestoreService.sendMessage(chatId, message);
}

// Stream messages in your chat screen
StreamBuilder(
  stream: firestoreService.streamMessages(chatId),
  builder: (context, snapshot) {
    final messages = snapshot.data ?? [];
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return Text(message.text);
      },
    );
  },
)
```

### Example 6: Send Notifications

```dart
import '../services/notification_service.dart';

Future<void> notifyUser() async {
  final notificationService = NotificationService();
  
  await notificationService.sendProjectNotification(
    userId: 'user123',
    projectId: 'project456',
    title: 'New Project Match',
    message: 'A project matching your skills is available!',
  );
}
```

## 🔒 Security Rules

### Firestore Security Rules

See **FIREBASE_SETUP.md** for complete security rules. Quick summary:

- Users can read all profiles, but only edit their own
- Projects can be read by anyone, edited by owner/mentor
- Messages restricted to chat participants
- Notifications private to owner
- Payments visible to sender/receiver only

### Storage Security Rules

See **FIREBASE_SETUP.md** for complete storage rules. Quick summary:

- Users can upload to their own folders only
- Project files accessible to project participants
- Chat media accessible to chat participants

## 📊 Offline Support

Enable offline persistence in your app:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Enable offline persistence
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  runApp(const MyApp());
}
```

## 🧪 Testing

Test Firestore connection:

```dart
Future<void> testConnection() async {
  try {
    await FirebaseFirestore.instance.collection('users').limit(1).get();
    print('✅ Firestore connected successfully!');
  } catch (e) {
    print('❌ Firestore connection failed: $e');
  }
}
```

## 📁 File Structure

```
lib/
├── models/
│   ├── user_model.dart ✅
│   ├── project_model.dart ✅
│   ├── message_model.dart ✅
│   ├── notification_model.dart ✅
│   ├── payment_model.dart ✅
│   ├── dispute_model.dart ✅
│   └── review_model.dart ✅
├── services/
│   ├── firestore_service.dart (copy from firestore_service_CODE.txt)
│   ├── storage_service.dart (copy from storage_service_CODE.txt)
│   ├── notification_service.dart (copy from notification_service_CODE.txt)
│   └── auth_service.dart (copy from auth_service_CODE.txt)
├── screens/ (existing)
└── main.dart (update to initialize Firebase)
```

## 🎯 Next Steps

After completing setup:

1. ✅ Update sign-in screen to use AuthService
2. ✅ Update profile screen to use Firestore and Storage
3. ✅ Connect project screens to Firestore
4. ✅ Implement real-time chat
5. ✅ Add notifications
6. ✅ Test offline functionality

## 🆘 Troubleshooting

**Issue**: Firestore permission denied
- Check security rules in Firebase Console
- Ensure user is authenticated
- Verify rule matches your data structure

**Issue**: Storage upload fails
- Check storage rules
- Verify file size limits
- Ensure Firebase Storage is enabled

**Issue**: Notifications not working
- Check FCM setup in Firebase Console
- Verify app is registered for push notifications
- Test with Firebase Console test message

## 📝 Clean Up

After copying service files, you can delete these temporary files:
- firestore_service_CODE.txt
- storage_service_CODE.txt
- notification_service_CODE.txt
- auth_service_CODE.txt
- create_services_dir.bat

---

**🎉 Your Firebase backend is ready to use!**
