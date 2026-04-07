# POSTMAN SETUP FLOW - VISUAL GUIDE

## 📊 Complete Setup Process (Visual Overview)

```
STEP 1: DOWNLOAD & INSTALL POSTMAN
┌─────────────────────────────────────┐
│ https://postman.com/downloads/      │
│ ↓                                   │
│ Download Installer                  │
│ ↓                                   │
│ Double-click & Install              │
│ ↓                                   │
│ Create Account & Login              │
└─────────────────────────────────────┘
                ↓
         ✅ Postman Ready


STEP 2: COLLECT ALL API KEYS (5 SERVICES)
┌──────────────────┬────────────────┬──────────────────┐
│                  │                │                  │
│  🔥 FIREBASE     │  💳 STRIPE     │  📱 TWILIO       │
│  (3 keys)        │  (2 keys)      │  (2 keys)        │
│                  │                │                  │
│  • API Key       │  • Secret Key  │  • Account SID   │
│  • Project ID    │  • Public Key  │  • Auth Token    │
│  • Database URL  │                │                  │
└──────────────────┴────────────────┴──────────────────┘
         ↓                                      ↓
┌──────────────────────────────────────────────────────┐
│              🎥 AGORA                  🤖 OPENAI    │
│              (2 keys)                  (1 key)       │
│                                                      │
│              • App ID           • API Key            │
│              • API Key                              │
└──────────────────────────────────────────────────────┘
                ↓
        ✅ All 10 Keys Ready


STEP 3: IMPORT INTO POSTMAN
┌─────────────────────────────────────┐
│ Open Postman                        │
│ ↓                                   │
│ Click "Import"                      │
│ ↓                                   │
│ Select "shecan-ai-collection.json"  │
│ ↓                                   │
│ Click "Import"                      │
│ ↓                                   │
│ Collection now in left sidebar ✓    │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│ Click "Import" again                │
│ ↓                                   │
│ Select "shecan-ai-environment.json" │
│ ↓                                   │
│ Click "Import"                      │
│ ↓                                   │
│ Environment imported ✓              │
└─────────────────────────────────────┘
                ↓
        ✅ Collection & Environment Ready


STEP 4: CONFIGURE ENVIRONMENT VARIABLES
┌──────────────────────────────────────────────────────┐
│ Select Environment (top-right dropdown)              │
│ ↓                                                    │
│ Choose: "Shecan AI - Development Environment"       │
│ ↓                                                    │
│ Click Eye Icon → Edit                               │
│ ↓                                                    │
│ Paste all 10 API keys:                              │
│                                                      │
│ • firebase_api_key        ← Paste here            │
│ • firebase_project_id      ← Paste here            │
│ • firebase_database_url    ← Paste here            │
│ • stripe_secret_key        ← Paste here            │
│ • stripe_publishable_key   ← Paste here            │
│ • twilio_account_sid       ← Paste here            │
│ • twilio_auth_token        ← Paste here            │
│ • agora_app_id             ← Paste here            │
│ • agora_api_key            ← Paste here            │
│ • openai_api_key           ← Paste here            │
│ ↓                                                    │
│ Click "Save"                                        │
└──────────────────────────────────────────────────────┘
                ↓
        ✅ Environment Configured


STEP 5: VERIFY SETUP (TEST 3 REQUESTS)
┌──────────────────────────────────────────────────────┐
│                                                      │
│  Test 1: Firebase                                    │
│  ┌──────────────────────────────────────────────┐  │
│  │ 🔐 Authentication → Sign Up (Create User)   │  │
│  │ Click "Send"                                │  │
│  │ ↓                                            │  │
│  │ Response: 200 OK ✅                         │  │
│  │ OR 401 Error ❌ (fix API key)              │  │
│  └──────────────────────────────────────────────┘  │
│                                                      │
│  Test 2: Stripe                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │ 💳 Payment → Create Payment Intent         │  │
│  │ Click "Send"                                │  │
│  │ ↓                                            │  │
│  │ Response: 200 OK ✅                         │  │
│  │ OR 401 Error ❌ (fix API key)              │  │
│  └──────────────────────────────────────────────┘  │
│                                                      │
│  Test 3: OpenAI                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │ 🤖 OpenAI → Chat Bot Query                  │  │
│  │ Click "Send"                                │  │
│  │ ↓                                            │  │
│  │ Response: 200 OK ✅                         │  │
│  │ OR 401 Error ❌ (fix API key)              │  │
│  └──────────────────────────────────────────────┘  │
│                                                      │
└──────────────────────────────────────────────────────┘
                ↓
        ✅ Setup Complete!
```

