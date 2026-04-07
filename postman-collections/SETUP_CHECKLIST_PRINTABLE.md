# POSTMAN SETUP - PRINTABLE CHECKLIST

Date Started: _______________

---

## ✓ STEP 1: DOWNLOAD & INSTALL POSTMAN (15 minutes)

### 1.1 - Download Postman
- [ ] Open browser
- [ ] Go to: https://www.postman.com/downloads/
- [ ] Click download for your OS
  - [ ] Windows (64-bit)
  - [ ] Mac
  - [ ] Linux
- [ ] Wait for download (100-200 MB)

### 1.2 - Install Postman
- [ ] Double-click installer
- [ ] Click "Install" when prompted
- [ ] Wait for installation (2-3 minutes)
- [ ] Postman launches automatically

### 1.3 - Create Account
- [ ] Click "Sign up with email"
- [ ] Enter email: _________________________
- [ ] Create password: _______________________
- [ ] Verify email (check inbox)
- [ ] Click verification link
- [ ] Login to Postman

✅ **Postman is ready!**

---

## ✓ STEP 2: GET FIREBASE API KEYS (5-10 minutes)

**Website:** https://console.firebase.google.com

- [ ] Sign in with Google
- [ ] Select project: shecan-ai-project
- [ ] Click gear icon (⚙️) → "Project Settings"
- [ ] Copy Web API Key:
  ```
  ________________________________
  ________________________________
  ```
- [ ] Copy Project ID:
  ```
  ________________________________
  ```
- [ ] Click "Realtime Database" in sidebar
- [ ] Copy Database URL:
  ```
  ________________________________
  ```

✅ **Firebase keys collected!**

---

## ✓ STEP 3: GET STRIPE API KEYS (5 minutes)

**Website:** https://dashboard.stripe.com

- [ ] Sign in with Stripe account
- [ ] Check that **Test Mode is ON** (⚠️ Important!)
- [ ] Click "Developers" in left sidebar
- [ ] Click "API keys"
- [ ] Copy Secret Key (starts with sk_test_):
  ```
  ________________________________
  ________________________________
  ```
- [ ] Copy Publishable Key (starts with pk_test_):
  ```
  ________________________________
  ________________________________
  ```

✅ **Stripe keys collected!**

---

## ✓ STEP 4: GET TWILIO API KEYS (10 minutes)

**Website:** https://console.twilio.com

- [ ] Go to: https://www.twilio.com/try-twilio
- [ ] Sign up with email
- [ ] Verify phone number (via SMS)
  - Phone number used: _____________________
  - SMS code: ______________________________
- [ ] Go to https://console.twilio.com
- [ ] Find Account SID on dashboard:
  ```
  ________________________________
  ```
- [ ] Find Auth Token on dashboard
- [ ] Click eye icon to reveal full value
- [ ] Copy Auth Token:
  ```
  ________________________________
  ________________________________
  ```

✅ **Twilio keys collected!**

---

## ✓ STEP 5: GET AGORA API KEYS (10 minutes)

**Website:** https://console.agora.io

- [ ] Go to: https://console.agora.io
- [ ] Sign up (Google/GitHub/Email)
- [ ] Verify email if needed
- [ ] Complete profile setup
- [ ] Click "Project" in sidebar
- [ ] Click "Create" button
- [ ] Enter project name: shecan-ai-video
- [ ] Use case: "Real-time communication"
- [ ] Click "Create"
- [ ] Copy App ID:
  ```
  ________________________________
  ```
- [ ] Click "Config"
- [ ] Click "Generate" for API Key
- [ ] Copy API Key:
  ```
  ________________________________
  ```

✅ **Agora keys collected!**

---

## ✓ STEP 6: GET OPENAI API KEYS (15 minutes)

**Website:** https://platform.openai.com

- [ ] Go to: https://platform.openai.com
- [ ] Click "Sign up"
- [ ] Enter email: _________________________
- [ ] Create password: _______________________
- [ ] Verify email (check inbox)
- [ ] Add phone number: _____________________
- [ ] **Add Payment Method:**
  - [ ] Go to Billing overview
  - [ ] Click "Add to account"
  - [ ] Enter credit card details
  - [ ] Set billing limit: $________/month
  - [ ] Click "Save"
- [ ] Click profile icon (top-right)
- [ ] Click "API keys"
- [ ] Click "Create new secret key"
- [ ] Name it: Shecan AI Development
- [ ] Click "Create secret key"
- [ ] **Copy immediately** (shown only once!):
  ```
  ________________________________
  ________________________________
  ```

✅ **OpenAI API key collected!**

---

## ✓ STEP 7: IMPORT POSTMAN COLLECTION (5 minutes)

