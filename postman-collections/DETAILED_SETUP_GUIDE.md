# Complete Step-by-Step API Keys Setup Guide

## 📋 Table of Contents
1. [Download & Install Postman](#download--install-postman)
2. [Get Firebase API Keys](#get-firebase-api-keys)
3. [Get Stripe API Keys](#get-stripe-api-keys)
4. [Get Twilio API Keys](#get-twilio-api-keys)
5. [Get Agora API Keys](#get-agora-api-keys)
6. [Get OpenAI API Keys](#get-openai-api-keys)
7. [Import Postman Collection](#import-postman-collection)
8. [Configure Environment Variables](#configure-environment-variables)
9. [Test Your Setup](#test-your-setup)

---

# PART 1: Download & Install Postman

## Step 1.1: Download Postman

1. **Open your browser** and go to: https://www.postman.com/downloads/
2. **Choose your operating system:**
   - Windows (64-bit) → Download `.exe` file
   - Mac → Download `.dmg` file
   - Linux → Download appropriate version

3. **Wait for download** to complete (usually 100-200 MB)

## Step 1.2: Install Postman

### On Windows:
1. Open your Downloads folder
2. **Double-click** `Postman-Setup-[version].exe`
3. Click **Install** when prompted
4. Wait for installation to complete (2-3 minutes)
5. **Postman will launch automatically**

### On Mac:
1. Double-click `Postman-[version].dmg`
2. Drag **Postman icon** to **Applications** folder
3. Open Applications → Launch Postman
4. Approve the security permission if prompted

### On Linux:
1. Extract the downloaded file
2. Run: `./Postman/Postman`

## Step 1.3: Create Postman Account

When Postman opens for the first time:

1. **Click "Sign up with email"** (or use Google/GitHub)
2. **Enter your email** and **create password**
3. **Verify email** - Check your inbox for confirmation link
4. **Click verification link** in email
5. **Login to Postman** with your account

✅ **Postman is now ready!**

---

# PART 2: Get Firebase API Keys

## Step 2.1: Open Firebase Console

1. **Go to:** https://console.firebase.google.com
2. **Sign in with Google account** (use same account you used to create Firebase project)
3. **Select your project** from the list (should be "shecan-ai-project")

## Step 2.2: Find Project Settings

1. **Look for gear icon (⚙️)** in top-left corner, next to "Project Overview"
2. **Click the gear icon**
3. **Click "Project Settings"** from dropdown menu

## Step 2.3: Get API Key

Inside Project Settings page:

1. **Scroll down** to find "Your apps" section (or click "General" tab if not visible)
2. **Look for "Web API Key"** section
3. You'll see a key that starts with `AIza...`
4. **Copy this key** (click copy icon or select all and Ctrl+C)
5. **Save it somewhere safe** (temp document, notepad)

Example: `AIza7s-k2n9F_YOUR_KEY_HERE`

## Step 2.4: Get Project ID

Same page, look for:
- **"Project ID"** field
- Usually looks like: `shecan-ai-project` or `shecan-ai-project-123456`
- **Copy this value**

## Step 2.5: Get Database URL

1. **Click "Realtime Database"** in left sidebar
2. **Look for your database URL**
- Usually: `https://shecan-ai-project.firebaseio.com`
- **Copy this value**

### Firebase Keys Summary:
```
firebase_api_key: AIza...YOUR_KEY_HERE
firebase_project_id: shecan-ai-project
firebase_database_url: https://shecan-ai-project.firebaseio.com
```

---

# PART 3: Get Stripe API Keys

## Step 3.1: Open Stripe Dashboard

1. **Go to:** https://dashboard.stripe.com
2. **Sign in** with your Stripe account (if you don't have one, create at https://stripe.com)
3. **Verify your email** if prompted

## Step 3.2: Switch to Test Mode

1. **Look for toggle** in top-right area labeled "Test mode" / "Live mode"
2. **Make sure "Test mode" is ON** (toggle should be blue/active)
   - ⚠️ **IMPORTANT:** Always use test mode for development!

## Step 3.3: Find API Keys

1. **Click "Developers"** in left sidebar (or top menu)
2. **Click "API keys"** from submenu

You'll see two keys:

### Secret Key (Keep Private!)
- Starts with: `sk_test_...`
- **Copy this** → Save safely
- ⚠️ **NEVER share this key!**

Format: `sk_test_` followed by random characters

### Publishable Key
- Starts with: `pk_test_...`
- **Copy this** → Save safely
- This is safe to share (frontend use)

Format: `pk_test_` followed by random characters

### Stripe Keys Summary:
```
stripe_secret_key: sk_test_...YOUR_KEY_HERE
stripe_publishable_key: pk_test_...YOUR_KEY_HERE
```

---

# PART 4: Get Twilio API Keys

## Step 4.1: Create Twilio Account

1. **Go to:** https://www.twilio.com/try-twilio
2. **Sign up** with email address
3. **Verify your phone number** (you'll receive SMS code)
4. **Agree to terms** and complete signup

## Step 4.2: Open Twilio Console

After signup, you'll be in the Twilio Console automatically.

If not, go to: https://console.twilio.com

## Step 4.3: Find Account SID

1. **Look at the main dashboard**
2. **Find "Account SID"** field (usually at top)
3. It looks like: `AC1234567890abcdefghijklmnop`
4. **Click the eye icon** to reveal full value
5. **Copy the full Account SID**

## Step 4.4: Find Auth Token

On same page:

1. **Find "Auth Token"** field (right next to Account SID)
2. **Click eye icon** to reveal it
3. It's a long random string: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`
4. **Copy the Auth Token**
5. ⚠️ **Keep this private!**

## Step 4.5: Enable Twilio Video (Optional)

1. **Click "Products"** in left sidebar
2. **Find "Video"**
3. **Click "Video"** to enable it
4. Your account now supports video features

### Twilio Keys Summary:
```
twilio_account_sid: AC1234567890abcdefghijklmnop
twilio_auth_token: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

---

# PART 5: Get Agora API Keys

## Step 5.1: Create Agora Account

1. **Go to:** https://console.agora.io
2. **Sign up** (use Google, GitHub, or email)
3. **Verify email** - Check inbox for confirmation
4. **Complete profile** setup

## Step 5.2: Create a New Project

1. **Click "Project"** in left sidebar
2. **Click "Create"** button
3. **Project name:** Enter `shecan-ai-video`
4. **Use case:** Select "Real-time communication"
5. **Click "Create"**

## Step 5.3: Find App ID

1. **Your project is now created**
2. **Look for "App ID"** on the project page
3. It's a long hex string: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t`
4. **Copy the App ID**

## Step 5.4: Get API Key

1. **Click "Config"** on the project page
2. **Look for "API Key"** section
3. Click **"Generate"** if no key exists
4. **Copy the generated API Key**

### Agora Keys Summary:
```
agora_app_id: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t
agora_api_key: b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u
```

---

# PART 6: Get OpenAI API Keys

## Step 6.1: Create OpenAI Account

1. **Go to:** https://platform.openai.com
2. **Click "Sign up"**
3. **Enter email** and create password
4. **Verify email** - Check your inbox
5. **Add phone number** for verification (may be required)

## Step 6.2: Add Payment Method

⚠️ **IMPORTANT:** OpenAI requires a valid payment method

1. **Click your profile icon** (top-right)
2. **Click "Billing overview"**
3. **Click "Add to account"** or **"Payment methods"**
4. **Enter credit card details:**
   - Card number
   - Expiration date
   - CVC (3-digit code on back)
5. **Set billing limit** (e.g., $5/month for testing)
6. **Save**

## Step 6.3: Get API Key

1. **Click your profile icon** (top-right)
2. **Click "API keys"** from dropdown
3. **Click "Create new secret key"** button
4. **Give it a name** (e.g., "Shecan AI Development")
5. **Click "Create secret key"**
6. **Copy the API key** (shows only once!)
   - Format: `sk-proj-1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6...`
7. ⚠️ **Save this immediately** - can't retrieve later!

## Step 6.4: Set Usage Limits (Optional)

1. **Go back to Billing overview**
2. **Find "Usage limits"**
3. **Set "Hard limit"** (e.g., $10/month)
4. **Set "Soft limit"** (e.g., $5/month for alerts)
5. **Save** - You'll get alerts if approaching limits

### OpenAI Keys Summary:
```
openai_api_key: sk-proj-1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6...
```

---

# PART 7: Import Postman Collection

## Step 7.1: Collect Your Files

Make sure you have downloaded from your project:

1. **shecan-ai-collection.json** ← Located in `postman-collections/` folder
2. **shecan-ai-environment.json** ← Located in `postman-collections/` folder

**File locations in your project:**
```
e:\shecan_ai\postman-collections\
├── shecan-ai-collection.json
├── shecan-ai-environment.json
└── POSTMAN_IMPORT_GUIDE.md
```

## Step 7.2: Open Postman

1. **Launch Postman** (already installed)
2. **Login with your account** if not already logged in
3. **You'll see the main workspace**

## Step 7.3: Import Collection

1. **Look for "Import" button** (top-left, near "Create")
2. **Click Import**
3. **You'll see 4 options:**
   - File
   - Folder
   - Link
   - Paste raw text
4. **Click "File"** tab
5. **Click "Upload Files"** button
6. **Navigate to:** `e:\shecan_ai\postman-collections\`
7. **Select:** `shecan-ai-collection.json`
8. **Click "Open"**
9. **Click "Import"** button at bottom
10. ✅ **Collection imported!** - You'll see "Shecan AI - Complete API Integration" in left sidebar

## Step 7.4: Import Environment

1. **Click "Import"** button again (same as before)
2. **Click "File"** tab
3. **Click "Upload Files"**
4. **Navigate to:** `e:\shecan_ai\postman-collections\`
5. **Select:** `shecan-ai-environment.json`
6. **Click "Open"**
7. **Click "Import"** button
8. ✅ **Environment imported!**

---

# PART 8: Configure Environment Variables

## Step 8.1: Open Environment Settings

1. **Look at top-right corner** - You'll see environment dropdown
2. **It currently shows:** "No Environment" or similar
3. **Click the dropdown**
4. **Select:** "Shecan AI - Development Environment"
5. ✅ **Environment is now active!**

## Step 8.2: Edit Environment Variables

Now you need to add your actual API keys:

1. **Click on the eye icon** (top-right) → Shows "Environment variables"
2. **Click "Edit"** button (or double-click environment name)
3. A modal will open showing all variables

### You'll see these placeholders:

| Variable | Current Value | You Need to Replace With |
|----------|---------------|--------------------------|
| `firebase_api_key` | `AIxxxxx_YOUR_FIREBASE_API_KEY_HERE` | Your actual Firebase API key |
| `firebase_project_id` | `shecan-ai-project` | Your actual Firebase project ID |
| `firebase_database_url` | `https://shecan-ai-project...` | Your actual Firebase database URL |
| `stripe_secret_key` | `sk_test_YOUR_STRIPE_SECRET_KEY_HERE` | Your actual Stripe secret key |
| `stripe_publishable_key` | `pk_test_YOUR_STRIPE_PUBLISHABLE_KEY_HERE` | Your Stripe publishable key |
| `twilio_account_sid` | `AC_YOUR_TWILIO_ACCOUNT_SID_HERE` | Your Twilio Account SID |
| `twilio_auth_token` | `YOUR_TWILIO_AUTH_TOKEN_HERE` | Your Twilio Auth Token |
| `agora_app_id` | `YOUR_AGORA_APP_ID_HERE` | Your Agora App ID |
| `agora_api_key` | `YOUR_AGORA_API_KEY_HERE` | Your Agora API Key |
| `openai_api_key` | `sk-YOUR_OPENAI_API_KEY_HERE` | Your OpenAI API Key |

## Step 8.3: Replace Each Value

For each variable:

1. **Click the VALUE field** (the placeholder text)
2. **Select all text** (Ctrl+A)
3. **Delete old text**
4. **Paste your actual key** from your saved notes
5. **Move to next variable**

### Example - Replacing Firebase API Key:

```
BEFORE:
firebase_api_key = "AIxxxxx_YOUR_FIREBASE_API_KEY_HERE"

AFTER:
firebase_api_key = "AIza7s-k2n9F_YOUR_ACTUAL_KEY_HERE"
```

## Step 8.4: Save Changes

1. **Click "Save"** button (bottom-right of modal)
2. **Wait for success message**
3. ✅ **All variables are now saved!**

---

# PART 9: Test Your Setup

## Step 9.1: Test Firebase Authentication

1. **In left sidebar**, expand "🔐 Authentication" folder
2. **Click "1. Sign Up (Create User)"**
3. **Modify the email** in the request body:
   ```json
   "email": "testuser@example.com"  // Change to a new test email
   ```
4. **Click "Send"** button (top-right)

### Expected Response ✅:
```json
{
  "idToken": "eyJhbGc...",
  "email": "testuser@example.com",
  "refreshToken": "AEu...",
  "expiresIn": "3600"
}
```

Status should show: **200 OK**

If you get **401 Unauthorized**:
- ❌ Your Firebase API key is wrong
- Go back to Step 2 and copy the correct key

## Step 9.2: Test Stripe Payment

1. **Expand "💳 Stripe Payment"** folder
2. **Click "1. Create Payment Intent"**
3. **Click "Send"**

### Expected Response ✅:
```json
{
  "id": "pi_1234567890abcdefghijklmn",
  "client_secret": "pi_1234567890abcdefghijklmn_secret_...",
  "status": "requires_payment_method"
}
```

Status should show: **200 OK**

If you get **401 Unauthorized**:
- ❌ Your Stripe secret key is wrong
- Go back to Step 3 and copy the correct `sk_test_...` key

## Step 9.3: Test Twilio Video (Optional)

1. **Expand "📹 Twilio Video"**
2. **Click "1. Generate Video Room Token"**
3. **Click "Send"**

### Expected Response ✅:
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

Status should show: **201 Created**

If you get **401 Unauthorized**:
- ❌ Your Twilio Account SID or Auth Token is wrong
- Go back to Step 4 and verify both values

## Step 9.4: Test OpenAI

1. **Expand "🤖 OpenAI"** folder
2. **Click "2. Chat Bot Query"**
3. **Click "Send"**

### Expected Response ✅:
```json
{
  "choices": [
    {
      "message": {
        "content": "...AI response here..."
      }
    }
  ]
}
```

Status should show: **200 OK**

If you get **401 Unauthorized**:
- ❌ Your OpenAI API key is wrong
- Go back to Step 6 and copy the correct `sk-proj-...` key

---

## ✅ Final Checklist

After completing all steps:

- [ ] Postman is downloaded and installed
- [ ] Postman account is created and logged in
- [ ] Firebase API key is obtained and tested
- [ ] Stripe API keys are obtained and tested
- [ ] Twilio Account SID & Auth Token are obtained and tested
- [ ] Agora App ID & API Key are obtained and tested
- [ ] OpenAI API key is obtained and tested
- [ ] Postman collection is imported
- [ ] Postman environment is imported
- [ ] All environment variables are configured
- [ ] At least one request from each service tests successfully
- [ ] All API keys are saved securely

---

## 🎯 You're Ready!

Once all tests pass, you can:

1. ✅ Test all 20+ API endpoints
2. ✅ Use requests as reference for Flutter integration
3. ✅ Share collection with team (without API keys)
4. ✅ Create additional test scenarios
5. ✅ Start integrating APIs into your app

---

## 🆘 Troubleshooting

### Problem: "401 Unauthorized" Error

**Solutions:**
1. Check the API key is fully copied (no missing characters)
2. Verify you're using TEST keys, not LIVE keys (for Stripe)
3. Make sure environment is selected (check dropdown)
4. Try refreshing environment: Click eye icon → Click refresh

### Problem: "400 Bad Request" Error

**Solutions:**
1. Check request body format (JSON or form-data)
2. Verify all required fields are present
3. Check email format is valid (if signup request)
4. Make sure password is at least 6 characters

### Problem: "Network Error" or "Connection Refused"

**Solutions:**
1. Check internet connection
2. Verify API service is online (check service status page)
3. Try disabling VPN/Proxy
4. Check firewall settings

### Problem: "Invalid API Key" Error

**Solutions:**
1. Copy API key again directly from service console
2. Paste into environment variable
3. Save environment
4. Try request again
5. If still fails, regenerate the API key from the service

---

## 📞 Support

If you're still stuck:
1. **Check the API service's documentation**
2. **Review error message carefully** - it usually tells you what's wrong
3. **Search Google** for the exact error message
4. **Contact service support** if service seems down

Good luck! 🚀