---

## 🔑 API KEY ACQUISITION FLOW

```
GETTING EACH API KEY:

┌──────────────────────────────────────────────────────────────┐
│                      🔥 FIREBASE                             │
├──────────────────────────────────────────────────────────────┤
│ https://console.firebase.google.com                          │
│ ↓                                                            │
│ Select your project → Settings → Check "Web API Key"        │
│                                                              │
│ Result:                                                      │
│ ✓ firebase_api_key: AIzaSy...                              │
│ ✓ firebase_project_id: shecan-ai-project                    │
│ ✓ firebase_database_url: https://shecan-ai-project.io       │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                      💳 STRIPE                               │
├──────────────────────────────────────────────────────────────┤
│ https://dashboard.stripe.com                                │
│ ↓                                                            │
│ Ensure TEST MODE is ON ⚠️                                   │
│ ↓                                                            │
│ Developers → API keys                                       │
│                                                              │
│ Result:                                                      │
│ ✓ stripe_secret_key: sk_test_...                           │
│ ✓ stripe_publishable_key: pk_test_...                      │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                      📱 TWILIO                               │
├──────────────────────────────────────────────────────────────┤
│ https://console.twilio.com                                  │
│ ↓                                                            │
│ Sign up → Verify phone number (SMS code)                    │
│ ↓                                                            │
│ Dashboard → Account SID + Auth Token                        │
│                                                              │
│ Result:                                                      │
│ ✓ twilio_account_sid: ACxxx...                             │
│ ✓ twilio_auth_token: (long string)                         │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                      🎥 AGORA                                │
├──────────────────────────────────────────────────────────────┤
│ https://console.agora.io                                    │
│ ↓                                                            │
│ Sign up → Create Project → Config                          │
│                                                              │
│ Result:                                                      │
│ ✓ agora_app_id: (hex string)                               │
│ ✓ agora_api_key: (another hex string)                      │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                      🤖 OPENAI                               │
├──────────────────────────────────────────────────────────────┤
│ https://platform.openai.com                                 │
│ ↓                                                            │
│ Sign up → Add payment method ⚠️ (required)                  │
│ ↓                                                            │
│ Profile → API keys → Create secret key                      │
│                                                              │
│ Result:                                                      │
│ ✓ openai_api_key: sk-proj-...                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 📦 FILE STRUCTURE IN POSTMAN

After importing, your Postman workspace looks like:

```
Left Sidebar:
├── 🔐 Authentication
│   ├── 1. Sign Up (Create User)
│   ├── 2. Sign In (Login)
│   └── 3. Refresh Token
├── 💬 Chat & Messaging
│   ├── 1. Create Conversation
│   ├── 2. Send Message
│   ├── 3. Get All Conversations
│   └── 4. Get Messages in Conversation
├── 💳 Stripe Payment
│   ├── 1. Create Payment Intent
│   ├── 2. Confirm Payment
│   ├── 3. Get Payment Status
│   ├── 4. Create Customer
│   └── 5. List Charges
├── 📹 Twilio Video
│   ├── 1. Generate Video Room Token
│   └── 2. List Active Rooms
├── 🎥 Agora Video
│   ├── 1. Generate RTC Token
│   └── 2. List Active Channels
├── 🤖 OpenAI
│   ├── 1. Generate AI Resume
│   ├── 2. Chat Bot Query
│   └── 3. Transcribe Audio
├── 🏆 Assessments & Skills
│   ├── 1. Submit Assessment
│   └── 2. Get User Badges
├── ⭐ Reviews & Ratings
│   ├── 1. Submit Review
│   └── 2. Get User Reviews
└── 🎯 Recommendations
    ├── 1. Get Recommended Projects
    └── 2. Get Trending Gigs

