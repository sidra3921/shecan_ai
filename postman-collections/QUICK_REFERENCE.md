# 🚀 Postman Setup - Quick Reference Card

## Copy-Paste This During Setup

---

## 📌 WHERE TO GET EACH KEY

### 1️⃣ FIREBASE
**Website:** https://console.firebase.google.com
**Steps:**
1. Select your project
2. Click gear icon (⚙️) → Project Settings
3. Copy the **Web API Key** (starts with `AIza...`)
4. Copy the **Project ID** (e.g., `shecan-ai-project`)
5. Click Realtime Database in sidebar
6. Copy the **Database URL** (https://...)

**What to Paste:**
```
firebase_api_key: AIza...
firebase_project_id: shecan-ai-project
firebase_database_url: https://shecan-ai-project.firebaseio.com
```

---

### 2️⃣ STRIPE
**Website:** https://dashboard.stripe.com
**Steps:**
1. ⚠️ Make sure **Test Mode is ON** (toggle in top-right)
2. Click "Developers" → "API keys"
3. Copy the **Secret Key** (starts with `sk_test_`)
4. Copy the **Publishable Key** (starts with `pk_test_`)

**What to Paste:**
```
stripe_secret_key: sk_test_...
stripe_publishable_key: pk_test_...
```

**Test Card (for payments):** `4242 4242 4242 4242`

---

### 3️⃣ TWILIO
**Website:** https://console.twilio.com
**Steps:**
1. Sign up at https://www.twilio.com/try-twilio
2. Verify phone number (via SMS)
3. On dashboard, find **Account SID** and **Auth Token**
4. Click eye icon next to Auth Token to reveal
5. Copy both values

**What to Paste:**
```
twilio_account_sid: AC...
twilio_auth_token: (long random string)
```

---

### 4️⃣ AGORA
**Website:** https://console.agora.io
**Steps:**
1. Sign up with Google/GitHub
2. Create a new project
3. Copy the **App ID** (hex string)
4. Click "Config"
5. Copy the **API Key**

**What to Paste:**
```
agora_app_id: (hex string)
agora_api_key: (another hex string)
```

---

### 5️⃣ OPENAI
**Website:** https://platform.openai.com
**Steps:**
1. Sign up at https://platform.openai.com
2. Verify email + add phone number
3. Add payment method (credit card required!)
4. Click profile icon → "API keys"
5. Click "Create new secret key"
6. Copy immediately (can't retrieve later!)

**What to Paste:**
```
openai_api_key: sk-proj-...
```

---

## 📋 POSTMAN SETUP CHECKLIST

### Download & Install (5 minutes)
- [ ] Go to https://www.postman.com/downloads/
- [ ] Download for your OS (Windows/Mac/Linux)
- [ ] Double-click installer
- [ ] Wait for installation
- [ ] Launch Postman
- [ ] Create account (email/Google/GitHub)

### Import Collections (2 minutes)
- [ ] Files location: `e:\shecan_ai\postman-collections\`
- [ ] Click "Import" button
- [ ] Select `shecan-ai-collection.json`
- [ ] Click "Import"
- [ ] Click "Import" again
- [ ] Select `shecan-ai-environment.json`
- [ ] Click "Import"

### Add API Keys (10 minutes)
- [ ] Look at top-right dropdown
- [ ] Select "Shecan AI - Development Environment"
- [ ] Click eye icon (Environment variables)
- [ ] Click "Edit"
- [ ] For each key below, paste your actual value:
  - [ ] firebase_api_key
  - [ ] firebase_project_id
  - [ ] firebase_database_url
  - [ ] stripe_secret_key
  - [ ] stripe_publishable_key
  - [ ] twilio_account_sid
  - [ ] twilio_auth_token
  - [ ] agora_app_id
  - [ ] agora_api_key
  - [ ] openai_api_key
- [ ] Click "Save"

### Test Setup (5 minutes)
- [ ] Expand "🔐 Authentication" folder
- [ ] Click "1. Sign Up (Create User)"
- [ ] Click "Send" → Should get 200 OK
- [ ] Expand "💳 Stripe Payment" folder
- [ ] Click "1. Create Payment Intent"
- [ ] Click "Send" → Should get 200 OK
- [ ] Expand "🤖 OpenAI" folder
- [ ] Click "2. Chat Bot Query"
- [ ] Click "Send" → Should get 200 OK

✅ **If all 3 tests return 200 OK, you're done!**

---

## 🔑 API CREDENTIAL TEMPLATE

Print this and fill in as you get each key:

```
FIREBASE:
  API Key: ________________________________
  Project ID: ____________________________
  Database URL: ___________________________

STRIPE:
  Secret Key: _____________________________
  Publishable Key: _________________________

TWILIO:
  Account SID: ____________________________
  Auth Token: _____________________________

AGORA:
  App ID: _________________________________
  API Key: ________________________________

OPENAI:
  API Key: ________________________________
```

---

## ⚠️ IMPORTANT SECURITY REMINDERS

❌ **NEVER:**
- Share your API keys in Slack/Discord/Email
- Commit them to GitHub
- Post them in public forums
- Use live keys for testing (always use test/sandbox)

✅ **DO:**
- Keep keys in safe place (password manager)
- Rotate keys regularly
- Use separate keys for Dev/Test/Production
- Set API usage limits

---

## 🆘 QUICK TROUBLESHOOTING

| Problem | Solution |
|---------|----------|
| **401 Unauthorized** | Check API key is correct (no missing chars) |
| **400 Bad Request** | Check request format (JSON body looks correct?) |
| **Network Error** | Check internet connection |
| **"Test Mode is Off"** (Stripe) | Toggle Test Mode ON in dashboard |
| **Can't find API key** | Scroll down on service page, look for "API" section |
| **Key keeps being invalid** | Delete old key, create new one from service |

---

## 📚 COMPLETE GUIDE

**For detailed step-by-step instructions with screenshots descriptions, see:**
📄 `DETAILED_SETUP_GUIDE.md` in the same folder

---

## ✓ SUCCESS INDICATORS

When everything is working:

1. ✅ Postman opens without errors
2. ✅ Collection loads in left sidebar
3. ✅ Environment dropdown shows "Shecan AI - Development Environment"
4. ✅ All 10 API keys are filled in (no placeholder text)
5. ✅ Firebase "Sign Up" returns 200 OK
6. ✅ Stripe "Create Payment Intent" returns 200 OK
7. ✅ OpenAI "Chat Bot Query" returns 200 OK

---

**Once all ✅ are complete, you're ready to test all 20+ API endpoints!**
