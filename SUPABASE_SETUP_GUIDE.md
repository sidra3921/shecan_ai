# Supabase Implementation Guide

## 🚀 Overview
This guide walks you through implementing Supabase as the complete backend replacement for Firebase in the SheCan AI project.

---

## ✅ Step 1: Create Supabase Project

### 1. Go to Supabase Dashboard
- Visit: https://app.supabase.com
- Sign up or log in with your account

### 2. Create a New Project
- Click **"New Project"** → **"Create a new project"**
- Fill in:
  - **Project Name**: `shecan-ai`
  - **Database Password**: Create a secure password (⚠️ Save this!)
  - **Region**: Choose closest to your users
  - Click **"Create new project"**

### 3. Wait for Setup (2-3 minutes)
You'll receive:
- **Project URL** (e.g., `https://xxxxx.supabase.co`)
- **Anon Key** (public key for client-side auth)
- **Service Role Key** (private - keep secure!)

### 4. Get Your Credentials
In your Supabase project:
1. Go: **Project Settings** → **API**
2. Copy:
   - **Project URL**
   - **Anon Key** (under "Project API keys")

---

## 📝 Step 2: Add Credentials to Your App

### Option A: Environment Variables (Recommended for Production)
Create a `.env` file in your project root:
```
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

### Option B: Direct Configuration (Development)
Update `lib/config/app_config.dart`:
```dart
/// ============ SUPABASE CONFIGURATION ============
static const String supabaseUrl = 'https://xxxxx.supabase.co';
static const String supabaseAnonKey = 'your_anon_key_here';
```

---

## 🗄️ Step 3: Create Database Tables

Run these SQL queries in Supabase SQL Editor:

### 1. Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  display_name TEXT,
  user_type TEXT, -- 'mentor', 'client', 'freelancer'
  photo_url TEXT,
  phone TEXT,
  rating DECIMAL(3,2) DEFAULT 0,
  completed_projects INT DEFAULT 0,
  skills TEXT[] DEFAULT '{}',
  bio TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_user_type ON users(user_type);
```

### 2. Projects Table
```sql
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES users(id),
  freelancer_id UUID REFERENCES users(id),
  title TEXT NOT NULL,
  description TEXT,
  budget DECIMAL(10,2),
  status TEXT, -- 'open', 'in_progress', 'completed', 'cancelled'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_projects_client ON projects(client_id);
CREATE INDEX idx_projects_freelancer ON projects(freelancer_id);
CREATE INDEX idx_projects_status ON projects(status);
```

### 3. Messages Table
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL,
  sender_id UUID NOT NULL REFERENCES users(id),
  receiver_id UUID NOT NULL REFERENCES users(id),
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id);
```

### 4. Notifications Table
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  type TEXT, -- 'message', 'project_update', 'payment'
  title TEXT,
  content TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
```

### 5. Payments Table
```sql
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id),
  user_id UUID NOT NULL REFERENCES users(id),
  amount DECIMAL(10,2),
  currency TEXT DEFAULT 'USD',
  status TEXT, -- 'pending', 'completed', 'failed'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_project ON payments(project_id);
CREATE INDEX idx_payments_user ON payments(user_id);
```

### 6. Reviews Table
```sql
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id),
  reviewer_id UUID NOT NULL REFERENCES users(id),
  reviewed_user_id UUID NOT NULL REFERENCES users(id),
  rating INT CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reviews_reviewed_user ON reviews(reviewed_user_id);
```

### 7. Disputes Table
```sql
CREATE TABLE disputes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id),
  initiator_id UUID NOT NULL REFERENCES users(id),
  reason TEXT,
  status TEXT, -- 'open', 'resolved', 'escalated'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_disputes_status ON disputes(status);
```

---

## 🗂️ Step 4: Enable Storage Buckets

In Supabase dashboard, go to **Storage** and create these public buckets:

1. **profile-photos** (for user profile pictures)
2. **project-photos** (for project images)
3. **documents** (for file uploads)
4. **videos** (for video consultation recordings)