Top Right Area:
├── Environment Dropdown
│   └── 🔹 Shecan AI - Development Environment (selected)
├── Eye Icon (View variables)
└── Send Button

```

---

## ⏱️ TIME BREAKDOWN

```
╔════════════════════════════════════════════════════════════╗
║             TOTAL SETUP TIME: ~1-2 HOURS                  ║
╠════════════════════════════════════════════════════════════╣
║ Step 1: Download & Install Postman     ⏱️  15 minutes     ║
║ Step 2: Get Firebase Keys              ⏱️  5-10 minutes   ║
║ Step 3: Get Stripe Keys                ⏱️  5 minutes      ║
║ Step 4: Get Twilio Keys                ⏱️  10 minutes     ║
║ Step 5: Get Agora Keys                 ⏱️  10 minutes     ║
║ Step 6: Get OpenAI Keys                ⏱️  15 minutes     ║
║ Step 7: Import Collection              ⏱️  5 minutes      ║
║ Step 8: Configure Environment          ⏱️  10 minutes     ║
║ Step 9: Test Setup                     ⏱️  10 minutes     ║
╚════════════════════════════════════════════════════════════╝
```

---

## ✅ SETUP DEPENDENCIES

```
These must be done IN ORDER:

1. ❌→❌→❌→❌→❌  (Can do in any order)
   (Get all 5 API keys)      ↓
                            ✅
2.              ✅→❌→❌
   Download Postman         ↓
                           ✅
3.               ✅→❌→❌
   Import Collection        ↓
                           ✅
4.                ✅→❌→❌
   Import Environment       ↓
                           ✅
5.                 ✅→❌→❌
   Configure Variables      ↓
                           ✅
6.                  ✅→❌
   Test Setup              ↓
                          ✅ DONE!
```

---

## 🎯 SUCCESS CHECKLIST

```
After completing all steps, you should have:

✅ Postman installed and account created
✅ 20+ API requests organized in 7 folders
✅ Environment with 10 API key variables
✅ All API keys filled in (no placeholders)
✅ Firebase request returns 200 OK
✅ Stripe request returns 200 OK
✅ OpenAI request returns 200 OK
✅ Ready to test all 20+ endpoints
✅ Ready to integrate APIs into Flutter app

⏭️ NEXT: See TESTING_GUIDE.md for how to test all endpoints
```

---

## 📚 REFERENCE DOCUMENTS

| Document | Purpose | When to Use |
|----------|---------|------------|
| **DETAILED_SETUP_GUIDE.md** | Step-by-step with details | During setup |
| **QUICK_REFERENCE.md** | Quick lookup for APIs | During config |
| **SETUP_CHECKLIST_PRINTABLE.md** | Printable checklist | Track progress |
| **POSTMAN_SETUP_FLOW.md** | This file - visual overview | Understand big picture |
| **POSTMAN_IMPORT_GUIDE.md** | Quick import steps | Quick start |

---

## 🆘 WHEN SOMETHING GOES WRONG

```
ERROR RESPONSE?
    ↓
Read the error message carefully
    ↓
    ├─→ 401 Unauthorized? → Check API key is correct
    ├─→ 400 Bad Request? → Check request format
    ├─→ 403 Forbidden? → Check permissions/limits
    ├─→ 500 Server Error? → API is down
    └─→ Network Error? → Check internet
         ↓
    Still stuck? See DETAILED_SETUP_GUIDE.md
    Troubleshooting section
```

---

**Remember: Keep all your API keys secure and never share them!** 🔐
