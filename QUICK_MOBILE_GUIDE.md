# 📱 Quick Mobile Setup Guide - SheCan AI

## ⚡ QUICK START (Follow These Steps)

### Step 1: Save Your Logo Image 🎨

**IMPORTANT:** You need to manually save your logo image!

1. **Download/Save the logo image** you provided to these locations:
   ```
   e:\shecan_ai\assets\icons\app_icon.png
   e:\shecan_ai\assets\images\shecan_logo.png
   ```

2. **Remove white background:**
   - Use online tool: https://www.remove.bg/
   - Or use: https://www.photopea.com/
   - Save as PNG with **transparent background**
   - Recommended size: **1024x1024 pixels**

### Step 2: Generate App Icons 🔧

After saving your logo, open terminal and run:

```bash
flutter pub run flutter_launcher_icons
```

This will automatically create app icons for Android and iOS!

### Step 3: Connect Your Phone 📱

**For Android:**
1. Enable Developer Options on your phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
2. Enable USB Debugging:
   - Settings → Developer Options → USB Debugging
3. Connect phone via USB cable
4. Accept "Allow USB Debugging" on your phone

**For iOS (needs Mac):**
1. Connect iPhone via USB
2. Trust the computer on your iPhone

### Step 4: Run the App 🚀

Check connected devices:
```bash
flutter devices
```

Run on your phone:
```bash
flutter run
```

Or run on specific device:
```bash
flutter run -d <device-id>
```

## 🎯 What I've Already Done For You:

✅ Added `flutter_launcher_icons` package  
✅ Created `assets/images/` and `assets/icons/` folders  
✅ Configured `pubspec.yaml` for assets and icons  
✅ Updated splash screen to use logo image  
✅ Set up icon generation config  
✅ Ran `flutter pub get`  

## 📦 Build Release APK (Optional)

To create an installable APK file:

```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

You can share this APK file with others!

## 🔥 Hot Reload Commands

While the app is running:
- Press **`r`** - Hot reload (fast)
- Press **`R`** - Hot restart (complete restart)
- Press **`q`** - Quit

## ⚠️ If You Get Errors:

**"Unable to locate asset"** error:
1. Make sure you saved the logo to exact paths above
2. Run: `flutter clean`
3. Run: `flutter pub get`
4. Run again: `flutter run`

**"No devices found":**
1. Check USB cable connection
2. Make sure USB Debugging is enabled
3. Run: `flutter devices` to see available devices

**"Gradle build failed"** (Android):
1. Make sure you have internet connection
2. First build takes 5-10 minutes (downloading dependencies)
3. Be patient!

## 📂 Your Logo Files Should Be At:

```
e:\shecan_ai\
├── assets\
│   ├── icons\
│   │   └── app_icon.png       ← Save here (1024x1024px, transparent background)
│   └── images\
│       └── shecan_logo.png    ← Save here (same image as above)
```

## 🎨 Logo Requirements:

- **Format:** PNG
- **Size:** 1024x1024 pixels (or larger)
- **Background:** Transparent (no white background)
- **Content:** Your SheCan AI logo

## 🚀 Ready to Test!

Once you've saved the logo images, just run:

```bash
flutter run
```

And your app will launch on your connected phone with your custom logo! 🎉

---

**Need help?** Check the terminal output for error messages and follow the suggestions above.
