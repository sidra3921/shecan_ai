# SheCan AI - Mobile Setup Instructions

## Step 1: Add Your Logo Image

1. **Save the logo image you provided** as:
   - `assets/icons/app_icon.png` (for app icons - should be 1024x1024px)
   - `assets/images/shecan_logo.png` (for splash screen - can be the same image)

2. **Remove the white background** from your logo:
   - You can use online tools like: remove.bg, photopea.com, or photoshop
   - Save as PNG with transparent background
   - Recommended size: 1024x1024 pixels

## Step 2: Install Dependencies

Open terminal and run:
```bash
cd e:\shecan_ai
flutter pub get
```

## Step 3: Generate App Icons

After adding your logo to `assets/icons/app_icon.png`, run:
```bash
flutter pub run flutter_launcher_icons
```

This will automatically generate app icons for:
- Android (all densities)
- iOS (all sizes)

## Step 4: Test on Mobile

### For Android:
1. Connect your Android device via USB
2. Enable Developer Options and USB Debugging
3. Run:
```bash
flutter run
```

### For iOS (requires Mac):
1. Connect your iPhone via USB
2. Run:
```bash
flutter run
```

### To build APK for Android:
```bash
flutter build apk --release
```
APK will be in: `build/app/outputs/flutter-apk/app-release.apk`

### To build for iOS (requires Mac):
```bash
flutter build ios --release
```

## Quick Commands

**List connected devices:**
```bash
flutter devices
```

**Run on specific device:**
```bash
flutter run -d <device-id>
```

**Hot reload while running:**
Press `r` in terminal

**Hot restart:**
Press `R` in terminal

## What I've Already Done:

✅ Added flutter_launcher_icons package
✅ Created assets folders (assets/images/ and assets/icons/)
✅ Configured pubspec.yaml for assets
✅ Set up icon generation configuration
✅ Updated splash screen to use logo image

## Next Steps for You:

1. Save your logo image (the one you showed me) to:
   - `e:\shecan_ai\assets\icons\app_icon.png`
   - `e:\shecan_ai\assets\images\shecan_logo.png`

2. Run `flutter pub get`

3. Run `flutter pub run flutter_launcher_icons`

4. Connect your phone and run `flutter run`

That's it! Your app will have the custom logo and icon! 🚀
