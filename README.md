# SheCan AI - Empowering Women to Earn, Learn and Empower

A beautiful, responsive Flutter application designed to connect women freelancers, mentors, and clients. Built with a modern pink-themed UI and comprehensive features for project management, payments, analytics, and more.

## 🌟 Features

### Authentication & Onboarding
- **Splash Screen** - Beautiful branded splash screen with app logo
- **User Type Selection** - Choose between Mentor and Client roles
- **Sign In/Create Account** - Complete authentication with email, phone, and social login options
- **Profile Completion** - Set up user profiles with photo upload and professional details

### Main Features
- **Dashboard** - Comprehensive overview with statistics, charts, and analytics
- **Project Management** - View and manage projects with status tracking and progress bars
- **Post Projects** - Create new project listings with detailed information
- **Best Matches** - Find and connect with talented professionals
- **Wellness Content** - Access educational content and resources
- **Payments** - Track earnings, pending payments, and financial projections
- **Analytics** - Detailed analytics dashboard with charts and insights
- **Messages** - Communication system for client-mentor interaction
- **Settings** - Comprehensive settings for notifications, privacy, and account management
- **Disputes** - Manage and resolve project disputes

### UI/UX Highlights
- ✨ Modern pink-themed design
- 📱 Fully responsive layout
- 🎨 Beautiful gradient cards and charts
- 📊 Interactive charts using FL Chart
- 🔔 Notification system
- 💳 Payment tracking
- 📈 Progress indicators
- 🎯 Bottom navigation for easy access

## 🛠 Tech Stack

- **Framework**: Flutter 3.8.1+
- **Language**: Dart
- **State Management**: Provider
- **Charts**: FL Chart
- **UI Components**: 
  - Percent Indicator
  - Image Picker
  - Custom widgets

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.1
  fl_chart: ^0.68.0
  percent_indicator: ^4.2.3
  image_picker: ^1.0.7
  intl: ^0.19.0
  shared_preferences: ^2.2.2
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/shecan_ai.git
   cd shecan_ai
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase (required for Sign In / Sign Up)**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This command links the app to your Firebase project and creates platform config files.

4. **Enable Email/Password auth in Firebase Console**
   - Open Firebase Console → Authentication → Sign-in method
   - Enable `Email/Password`

5. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For Windows
   flutter run -d windows

   # For Web
   flutter run -d chrome
   ```

## 📱 Screens

### Authentication Flow
1. Splash Screen
2. User Type Selection (Mentor/Client)
3. Sign In / Create Account
4. Complete Profile

### Main Application
1. **Home (Dashboard)**
   - Statistics cards
   - User growth charts
   - Project completion charts
   - Revenue charts
   - Skills distribution

2. **Projects**
   - Completed projects tab
   - Pending projects tab
   - Project cards with progress
   - Budget and deadline tracking

3. **Post Project**
   - Project creation form
   - Category selection
   - Budget input
   - Duration selection

4. **Notifications**
   - Real-time notifications
   - Activity tracking
   - Action buttons

5. **Profile**
   - User information
   - Statistics
   - Settings access
   - Menu items

### Additional Screens
- Analytics Dashboard
- Project Management (Table View)
- Disputes Management
- Payments & Wallet
- Best Matches/Talent Discovery
- Wellness Content
- Messages/Chat
- Settings

## 🎨 Design System

### Colors
- **Primary**: `#E91E63` (Pink)
- **Primary Light**: `#F8BBD0`
- **Primary Dark**: `#C2185B`
- **Success**: `#4CAF50`
- **Warning**: `#FFC107`
- **Error**: `#F44336`
- **Info**: `#2196F3`

### Typography
- **Display Large**: 32px, Bold
- **Display Medium**: 28px, Bold
- **Headline**: 20px, Semi-bold
- **Body**: 16px, Regular
- **Caption**: 12px, Regular

## 📂 Project Structure

```
lib/
├── constants/
│   ├── app_colors.dart
│   └── app_theme.dart
├── screens/
│   ├── splash_screen.dart
│   ├── user_type_screen.dart
│   ├── sign_in_screen.dart
│   ├── complete_profile_screen.dart
│   ├── main_navigation_screen.dart
│   ├── dashboard_screen.dart
│   ├── projects_screen.dart
│   ├── post_project_screen.dart
│   ├── notifications_screen.dart
│   ├── profile_screen.dart
│   ├── best_matches_screen.dart
│   ├── wellness_content_screen.dart
│   ├── project_management_screen.dart
│   ├── disputes_screen.dart
│   ├── payments_screen.dart
│   ├── analytics_screen.dart
│   ├── settings_screen.dart
│   └── messages_screen.dart
├── widgets/
├── models/
└── main.dart
```

## 🔧 Customization

### Changing Theme Colors
Edit [lib/constants/app_colors.dart](lib/constants/app_colors.dart):
```dart
static const Color primary = Color(0xFFE91E63); // Change to your color
```

### Adding New Screens
1. Create a new file in `lib/screens/`
2. Import necessary packages
3. Create a StatelessWidget or StatefulWidget
4. Add navigation in the appropriate screen

## 📝 Features Roadmap

- [ ] Backend integration
- [ ] Real-time chat functionality
- [ ] Payment gateway integration
- [ ] Push notifications
- [ ] Advanced analytics
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Offline support

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👏 Acknowledgments

- Design inspired by modern freelancing platforms
- Built with Flutter and love for women empowerment
- Icons from Material Design Icons

## 📞 Contact

For any queries or support, please reach out:
- Email: support@shecan.ai
- Website: https://shecan.ai

---

**Made with ❤️ for empowering women worldwide**