### Set Bucket Policies (Storage → Policies)
For each bucket, add this policy to allow public read (adjust as needed):
```sql
-- Allow public read access
CREATE POLICY "Public read access"
  ON storage.objects
  FOR SELECT USING (bucket_id = 'bucket-name');

-- Allow authenticated users to upload
CREATE POLICY "Authenticated users can upload"
  ON storage.objects
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

---

## ⚙️ Step 5: Enable Row Level Security (RLS)

Go to **Authentication** → **Policies** and enable RLS for all tables:

### Example: Users Table RLS
```sql
-- Users can only see their own data
CREATE POLICY "Users can see own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Users can only update their own data
CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);
```

---

## 🔧 Step 6: Environment Variables Setup

### For Android
Add to `android/local.properties`:
```properties
supabase.url=https://xxxxx.supabase.co
supabase.anon_key=your_anon_key
```

### For iOS
Edit `ios/Runner/Runner.xcodeproj/project.pbxproj` or use Xcode to add build variables

### For Web
Create `web/.env`:
```
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key
```

---

## 📱 Step 7: Flutter Package Installation

```bash
cd e:\shecan_ai
flutter pub get
```

The following Supabase package is already added:
- `supabase_flutter: ^2.6.0`

---

## 🚀 Step 8: Update main.dart

Update your `lib/main.dart` to initialize Supabase:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';

final supabaseService = SupabaseService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await supabaseService.initialize(
    supabaseUrl: 'YOUR_SUPABASE_URL',
    supabaseAnonKey: 'YOUR_ANON_KEY',
  );

  // Setup Service Locator
  _setupServiceLocator();

  runApp(const MyApp());
}
```

---

## 📚 Service Classes

### Available Services:

1. **SupabaseService** - Core initialization and auth state
   - Location: `lib/services/supabase_service.dart`
   - Usage: Initialization and general client access

2. **SupabaseAuthService** - Authentication (replaces Firebase Auth)
   - Location: `lib/services/supabase_auth_service.dart`
   - Methods:
     - `signUpWithEmail()` - Register new user
     - `signInWithEmail()` - Login user
     - `sendPasswordResetEmail()` - Password reset
     - `changePassword()` - Change password
     - `signOut()` - Logout

3. **SupabaseDatabaseService** - Database operations (replaces Firestore)
   - Location: `lib/services/supabase_database_service.dart`
   - Methods for: Users, Projects, Messages, Payments, Reviews, Disputes

4. **SupabaseStorageService** - File storage (replaces Firebase Storage)
   - Location: `lib/services/supabase_storage_service.dart`
   - Methods for: Profile photos, Project photos, Documents, Videos

---

## 💡 Usage Examples

### Authentication
```dart
final authService = SupabaseAuthService();

// Sign up
final user = await authService.signUpWithEmail(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'John Doe',
  userType: 'mentor',
);

// Sign in
final user = await authService.signInWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

// Sign out
await authService.signOut();
```

### Database Operations
```dart
final dbService = SupabaseDatabaseService();

// Get user
final user = await dbService.getUser(userId);

// Stream user data (real-time)
dbService.streamUser(userId).listen((user) {
  print(user);
});

// Create project
final projectId = await dbService.createProject(projectModel);

// Get all mentors
final mentors = await dbService.getMentors(skills: ['Flutter', 'Dart']);
```

### File Storage
```dart
final storageService = SupabaseStorageService();

// Upload profile photo
final photoUrl = await storageService.uploadProfilePhoto(
  userId: userId,
  imageFile: file,
);

// Upload project photos
final urls = await storageService.uploadProjectPhotos(
  projectId: projectId,
  imageFiles: [file1, file2],
);
```

---

## 🔒 Security Best Practices

1. **NEVER commit API keys to GitHub**
   - Use `.env` files (add to `.gitignore`)
   - Use environment variables
   - Use secure secret management

2. **Enable Row Level Security (RLS)**
   - Restrict data access per user
   - Prevent unauthorized data access

3. **Use Service Role Key carefully**
   - Only on backend servers
   - Never expose in client code

4. **Validate inputs**
   - Always validate user input before database operations

5. **Use HTTPS only**
   - Supabase handles this automatically

---

## 🐛 Troubleshooting

### Connection Issues
- Check your Supabase URL and API key
- Ensure your project is running in Supabase
- Check network connectivity

### Authentication Errors
- Verify email/password is correct
- Check if user exists in database
- Check Supabase auth logs: **Authentication** → **Policies**

### Storage Issues
- Verify bucket exists and is public
- Check file permissions and RLS policies
- Ensure file paths are correct

### Database Errors
- Check table schema matches your models
- Verify RLS policies allow the operation
- Check for type mismatches in data

---

## 📖 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/flutter)
- [Supabase Database Guide](https://supabase.com/docs/guides/database)
- [Supabase Authentication](https://supabase.com/docs/guides/auth)
- [Supabase Storage](https://supabase.com/docs/guides/storage)

---

## ✨ Next Steps

1. ✅ Create Supabase project
2. ✅ Get credentials (URL + Anon Key)
3. ✅ Create database tables (SQL scripts above)
4. ✅ Set up storage buckets
5. ✅ Configure Flutter app
6. ⏳ Update your screens to use new services
7. ⏳ Test authentication flow
8. ⏳ Test database operations
9. ⏳ Test file uploads

---

**Happy building! 🎉**