### 7.1 - Collect Files
- [ ] Files are in: `e:\shecan_ai\postman-collections\`
- [ ] Verify you have:
  - [ ] shecan-ai-collection.json
  - [ ] shecan-ai-environment.json

### 7.2 - Import Collection
- [ ] Open Postman (already installed)
- [ ] Click "Import" button (top-left)
- [ ] Click "File" tab
- [ ] Click "Upload Files"
- [ ] Navigate to: e:\shecan_ai\postman-collections\
- [ ] Select: shecan-ai-collection.json
- [ ] Click "Open"
- [ ] Click "Import" button
- [ ] ✅ Collection imported! (Check left sidebar)

### 7.3 - Import Environment
- [ ] Click "Import" button again
- [ ] Click "File" tab
- [ ] Click "Upload Files"
- [ ] Select: shecan-ai-environment.json
- [ ] Click "Open"
- [ ] Click "Import" button
- [ ] ✅ Environment imported!

---

## ✓ STEP 8: CONFIGURE ENVIRONMENT VARIABLES (10 minutes)

### 8.1 - Activate Environment
- [ ] Look at top-right (environment dropdown)
- [ ] Click dropdown
- [ ] Select: "Shecan AI - Development Environment"
- [ ] ✅ Environment is now active!

### 8.2 - Edit Variables
- [ ] Click eye icon (top-right)
- [ ] Click "Edit" button
- [ ] Environment editor modal opens

### 8.3 - Paste Each API Key

For each variable below:
1. Click the VALUE field
2. Select all (Ctrl+A)
3. Delete old text
4. Paste your actual key
5. Move to next

| Variable | Your Value | Pasted? |
|----------|-----------|---------|
| `firebase_api_key` | (from Step 2) | [ ] |
| `firebase_project_id` | (from Step 2) | [ ] |
| `firebase_database_url` | (from Step 2) | [ ] |
| `stripe_secret_key` | (from Step 3) | [ ] |
| `stripe_publishable_key` | (from Step 3) | [ ] |
| `twilio_account_sid` | (from Step 4) | [ ] |
| `twilio_auth_token` | (from Step 4) | [ ] |
| `agora_app_id` | (from Step 5) | [ ] |
| `agora_api_key` | (from Step 5) | [ ] |
| `openai_api_key` | (from Step 6) | [ ] |

### 8.4 - Save
- [ ] Click "Save" button (bottom-right)
- [ ] Wait for success message
- [ ] ✅ All variables saved!

---

## ✓ STEP 9: TEST YOUR SETUP (10 minutes)

### 9.1 - Test Firebase
- [ ] Expand "🔐 Authentication" folder
- [ ] Click "1. Sign Up (Create User)"
- [ ] Change email to: test_____________@example.com
- [ ] Click "Send" button
- [ ] Check response status
  - [ ] ✅ 200 OK (Success!)
  - [ ] ❌ 401 Unauthorized (Check firebase_api_key)
  - [ ] ❌ Other error (See troubleshooting)

### 9.2 - Test Stripe
- [ ] Expand "💳 Stripe Payment" folder
- [ ] Click "1. Create Payment Intent"
- [ ] Click "Send" button
- [ ] Check response status
  - [ ] ✅ 200 OK (Success!)
  - [ ] ❌ 401 Unauthorized (Check stripe_secret_key)
  - [ ] ❌ Other error (See troubleshooting)

### 9.3 - Test OpenAI
- [ ] Expand "🤖 OpenAI" folder
- [ ] Click "2. Chat Bot Query"
- [ ] Click "Send" button
- [ ] Check response status
  - [ ] ✅ 200 OK (Success!)
  - [ ] ❌ 401 Unauthorized (Check openai_api_key)
  - [ ] ❌ Other error (See troubleshooting)

---

## ✅ FINAL VERIFICATION

All of these must be checked:

- [ ] Postman is downloaded and installed
- [ ] Postman account is created
- [ ] Postman is logged in
- [ ] Collection is imported (visible in left sidebar)
- [ ] Environment is imported and selected
- [ ] All 10 API keys are configured (no placeholders)
- [ ] Firebase auth test returns 200 OK
- [ ] Stripe payment test returns 200 OK
- [ ] OpenAI chat test returns 200 OK
- [ ] I have saved my API keys in a secure location

---

## 🎉 SUCCESS!

**Date Completed:** _______________

**All tests passed:** ____ / ____ 

Once all ✅ are complete:
1. Keep this checklist for reference
2. Go to DETAILED_SETUP_GUIDE.md for in-depth help
3. Go to QUICK_REFERENCE.md for quick lookups
4. You're ready to test all 20+ API endpoints!

---

## 🆘 TROUBLESHOOTING QUICK LOOK

```
401 Unauthorized?
  → Check API key is fully copied (no missing characters)
  → Verify you're using TEST keys (not LIVE)
  → Make sure environment is selected (dropdown)
  → Try refresh: Click eye icon → refresh button

400 Bad Request?
  → Check JSON format in request body
  → Verify all required fields are present
  → Check email format is valid
  → Check password is at least 6 characters

Network Error?
  → Check internet connection
  → Check service status (is API online?)
  → Disable VPN/Proxy if using one
  → Check firewall settings

"Can't find my API key?"
  → Scroll down on service page carefully
  → Look for "API" or "Keys" section
  → Some services need you to create key first (click Generate)
```

---

**For detailed help, see: DETAILED_SETUP_GUIDE.md**
